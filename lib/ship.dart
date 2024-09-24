import 'dart:math';

import 'package:sea_battle/board.dart';

class Ship {
  String name = '';
  int size = 0;
  late List<BoardCell> place = [];
  bool isDead = false;

  Ship.empty();

  Ship(this.name, this.size);

  void addPlace(BoardCell cell) {
    place.add(cell);
  }

  void resetShip() {
    place = [];
    isDead = false;
  }

  bool checkDead() {
    bool isShipDead = true;
    for (var element in place) {
      isShipDead = isShipDead && element.isShot;
    }
    isDead = isShipDead;
    return isDead;
  }
}

class FakeShip {
  late List<Coordinate> ship = [];
  late List<Coordinate> area = [];

  FakeShip(int size) {
    int row = Random().nextInt(10);
    int col = Random().nextInt(10);
    int direction = Random().nextInt(3);

    switch (direction) {
      case 0: //up
        for (int i = 0; i <= size; i++) {
          ship.add(Coordinate(row - i, col));
        }
      case 1: //right
        for (int i = 0; i <= size; i++) {
          ship.add(Coordinate(row, col + i));
        }
      case 2: //down
        for (int i = 0; i <= size; i++) {
          ship.add(Coordinate(row + i, col));
        }
      case 3: //left
        for (int i = 0; i <= size; i++) {
          ship.add(Coordinate(row, col - 1));
        }
    }
  }

  bool checkShip() {
    for (var element in ship) {
      if (!element.check()) {
        return false;
      }
    }
    return true;
  }

  void generateArea() {
    for (var element in ship) {
      int rowUp = max(element.row - 1, 0);
      int rowDown = min(element.row + 1, 9);
      int colLeft = max(element.col - 1, 0);
      int colRight = min(element.col + 1, 9);
      for (int row = rowUp; row <= rowDown; row++) {
        for (int col = colLeft; col <= colRight; col++) {
          area.add(Coordinate(row, col));
        }
      }
    }
  }
}
