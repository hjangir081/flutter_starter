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

  // Add dependencies to pubspec.yaml
  addDependencies(projectName);

  // Run flutter pub get to install dependencies
  runFlutterPubGet(projectName);

  print('Project setup complete!');
}

// Create the apiEnvironment.dart file inside utils/constants/
createApiEnvironmentFile('$libPath/utils/constants/apiEnvironment.dart');

print('Project setup complete!');
}

void createApiEnvironmentFile(String filePath) {
File apiFile = File(filePath);

if (!apiFile.existsSync()) {
apiFile.writeAsStringSync('''
class ApiEnvironment {
  // Define API configurations here
  static const baseUrl = ""; // Add your base URL here
  static const apiPrefix = ""; // Add your API prefix here
  // End Points
  static const login='login'; // Add your endpoints here
}
''');
print('Created file: $filePath');
}
}

void addDependencies(String projectPath) {
  // Path to the pubspec.yaml file
  var pubspecPath = '$projectPath/pubspec.yaml';

  // Read the existing pubspec.yaml content
  var pubspecFile = File(pubspecPath);
  var pubspecContent = pubspecFile.readAsStringSync();

  // Add necessary dependencies
  if (!pubspecContent.contains('dotsquares_flutter_starter')) {
    pubspecContent = pubspecContent.replaceFirst(
        'dependencies:',
        '''
dependencies:
  dotsquares_flutter_starter: ^1.0.0
'''
    );
    pubspecFile.writeAsStringSync(pubspecContent);
    print('Added dotsquares_flutter_starter to pubspec.yaml');
  }
}

void runFlutterPubGet(String projectPath) async {
  var result = await Process.run('flutter', ['pub', 'get'], workingDirectory: projectPath);
  if (result.exitCode == 0) {
    print('Dependencies installed successfully.');
  } else {
    print('Failed to install dependencies.');
    print(result.stderr);
  }
}
