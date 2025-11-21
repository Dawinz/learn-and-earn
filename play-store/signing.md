# Android Signing

## Options
- **App signing by Google Play (recommended)**: Google manages the app signing key; you upload a separate upload key
- **Manage your own keys**: You manage both signing and upload keys

## Generate upload keystore

Run this on your machine (do not commit the `.jks` file):

```bash
keytool -genkeypair -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Keep the keystore and passwords secure.

## Configure Gradle
Add to `android/key.properties` (do not commit):

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=../upload-keystore.jks
```

Ensure `android/app/build.gradle.kts` loads these properties and sets the release signing config.

## Register upload key in Play Console
- Export public certificate (`.pem`) generated with:
```bash
keytool -export -rfc -alias upload -file upload_certificate.pem -keystore upload-keystore.jks
```
- In Play Console: App Integrity → App signing → Upload key certificate

## Backups
Store keystore + passwords in a secret manager (e.g., 1Password, GitHub Encrypted Secrets).
