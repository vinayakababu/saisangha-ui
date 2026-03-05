# Stage 1: Build Flutter Web using prebuilt image
FROM cirrusci/flutter:latest AS build

WORKDIR /app

# Copy only pubspec files first to cache dependencies
COPY pubspec.* ./
RUN flutter pub get

# Copy the rest of the project
COPY . .

# Build Flutter Web
RUN flutter build web --release

# Stage 2: Serve with Nginx
FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
