import 'dart:html';

abstract class ImageContainer {
  ImageElement image;
  File imgFile;
  CanvasElement canvas;
  CanvasRenderingContext2D get ctx => canvas.context2D;
  CanvasElement drawLayer = new CanvasElement();
  CanvasRenderingContext2D get drawLayerCtx => drawLayer.context2D;
  CanvasElement imageLayer = new CanvasElement();
  CanvasRenderingContext2D get imageLayerCtx => imageLayer.context2D;
  CanvasElement scratchCanvas = new CanvasElement();
  CanvasRenderingContext2D get scratchCanvasCtx => scratchCanvas.context2D;

  double scalar = 1.0;
  int get canvasWidth => canvas.width;
  void set canvasWidth(int value) {
    canvas.width = value;
    drawLayer.width = value;
    imageLayer.width = value;

    scalar = canvas.width / canvas.getBoundingClientRect().width;
  }
  int get canvasHeight => canvas.height;
  void set canvasHeight(int value) {
    canvas.height = value;
    drawLayer.height = value;
    imageLayer.height = value;
  }

  ImageContainer(CanvasElement canvas, File imageFile) {
    this.canvas = canvas;
    imgFile = imageFile;
    loadFile();
  }

  loadFile() {
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
      image.src = (e.target as FileReader).result as String;
    });
    reader.readAsDataUrl(imgFile);
  }

  refreshDisplay() {
    ctx.clearRect(0, 0, canvasWidth, canvasHeight);
    ctx.drawImage(imageLayer, 0, 0);
    ctx.drawImage(drawLayer, 0, 0);
  }
}
