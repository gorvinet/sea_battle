//import 'dart:ffi';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const SeaBattleApp());
}

class SeaBattleApp extends StatefulWidget {
  const SeaBattleApp({super.key});

  @override
  State<SeaBattleApp> createState() => _SeaBattleAppState();
}

class _SeaBattleAppState extends State<SeaBattleApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SeaBattleGame(),
    );
  }
}

class SeaBattleGame extends StatefulWidget {
  const SeaBattleGame({super.key});

  @override
  _SeaBattleGameState createState() => _SeaBattleGameState();
}

class _SeaBattleGameState extends State<SeaBattleGame> {
  Human player = Human();
  Computer comp = Computer();
  bool isGameStarted = false;
  bool isComputerTurn = false;

  @override
  void initState() {
    super.initState();
    initializeGame();
    //test
  }

  void initializeGame() {
    player.reset();
    comp.reset();
    isGameStarted = false;
    isComputerTurn = false;
    setState(() {});
    //test
  }

  Future<void> fireCompShot() async {
    Future.delayed(const Duration(seconds: 1), () async {
      if (player.shot(player.findShotCell())) {
        setState(() {});
        await fireCompShot();
      } else {
        isComputerTurn = false;
        setState(() {});
      }
    });
  }

  Future<void> onCellTapped(int row, int col) async {
    if (!isGameStarted) {
      return;
    }
    if (isComputerTurn) {
      return;
    }

    if (checkWinStatus()) {
      isGameStarted = false;
      return;
    }

    if (comp.shot(Coordinate(row, col))) {
      setState(() {});
      return;
    }
    isComputerTurn = true;
    setState(() {});
    await fireCompShot();
  }

  bool checkWinStatus(){

    String alertDescrption = '';
    bool gameOver = false;

    if (comp.checkLose()) {
      alertDescrption = 'Player won';
      gameOver = true;
    }
    else if(player.checkLose()) {
      alertDescrption = 'Computer won';
      gameOver = true;
    }

    if (gameOver) {
      showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text(alertDescrption),
          ));
      return true;
    }

    return false;

  }

  void startGame() {
    initializeGame();

    setState(() {
      player.placeShips();
      comp.placeShips();
      isGameStarted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('SEA BATTLE'),
          centerTitle: true,
          actions: [
            ElevatedButton(
                // icon: const Icon(Icons.access_alarm),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  disabledForegroundColor: Colors.redAccent.withOpacity(0.38),
                ),
                onPressed: () => startGame(),
                child: const Text(
                  'Start game',
                )),
          ],
        ),
        body: Center(
            child: SizedBox(
                width: 700,
                child: ListView(
                  children: [
                    Card(
                        color: isGameStarted && !isComputerTurn
                            ? Colors.greenAccent.shade100
                            : null,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.face),
                              title: const Text('Player'),
                              subtitle: Text('Shots: ${comp.shots}'),
                            ),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                      width: 400,
                                      height: 400,
                                      child: GridView.builder(
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 10,
                                            crossAxisSpacing: 0,
                                            mainAxisSpacing: 0,
                                          ),
                                          itemCount: 100,
                                          padding: const EdgeInsets.all(20),
                                          itemBuilder: (context, index) {
                                            final row = index ~/ 10;
                                            final col = index % 10;
                                            //debugPrint('row=$row col=$col');
                                            // log(row);
                                            return GestureDetector(
                                                onTap: () =>
                                                    onCellTapped(row, col),
                                                child: comp.drawBoardCell(
                                                    row, col));
                                          })),
                                  Container(
                                      padding: const EdgeInsets.all(20),
                                      width: 200,
                                      height: 400,
                                      child: ListView.builder(
                                          itemCount: comp.ships.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return comp.drawShipsPanel(
                                                context, index);
                                          })),
                                ]),
                          ],
                        )),
                    Card(
                        color: isGameStarted && isComputerTurn
                            ? Colors.greenAccent.shade100
                            : null,
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ListTile(
                                leading: const Icon(Icons.computer),
                                title: const Text('Computer'),
                                subtitle: Text('Shots: ${player.shots}'),
                              ),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                        width: 400,
                                        height: 400,
                                        child: GridView.builder(
                                            gridDelegate:
                                                const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 10,
                                              crossAxisSpacing: 0,
                                              mainAxisSpacing: 0,
                                            ),
                                            itemCount: 100,
                                            padding: const EdgeInsets.all(20),
                                            itemBuilder: (context, index) {
                                              final row = index ~/ 10;
                                              final col = index % 10;
                                              //debugPrint('row=$row col=$col');
                                              // log(row);
                                              return GestureDetector(
                                                  child: player.drawBoardCell(
                                                      row, col));
                                            })),
                                    Container(
                                        padding: const EdgeInsets.all(20),
                                        width: 200,
                                        height: 400,
                                        child: ListView.builder(
                                            itemCount: player.ships.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return player.drawShipsPanel(
                                                  context, index);
                                            }))
                                  ]),
                            ]))
                  ],
                ))));
  }
}

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
