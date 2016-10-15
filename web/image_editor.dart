import 'dart:html';
import 'dart:math';
import 'r_point.dart';

class ImageEditor {
  CanvasElement canvas;
  CanvasRenderingContext2D ctx;
  CanvasElement drawLayer = new CanvasElement();
  CanvasRenderingContext2D get drawLayerCtx => drawLayer.context2D;
  CanvasElement imageLayer = new CanvasElement();
  CanvasRenderingContext2D get imageLayerCtx => imageLayer.context2D;
  ImageElement image;
  File imgFile;
  bool draggingCropBox = false;
  bool _cropping = false;
  bool get cropping => _cropping;
  void set cropping(bool value) {
    if (!_cropping && value == true) {
      //add/draw points
      p1 = new RPoint((100 * scalar).round(), (100 * scalar).round());
      p2 = new RPoint((200 * scalar).round(), (100 * scalar).round());
      p3 = new RPoint((200 * scalar).round(), (200 * scalar).round());
      p4 = new RPoint((100 * scalar).round(), (200 * scalar).round());
      _drawBox();
    }
    _cropping = value;
  }
  RPoint pSelected = null;
  RPoint p1 = null; //crop box point 1
  RPoint p2 = null; //crop box point 2
  RPoint p3 = null; //crop box point 3
  RPoint p4 = null; //crop box point 4
  double scalar = 1.0;
  int get canvasWidth => canvas.width;

  void set canvasWidth(int value) {
    canvas.width = value;
    drawLayer.width = value;
    imageLayer.width = value;
    scalar = image.width / canvas.getBoundingClientRect().width;
  }

  int get canvasHeight => canvas.height;

  void set canvasHeight(int value) {
    canvas.height = value;
    drawLayer.height = value;
    imageLayer.height = value;
  }

  ImageEditor(CanvasElement canvas, File imageFile) {
    this.canvas = canvas;
    ctx = canvas.context2D;
    imgFile = imageFile;
    _loadFile();
    _handleCropping();
  }

  _refreshDisplay() {
    ctx.clearRect(0, 0, canvasWidth, canvasHeight);
    ctx.drawImage(imageLayer, 0, 0);
    ctx.drawImage(drawLayer, 0, 0);
  }

  _loadFile() {
    FileReader reader = new FileReader();
    image = new ImageElement();
    reader.onLoad.listen((var e) {
      image.onLoad.listen((var e) {
        if (image.width < window.innerWidth)
          canvas.style.width = image.width.toString() + 'px';
        else
          canvas.style.width = "100%";
        canvasWidth = image.width;
        //canvasHeight = (image.height * (canvas.width / image.width)).round(); //scale correctly
        canvasHeight = image.height;
        imageLayerCtx.drawImageScaled(image, 0, 0, canvas.width, canvas.height);
        _refreshDisplay();
      });
      image.src = e.target.result;
    });
    reader.readAsDataUrl(imgFile);
  }

  _handleCropping() {
    int ogX = 0;
    int ogY = 0;
    canvas.onMouseDown.listen((MouseEvent e) {
      if (cropping) {
        var cRect = canvas.getBoundingClientRect();
        int realX = (e.client.x - cRect.left) * scalar;
        int realY = (e.client.y - cRect.top) * scalar;
        ogX = realX;
        ogY = realY;
        //if box coordinates have not been set
        pSelected = _getSelectedCropCorner(realX, realY);
        if (pSelected == null)
          draggingCropBox = _isInCropBox(realX, realY);
      }
    });

    canvas.onMouseMove.listen((var e) {
      if (cropping) {
        var cRect = canvas.getBoundingClientRect();
        int realX = (e.client.x - cRect.left) * scalar;
        int realY = (e.client.y - cRect.top) * scalar;
        if (pSelected != null) {
          pSelected.x = realX;
          pSelected.y = realY;
          _drawBox();
        } else if (draggingCropBox) {
          _moveBox(ogX - realX, ogY - realY);
          ogX = realX;
          ogY = realY;
        }
      }
    });

    canvas.onMouseUp.listen((var e) {
      if (cropping) {
        pSelected = null;
        draggingCropBox = false;
      }
    });
  }

