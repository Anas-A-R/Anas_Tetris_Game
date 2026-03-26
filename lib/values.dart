import 'package:flutter/material.dart';

enum Tetromino { L, J, I, O, S, Z, T }

enum Direction { left, right, down }

int rowLenght = 10;
int columnLength = 15;

const Map<Tetromino, Color> tetrominoColor = {
  Tetromino.L: Color.fromARGB(255, 239, 144, 0),
  Tetromino.J: Color.fromARGB(255, 12, 145, 254),
  Tetromino.I: Color.fromARGB(255, 225, 21, 89),
  Tetromino.O: Colors.amber,
  Tetromino.S: Color.fromARGB(255, 37, 160, 41),
  Tetromino.Z: Color.fromARGB(255, 244, 55, 41),
  Tetromino.T: Color.fromARGB(255, 157, 28, 180),
};
