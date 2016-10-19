import 'dart:html';
import 'dart:math';
import 'dart:async';
import 'r_point.dart';

class CropBox {
  CanvasElement canvas;
  CanvasRenderingContext2D get ctx => canvas.context2D;
  CanvasElement drawLayer;
  CanvasRenderingContext2D get drawLayerCtx => drawLayer.context2D;
  CanvasElement imageLayer;
  CanvasRenderingContext2D get imageLayerCtx => imageLayer.context2D;
  CanvasElement scratchCanvas = new CanvasElement();
  CanvasRenderingContext2D get scratchCanvasCtx => scratchCanvas.context2D;
  bool draggingCropBox = false;
  bool _cropping = false;
  bool get cropping => _cropping;
  void set cropping(bool value) {
    if (!_cropping && value == true) {
      int tempW = (.25 * canvas.width).truncate();
      int tempH = (.25 * canvas.height).truncate();
      //add/draw points
      p1 = new RPoint(tempW, tempH);
      p2 = new RPoint(2 * tempW, tempH);
      p3 = new RPoint(2 * tempW, 2 * tempH);
      p4 = new RPoint(tempW, 2 * tempH);
      _drawBox();
    } else if (_cropping && !value) {
      //drawLayerCtx.clearRect(0, 0, drawLayer.width, drawLayer.height);
      //_refreshDisplay();
    }
    _cropping = value;
  }
  RPoint pSelected = null;
  RPoint p1 = null; //crop box point 1
  RPoint p2 = null; //crop box point 2
  RPoint p3 = null; //crop box point 3
  RPoint p4 = null; //crop box point 4
  double scalar = 1.0;
  int _cornerRadius = 4;
  int get cornerRadius => (_cornerRadius * scalar).round();
  StreamController _cropStreamer = new StreamController.broadcast();
  Stream get onCrop => _cropStreamer.stream;

  CropBox(CanvasElement canvas, CanvasElement drawLayer, CanvasElement imageLayer, double scalar) {
    this.canvas = canvas;
    this.drawLayer = drawLayer;
    this.imageLayer = imageLayer;
    this.scalar = scalar;
    _handleCropping();
  }

  _refreshDisplay() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    ctx.drawImage(imageLayer, 0, 0);
    ctx.drawImage(drawLayer, 0, 0);
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

