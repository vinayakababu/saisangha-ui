# Stage 1: Build Flutter Web using prebuilt image
FROM cirrusci/flutter:latest AS build

WORKDIR /app
COPY . .

# Get dependencies
RUN flutter pub get

# Build Flutter Web
RUN flutter build web

# Stage 2: Serve with Nginx
FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
