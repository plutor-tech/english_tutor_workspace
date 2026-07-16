# ==========================================
# STAGE 1: Compilation Environment
# ==========================================
FROM dart:stable AS build

# 1. Establish the working directory inside the container
WORKDIR /app

# 2. Copy the root workspace configuration file, tutor_server and tutor_shared.
COPY pubspec.yaml ./
COPY packages/tutor_shared/ ./packages/tutor_shared/
COPY tutor_server/ ./tutor_server/

# 3. Remove the tutor_client line from the root pubspec.yaml workspace list 
# so the Dart compiler treats this strictly as a pure-Dart workspace.
RUN sed -i '/tutor_client/d' pubspec.yaml

# 4. Resolve all dependencies safely without needing the Flutter SDK
RUN dart pub get

# 5. Activate the Dart Frog CLI globally within the build environment
RUN dart pub global activate dart_frog_cli

# 6. Change working directory specifically to the backend server app
WORKDIR /app/tutor_server

# 7. Resolve all dependencies using the monorepo workspace resolution
RUN dart pub get

# 8. Execute Dart Frog production compilation.
# This generates an optimized standalone production package
RUN dart pub global run dart_frog_cli:dart_frog build

# 9. Ensure production dependencies are downloaded and verified offline
RUN dart pub get --offline

# 10. Compile the entry point server file into a standalone, native machine-code binary
RUN dart compile exe build/bin/server.dart -o build/bin/server

# ==========================================
# STAGE 2: Optimized Minimal Runtime Environment
# ==========================================
FROM debian:stable-slim

# 1. Copy the compiled native machine-code binary from Stage 1
COPY --from=build /app/tutor_server/build/bin/server /app/bin/server

# 2. Inform Cloud Run that the server application listens on port 8080 by default
EXPOSE 8080

# 3. Execute the native binary when the container boots up
CMD ["/app/bin/server"]