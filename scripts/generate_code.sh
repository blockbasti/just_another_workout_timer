echo 'Generate license data'
dart pub run flutter_oss_licenses:generate.dart

echo 'Generate translations'
dart run intl_utils:generate

echo 'build runner'
dart run build_runner build --delete-conflicting-outputs