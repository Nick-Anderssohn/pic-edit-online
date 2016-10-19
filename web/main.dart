import 'dart:html';
import 'image_editor.dart';

CanvasElement picCanvas;
InputElement fileInput;
ImageEditor editor;
DivElement divDownload;
DivElement optionCrop;
DivElement divSelectFile;
DivElement canvasContainer;

main() {
  _getElements();
  _setHandlers();
}

_getElements() {
  picCanvas = querySelector('#pic-canvas');
  fileInput = querySelector('#file-input');
  optionCrop = querySelector('#option-crop');
  divDownload = querySelector('#option-download');
  divSelectFile = querySelector('#option-select-file');
  canvasContainer = querySelector('#canvas-container');
}


_setHandlers() {
  divSelectFile.onClick.listen((var e) => document.getElementById('file-input').click());
  fileInput.onChange.listen((var e) => _loadFile());
  optionCrop.onClick.listen((var e) => editor.cropBox.cropping = !editor.cropBox.cropping);
  divDownload.onClick.listen((var e) {
    var dataURL = editor.canvas.toDataUrl();
    window.location.href = dataURL;
  });
}

_loadFile() {
  picCanvas.remove();
  picCanvas = new CanvasElement();
  canvasContainer.children.add(picCanvas);
  picCanvas.classes.add('pic-canvas');
  editor = new ImageEditor(picCanvas, fileInput.files[0]);
}
