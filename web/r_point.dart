import 'dart:math';

class RPoint {
  Point point;
  double get x => point.x as double;
  double get y => point.y as double;
  void set x(double value) {
    point = new Point(value, y);
  }
  void set y(double value) {
    point = new Point(x, value);
  }
  RPoint(double x, double y) {
    point = new Point(x, y);
  }
}
