import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/core/errors/failure.dart';
import 'package:noveles/features/books/domain/upload_image.dart';
import 'package:noveles/features/scan/presentation/bloc/scan_cover_bloc.dart';

class MockUploadImage extends Mock implements UploadImage {}

void main() {
  late MockUploadImage mockUploadImage;
  late ScanCoverBloc scanCoverBloc;

  setUp(() {
    mockUploadImage = MockUploadImage();
    scanCoverBloc = ScanCoverBloc(
      uploadImage: mockUploadImage,
    );
  });

  tearDown(() {
    scanCoverBloc.close();
  });

  group('ScanCoverBloc', () {
    test('initial state is ScanCoverInitial', () {
      expect(scanCoverBloc.state, equals(ScanCoverInitial()));
    });

    blocTest<ScanCoverBloc, ScanCoverState>(
      'emits [ScanCoverUploading, ScanCoverUploaded] when UploadScanCover succeeds',
      build: () {
        when(() => mockUploadImage(any()))
            .thenAnswer((_) async => Ok('uploaded_cover.png'));
        return scanCoverBloc;
      },
      act: (bloc) => bloc.add(UploadScanCover('/path/to/cover.png')),
      expect: () => [
        isA<ScanCoverUploading>(),
        isA<ScanCoverUploaded>().having(
          (s) => s.filename,
          'filename',
          'uploaded_cover.png',
        ),
      ],
    );

    blocTest<ScanCoverBloc, ScanCoverState>(
      'emits [ScanCoverUploading, ScanCoverError] when UploadScanCover fails',
      build: () {
        when(() => mockUploadImage(any()))
            .thenAnswer((_) async => Err(BookFailure('Error al subir')));
        return scanCoverBloc;
      },
      act: (bloc) => bloc.add(UploadScanCover('/path/to/cover.png')),
      expect: () => [
        isA<ScanCoverUploading>(),
        isA<ScanCoverError>().having(
          (s) => s.message,
          'message',
          contains('Error al subir'),
        ),
      ],
    );
  });
}
