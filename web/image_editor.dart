import 'dart:html';


class ImageEditor {
  CanvasElement canvas;
  CanvasRenderingContext2D ctx;
  ImageElement image;
  File imgFile;

  ImageEditor(CanvasElement canvas, File imageFile) {
    this.canvas = canvas;
    ctx = canvas.context2D;
    imgFile = imageFile;
    _loadFile();
  }

  _loadFile() {
    FileReader reader = new FileReader();
    image = new ImageElement();
    reader.onLoad.listen((var e) {
      image.onLoad.listen((var e) {
        canvas.width = image.width;
        canvas.height = image.height;
        ctx.drawImage(image, 0, 0);
      });
      image.src = e.target.result;
    });
    reader.readAsDataUrl(imgFile);
  }
}