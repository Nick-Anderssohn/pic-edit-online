import 'dart:html';
import 'image_editor.dart';
Element titleElement;
CanvasElement picCanvas;
InputElement fileInput;
ImageEditor editor;

main() {
  _getElements();
  _updateStyles();
  fileInput.onChange.listen((var e) {
    editor = new ImageEditor(picCanvas, fileInput.files[0]);
  });
}

_getElements() {
  titleElement = querySelector('#title');
  picCanvas = querySelector('#pic-canvas');
  fileInput = querySelector('#file-input');
}

_updateStyles() {
  titleElement.classes.add('title');
  picCanvas.classes.add('pic-canvas');
}
