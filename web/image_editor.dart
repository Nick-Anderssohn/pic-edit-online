import 'dart:html';
import 'crop_box.dart';

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
  double scalar = 1.0;
  int get canvasWidth => canvas.width;
  void set canvasWidth(int value) {
    canvas.width = value;
    drawLayer.width = value;
    imageLayer.width = value;
    scalar = image.width / canvas.getBoundingClientRect().width;
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
    cropBox = new CropBox(canvas, drawLayer, imageLayer, scalar);

    // window.onKeyDown.listen((KeyboardEvent e) {
    //   if (e.keyCode == KeyCode.ENTER && cropBox.cropping) {
    //     try {
    //       _crop();
    //     } catch (e) {
    //       print(e);
    //     }
    //   }
    // });
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

  //crops the photo to whatever fits inside the crop box
  _crop() {
    //draw image onto scratch
    // scratchCanvas.width = cropBox.p2.x - cropBox.p1.x;
    // scratchCanvas.height = cropBox.p4.y - cropBox.p1.y;
    // ctx.translate(cropBox.p1.x, cropBox.p1.y);
    // scratchCanvasCtx.drawImage(canvas, 0, 0);
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    //draw scale back onto canvas
    // ctx.drawImageScaled(scratchCanvas, 0, 0, scratchCanvas.width, scratchCanvas.height);

    // cropBox.cropping = false;
  }
}
