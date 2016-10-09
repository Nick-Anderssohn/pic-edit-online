import 'dart:html';
Element titleElement;

main() {
  _getElements();
  _updateStyles();
}

_getElements() {
  titleElement = querySelector('#title');
}

_updateStyles() {
  titleElement.classes.add('title');
}
