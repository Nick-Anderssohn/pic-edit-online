import 'dart:html';
import 'crop_box.dart';
import 'undo_redo_manager.dart';
import 'package:image/image.dart';

class ImageEditor {
  UndoRedoManager urManager = new UndoRedoManager();
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
    urManager.canvas = canvas;
    ctx = canvas.context2D;
    imgFile = imageFile;
    _loadFile();
    cropBox = new CropBox(canvas, drawLayer, imageLayer, scalar);
    cropBox.onCrop.listen((var e) {
      scalar = imageLayer.width / canvas.getBoundingClientRect().width;
      urManager.addState(getCurState());
    });
    urManager.onUndo.listen((var e) {
      if (canvas.width > window.innerWidth) {
        print("test");
          canvas.style.width = "100%";
          scalar = imageLayer.width / canvas.getBoundingClientRect().width;
      }
      else {
        canvas.style.width = canvas.width.toString() + 'px';
        canvas.style.height = canvas.height.toString() + 'px';
        scalar = imageLayer.width / canvas.getBoundingClientRect().width;
      }
      // imageLayer.width = canvas.width;
      // imageLayer.height = canvas.height;
      // imageLayerCtx.clearRect(0, 0, imageLayer.width, imageLayer.height);
      // drawLayer.width = canvas.width;
      // drawLayer.height = canvas.height;
      // drawLayerCtx.clearRect(0, 0, drawLayer.width, drawLayer.height);
      // imageLayerCtx.drawImage(canvas, 0, 0);
      // refreshDisplay();
    });
    urManager.addState(getCurState());
  }

  URAction getCurState() {
    return new URAction(ctx.getImageData(0, 0, canvas.width, canvas.height).data, canvas.width, canvas.height);
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
          canvas.style.width = "100%";
        canvasWidth = image.width;
        //canvasHeight = (image.height * (canvas.width / image.width)).round(); //scale correctly
        canvasHeight = image.height;
        imageLayerCtx.drawImageScaled(image, 0, 0, canvas.width, canvas.height);
        refreshDisplay();
      });
      image.src = e.target.result;
    });
    reader.readAsDataUrl(imgFile);
  }

  //image conversion using Brendan Duncan's library from https://github.com/brendan-duncan/image
  Blob getPNGBlob() {
    var imageData = ctx.getImageData(0, 0, canvas.width, canvas.height);
    Image i = new Image.fromBytes(canvas.width, canvas.height, imageData.data);
    return new Blob([encodePng(i)]);
  }
}
