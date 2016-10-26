import 'dart:html';
import 'dart:typed_data';
import 'crop_box.dart';
import 'package:image/image.dart';
import 'image_container.dart';

class URAction {
  int width;
  int height;
  Uint8ClampedList canvasData;

  URAction(Uint8ClampedList cData, width, height) {
    this.canvasData = cData;
    this.width = width;
    this.height = height;
  }
}

class ImageEditor extends ImageContainer {
  List<URAction> undoStack = new List<URAction>();
  List<URAction> redoStack = new List<URAction>();
  CropBox cropBox;

  // void set canvasWidth(int value) {
  //   super.canvasWidth = value;
  //   cropBox.scalar = scalar;
  // }

  ImageEditor(CanvasElement canvas, File imageFile) : super (canvas, imageFile) {
    window.onKeyDown.listen((KeyboardEvent e) {
      if (e.keyCode == KeyCode.ENTER)
      if (cropBox.cropping) {
        drawLayerCtx.clearRect(0, 0, drawLayer.width, drawLayer.height);
        refreshDisplay();
        addUndoState();
      }
    });
    cropBox = new CropBox(this);
    cropBox.onCrop.listen((var e) {
      scalar = imageLayer.width / canvas.getBoundingClientRect().width;
      clearRedoStack();
    });

  }

  URAction getCurState() {
    Uint8ClampedList cData = ctx.getImageData(0, 0, canvas.width, canvas.height).data;
    return new URAction(cData, canvasWidth, canvasHeight);
  }

  addUndoState() {
    undoStack.add(getCurState());
    querySelector('#undo-option').style.color = '#FFFFFF';
  }

  addRedoState() {
    redoStack.add(getCurState());
    querySelector('#redo-option').style.color = '#FFFFFF';
  }

  clearUndoStack() {
    undoStack.clear();
    querySelector('#undo-option').style.color = '#000000';
  }

  clearRedoStack() {
    redoStack.clear();
    querySelector('#redo-option').style.color = '#000000';
  }

  undo() {
    addRedoState();
    if (undoStack.last.width < window.innerWidth) {
      canvas.style.width = undoStack.last.width.toString() + 'px';
    } else {
      canvas.style.width = '100%';
    }
    canvasWidth = undoStack.last.width;
    canvasHeight = undoStack.last.height;
    ImageData cTemp = new ImageData(undoStack.last.canvasData, undoStack.last.width);
    ctx.putImageData(cTemp, 0, 0);
    imageLayerCtx.drawImage(canvas, 0, 0);
    undoStack.removeLast();
    if (undoStack.length == 0)
      querySelector('#undo-option').style.color = '#000000';
  }

  redo() {
    addUndoState();
    if (redoStack.last.width < window.innerWidth) {
      canvas.style.width = redoStack.last.width.toString() + 'px';
    } else {
      canvas.style.width = '100%';
    }
    canvasWidth = redoStack.last.width;
    canvasHeight = redoStack.last.height;
    ImageData cTemp = new ImageData(redoStack.last.canvasData, redoStack.last.width);
    ctx.putImageData(cTemp, 0, 0);
    imageLayerCtx.drawImage(canvas, 0, 0);
    redoStack.removeLast();
    if (redoStack.length == 0)
      querySelector('#redo-option').style.color = '#000000';
  }

  //image conversion using Brendan Duncan's library from https://github.com/brendan-duncan/image
  Blob getPNGBlob() {
    var imageData = ctx.getImageData(0, 0, canvas.width, canvas.height);
    Image i = new Image.fromBytes(canvas.width, canvas.height, imageData.data);
    return new Blob([encodePng(i)]);
  }
}
