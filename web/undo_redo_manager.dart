import 'dart:html';
import 'dart:typed_data';
import 'dart:async';

class URAction {
  int width;
  int height;
  Uint8ClampedList data;

  URAction(Uint8ClampedList data, width, height) {
    this.data = data;
    this.width = width;
    this.height = height;
  }
}

//works by storing a copy of previous pixel data....memory inefficient
class UndoRedoManager {
  CanvasElement _canvas = null;
  URAction _curState = null;
  CanvasElement get canvas => _canvas;
  void set canvas(CanvasElement value) {
    _canvas = value;
  }
  CanvasRenderingContext2D get ctx => canvas.context2D;
  List<URAction> _undoStack = new List<URAction>();
  //List<Uint8ClampedList> _redoStack = new List<Uint8ClampedList>();
  StreamController _undoStreamer = new StreamController.broadcast();
  Stream get onUndo => _undoStreamer.stream;

  UndoRedoManager() {

  }
  addState(URAction state) {
    _undoStack.add(_curState);
    _curState = state;
  }

  undo() {
    canvas.width = _undoStack.last.width;
    canvas.height = _undoStack.last.height;
    ImageData temp = new ImageData(_undoStack.last.data, _undoStack.last.width);
    ctx.putImageData(temp, 0, 0);
    _undoStack.removeLast();
    _undoStreamer.add("undone");
  }
}
