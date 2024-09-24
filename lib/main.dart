//import 'dart:ffi';
import 'package:flutter/material.dart';

import 'package:sea_battle/board.dart';
import 'package:sea_battle/player.dart';

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



