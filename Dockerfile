FROM ghcr.io/gmeligio/flutter-android:3.47.6

WORKDIR /app

COPY pubspec.yaml pubspec.lock* ./

RUN flutter config --enable-web

RUN flutter pub get

COPY . .

# Build as a dedicated non-root user when possible to keep the image safer.
# We'll ensure the flutter SDK is trusted by git and then chown the project
# directory to UID 1000 (common non-root user) and run the build as that user.
USER root

# Mark the Flutter SDK directory as safe for git operations (system-wide).
RUN git config --system --add safe.directory /home/flutter/sdks/flutter || true

# Give the non-root user (UID 1000) ownership of the project files so the
# build can run without root. Fall back to continuing on error.
RUN chown -R 1000:1000 /app || true

ARG BACKEND_BASE_URL=https://host

# Optionally read BACKEND_BASE_URL from a local env JSON (e.g. env/dev.json)
# If the file exists, attempt to parse it with python3. Otherwise fall back
# to the build-arg value. This allows you to keep environment files in the
# repo for local builds while still supporting overriding via --build-arg.
USER root
RUN set -eux; \
	if [ -f env/dev.json ]; then \
	  if command -v python3 >/dev/null 2>&1; then \
		BACKEND_BASE_URL_PARSED=$(python3 -c "import sys,json;print(json.load(open('env/dev.json')).get('BACKEND_BASE_URL',''))"); \
	  else \
		BACKEND_BASE_URL_PARSED=$(sed -n "s/.*\"BACKEND_BASE_URL\"\s*:\s*\"\([^\"]*\)\".*/\1/p" env/dev.json || true); \
	  fi; \
	  if [ -n "$BACKEND_BASE_URL_PARSED" ]; then BACKEND_BASE_URL="$BACKEND_BASE_URL_PARSED"; fi; \
	fi; \
	echo "Building with BACKEND_BASE_URL=$BACKEND_BASE_URL"; \
	flutter build web --release --dart-define=BACKEND_BASE_URL="$BACKEND_BASE_URL"

FROM nginx:alpine

COPY --from=0 /app/build/web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]