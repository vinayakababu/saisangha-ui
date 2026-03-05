# Stage 1: Build Flutter Web
FROM ubuntu:22.04 AS build

# Install dependencies
RUN apt-get update && apt-get install -y curl unzip xz-utils git wget libglu1-mesa

# Install Flutter SDK
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Pre-download Flutter dependencies
RUN flutter doctor

# Copy project
WORKDIR /app
COPY . .

# Build Flutter web
RUN flutter build web

# Stage 2: Serve with Nginx
FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
