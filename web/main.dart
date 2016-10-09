import 'dart:html';
Element titleElement;
CanvasElement picCanvas;

main() {
  _getElements();
  _updateStyles();
}

_getElements() {
  titleElement = querySelector('#title');
  picCanvas = querySelector('#pic-canvas');
}

_updateStyles() {
  titleElement.classes.add('title');
  picCanvas.classes.add('pic-canvas');
}