    window.onMouseMove.listen((var e) {
      if (cropping) {
        var cRect = canvas.getBoundingClientRect();
        int realX = (e.client.x - cRect.left) * scalar;
        int realY = (e.client.y - cRect.top) * scalar;

        if (pSelected != null) {
          if (realX < 0)
            realX = 0;
          else if (realX > canvas.width)
            realX = canvas.width;

          if (realY < 0)
            realY = 0;
          else if (realY > canvas.height)
            realY = canvas.height;
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

    window.onMouseUp.listen((var e) {
      if (cropping) {
        pSelected = null;
        draggingCropBox = false;
      }
    });

    window.onKeyDown.listen((KeyboardEvent e) {
      if (e.keyCode == KeyCode.ENTER) {
        try {
          _crop();
        } catch (e) {
          print(e);
        }
      }

    });
  }

  RPoint _getSelectedCropCorner(int realX, int realY) {
    if (realX > (p1.x + cornerRadius / 2) - cornerRadius && realX < (p1.x + cornerRadius / 2) + cornerRadius && realY > (p1.y + cornerRadius / 2) - cornerRadius && realY < (p1.y + cornerRadius / 2) + cornerRadius)
      return p1;
    if (realX > (p2.x + cornerRadius / 2) - cornerRadius && realX < (p2.x + cornerRadius / 2) + cornerRadius && realY > (p2.y + cornerRadius / 2) - cornerRadius && realY < (p2.y + cornerRadius / 2) + cornerRadius)
      return p2;
    if (realX > (p3.x + cornerRadius / 2) - cornerRadius && realX < (p3.x + cornerRadius / 2) + cornerRadius && realY > (p3.y + cornerRadius / 2) - cornerRadius && realY < (p3.y + cornerRadius / 2) + cornerRadius)
      return p3;
    if (realX > (p4.x + cornerRadius / 2) - cornerRadius && realX < (p4.x + cornerRadius / 2) + cornerRadius && realY > (p4.y + cornerRadius / 2) - cornerRadius && realY < (p4.y + cornerRadius / 2) + cornerRadius)
      return p4;

    return null;
  }

  bool _isInCropBox(int realX, int realY) {
    if (realX > p1.x && realX < p2.x && realY > p1.y && realY < p4.y)
      return true;
    return false;
  }

  _moveBox(int distX, int distY) {
    int ogW = p2.x - p1.x;
    int ogH = p4.y - p1.y;
    p1.x -= distX;
    p2.x -= distX;
    p3.x -= distX;
    p4.x -= distX;

    p1.y -= distY;
    p2.y -= distY;
    p3.y -= distY;
    p4.y -= distY;

    if (p1.x < 0) {
      p4.x = p1.x = 0;
      p3.x = p2.x = p1.x + ogW;
    }
    else if (p2.x > canvas.width) {
      p3.x = p2.x = canvas.width;
      p4.x = p1.x = p3.x - ogW;
    }

    if (p4.y > canvas.height) {
      p4.y = p3.y = canvas.height;
      p1.y = p2.y = p4.y - ogH;
    }
    else if (p1.y < 0) {
      p1.y = p2.y = 0;
      p4.y = p3.y = p1.y + ogH;
    }

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

      drawLayerCtx.clearRect(0, 0, canvas.width, canvas.height);

      drawLayerCtx.save();
      drawLayerCtx.lineWidth = 2;
      drawLayerCtx.shadowColor = '#FFFFFF';
      drawLayerCtx.shadowBlur = 3;
      drawLayerCtx.shadowOffsetX = 0;
      drawLayerCtx.shadowOffsetY = 0;

      //draw dots at corners
      drawLayerCtx.beginPath();
      drawLayerCtx.arc(p1.x, p1.y, cornerRadius, 0, 2 * PI);
      drawLayerCtx.fill();
      drawLayerCtx.closePath();
      drawLayerCtx.beginPath();
      drawLayerCtx.arc(p2.x, p2.y, cornerRadius, 0, 2 * PI);
      drawLayerCtx.fill();
      drawLayerCtx.closePath();
      drawLayerCtx.beginPath();
      drawLayerCtx.arc(p3.x, p3.y, cornerRadius, 0, 2 * PI);
      drawLayerCtx.fill();
      drawLayerCtx.closePath();
      drawLayerCtx.beginPath();
      drawLayerCtx.arc(p4.x, p4.y, cornerRadius, 0, 2 * PI);
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

      drawLayerCtx.restore();

      _refreshDisplay();
    }

    //crops the photo to whatever fits inside the crop box
    _crop() {
      drawLayerCtx.clearRect(0, 0, drawLayer.width, drawLayer.height); //so crop box doesnt show up
      _refreshDisplay();
      //draw image onto scratch
      scratchCanvas.width = p2.x - p1.x;
      scratchCanvas.height = p4.y - p1.y;
      ctx.save();
      ctx.translate(-p1.x, -p1.y);
      ctx.drawImage(canvas, 0, 0);
      ctx.restore();
      scratchCanvasCtx.drawImage(canvas, 0, 0);
      ctx.clearRect(0, 0, canvas.width, canvas.height);
      //draw scale back onto canvas
      imageLayer.width = scratchCanvas.width;
      imageLayer.height = scratchCanvas.height;
      imageLayerCtx.clearRect(0, 0, imageLayer.width, imageLayer.height);
      _canvasToImageSize();
      imageLayerCtx.drawImage(scratchCanvas, 0, 0);
      //ctx.drawImage(scratchCanvas, 0, 0);

      drawLayerCtx.clearRect(0, 0, drawLayer.width, drawLayer.height);
      _refreshDisplay();

      cropping = false;
      _cropStreamer.add("cropped");
    }

    _canvasToImageSize() {
      if (imageLayer.width < window.innerWidth)
        canvas.style.width = imageLayer.width.toString() + 'px';
      else
        canvas.style.width = "100%";
      //canvas.style.height = imageLayer.height.toString() + "px";
      canvas.width = imageLayer.width;
      canvas.height = imageLayer.height;
      scalar = imageLayer.width / canvas.getBoundingClientRect().width;
    }
}
