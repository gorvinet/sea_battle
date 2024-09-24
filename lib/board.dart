import 'package:sea_battle/ship.dart';


class Board {
  List<List<BoardCell>> grid = [];

  Board() {
    reset();
  }

  bool placeShip(Ship ship) {
    FakeShip newShip = FakeShip(ship.size - 1);
    if (!newShip.checkShip()) {
      return false;
    }

    if (checkPlace(newShip)) {
      for (var element in newShip.ship) {
        BoardCell boardCell = getCell(element.row, element.col);
        boardCell.ship = ship;
        ship.addPlace(boardCell);
        boardCell.isShip = true;
      }
      newShip.generateArea();
      for (var element in newShip.area) {
        BoardCell cell = getCell(element.row, element.col);
        cell.isShipArea = true;
        cell.addNeighbour(ship);
      }
      return true;
    }
    return false;
  }

  BoardCell getCell(int row, int col) {
    return grid[row][col];
  }

  bool checkPlace(FakeShip ship) {
    for (var element in ship.ship) {
      if (getCell(element.row, element.col).isShipArea) {
        return false;
      }
    }
    return true;
  }

  void reset() {
    grid = List.generate(10, (row) => List.generate(10, (col) => BoardCell()));
  }

  List<Coordinate> getAllAvailableShots() {
    List<Coordinate> availableCells = [];

    for (int row = 0; row < 10; row++) {
      for (int col = 0; col < 10; col++) {
        BoardCell cell = getCell(row, col);
        if (cell.isShotAvailable()) {
          availableCells.add(Coordinate(row, col));
        }
      }
    }
    return availableCells;
  }
}

class BoardCell {
  bool isShot = false;
  bool isShipArea = false;
  bool isShip = false;
  Ship ship = Ship.empty();
  List<Ship> neighbours = [];

  BoardCell();

  void addNeighbour(Ship ship) {
    neighbours.add(ship);
  }

  bool isNeighbourDead() {
    for (var element in neighbours) {
      if (element.isDead) {
        return true;
      }
    }
    return false;
  }

  bool isShotAvailable() {
    if (isShot) {
      return false;
    }
    for (Ship ship in neighbours) {
      if (ship.isDead) {
        return false;
      }
    }
    return true;
  }
}

class Coordinate {
  late int row;
  late int col;

  Coordinate(this.row, this.col);

  bool check() {
    bool isCorrect = true;
    if (row < 0 || row > 9 || col < 0 || col > 9) {
      isCorrect = false;
    }
    return isCorrect;
  }

  Map<String, Coordinate> getNeighbours() {
    Map<String, Coordinate> res = <String, Coordinate>{};
    if (row > 0) {
      res['up'] = Coordinate(row - 1, col);
    }
    if (row < 9) {
      res['down'] = Coordinate(row + 1, col);
    }
    if (col > 0) {
      res['left'] = Coordinate(row, col - 1);
    }
    if (row > 0) {
      res['right'] = Coordinate(row, col + 1);
    }
    return res;
  }
}

