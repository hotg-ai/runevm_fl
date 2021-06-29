import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'mycolor.dart';
import 'tile.dart';
import 'grid.dart';
import 'game.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:hotg_2048/runic/audio.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  List<List<int>> grid = [];
  List<List<int>> gridNew = [];
  dynamic sharedPreferences;
  int score = 0;
  bool isgameOver = false;
  bool isgameWon = false;
  Audio _audio = new Audio();
  String lastCommand = "Left";
  @override
  void initState() {
    grid = blankGrid();
    gridNew = blankGrid();
    addNumber(grid, gridNew);
    addNumber(grid, gridNew);
    super.initState();
    _audio.onStep = (String? output) async {
      if (output != null) {
        lastCommand = jsonDecode(output)["elements"][0];
        /*
    
        0 = up
        1 = down
        2 = left
        3 = right

        */
        switch (lastCommand) {
          case "up":
            {
              handleGesture(0);
            }
            break;

          case "down":
            {
              handleGesture(1);
            }
            break;

          case "right":
            {
              handleGesture(2);
            }
            break;
          case "left":
            {
              handleGesture(3);
            }
            break;
          default:
            {
              //nothing
            }
            break;
        }
      }
      setState(() {});
    };
    _audio.startRecording();
  }

  List<Widget> getGrid(double width, double height) {
    List<Widget> grids = [];
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        int num = grid[i][j];
        String number;
        int color;
        if (num == 0) {
          color = MyColor.emptyGridBackground;
          number = "";
        } else if (num == 2 || num == 4) {
          color = MyColor.gridColorTwoFour;
          number = "${num}";
        } else if (num == 8 || num == 64 || num == 256) {
          color = MyColor.gridColorEightSixtyFourTwoFiftySix;
          number = "${num}";
        } else if (num == 16 || num == 32 || num == 1024) {
          color = MyColor.gridColorSixteenThirtyTwoOneZeroTwoFour;
          number = "${num}";
        } else if (num == 128 || num == 512) {
          color = MyColor.gridColorOneTwentyEightFiveOneTwo;
          number = "${num}";
        } else {
          color = MyColor.gridColorWin;
          number = "${num}";
        }
        double size = 0;
        String n = "${number}";
        switch (n.length) {
          case 1:
          case 2:
            size = 40.0;
            break;
          case 3:
            size = 30.0;
            break;
          case 4:
            size = 20.0;
            break;
        }
        grids.add(Tile(number, width, height, color, size));
      }
    }
    return grids;
  }

  void handleGesture(int direction) {
    /*
    
      0 = up
      1 = down
      2 = left
      3 = right

    */
    bool flipped = false;
    bool played = true;
    bool rotated = false;
    if (direction == 0) {
      setState(() {
        grid = transposeGrid(grid);
        grid = flipGrid(grid);
        rotated = true;
        flipped = true;
      });
    } else if (direction == 1) {
      setState(() {
        grid = transposeGrid(grid);
        rotated = true;
      });
    } else if (direction == 2) {
    } else if (direction == 3) {
      setState(() {
        grid = flipGrid(grid);
        flipped = true;
      });
    } else {
      played = false;
    }

    if (played) {
      print('playing');
      List<List<int>> past = copyGrid(grid);
      print('past ${past}');
      for (int i = 0; i < 4; i++) {
        setState(() {
          List result = operate(grid[i], score, sharedPreferences);
          score = result[0];
          print('score in set state ${score}');
          grid[i] = result[1];
        });
      }
      setState(() {
        grid = addNumber(grid, gridNew);
      });
      bool changed = compare(past, grid);
      print('changed ${changed}');
      if (flipped) {
        setState(() {
          grid = flipGrid(grid);
        });
      }

      if (rotated) {
        setState(() {
          grid = transposeGrid(grid);
        });
      }

      if (changed) {
        setState(() {
          grid = addNumber(grid, gridNew);
          print('is changed');
        });
      } else {
        print('not changed');
      }

      bool gameover = isGameOver(grid);
      if (gameover) {
        print('game over');
        setState(() {
          isgameOver = true;
        });
      }

      bool gamewon = isGameWon(grid);
      if (gamewon) {
        print("GAME WON");
        setState(() {
          isgameWon = true;
        });
      }
      print(grid);
      print(score);
    }
  }

  Future<String> getHighScore() async {
    sharedPreferences = await SharedPreferences.getInstance();
    int score = sharedPreferences.getInt('high_score');
    if (score == null) {
      score = 0;
    }
    return score.toString();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    double width = MediaQuery.of(context).size.width;
    double gridWidth = (width - 80) / 4;
    double gridHeight = gridWidth;
    double height = 30 + (gridHeight * 4) + 10;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        leading: Row(children: [
          Container(
            width: 10,
          ),
          Image.asset(
            "assets/HOTG_white.png",
            height: 26,
          )
        ]),
        leadingWidth: 300,
        title: Text(
          '2048',
          style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(MyColor.gridBackground),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(20.0),
                child: Container(
                  constraints: BoxConstraints(minWidth: 220, maxWidth: 500),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Color(MyColor.backGroundTwo),
                  ),
                  height: 82.0,
                  child: Row(children: [
                    Expanded(child: Container()),
                    Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                              top: 10.0, bottom: 5.0, left: 10.0, right: 10.0),
                          child: Text(
                            'Score',
                            style: TextStyle(
                                fontSize: 15.0,
                                color: Colors.white70,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: 5.0, bottom: 5.0, left: 10.0, right: 10.0),
                          child: Text(
                            '${score}',
                            style: TextStyle(
                                fontSize: 20.0,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                    Expanded(child: Container()),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: IconButton(
                        iconSize: 35.0,
                        icon: Icon(
                          Icons.refresh,
                          color: Colors.white70,
                        ),
                        onPressed: () {
                          setState(() {
                            grid = blankGrid();
                            gridNew = blankGrid();
                            grid = addNumber(grid, gridNew);
                            grid = addNumber(grid, gridNew);
                            score = 0;
                            isgameOver = false;
                            isgameWon = false;
                          });
                        },
                      ),
                    ),
                    Expanded(child: Container()),
                    Column(
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(
                                top: 10.0,
                                bottom: 5.0,
                                left: 10.0,
                                right: 10.0),
                            child: Text(
                              'High Score',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold),
                            )),
                        Padding(
                            padding: EdgeInsets.only(
                                top: 5.0, bottom: 5.0, left: 10.0, right: 10.0),
                            child: FutureBuilder<String>(
                              future: getHighScore(),
                              builder: (ctx, snapshot) {
                                if (snapshot.hasData) {
                                  return Text(
                                    snapshot.data.toString(),
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  );
                                } else {
                                  return Text(
                                    '0',
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  );
                                }
                              },
                            ))
                      ],
                    ),
                    Expanded(child: Container()),
                  ]),
                ),
              ),
              Container(
                height: height,
                constraints: BoxConstraints(
                    minWidth: 220,
                    maxWidth: 500,
                    minHeight: 220,
                    maxHeight: 500),
                child: Stack(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: GestureDetector(
                        child: GridView.count(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          primary: true,
                          crossAxisSpacing: 10.0,
                          mainAxisSpacing: 10.0,
                          crossAxisCount: 4,
                          children: getGrid(gridWidth, gridHeight),
                        ),
                        onVerticalDragStart: (DragStartDetails details) {
                          print("start");
                        },
                        onVerticalDragEnd: (DragEndDetails details) {
                          //primaryVelocity -ve up +ve down
                          if (details.primaryVelocity! < 0) {
                            handleGesture(0);
                          } else if (details.primaryVelocity! > 0) {
                            handleGesture(1);
                          }
                        },
                        onHorizontalDragEnd: (details) {
                          //-ve right, +ve left
                          if (details.primaryVelocity! > 0) {
                            handleGesture(2);
                          } else if (details.primaryVelocity! < 0) {
                            handleGesture(3);
                          }
                        },
                      ),
                    ),
                    isgameOver
                        ? Container(
                            height: height,
                            color: Color(MyColor.transparentWhite),
                            child: Center(
                              child: Text(
                                'Game over!',
                                style: TextStyle(
                                    fontSize: 30.0,
                                    fontWeight: FontWeight.bold,
                                    color: Color(MyColor.gridBackground)),
                              ),
                            ),
                          )
                        : SizedBox(),
                    isgameWon
                        ? Container(
                            height: height,
                            color: Color(MyColor.transparentWhite),
                            child: Center(
                              child: Text(
                                'You Won!',
                                style: TextStyle(
                                    fontSize: 30.0,
                                    fontWeight: FontWeight.bold,
                                    color: Color(MyColor.gridBackground)),
                              ),
                            ),
                          )
                        : SizedBox(),
                  ],
                ),
                color: Color(MyColor.gridBackground),
              ),
              Container(
                padding: EdgeInsets.all(20.0),
                child: Container(
                  constraints: BoxConstraints(minWidth: 220, maxWidth: 500),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Color(MyColor.backGroundTwo),
                  ),
                  height: 82.0,
                  child: Row(children: [
                    Expanded(
                        child: Stack(children: [
                      Container(
                          child: LineChart(
                        _audio.audioData(_audio.getBuffer()),
                      )),
                      Container(
                          width: width,
                          height: 82,
                          child: Center(
                              child: Text("$lastCommand",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 21))))
                    ])),
                  ]),
                ),
              ),
              Center(
                  child: Text("Sample Rate: ${_audio.sampleRate}",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 8)))
            ],
          ),
        ),
      ),
    );
  }
}
