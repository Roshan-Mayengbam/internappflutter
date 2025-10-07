// test/mocks.dart

import 'package:internappflutter/features/data/datasources/guardian_api_remote_datasource.dart';
import 'package:internappflutter/features/domain/repositories/news_repository.dart';
import 'package:mockito/annotations.dart';

// Generates the mock for GuardianApiDataSource
@GenerateMocks([GuardianApiDataSource, NewsRepository])
void main() {}
