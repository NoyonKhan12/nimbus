# Nimbus Driver App - Default multi-stage build
FROM cirrusci/flutter:latest AS build

WORKDIR /app

COPY pubspec.yaml pubspec.yaml
COPY lib lib
RUN flutter pub get

RUN flutter build apk --release --split-per-abi

FROM alpine:latest
RUN apk add --no-cache unzip
COPY --from=build /app/build/app/outputs/flutter-apk/ /output/
WORKDIR /output
ENTRYPOINT ["echo"]
CMD ["Driver APK built. Check /output/"]
