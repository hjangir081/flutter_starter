import 'dart:io';

void main(List<String> arguments) async {
  print('dotsquares_flutter_starter is working!');

  if (arguments.isEmpty) {
    print('Usage: flutter_starter <project_name>');
    exit(1);
  }

  String projectName = arguments[0];
  print('Creating Flutter project: $projectName');

  var result = await Process.run('flutter', ['create', projectName]);
  if (result.exitCode != 0) {
    print('Failed to create Flutter project');
    print(result.stderr);
    exit(1);
  }
  print(result.stdout);

  String libPath = '$projectName/lib/src';
  List<String> folders = [
    'data/datasource'
    'data/datasource/remote',
    'data/datasource/local',
    'data/repositories'
    'data/repositories/base',
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
    print('Created folder: $libPath/$folder');
  }

  createApiEnvironmentFile('$libPath/utils/constants/apiEnvironment.dart');
  createDataStateFile('$libPath/utils/resources/data_state.dart');
  createApiRepositoryFile('$libPath/domain/repositories/api_repositories.dart');
  createApiServiceFile('$libPath/data/datasource/remote/api_service.dart');
  createBaseApiRepositoryFile('$libPath/data/repositories/base/base_api_repository.dart');

  addDependencies(projectName);
  await runFlutterPubGet(projectName);

  print('Project setup complete!');
}

void createApiEnvironmentFile(String filePath) {
  File(filePath).writeAsStringSync('''
class ApiEnvironment {
  static const baseUrl = "";
  static const apiPrefix = "";
  static const login = 'login';
}
''');
  print('Created file: $filePath');
}

void createDataStateFile(String filePath) {
  File(filePath).writeAsStringSync('''
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

void createApiRepositoryFile(String filePath) {
  File(filePath).writeAsStringSync('''
abstract class ApiRepository {}
''');
  print('Created file: $filePath');
}

void createApiServiceFile(String filePath) {
  File(filePath).writeAsStringSync('''
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
part 'api_service.g.dart';

@RestApi(baseUrl: ApiEnvironment.baseUrl + ApiEnvironment.apiPrefix, parser: Parser.JsonSerializable)
abstract class ApiService {}
''');
  print('Created file: $filePath');
}

void createBaseApiRepositoryFile(String filePath) {
  File(filePath).writeAsStringSync('''
import 'dart:io' show HttpStatus;
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:retrofit/retrofit.dart';
import '../../../utils/resources/data_state.dart';

abstract class BaseApiRepository {
  @protected
  Future<DataState<T>> getStateOf<T>({
    required Future<HttpResponse<T>> Function() request,
  }) async {
    try {
      final httpResponse = await request();
      if (httpResponse.response.statusCode == HttpStatus.ok) {
        return DataSuccess(httpResponse.data);
      } else {
        throw DioException(
          response: httpResponse.response,
          requestOptions: httpResponse.response.requestOptions,
        );
      }
    } on DioException catch (exception) {
      return DataFailed(exception);
    }
  }
}
''');
  print('Created file: $filePath');
}

void addDependencies(String projectPath) {
  var pubspecPath = '$projectPath/pubspec.yaml';
  var pubspecFile = File(pubspecPath);
  var pubspecContent = pubspecFile.readAsStringSync();

  if (!pubspecContent.contains('dependencies:')) {
    pubspecContent += '\ndependencies:\n';
  }

  if (!pubspecContent.contains('dotsquares_flutter_starter:')) {
    pubspecContent = pubspecContent.replaceFirst('dependencies:', 'dependencies:\n  dotsquares_flutter_starter:\n  dio:\n  retrofit:\n  json_annotation:\n  http:\n');
  }

  if (!pubspecContent.contains('dev_dependencies:')) {
    pubspecContent += '\ndev_dependencies:\n';
  }

  if (!pubspecContent.contains('retrofit_generator:')) {
    pubspecContent = pubspecContent.replaceFirst('dev_dependencies:', 'dev_dependencies:\n  retrofit_generator: ');
  }
  if (!pubspecContent.contains('build_runner:')) {
    pubspecContent = pubspecContent.replaceFirst('dev_dependencies:', 'dev_dependencies:\n  build_runner: ');
  }
  if (!pubspecContent.contains('json_serializable:')) {
    pubspecContent = pubspecContent.replaceFirst('dev_dependencies:', 'dev_dependencies:\n  json_serializable: ');
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
