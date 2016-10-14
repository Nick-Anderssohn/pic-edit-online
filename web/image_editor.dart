import 'dart:html';
import 'dart:math';

class ImageEditor {
  CanvasElement canvas;
  CanvasRenderingContext2D ctx;
  CanvasElement drawLayer = new CanvasElement();
  CanvasRenderingContext2D get drawLayerCtx => drawLayer.context2D;
  CanvasElement imageLayer = new CanvasElement();
  CanvasRenderingContext2D get imageLayerCtx => imageLayer.context2D;
  ImageElement image;
  File imgFile;
  bool cropping = false;
  bool drawingBox = false;
  bool croppingStarted = false;
  Point p1 = null; //crop box point 1
  Point p2 = null; //crop box point 2
  Point p3 = null; //crop box point 3
  Point p4 = null; //crop box point 4
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
    Point startP = null;
    canvas.onMouseDown.listen((MouseEvent e) {
      if (cropping) {
        //if box coordinates have not been set
        if (startP == null) {
          var cRect = canvas.getBoundingClientRect();
          //instantiate all 4 points at current location
          startP = new Point(e.client.x - cRect.left, e.client.y - cRect.top);
        }
      }
    });

    canvas.onMouseMove.listen((var e) {
      if (cropping) {
        if (startP != null) {
          if (!croppingStarted) { //drawing initial box....
            var cRect = canvas.getBoundingClientRect();
            _drawBox(startP, new Point(e.client.x - cRect.left, e.client.y - cRect.top)); //refreshes display in this function as well
          }
        }
      }
    });

    canvas.onMouseUp.listen((var e) {
      if (cropping) {
        if (startP != null) {
          if (!croppingStarted) {
            var cRect = canvas.getBoundingClientRect();
            int width = startP.x - (e.client.x - cRect.left);
            int height = startP.y - (e.client.y - cRect.top);
            croppingStarted = true;
            p1 = startP;
            p2 = new Point(startP.x + width, startP.y);
            p3 = new Point(startP.x + width, startP.y + height);
            p4 = new Point(startP.x, startP.y + height);
          }
        }
      }
    });
  }

//accepts 2 points diagonal from each other
  _drawBox(Point d1, Point d2) {
    int width = d2.x - d1.x;
    int height = d2.y - d1.y;
    drawLayerCtx.clearRect(0, 0, canvasWidth, canvasHeight);

    drawLayerCtx.beginPath();
    drawLayerCtx.moveTo(d1.x * scalar, d1.y * scalar);
    drawLayerCtx.lineTo(d1.x * scalar, (d1.y + height) * scalar);
    drawLayerCtx.lineTo((d1.x + width) * scalar, (d1.y + height) * scalar);
    drawLayerCtx.lineTo((d1.x + width) * scalar, d1.y * scalar);
    drawLayerCtx.lineTo(d1.x * scalar, d1.y * scalar);
    drawLayerCtx.stroke();
    drawLayerCtx.closePath();


    _refreshDisplay();
  }
}
