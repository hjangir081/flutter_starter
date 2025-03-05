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
    'data/dataSources/remote',
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

  // Create necessary files
  createApiEnvironmentFile('$libPath/utils/constants/apiEnvironment.dart');
  createDataStateFile('$libPath/utils/resources/data_state.dart');
  createApiRepositoryFile('$libPath/domain/repositories/api_repositories.dart');
  createApiServiceFile('$libPath/data/dataSources/remote/api_service.dart');

  // Add dependencies to pubspec.yaml
  addDependencies(projectName);

  // Run flutter pub get to install dependencies
  await runFlutterPubGet(projectName);

  print('Project setup complete!');
}

// Function to create apiEnvironment.dart
void createApiEnvironmentFile(String filePath) {
  File apiFile = File(filePath);

  if (!apiFile.existsSync()) {
    apiFile.writeAsStringSync('''
class ApiEnvironment {
  // Define API configurations here
  static const baseUrl = ""; // Add your base URL here
  static const apiPrefix = ""; // Add your API prefix here
  // End Points
  static const login = 'login'; // Add your endpoints here
}
''');
    print('Created file: $filePath');
  }
}

// Function to create data_state.dart
void createDataStateFile(String filePath) {
  File dataStateFile = File(filePath);

  if (!dataStateFile.existsSync()) {
    dataStateFile.writeAsStringSync('''
import 'package:dio/dio.dart';

abstract class DataState<T> {
  T? data;
  DioException? exception;
  DataState({this.data, this.exception});
}

class DataSuccess<T> extends DataState<T> {
  DataSuccess(T data) : super(data: data);
}

class DataFailed<T> extends DataState<T> {
  DataFailed(DioException exception) : super(exception: exception);
}
''');
    print('Created file: $filePath');
  }
}

// Function to create api_repositories.dart
void createApiRepositoryFile(String filePath) {
  File apiRepoFile = File(filePath);

  if (!apiRepoFile.existsSync()) {
    apiRepoFile.writeAsStringSync('''
abstract class ApiRepository {
  // Future<DataState<SignInResponseModel>> signIn({required SignInRequestModel signInRequestModel});
}
''');
    print('Created file: $filePath');
  }
}

// Function to create api_service.dart
void createApiServiceFile(String filePath) {
  File apiServiceFile = File(filePath);

  if (!apiServiceFile.existsSync()) {
    apiServiceFile.writeAsStringSync('''
import 'package:dio/dio.dart';
import 'package:retrofit/http.dart';
import 'package:http/http.dart' as http;
import '../../utils/constants/apiEnvironment.dart';

part 'api_service.g.dart';

@RestApi(
    baseUrl: ApiEnvironment.baseUrl + ApiEnvironment.apiPrefix,
    parser: Parser.JsonSerializable)
abstract class ApiService {
  //@POST(ApiEnvironment.signIn)
  //Future<HttpResponse<SignInResponseModel>> signIn({
   // @Body() required SignInRequestModel signInRequestModel,
  //});
}
''');
    print('Created file: $filePath');
  }
}

void addDependencies(String projectPath) {
  var pubspecPath = '$projectPath/pubspec.yaml';
  var pubspecFile = File(pubspecPath);
  var pubspecContent = pubspecFile.readAsStringSync();

  // Ensure dependencies exist and add required ones dynamically
  if (!pubspecContent.contains('dependencies:')) {
    pubspecContent += '\ndependencies:\n';
  }

  if (!pubspecContent.contains('dotsquares_flutter_starter:')) {
    pubspecContent = pubspecContent.replaceFirst(
      'dependencies:',
      '''
dependencies:
  dotsquares_flutter_starter: any
  dio: any
  retrofit: any
  json_annotation: any
  http: any
''',
    );
  }

  // Ensure dev_dependencies exist and add required ones dynamically
  if (!pubspecContent.contains('dev_dependencies:')) {
    pubspecContent += '\ndev_dependencies:\n';
  }

  if (!pubspecContent.contains('retrofit_generator:')) {
    pubspecContent = pubspecContent.replaceFirst('dev_dependencies:', 'dev_dependencies:\n  retrofit_generator: any');
  }
  if (!pubspecContent.contains('build_runner:')) {
    pubspecContent = pubspecContent.replaceFirst('dev_dependencies:', 'dev_dependencies:\n  build_runner: any');
  }
  if (!pubspecContent.contains('json_serializable:')) {
    pubspecContent = pubspecContent.replaceFirst('dev_dependencies:', 'dev_dependencies:\n  json_serializable: any');
  }

  pubspecFile.writeAsStringSync(pubspecContent);
  print('Updated pubspec.yaml with required dependencies and dev_dependencies');
}

Future<void> runFlutterPubGet(String projectPath) async {
  var result = await Process.run('flutter', ['pub', 'get'], workingDirectory: projectPath);
  if (result.exitCode == 0) {
    print('Dependencies installed successfully.');
  } else {
    print('Failed to install dependencies.');
    print(result.stderr);
  }
}
