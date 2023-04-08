#!/bin/bash

flutter clean
flutter build apk
cp build/app/outputs/flutter-apk/app-release.apk Fahrplan.apk
flutter build appbundle

echo "Fahrplan.apk auf Google Drive hochladen"

echo "App auf Google Play hochladen"