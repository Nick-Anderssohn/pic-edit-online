import 'dart:html';
import 'image_editor.dart';

CanvasElement picCanvas;
InputElement fileInput;
ImageEditor editor;
ButtonElement btnDownload;
DivElement optionCrop;

main() {
  _getElements();
  _setHandlers();
}

_getElements() {
  picCanvas = querySelector('#pic-canvas');
  fileInput = querySelector('#file-input');
  optionCrop = querySelector('#option-crop');
  btnDownload = querySelector('#btn-download');

}


_setHandlers() {
  fileInput.onChange.listen((var e) => editor = new ImageEditor(picCanvas, fileInput.files[0]));
  optionCrop.onClick.listen((var e) => editor.cropBox.cropping = !editor.cropBox.cropping);
  btnDownload.onClick.listen((var e) {
    var dataURL = editor.canvas.toDataUrl();
    window.location.href = dataURL;
  });
}
