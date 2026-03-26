// ignore_for_file: deprecated_member_use

import 'dart:async';
// import 'dart:nativewrappers/_internal/vm/lib/math_patch.dart';
import 'dart:math' as m;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tetris_game/piece.dart';
import 'package:tetris_game/pixel.dart';
import 'package:tetris_game/values.dart';
import 'package:tetris_game/values.dart' as val;

/*

This is 2 by 2 grid with null represeting empty space.
A non empty space will have the color to represent the landed pieces

*/

//create game board
List<List<Tetromino?>> gameBoard = List.generate(
  columnLength,
  (i) => List.generate(rowLenght, (j) => null),
);

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  var currentPiece = Piece(type: Tetromino.I);
  int currentScore = 0;
  bool gameOver = false;
  bool isPaused = false;

  Timer? gameTimer; // Added to manage game loop timer

  @override
  void initState() {
    startGame();
    super.initState();
  }

  startGame() {
    currentPiece.initPiece();
    Duration frameRefrehsRate = Duration(milliseconds: 800);
    gameLoop(frameRefrehsRate);
  }

  void pauseGame() {
    if (!isPaused && !gameOver) {
      setState(() {
        isPaused = true;
        gameTimer?.cancel(); // Cancel the game loop timer
      });
    }
  }

  void resumeGame() {
    if (isPaused && !gameOver) {
      setState(() {
        isPaused = false;
        Duration frameRefrehsRate = Duration(milliseconds: 800);
        gameLoop(frameRefrehsRate); // Restart the game loop
      });
    }
  }

  void dropPieceToBottom() {
    setState(() {
      while (!checkCollision(val.Direction.down)) {
        currentPiece.movePiece(val.Direction.down);
      }
      checkLanding(); // Force landing when piece reaches bottom
    });
  }

  gameLoop(Duration frameRate) {
    gameTimer = Timer.periodic(frameRate, (timer) {
      setState(() {
        clearLines();
        checkLanding();
        if (isGameOver()) {
          timer.cancel();
          showGameDialog();
        }
        currentPiece.movePiece(val.Direction.down);
      });
    });
  }

  bool checkCollision(val.Direction direction) {
    //check for collision in future position
    //return true if there is collision
    //return false if there is no collision

    for (int i = 0; i < currentPiece.position.length; i++) {
      int row = (currentPiece.position[i] / rowLenght).floor();
      int col = currentPiece.position[i] % rowLenght;

      if (direction == val.Direction.left) {
        col -= 1;
      } else if (direction == val.Direction.right) {
        col += 1;
      } else if (direction == val.Direction.down) {
        row += 1;
      }

      // Check if the piece is out of bounds or collides with a landed piece
      if (col < 0 || col >= rowLenght || row >= columnLength) {
        return true;
      }
      // Check if the position is occupied on the game board
      if (row >= 0 && col >= 0 && gameBoard[row][col] != null) {
        return true;
      }
    }
    return false;
  }

  void checkLanding() {
    //if going down is occupied
    if (checkCollision(val.Direction.down)) {
      //mark position as occupied on game board
      //loop through each position of current piece
      for (int i = 0; i < currentPiece.position.length; i++) {
        int row = (currentPiece.position[i] / rowLenght).floor();
        int col = (currentPiece.position[i] % rowLenght).floor();
        if (row >= 0 && col >= 0) {
          gameBoard[row][col] = currentPiece.type;
        }
      }
      //once landed, create a new piece
      createNewPiece();
    }
  }

  void createNewPiece() {
    //create a random object to create a random tetromino types
    m.Random rand = m.Random();
    //create a new piece with random type
    Tetromino randomType =
        Tetromino.values[rand.nextInt(Tetromino.values.length)];
    currentPiece = Piece(type: randomType);
    currentPiece.initPiece();
    if (isGameOver()) {
      gameOver = true;
    }
  }

  void moveLeft() {
    //make sure to check if move is valide before moving
    if (!checkCollision(val.Direction.left)) {
      setState(() => currentPiece.movePiece(val.Direction.left));
    }
  }

  void moveRight() {
    //make sure to check if move is valide before moving
    if (!checkCollision(val.Direction.right)) {
      setState(() => currentPiece.movePiece(val.Direction.right));
    }
  }

  void rotatePiece() {
    setState(() => currentPiece.rotatePiece());
  }

  void clearLines() {
    //loop through each row of game board from bottom to top
    for (int row = columnLength - 1; row >= 0; row--) {
      //.init a var to check if a row is full
      bool rowIsFull = true;
      //check if row is full(all col in row are filled with pieces)
      for (int col = 0; col < rowLenght; col++) {
        //if there is an empty col, set rowIsFull to false and break the loop
        if (gameBoard[row][col] == null) {
          rowIsFull = false;
          break;
        }
      }
      //if row is full , clear the row and shift the row down
      if (rowIsFull) {
        //move all rows above the cleared row by one position
        for (int r = row; r > 0; r--) {
          //copy the above row to the current row
          gameBoard[r] = List.from(gameBoard[r - 1]);
        }
        //set the top row to empty
        gameBoard[0] = List.generate(row, (index) => null);
        //increase the score
        currentScore++;
      }
    }
  }

  bool isGameOver() {
    //check if any col in top row is filled
    for (int col = 0; col < rowLenght; col++) {
      if (gameBoard[0][col] != null) {
        return true;
      }
    }
    //if top row is empty game is not over
    return false;
  }

  Widget showGameDialog() {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.8),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          // height: 290,
          width: 330,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 57, 15, 64).withOpacity(0.9),
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            border: Border.all(
              color: const Color.fromARGB(255, 217, 0, 255),
              width: 5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.face,
                color: Colors.amber,
                size: 70,
              ).animate().scaleXY(duration: 600.ms, curve: Curves.bounceOut),
              const SizedBox(height: 20),
              Text(
                isPaused ? 'Paused' : 'Game Over',
                style: GoogleFonts.orbitron(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildDialogButton(
                        Icons.home_outlined,
                        const Color.fromARGB(255, 217, 0, 255),
                        Colors.white,
                        () {
                          resetGame();
                          Navigator.pop(context);
                        },
                      )
                      .animate(delay: 300.ms)
                      .scaleXY(
                        begin: 0,
                        duration: 400.ms,
                        curve: Curves.easeOutBack,
                      ),
                  _buildDialogButton(
                        isPaused ? Icons.play_arrow_outlined : Icons.refresh,
                        const Color.fromARGB(255, 217, 0, 255),
                        Colors.white,
                        () {
                          if (isPaused) {
                            resumeGame();
                          } else {
                            setState(() {
                              gameOver = false;
                              resetGame();
                            });
                          }
                        },
                      )
                      .animate(delay: 300.ms)
                      .scaleXY(
                        begin: 0,
                        duration: 400.ms,
                        curve: Curves.easeOutBack,
                      ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogButton(
    IconData icon,
    Color backgroundColor,
    Color borderColor,
    VoidCallback onTap, [
    bool isBoardButton = false,
  ]) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: isBoardButton ? 40 : 60,
        width: isBoardButton ? 40 : 60,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.all(
            Radius.circular(isBoardButton ? 10 : 15),
          ),
          border: Border.all(color: borderColor, width: isBoardButton ? 2 : 3),
        ),
        child: Icon(icon, color: Colors.white, size: isBoardButton ? 25 : 35),
      ),
    );
  }

  resetGame() {
    gameBoard = List.generate(
      columnLength,
      (i) => List.generate(rowLenght, (j) => null),
    );
    gameOver = false;
    currentScore = 0;
    createNewPiece();
    startGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Score: $currentScore',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    // Added pause/resume button
                    _buildDialogButton(
                      Icons.pause,
                      Colors.black,
                      Colors.white,
                      () {
                        pauseGame();
                        showGameDialog();
                      },
                      true,
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Expanded(
                  child: GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: rowLenght,
                    ),
                    itemCount: rowLenght * columnLength,
                    itemBuilder: (context, index) {
                      int row = (index / rowLenght).floor();
                      int col = index % rowLenght;
                      //current piece
                      if (currentPiece.position.contains(index)) {
                        return Pixel(
                          color: currentPiece.color,
                          text: index.toString(),
                        );
                      }
                      //landed piece
                      else if (gameBoard[row][col] != null) {
                        final Tetromino? tetrominoType = gameBoard[row][col];
                        return Pixel(
                          color: tetrominoColor[tetrominoType]!,
                          text: '',
                        );
                      } else {
                        //blank piece
                        return Pixel(
                          color: Colors.grey.withOpacity(0.8),
                          text: index.toString(),
                        );
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      //left
                      _buildDialogButton(
                        Icons.keyboard_arrow_left_outlined,
                        Colors.black,
                        Colors.white,
                        () => moveLeft(),
                        true,
                      ),
                      //rotate
                      _buildDialogButton(
                        Icons.refresh_outlined,
                        Colors.black,
                        Colors.white,
                        () => rotatePiece(),
                        true,
                      ),
                      //down
                      _buildDialogButton(
                        Icons.keyboard_arrow_down_outlined,
                        Colors.black,
                        Colors.white,
                        () => dropPieceToBottom(),
                        true,
                      ),
                      //right
                      _buildDialogButton(
                        Icons.keyboard_arrow_right_outlined,
                        Colors.black,
                        Colors.white,
                        () => moveRight(),
                        true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (gameOver || isPaused) showGameDialog(),
          ],
        ),
      ),
    );
  }
}
