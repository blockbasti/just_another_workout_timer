echo 'Generate license data'
flutter pub run flutter_oss_licenses:generate.dart

echo 'Generate translations'
flutter pub run intl_utils:generate