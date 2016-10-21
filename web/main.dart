import 'dart:html';
import 'dart:async';
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
DivElement undoOption;
DivElement redoOption;
AreaElement downloadHelper;
DivElement titleElement;
bool loading = false;

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
  titleElement = querySelector('#title');

  editDD = new DropDown(divEdit);
  restoreOriginalOption = new DivElement();
  restoreOriginalOption.text = 'Restore Original';
  undoOption = new DivElement();
  undoOption.text = 'Undo';
  redoOption = new DivElement();
  redoOption.text = 'Redo';
}


_setHandlers() async {
  divSelectFile.onClick.listen((var e) => document.getElementById('file-input').click());
  fileInput.onChange.listen((var e) => _loadFile());
  optionCrop.onClick.listen((var e) {
    if (editor.cropBox.cropping) {
      editor.drawLayerCtx.clearRect(0, 0, editor.drawLayer.width, editor.drawLayer.height);
      editor.refreshDisplay();
    }
    editor.cropBox.cropping = !editor.cropBox.cropping;
  });
  divDownload.onClick.listen((var e) async {
    //var dataURL = editor.canvas.toDataUrl();
    _downloadPNG();
  });
  restoreOriginalOption.onClick.listen((var e) => _loadFile());
  divEdit.onClick.listen((var e) => editDD.target.hidden = !editDD.target.hidden);
  editDD.addItem(restoreOriginalOption);
  editDD.addItem(undoOption);
  editDD.addItem(redoOption);
  undoOption.style.color = '#000000';
  redoOption.style.color = '#000000';
  undoOption.id = 'undo-option';
  redoOption.id = 'redo-option';
}

_downloadPNG() async {
  titleElement.text = 'Pic Edit Online - Creating PNG...';
  await new Future.delayed(new Duration(milliseconds: 1)); //otherwise above text doesn't have time to appear...
  downloadHelper.href = Url.createObjectUrlFromBlob(editor.getPNGBlob());
  document.getElementById('download-helper').click();
  titleElement.text = 'Pic Edit Online';
}

_loadFile() {
  if (picCanvas != null)
    picCanvas.remove();
  picCanvas = new CanvasElement();
  canvasContainer.children.add(picCanvas);
  picCanvas.classes.add('pic-canvas');
  if (fileInput.files[0] != null)
    editor = new ImageEditor(picCanvas, fileInput.files[0]);
  undoOption.onClick.listen((var e) {
    if (editor.undoStack.length > 0)
    editor.undo();
  });
  redoOption.onClick.listen((var e) {
    if (editor.redoStack.length > 0)
     editor.redo();
   });
}
