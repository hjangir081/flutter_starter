#!/usr/bin/env dart

import 'dart:io';

void main(List<String> arguments) async {
  print('dotsquares_flutter_starter is working!');

  // Check if project name is provided as an argument
  if (arguments.isEmpty) {
    print('Usage: flutter_starter <project_name>');
    exit(1);
  }

  // Assign the first argument as the project name
  String projectName = arguments[0];

  print('Creating Flutter project: $projectName');

  // Run flutter create to create the Flutter project
  var result = await Process.run('flutter', ['create', projectName]);

  // Check if flutter create was successful
  if (result.exitCode != 0) {
    print('Failed to create Flutter project');
    print(result.stderr);
    exit(1);
  }
  print(result.stdout);

  // Define the folder structure under lib/src
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

  // Create the folder structure recursively
  for (var folder in folders) {
    Directory('$libPath/$folder').createSync(recursive: true);
    print('Created folder: $libPath/$folder');
  }

  print('Project setup complete!');
}
