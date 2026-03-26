// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:tetris_game/game_board.dart';
import 'package:tetris_game/values.dart';

class Piece {
  Tetromino type; //type of tetris pieces
  Piece({required this.type});

  List<int> position = [];

  //Color of piece
  Color get color {
    return tetrominoColor[type] ?? Colors.white;
  }

  void initPiece() {
    switch (type) {
      case Tetromino.L:
        position = [-26, -16, -6, -5];
        break;
      case Tetromino.J:
        position = [-25, -15, -5, -6];
        break;
      case Tetromino.I:
        position = [-4, -5, -6, -7];
        break;
      case Tetromino.O:
        position = [-15, -16, -5, -6];
        break;
      case Tetromino.S:
        position = [-15, -14, -6, -5];
        break;
      case Tetromino.Z:
        position = [-17, -16, -6, -5];
        break;
      case Tetromino.T:
        position = [-26, -16, -6, -15];
        break;
    }
  }

  void movePiece(Direction direction) {
    switch (direction) {
      case Direction.left:
        for (int i = 0; i < position.length; i++) {
          position[i] -= 1;
        }
        break;
      case Direction.right:
        for (int i = 0; i < position.length; i++) {
          position[i] += 1;
        }
        break;
      case Direction.down:
        for (int i = 0; i < position.length; i++) {
          position[i] += rowLenght;
        }
        break;
    }
  }

  //rotate piece
  int rotationState = 1;

  void rotatePiece() {
    // O piece doesn’t rotate
    if (type == Tetromino.O) return;

    // Pivot is usually block 1
    int pivot = position[1];
    int pivotRow = pivot ~/ rowLenght;
    int pivotCol = pivot % rowLenght;

    List<int> newPosition = [];

    for (int i = 0; i < position.length; i++) {
      int row = position[i] ~/ rowLenght;
      int col = position[i] % rowLenght;

      // Convert to pivot-relative coords
      int relRow = row - pivotRow;
      int relCol = col - pivotCol;

      // Apply rotation: (row, col) → (-col, row) for clockwise
      int rotatedRow = -relCol;
      int rotatedCol = relRow;

      // Convert back to board coords
      int newRow = pivotRow + rotatedRow;
      int newCol = pivotCol + rotatedCol;

      newPosition.add(newRow * rowLenght + newCol);
    }

    // Validate and commit rotation
    if (piecePositionIsValid(newPosition)) {
      position = newPosition;
      rotationState = (rotationState + 1) % 4;
    }
  }

  //check if valid position
  bool positionIsValid(int position) {
    //get row and col of position
    int row = (position / rowLenght).floor();
    int col = (position % rowLenght).floor();
    //if position is taken then return false
    if (row < 0 || col < 0 || gameBoard[row][col] != null) {
      return false;
    }
    //other wise position is valid
    return true;
  }

  //check if piece position is valid
  bool piecePositionIsValid(List<int> piecePositions) {
    bool firstColOccupeid = false;
    bool lastColOccupeid = false;
    for (var pos in piecePositions) {
      //return false if any position is already taken
      if (!positionIsValid(pos)) {
        return false;
      }
      //get col of position
      int col = pos % rowLenght;
      //check if first or last column is occupied
      if (col == 0) {
        firstColOccupeid = true;
      }
      if (col == rowLenght - 1) {
        lastColOccupeid = true;
      }
    }
    //if there is a piece in first col and last col, it is going through the wall
    return !(firstColOccupeid && lastColOccupeid);
  }
}
