COPY pubspec.* ./
RUN flutter pub get
COPY . .
RUN flutter build web --release
