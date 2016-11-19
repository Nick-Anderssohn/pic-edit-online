import 'dart:math';

class RPoint {
  Point point;
  int get x => point.x;
  int get y => point.y;
  void set x(int value) {
    point = new Point(value, y);
  }
  void set y(int value) {
    point = new Point(x, value);
  }
  RPoint(int x, int y) {
    point = new Point(x, y);
  }
}
