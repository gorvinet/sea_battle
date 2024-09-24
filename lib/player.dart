import 'dart:math';
import 'package:flutter/material.dart';

import 'package:sea_battle/board.dart';
import 'package:sea_battle/ship.dart';


mixin Player {
  String name = '';
  Board board = Board();
  late bool isComp;
  List<Ship> ships = [
    Ship('ship4', 4),
    Ship('ship3_1', 3),
    Ship('ship3_2', 3),
    Ship('ship2_1', 2),
    Ship('ship2_2', 2),
    Ship('ship2_3', 2),
    Ship('ship1_1', 1),
    Ship('ship1_2', 1),
    Ship('ship1_3', 1),
    Ship('ship1_4', 1),
  ];
  List<Coordinate> successfulShots = [];
  int shots = 0;

  void placeShips() {
    for (var ship in ships) {
      ship.resetShip();
      while (true) {
        if (board.placeShip(ship)) {
          break;
        }
      }
    }
  }

  Widget drawShipsPanel(BuildContext context, int index) {
    Ship ship = ships[index];
    // double containerSize = ship.size * 40;

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: ship.size * 20 + 20,
        maxWidth: ship.size * 20 + 20,
        minHeight: 30,
        maxHeight: 30,
      ),
      child: Row(
          children: List.generate(ship.size, (index) {
            return Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                    border: Border.all(width: 0.2),
                    color: ship.isDead ? Colors.redAccent : Colors.white));
          })),
    );
  }

  Widget drawBoardCell(int row, int col) {
    BoardCell cell = board.getCell(row, col);

    return
      Container(
          decoration: BoxDecoration(
            border: Border.all(width: 0.2),
            //gradient: getCellGradient(cell),
            color: getCellColor(cell),
          ),
          child: Center(
            child: Text(
              cell.isShot ? '•' : '',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 30,
              ),
            ),
          )
        //color: Colors.transparent,
      );
  }

  Color getCellColor(BoardCell cell) {
    return Colors.white;
  }

  bool shot(Coordinate coord) {
    BoardCell cell = board.getCell(coord.row, coord.col);
    if (!cell.isShotAvailable()) {
      return false;
    }
    shots++;
    cell.isShot = true;
    if (cell.isShip) {
      if (cell.ship.checkDead()) {
        successfulShots.clear();
      } else {
        successfulShots.add(coord);
      }
      if (checkLose()) {}
      return true;
    }
    return false;
  }

  void reset() {
    board.reset();
    successfulShots = [];
    shots = 0;
  }

  bool checkLose() {
    bool allDead = true;
    for (Ship item in ships) {
      allDead = allDead && item.isDead;
    }
    return allDead;
  }
}

class Computer with Player {
  Computer() {
    isComp = true;
  }

  @override
  Color getCellColor(BoardCell cell) {
    if (cell.isShot) {
      if (cell.isShip && cell.ship.isDead) {
        return Colors.redAccent;
      }
      if (cell.isShip) {
        return Colors.grey;
      }
    }
    if (cell.isShipArea && cell.isNeighbourDead()) {
      return Colors.grey.shade300;
    }
    return Colors.white;
  }
}

class Human with Player {
  Human() {
    board = Board();
    isComp = false;
  }

  @override
  Color getCellColor(BoardCell cell) {
    if (cell.isShot && cell.isShip) {
      return Colors.redAccent;
    }
    if (cell.isShip) {
      return Colors.grey;
    }

    return Colors.white;
  }

  Coordinate _findShotCellSmart() {
    if (successfulShots.length == 1) {
      Map<String, Coordinate> cellNeighbours =
      successfulShots.single.getNeighbours();
      if (cellNeighbours.containsKey('up') &&
          board
              .getCell(cellNeighbours['up']!.row, cellNeighbours['up']!.col)
              .isShotAvailable()) {
        return Coordinate(cellNeighbours['up']!.row, cellNeighbours['up']!.col);
      }
      if (cellNeighbours.containsKey('down') &&
          board
              .getCell(cellNeighbours['down']!.row, cellNeighbours['down']!.col)
              .isShotAvailable()) {
        return Coordinate(
            cellNeighbours['down']!.row, cellNeighbours['down']!.col);
      }
      if (cellNeighbours.containsKey('left') &&
          board
              .getCell(cellNeighbours['left']!.row, cellNeighbours['left']!.col)
              .isShotAvailable()) {
        return Coordinate(
            cellNeighbours['left']!.row, cellNeighbours['left']!.col);
      }
      if (cellNeighbours.containsKey('right') &&
          board
              .getCell(
              cellNeighbours['right']!.row, cellNeighbours['right']!.col)
              .isShotAvailable()) {
        return Coordinate(
            cellNeighbours['right']!.row, cellNeighbours['right']!.col);
      }
    } else {
      String mode = '';
      Coordinate cell1;
      Coordinate cell2;

      if (successfulShots[0].row == successfulShots[1].row) {
        mode = 'row';
      } else {
        mode = 'col';
      }
      int maxItem = 0;
      int minItem = 10;
      for (Coordinate item in successfulShots) {
        if (mode == 'row') {
          maxItem = max(maxItem, item.col);
          minItem = min(minItem, item.col);
        } else {
          maxItem = max(maxItem, item.row);
          minItem = min(minItem, item.row);
        }
      }
      if (mode == 'row') {
        cell1 = Coordinate(successfulShots[0].row, minItem);
        cell2 = Coordinate(successfulShots[0].row, maxItem);
      } else {
        cell1 = Coordinate(minItem, successfulShots[0].col);
        cell2 = Coordinate(maxItem, successfulShots[0].col);
      }
      Map<String, Coordinate> neighbours1 = cell1.getNeighbours();
      Map<String, Coordinate> neighbours2 = cell2.getNeighbours();

      if (mode == 'row') {
        if (neighbours1.containsKey('left') &&
            board
                .getCell(neighbours1['left']!.row, neighbours1['left']!.col)
                .isShotAvailable()) {
          return Coordinate(neighbours1['left']!.row, neighbours1['left']!.col);
        } else {
          return Coordinate(
              neighbours2['right']!.row, neighbours1['right']!.col);
        }
      } else {
        if (neighbours1.containsKey('up') &&
            board
                .getCell(neighbours1['up']!.row, neighbours1['up']!.col)
                .isShotAvailable()) {
          return Coordinate(neighbours1['up']!.row, neighbours1['up']!.col);
        } else {
          return Coordinate(neighbours2['down']!.row, neighbours1['down']!.col);
        }
      }
    }
    return Coordinate(-1, -1);
  }

  Coordinate _findShotCellRandom() {
    List<Coordinate> availableCells = board.getAllAvailableShots();

    return availableCells[Random().nextInt(availableCells.length)];
    //   row = Random().nextInt(10);
    //   col = Random().nextInt(10);
    //   cell = board.getCell(row, col);
    //   if (cell.isShotAvailable()) {
    //     break;
    //   }
    // }

    // return Coordinate(row, col);
  }

  Coordinate findShotCell() {
    if (successfulShots.isNotEmpty) {
      return _findShotCellSmart();
    } else {
      return _findShotCellRandom();
    }
  }
}

