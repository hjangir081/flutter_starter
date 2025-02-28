#!/usr/bin/env dart

import 'dart:io';

void main(List<String> arguments) async {
  if (arguments.isEmpty) {
    print('Usage: flutter_starter <project_name>');
    exit(1);
  }

  String projectName = arguments[0];

  print('Creating Flutter project: $projectName');

  // Run flutter create
  var result = await Process.run('flutter', ['create', projectName]);
  if (result.exitCode != 0) {
    print('Failed to create Flutter project');
    print(result.stderr);
    exit(1);
  }
  print(result.stdout);

  // Define the folder structure
  String libPath = '$projectName/lib/src';
  List<String> folders = [
    'data/dataSources',
    'data/repositories',
    'domain/models',
    'domain/repositories',
    'presentation/cubits',
    'presentation/views',
    'presentation/widgets',
    'utils/constants',
    'utils/extensions',
    'utils/resources',
    'config/router',
    'config/theme'
  ];

  for (var folder in folders) {
    Directory('$libPath/$folder').createSync(recursive: true);
  }

  // Create locator.dart
  String locatorFilePath = '$libPath/locator.dart';
  File(locatorFilePath).writeAsStringSync('''
import 'package:get_it/get_it.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  // Register your services here
}
''');

  print('Project setup complete!');
}
