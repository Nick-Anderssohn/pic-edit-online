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
  bool croppingStarted = false;
  bool draggingCorner = false;
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
        var cRect = canvas.getBoundingClientRect();
        int realX = e.client.x - cRect.left;
        int realY = e.client.y - cRect.top;
        //if box coordinates have not been set
        if (startP == null)
          startP = new Point(realX, realY);
        else if (_getSelectedCropCorner(realX, realY) != null)
          draggingCorner = true;
      }
      print("dragging corner: " + draggingCorner.toString());
    });

    canvas.onMouseMove.listen((var e) {
      if (cropping) {
        if (startP != null) {
          var cRect = canvas.getBoundingClientRect();
          int realX = e.client.x - cRect.left;
          int realY = e.client.y - cRect.top;
          if (!croppingStarted) { //drawing initial box....

            _drawBox(startP, new Point(realX, realY)); //refreshes display in this function as well
          } else if (draggingCorner) {
            var points = _getSelectedCropCorner(realX, realY);
            _drawBox(points[0], points[1]);
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
        draggingCorner = false;
      }
    });
  }

  List<Point> _getSelectedCropCorner(int realX, int realY) {
    print("p1.x: " + p1.x.toString());
    //print("p1.x * scalar: " + (p1.x * scalar).toString());
    print("p2.x: " + p2.x.toString());
    //print("p1.x * scalar: " + (p1.x * scalar).toString());
    print("p3.x: " + p3.x.toString());
    //print("p1.x * scalar: " + (p1.x * scalar).toString());
    print("p4.x: " + p4.x.toString());
    //print("p1.x * scalar: " + (p1.x * scalar).toString());
    print("realX: " + realX.toString());
    //print("realX * scalar: " + (realX * scalar).toString());
    print("p1.y: " + p1.y.toString());
    //print("p1.x * scalar: " + (p1.x * scalar).toString());
    print("p2.y: " + p2.y.toString());
    //print("p1.x * scalar: " + (p1.x * scalar).toString());
    print("p3.y: " + p3.y.toString());
    //print("p1.x * scalar: " + (p1.x * scalar).toString());
    print("p4.y: " + p4.y.toString());
    //print("p1.x * scalar: " + (p1.x * scalar).toString());
    print("realY: " + realY.toString());
    //print("realX * scalar: " + (realX * scalar).toString());
    if (realX > p1.x - 10 && realX < p1.x + 10 && realY > p1.y - 10 && realY < p1.y + 10)
      return [p1, p3];
    if (realX > p2.x - 10 && realX < p2.x + 10 && realY > p2.y - 10 && realY < p2.y + 10)
      return [p2, p4];
    if (realX > p3.x - 10 && realX < p3.x + 10 && realY > p3.y - 10 && realY < p3.y + 10)
      return [p3, p1];
    if (realX > p4.x - 10 && realX < p4.x + 10 && realY > p4.y - 10 && realY < p4.y + 10)
      return [p4, p2];

    return null;
  }

//accepts 2 points diagonal from each other
  _drawBox(Point d1, Point d2) {
    int width = d2.x - d1.x;
    int height = d2.y - d1.y;
    drawLayerCtx.clearRect(0, 0, canvasWidth, canvasHeight);

    //draw dots at corners
    drawLayerCtx.beginPath();
    drawLayerCtx.arc(d1.x * scalar, d1.y * scalar, 4, 0, 2 * PI);
    drawLayerCtx.fill();
    drawLayerCtx.closePath();
    drawLayerCtx.beginPath();
    drawLayerCtx.arc(d1.x * scalar, (d1.y + height) * scalar, 4, 0, 2 * PI);
    drawLayerCtx.fill();
    drawLayerCtx.closePath();
    drawLayerCtx.beginPath();
    drawLayerCtx.arc((d1.x + width) * scalar, (d1.y + height) * scalar, 4, 0, 2 * PI);
    drawLayerCtx.fill();
    drawLayerCtx.closePath();
    drawLayerCtx.beginPath();
    drawLayerCtx.arc((d1.x + width) * scalar, d1.y * scalar, 4, 0, 2 * PI);
    drawLayerCtx.fill();
    drawLayerCtx.closePath();

    //draw box
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
