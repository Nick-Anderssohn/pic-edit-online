import 'dart:html';


class DropDown {
  DivElement target = new DivElement();
  List<DivElement> items = new List<DivElement>();
  bool _mouseIsOver = false;
  bool _mouseIsOverParent = false;
  DropDown(DivElement parent) {
    parent.children.add(target);
    target.classes.add('drop-down');
    hide();

    window.onClick.listen((MouseEvent e) {
      if (!_mouseIsOver && !_mouseIsOverParent) {
        hide();
      }
    });

    target.onMouseEnter.listen((var e) => _mouseIsOver = true);
    target.onMouseLeave.listen((var e) => _mouseIsOver = false);
    target.parent.onMouseEnter.listen((var e) => _mouseIsOverParent = true);
    target.parent.onMouseLeave.listen((var e) => _mouseIsOverParent = false);
  }

  //applies styling for you
  addItem(DivElement item) {
    item.classes.add('drop-down-item');
    target.children.add(item);
  }

  show() {
    target.hidden = false;
  }

  hide() {
    target.hidden = true;
  }
}
