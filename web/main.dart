import 'dart:html';
import 'image_editor.dart';
import 'drop_down.dart';

CanvasElement picCanvas;
InputElement fileInput;
ImageEditor editor;
DivElement divDownload;
DivElement optionCrop;
DivElement divSelectFile;
DivElement divEdit;
DivElement canvasContainer;
DropDown editDD;
DivElement restoreOriginalOption;
AreaElement downloadHelper;

main() {
  _getElements();
  _setHandlers();
}

_getElements() {
  picCanvas = null;
  fileInput = querySelector('#file-input');
  optionCrop = querySelector('#option-crop');
  divDownload = querySelector('#option-download');
  divSelectFile = querySelector('#option-select-file');
  divEdit = querySelector('#option-edit');
  canvasContainer = querySelector('#canvas-container');
  downloadHelper = querySelector('#download-helper');

  editDD = new DropDown(divEdit);
  restoreOriginalOption = new DivElement();
  restoreOriginalOption.text = 'Restore Original';
}


_setHandlers() {
  divSelectFile.onClick.listen((var e) => document.getElementById('file-input').click());
  fileInput.onChange.listen((var e) => _loadFile());
  optionCrop.onClick.listen((var e) => editor.cropBox.cropping = !editor.cropBox.cropping);
  divDownload.onClick.listen((var e) {
    var dataURL = editor.canvas.toDataUrl();
    downloadHelper.href = dataURL;
    print("test1");
    document.getElementById('download-helper').click();
    //window.location.href = dataURL;
  });
  restoreOriginalOption.onClick.listen((var e) => _loadFile());
  divEdit.onClick.listen((var e) => editDD.target.hidden = !editDD.target.hidden);
  editDD.addItem(restoreOriginalOption);
}

_loadFile() {
  if (picCanvas != null)
    picCanvas.remove();
  picCanvas = new CanvasElement();
  canvasContainer.children.add(picCanvas);
  picCanvas.classes.add('pic-canvas');
  editor = new ImageEditor(picCanvas, fileInput.files[0]);
}
