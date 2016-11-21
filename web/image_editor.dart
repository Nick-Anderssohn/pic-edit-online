import 'dart:html';
import 'dart:typed_data';
import 'dart:math';
import 'crop_box.dart';
import 'package:image/image.dart';
import 'image_container.dart';

class URAction {
  int width;
  int height;
  Uint8ClampedList canvasData;

  URAction(Uint8ClampedList cData, int width, int height) {
    this.canvasData = cData;
    this.width = width;
    this.height = height;
  }
}

class ImageEditor extends ImageContainer {
  List<URAction> undoStack = new List<URAction>();
  List<URAction> redoStack = new List<URAction>();
  CropBox cropBox;
  set cropMode(bool value) {
    if (value) {
      eraserMode = erasing = false;
    } else {
      _clearDrawLayer();
    }
    cropBox.cropping = value;
   }
  bool get cropMode => cropBox.cropping;
  bool _eraserMode = false;
  get eraserMode => _eraserMode;
  set eraserMode(bool value) {
    if (value) {
      canvas.style.cursor = "none";
      if (rSliderLabel != null)
        rSliderLabel.hidden = false;
      if (radiusSlider != null)
        radiusSlider.hidden = false;
      if (rSliderValueLabel != null)
        rSliderValueLabel.hidden = false;
    }
    else {
      canvas.style.cursor = "default";
      _clearDrawLayer();
      refreshDisplay();
      drawLayerCtx.stroke();
      refreshDisplay();
      erasing = false;
      if (rSliderLabel != null)
        rSliderLabel.hidden = true;
      if (radiusSlider != null)
        radiusSlider.hidden = true;
      if (rSliderValueLabel != null)
        rSliderValueLabel.hidden = true;
    }
    _eraserMode = value;
  }
  bool erasing = false;
  int eraserRadius = 16;
  DivElement rSliderLabel = null;
  RangeInputElement radiusSlider = null;
  DivElement rSliderValueLabel = null;

  ImageEditor(CanvasElement canvas, File imageFile) : super (canvas, imageFile) {
    window.onKeyDown.listen((KeyboardEvent e) {
      if (e.keyCode == KeyCode.ENTER)
      if (cropMode) {
        drawLayerCtx.clearRect(0, 0, drawLayer.width, drawLayer.height);
        refreshDisplay();
        addUndoState();
      }
    });

    cropBox = new CropBox(this);
    cropBox.onCrop.listen((var e) {
      scalar = canvas.width / canvas.getBoundingClientRect().width;
      clearRedoStack();
    });

    _eraserHandlers();
  }

  URAction getCurState() {
    Uint8ClampedList cData = imageLayerCtx.getImageData(0, 0, canvas.width, canvas.height).data;
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
    cropMode = false;
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
    var imageData = imageLayerCtx.getImageData(0, 0, canvas.width, canvas.height);
    Image i = new Image.fromBytes(canvas.width, canvas.height, imageData.data);
    return new Blob([encodePng(i)]);
  }

  convertToGrayscale() {
    cropMode = false;
    eraserMode = false;
    addUndoState();
    Uint8ClampedList cData = imageLayerCtx.getImageData(0, 0, canvas.width, canvas.height).data;
    for (int i = 3; i < cData.length; i += 4) {
      cData[i - 3] = cData[i - 2] = cData[i - 1] = (cData[i - 3] * 0.3 + cData[i - 2] * 0.59 + cData[i - 1] * 0.11).truncate();
    }
    ImageData imgData = new ImageData(cData, canvas.width);
    imageLayerCtx.putImageData(imgData, 0, 0);
    refreshDisplay();
  }

  _eraserHandlers() {
    window.onMouseMove.listen((MouseEvent e) {
      if (eraserMode) {
        var cRect = canvas.getBoundingClientRect();
        int realX = (e.client.x - cRect.left) * scalar;
        int realY = (e.client.y - cRect.top) * scalar;
        if (erasing)
          _erase(realX, realY);
        _drawEraser(realX, realY);
      }
    });

    canvas.onMouseDown.listen((MouseEvent e) {
      if (eraserMode) {
        addUndoState();
        erasing = true;
      }
    });

    window.onMouseUp.listen((MouseEvent e) {
      if (eraserMode)
        erasing = false;
    });

    canvas.onMouseLeave.listen((MouseEvent e) {
      if (eraserMode) {
        drawLayerCtx.beginPath();
        drawLayerCtx.clearRect(0, 0, drawLayer.width, drawLayer.height);
        drawLayerCtx.closePath();
        refreshDisplay();
      }
    });
  }

  _drawEraser(int x, int y) {
    drawLayerCtx.clearRect(0, 0, canvas.width, canvas.height);
    refreshDisplay();
    drawLayerCtx.save();
    drawLayerCtx.beginPath();
    drawLayerCtx.strokeStyle = "#000000";
    drawLayerCtx.arc(x, y, eraserRadius, 0, PI * 2);
    drawLayerCtx.stroke();
    drawLayerCtx.closePath();
    drawLayerCtx.restore();
    refreshDisplay();
  }

  _erase(int x, int y) {
    imageLayerCtx.save();
    imageLayerCtx.beginPath();
    imageLayerCtx.globalCompositeOperation="destination-out";
    imageLayerCtx.arc(x, y, eraserRadius, 0, PI * 2);
    imageLayerCtx.fill();
    imageLayerCtx.closePath();
    imageLayerCtx.restore();
    refreshDisplay();
  }

  _clearDrawLayer() {
    drawLayerCtx.beginPath();
    drawLayerCtx.clearRect(0, 0, drawLayer.width, drawLayer.height);
    drawLayerCtx.closePath();
  }
}
