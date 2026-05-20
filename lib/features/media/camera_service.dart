/// CameraService: contrato y captura simulada de imágenes.
library;

abstract class CameraService {
  factory CameraService() => InMemoryCameraService();

  Future<List<int>> takePictureBytes();
}

class InMemoryCameraService implements CameraService {
  @override
  Future<List<int>> takePictureBytes() async {
    // TODO: Integrar con camera o image_picker.
    return List<int>.filled(10, 0);
  }
}
