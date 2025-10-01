import 'package:logger/logger.dart';

void main() {
  final logger = Logger();
  logger.d('Test debug message');
  logger.i('Test info message');
  logger.w('Test warning message');
  logger.e('Test error message');
  print('Logger test completed');
}
