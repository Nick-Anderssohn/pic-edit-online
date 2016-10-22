import 'dart:html';
import 'dart:typed_data';
import 'crop_box.dart';
import 'package:image/image.dart';

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

class ImageEditor {
  CanvasElement canvas;
  CanvasRenderingContext2D ctx;
  CanvasElement drawLayer = new CanvasElement();
  CanvasRenderingContext2D get drawLayerCtx => drawLayer.context2D;
  CanvasElement imageLayer = new CanvasElement();
  CanvasRenderingContext2D get imageLayerCtx => imageLayer.context2D;
  CanvasElement scratchCanvas = new CanvasElement();
  CanvasRenderingContext2D get scratchCanvasCtx => scratchCanvas.context2D;
  ImageElement image;
  File imgFile;
  List<URAction> undoStack = new List<URAction>();
  List<URAction> redoStack = new List<URAction>();
  double scalar = 1.0;
  int get canvasWidth => canvas.width;
  void set canvasWidth(int value) {
    canvas.width = value;
    drawLayer.width = value;
    imageLayer.width = value;
    scalar = imageLayer.width / canvas.getBoundingClientRect().width;
    cropBox.scalar = scalar;
  }
  int get canvasHeight => canvas.height;
  void set canvasHeight(int value) {
    canvas.height = value;
    drawLayer.height = value;
    imageLayer.height = value;
  }
  CropBox cropBox;

  ImageEditor(CanvasElement canvas, File imageFile) {
    this.canvas = canvas;
    ctx = canvas.context2D;
    imgFile = imageFile;
    _loadFile();
    window.onKeyDown.listen((KeyboardEvent e) {
      if (e.keyCode == KeyCode.ENTER)
      if (cropBox.cropping) {
        drawLayerCtx.clearRect(0, 0, drawLayer.width, drawLayer.height);
        refreshDisplay();
        addUndoState();
      }
    });
    cropBox = new CropBox(canvas, drawLayer, imageLayer, scalar);
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

  refreshDisplay() {
    ctx.clearRect(0, 0, canvasWidth, canvasHeight);
    ctx.drawImage(imageLayer, 0, 0);
    ctx.drawImage(drawLayer, 0, 0);
  }

  _loadFile() {
    FileReader reader = new FileReader();
    image = new ImageElement();
    reader.onLoad.listen((var e) {
      image.onLoad.listen((var e) {
        if (image.width < window.innerWidth) {
          canvas.style.width = image.width.toString() + 'px';
        }
        else
          canvas.style.width = '100%';
        canvasWidth = image.width;
        canvasHeight = image.height;
        imageLayerCtx.drawImageScaled(image, 0, 0, canvas.width, canvas.height);
        refreshDisplay();
      });
      image.src = e.target.result;
    });
    reader.readAsDataUrl(imgFile);
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
