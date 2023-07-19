import 'package:flutter/material.dart';

import 'game_board.dart';

/*

Welcome! This Chess game in Flutter makes use of several variables and methods to create the game.

1.  The board is a two-dimensional list representing the chess board, 
    each cell possibly containing a ChessPiece. 
    A ChessPiece has a type (pawn, rook, knight, bishop, queen, king), 
    a Boolean to define its color (white or black), and an image path.

2.  The selectedPiece variable stores the piece selected by the user on the board,
    while selectedRow and selectedCol store its location.
    validMoves keeps track of possible moves for the selected piece.
    isWhiteTurn is a Boolean indicating the current player's turn.

3.  There are also two lists for each player's captured pieces
    (whitePiecesTaken and blackPiecesTaken),
    and a checkStatus Boolean to check if a king is in check.
    whiteKingPosition and blackKingPosition store the current positions of both kings.

4.  The game starts by initializing the board in the _initializeBoard method,
    setting all pieces to their respective initial positions. 
    When a piece is selected through the pieceSelected method, 
    it's verified if the move is valid, and then the piece's valid moves are calculated.

5.  The calculateRawValidMoves method provides all potential moves for a piece.
    The calculateValidMoves method then refines these, removing any that would put the player's own king in check.

In summary, the game logic is organized around a user selecting a piece and making a move,
and the game verifies if the move is valid according to chess rules.

*/

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GameBoard(),
    );
  }
}
