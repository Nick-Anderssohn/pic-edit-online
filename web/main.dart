import 'dart:html';
import 'image_editor.dart';

Element titleElement;
CanvasElement picCanvas;
InputElement fileInput;
ImageEditor editor;
ButtonElement btnCrop;

main() {
  _getElements();
  _updateStyles();
  _setHandlers();
}

_getElements() {
  titleElement = querySelector('#title');
  picCanvas = querySelector('#pic-canvas');
  fileInput = querySelector('#file-input');
  btnCrop = querySelector('#btn-crop');
}

_updateStyles() {
  titleElement.classes.add('title');
  picCanvas.classes.add('pic-canvas');
}

_setHandlers() {
  fileInput.onChange.listen((var e) => editor = new ImageEditor(picCanvas, fileInput.files[0]));
  btnCrop.onClick.listen((var e) => editor.cropBox.cropping = !editor.cropBox.cropping);
}