  RPoint _getSelectedCropCorner(int realX, int realY) {
    if (realX > (p1.x + 2 * scalar) - 4 * scalar && realX < (p1.x + 2 * scalar) + 4 * scalar && realY > (p1.y + 2 * scalar) - 4 * scalar && realY < (p1.y + 2 * scalar) + 4 * scalar)
      return p1;
    if (realX > (p2.x + 2 * scalar) - 4 * scalar && realX < (p2.x + 2 * scalar) + 4 * scalar && realY > (p2.y + 2 * scalar) - 4 * scalar && realY < (p2.y + 2 * scalar) + 4 * scalar)
      return p2;
    if (realX > (p3.x + 2 * scalar) - 4 * scalar && realX < (p3.x + 2 * scalar) + 4 * scalar && realY > (p3.y + 2 * scalar) - 4 * scalar && realY < (p3.y + 2 * scalar) + 4 * scalar)
      return p3;
    if (realX > (p4.x + 2 * scalar) - 4 * scalar && realX < (p4.x + 2 * scalar) + 4 * scalar && realY > (p4.y + 2 * scalar) - 4 * scalar && realY < (p4.y + 2 * scalar) + 4 * scalar)
      return p4;

    return null;
  }

  bool _isInCropBox(int realX, int realY) {
    if (realX > p1.x && realX < p2.x && realY > p1.y && realY < p4.y)
      return true;
    return false;
  }

  _moveBox(int distX, int distY) {
    p1.x -= distX;
    p2.x -= distX;
    p3.x -= distX;
    p4.x -= distX;

    p1.y -= distY;
    p2.y -= distY;
    p3.y -= distY;
    p4.y -= distY;

    _drawBox();
  }

  _drawBox() {
      if (pSelected == p1) {
        p2.y = p1.y;
        p4.x = p1.x;
      } else if (pSelected == p2) {
        p1.y = p2.y;
        p3.x = p2.x;
      } else if (pSelected == p3) {
        p4.y = p3.y;
        p2.x = p3.x;
      } else if (pSelected == p4) {
        p3.y = p4.y;
        p1.x = p4.x;
      }

      drawLayerCtx.clearRect(0, 0, canvasWidth, canvasHeight);

      //draw dots at corners
      drawLayerCtx.beginPath();
      drawLayerCtx.arc(p1.x, p1.y, 4 * scalar, 0, 2 * PI);
      drawLayerCtx.fill();
      drawLayerCtx.closePath();
      drawLayerCtx.beginPath();
      drawLayerCtx.arc(p2.x, p2.y, 4 * scalar, 0, 2 * PI);
      drawLayerCtx.fill();
      drawLayerCtx.closePath();
      drawLayerCtx.beginPath();
      drawLayerCtx.arc(p3.x, p3.y, 4 * scalar, 0, 2 * PI);
      drawLayerCtx.fill();
      drawLayerCtx.closePath();
      drawLayerCtx.beginPath();
      drawLayerCtx.arc(p4.x, p4.y, 4 * scalar, 0, 2 * PI);
      drawLayerCtx.fill();
      drawLayerCtx.closePath();

      //draw box
      drawLayerCtx.beginPath();
      drawLayerCtx.moveTo(p1.x, p1.y);
      drawLayerCtx.lineTo(p2.x, p2.y);
      drawLayerCtx.lineTo(p3.x, p3.y);
      drawLayerCtx.lineTo(p4.x, p4.y);
      drawLayerCtx.lineTo(p1.x, p1.y);
      drawLayerCtx.stroke();
      drawLayerCtx.closePath();

      _refreshDisplay();
    }
}
