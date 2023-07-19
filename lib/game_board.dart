import 'package:flutter/material.dart';
import 'components/dead_piece.dart';
import 'components/piece.dart';
import 'components/square.dart';
import 'helper/helper_methods.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  // A 2-dimensional list representing the chess board, with each element
  // possibly containing a reference to a ChessPiece.
  late List<List<ChessPiece?>> board;

  // The currently selected piece on the chess board. If no piece is selected, this is null.
  ChessPiece? selectedPiece;

  // The row index of the selected piece on the board.
  // Default value -1 indicates no piece is currently selected.
  int selectedRow = -1;

  // The column index of the selected piece on the board.
  // Default value -1 indicates no piece is currently selected.
  int selectedCol = -1;

  // A list of valid moves for the currently selected piece.
  // Each move is represented as a list with two elements: row and column indices.
  List<List<int>> validMoves = [];

  // A boolean indicating whose turn it is to play: true for white, false for black.
  bool isWhiteTurn = true;

  // A list of white pieces that have been taken by the black player.
  List<ChessPiece> whitePiecesTaken = [];

  // A list of black pieces that have been taken by the white player.
  List<ChessPiece> blackPiecesTaken = [];

  // A boolean to see if a king is in check
  bool checkStatus = false;

  // initial position for kings
  List<int> whiteKingPosition = [7, 4];
  List<int> blackKingPosition = [0, 4];

  @override
  void initState() {
    super.initState();
    _initializeBoard();
  }

  // INITIALIZE BOARD
  void _initializeBoard() {
    // Initialize the board with nulls, meaning no pieces
    List<List<ChessPiece?>> newBoard =
        List.generate(8, (_) => List.generate(8, (_) => null));

    // Place pawns
    for (int i = 0; i < 8; i++) {
      newBoard[1][i] = ChessPiece(
          type: ChessPieceType.pawn,
          isWhite: false,
          imagePath: 'lib/images/pawn.png');
      newBoard[6][i] = ChessPiece(
          type: ChessPieceType.pawn,
          isWhite: true,
          imagePath: 'lib/images/pawn.png');
    }

    // Place rooks
    newBoard[0][0] = ChessPiece(
        type: ChessPieceType.rook,
        isWhite: false,
        imagePath: 'lib/images/rook.png');
    newBoard[0][7] = ChessPiece(
        type: ChessPieceType.rook,
        isWhite: false,
        imagePath: 'lib/images/rook.png');
    newBoard[7][0] = ChessPiece(
        type: ChessPieceType.rook,
        isWhite: true,
        imagePath: 'lib/images/rook.png');
    newBoard[7][7] = ChessPiece(
        type: ChessPieceType.rook,
        isWhite: true,
        imagePath: 'lib/images/rook.png');

    // Place knights
    newBoard[0][1] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: false,
        imagePath: 'lib/images/knight.png');
    newBoard[0][6] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: false,
        imagePath: 'lib/images/knight.png');
    newBoard[7][1] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: true,
        imagePath: 'lib/images/knight.png');
    newBoard[7][6] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: true,
        imagePath: 'lib/images/knight.png');

    // Place bishops
    newBoard[0][2] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: false,
        imagePath: 'lib/images/bishop.png');
    newBoard[0][5] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: false,
        imagePath: 'lib/images/bishop.png');
    newBoard[7][2] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: true,
        imagePath: 'lib/images/bishop.png');
    newBoard[7][5] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: true,
        imagePath: 'lib/images/bishop.png');

    // Place queens
    newBoard[0][3] = ChessPiece(
        type: ChessPieceType.queen,
        isWhite: false,
        imagePath: 'lib/images/queen.png');
    newBoard[7][3] = ChessPiece(
        type: ChessPieceType.queen,
        isWhite: true,
        imagePath: 'lib/images/queen.png');

    // Place kings
    newBoard[0][4] = ChessPiece(
        type: ChessPieceType.king,
        isWhite: false,
        imagePath: 'lib/images/king.png');
    newBoard[7][4] = ChessPiece(
        type: ChessPieceType.king,
        isWhite: true,
        imagePath: 'lib/images/king.png');

    board = newBoard;
  }

  // USER SELECTED A PIECE
  void pieceSelected(int row, int col) {
    setState(() {
      // No piece has been selected yet, this is the first selection
      if (selectedPiece == null && board[row][col] != null) {
        // if the square you are selecting is white and it's white turn, user can select it
        if (board[row][col]!.isWhite == isWhiteTurn) {
          selectedPiece = board[row][col];
          selectedRow = row;
          selectedCol = col;
        }
      }
      // There is already a piece selected, but user can select another one of their pieces
      else if (board[row][col] != null &&
          board[row][col]!.isWhite == selectedPiece!.isWhite) {
        selectedPiece = board[row][col];
        selectedRow = row;
        selectedCol = col;
      }
      // There is a piece selected and the square clicked is a valid move
      else if (selectedPiece != null &&
          validMoves.any((element) => element[0] == row && element[1] == col)) {
        movePiece(row, col);
      }

      // If a piece is selected after the first selection, calculate its valid moves
      if (selectedPiece != null) {
        validMoves =
            calculateValidMoves(selectedRow, selectedCol, selectedPiece, true);
      }
    });
  }

  // CALCULATE RAW VALID MOVES
  List<List<int>> calculateRawValidMoves(int row, int col, ChessPiece? piece) {
    List<List<int>> candidateMoves = [];

    // different directions based on their color
    int direction = piece!.isWhite ? -1 : 1;

    switch (piece.type) {
      case ChessPieceType.pawn:
        // implement pawn logic
        // pawns can move forward if the square is not occupied
        if (isInBoard(row + direction, col) &&
            board[row + direction][col] == null) {
          candidateMoves.add([row + direction, col]);
        }

        // Pawns can move two squares forward if they are at their initial positions
        if ((row == 1 && !piece.isWhite) || (row == 6 && piece.isWhite)) {
          if (isInBoard(row + 2 * direction, col) &&
              board[row + 2 * direction][col] == null &&
              board[row + direction][col] == null) {
            candidateMoves.add([row + 2 * direction, col]);
          }
        }

        // Pawns can capture pieces diagonally
        if (isInBoard(row + direction, col - 1) &&
            board[row + direction][col - 1] != null &&
            board[row + direction][col - 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col - 1]);
        }
        if (isInBoard(row + direction, col + 1) &&
            board[row + direction][col + 1] != null &&
            board[row + direction][col + 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col + 1]);
        }

        break;
      case ChessPieceType.rook:
        // horizontal and vertical directions
        var directions = [
          [-1, 0], // up
          [1, 0], // down
          [0, -1], // left
          [0, 1], // right
        ];

        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]); // capture
              }
              break; // blocked
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;

      case ChessPieceType.knight:
        // all eight possible L shapes the knight can move
        var knightMoves = [
          [-2, -1], // up 2 left 1
          [-2, 1], // up 2 right 1
          [-1, -2], // up 1 left 2
          [-1, 2], // up 1 right 2
          [1, -2], // down 1 left 2
          [1, 2], // down 1 right 2
          [2, -1], // down 2 left 1
          [2, 1], // down 2 right 1
        ];

        for (var move in knightMoves) {
          var newRow = row + move[0];
          var newCol = col + move[1];
          if (!isInBoard(newRow, newCol)) {
            continue;
          }
          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]); // capture
            }
            continue; // blocked
          }
          candidateMoves.add([newRow, newCol]);
        }

        break;

      case ChessPieceType.bishop:
        // diagonal directions
        var directions = [
          [-1, -1], // up left
          [-1, 1], // up right
          [1, -1], // down left
          [1, 1], // down right
        ];

        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]); // capture
              }
              break; // blocked
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;

      case ChessPieceType.queen:
        // all eight directions: up, down, left, right, and the four diagonals
        var directions = [
          [-1, 0], // up
          [1, 0], // down
          [0, -1], // left
          [0, 1], // right
          [-1, -1], // up left
          [-1, 1], // up right
          [1, -1], // down left
          [1, 1], // down right
        ];

        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]); // capture
              }
              break; // blocked
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;

      case ChessPieceType.king:
        // all eight directions: up, down, left, right, and the four diagonals
        var directions = [
          [-1, 0], // up
          [1, 0], // down
          [0, -1], // left
          [0, 1], // right
          [-1, -1], // up left
          [-1, 1], // up right
          [1, -1], // down left
          [1, 1], // down right
        ];

        for (var direction in directions) {
          var newRow = row + direction[0];
          var newCol = col + direction[1];
          if (!isInBoard(newRow, newCol)) {
            continue;
          }
          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]); // capture
            }
            continue; // blocked
          }
          candidateMoves.add([newRow, newCol]);
        }

        break;
    }

    return candidateMoves;
  }

  // CALCULATE REAL VALID MOVES
  List<List<int>> calculateValidMoves(
      int row, int col, ChessPiece? piece, bool checkSimulation) {
    List<List<int>> validMoves = [];
    List<List<int>> candidateMoves = calculateRawValidMoves(row, col, piece);

    // After generating all candidate moves for the piece, filter out any that would result in check.
    if (checkSimulation) {
      for (List<int> candidateMove in candidateMoves) {
        int endRow = candidateMove[0];
        int endCol = candidateMove[1];
        if (simulatedMoveIsSafe(piece!, row, col, endRow, endCol)) {
          validMoves.add(candidateMove);
        }
      }
    } else {
      validMoves = candidateMoves;
    }

    return validMoves;
  }

  // MOVE PIECE TO NEW POSITION
  void movePiece(int newRow, int newCol) {
    // if the new spot has a piece
    if (board[newRow][newCol] != null) {
      // Add the captured piece to the appropriate list.
      var capturedPiece = board[newRow][newCol];
      if (capturedPiece!.isWhite) {
        whitePiecesTaken.add(capturedPiece);
      } else {
        blackPiecesTaken.add(capturedPiece);
      }
    }

    // Check if the piece being moved is a King
    if (selectedPiece!.type == ChessPieceType.king) {
      // Update the appropriate King position
      if (selectedPiece!.isWhite) {
        whiteKingPosition = [newRow, newCol];
      } else {
        blackKingPosition = [newRow, newCol];
      }
    }

    // Move the piece and clear the old spot
    board[newRow][newCol] = selectedPiece;
    board[selectedRow][selectedCol] = null;

    // see if any kings are under attack
    if (isKingInCheck(!isWhiteTurn)) {
      checkStatus = true;
    } else {
      checkStatus = false;
    }

    // Clear the selection
    setState(() {
      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];
    });

    // change turns
    isWhiteTurn = !isWhiteTurn;

    // check if it's check mate
    if (isCheckMate(isWhiteTurn)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            "CHECK MATE!",
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            // play again button
            TextButton(
              onPressed: resetGame,
              child: const Text("Play Again"),
            )
          ],
        ),
      );
    }
  }

  // CHECK IF KING IS IN CHECK
  bool isKingInCheck(bool isWhiteKing) {
    // Get the position of the King
    List<int> kingPosition =
        isWhiteKing ? whiteKingPosition : blackKingPosition;

    // Check if any enemy piece can attack the King
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        // Skip empty squares and pieces of the same color as the King
        if (board[i][j] == null || board[i][j]!.isWhite == isWhiteKing) {
          continue;
        }

        List<List<int>> pieceValidMoves =
            calculateValidMoves(i, j, board[i][j], false);

        // Check if the King's position is in this piece's valid moves
        if (pieceValidMoves.any((move) =>
            move[0] == kingPosition[0] && move[1] == kingPosition[1])) {
          return true;
        }
      }
    }

    return false;
  }

  // SIMULATE A FUTURE MOVE TO SEE IF IT'S SAFE (DOESN'T PUT YOUR KING UNDER ATTACK!)
  bool simulatedMoveIsSafe(
      ChessPiece piece, int startRow, int startCol, int endRow, int endCol) {
    // Save the current board state
    ChessPiece? originalDestinationPiece = board[endRow][endCol];

    // If the piece is the king, save its current position and update to the new one
    List<int>? originalKingPosition;
    if (piece.type == ChessPieceType.king) {
      originalKingPosition =
          piece.isWhite ? whiteKingPosition : blackKingPosition;

      // Update the king's position
      if (piece.isWhite) {
        whiteKingPosition = [endRow, endCol];
      } else {
        blackKingPosition = [endRow, endCol];
      }
    }

    // Simulate the move
    board[endRow][endCol] = piece;
    board[startRow][startCol] = null;

    // Check if our own king is in check
    bool kingInCheck = isKingInCheck(piece.isWhite);

    // Restore the board to its original state
    board[startRow][startCol] = piece;
    board[endRow][endCol] = originalDestinationPiece;

    // If the piece was the king, restore its original position
    if (piece.type == ChessPieceType.king) {
      if (piece.isWhite) {
        whiteKingPosition = originalKingPosition!;
      } else {
        blackKingPosition = originalKingPosition!;
      }
    }

    return !kingInCheck;
  }

  // IS IT CHECK MATE?
  bool isCheckMate(bool isWhiteKing) {
    // If the king is not in check, then it's not checkmate.
    if (!isKingInCheck(isWhiteKing)) {
      return false;
    }

    // If there is at least one legal move for any of the player's pieces, then it's not checkmate.
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        // Skip empty squares and pieces of the other color
        if (board[i][j] == null || board[i][j]!.isWhite != isWhiteKing) {
          continue;
        }

        List<List<int>> pieceValidMoves =
            calculateValidMoves(i, j, board[i][j], true);

        // If this piece has any valid moves, then it's not checkmate.
        if (pieceValidMoves.isNotEmpty) {
          return false;
        }
      }
    }

    // If we haven't returned yet, then there are no legal moves and it is checkmate.
    return true;
  }

  // GAME IS OVER, RESET GAME
  void resetGame() {
    Navigator.pop(context);
    _initializeBoard();
    checkStatus = false;
    whitePiecesTaken.clear();
    blackPiecesTaken.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[600],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // WHITE PIECES TAKEN
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                itemCount: whitePiecesTaken.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8),
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) => DeadPiece(
                  imagePath: whitePiecesTaken[index].imagePath,
                  isWhite: true,
                ),
              ),
            ),
          ),

          // GAME STATUS
          Text(
            checkStatus ? "CHECK!" : "",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.grey[800],
            ),
          ),

          // CHESS BOARD
          Expanded(
            flex: 3,
            child: GridView.builder(
              itemCount: 8 * 8,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8),
              itemBuilder: (context, index) {
                // get the row and col position of the square
                int row = index ~/ 8;
                int col = index % 8;

                // check if this square is selected
                bool isSelected = row == selectedRow && col == selectedCol;

                // check if this square is a valid move
                bool isValidMove = false;
                for (var position in validMoves) {
                  // compare row and col
                  if (position[0] == row && position[1] == col) {
                    isValidMove = true;
                  }
                }

                return Square(
                  isWhite: isWhite(index),
                  piece: board[row][col],
                  onTap: () => pieceSelected(row, col),
                  isSelected: isSelected,
                  isValidMove: isValidMove,
                );
              },
            ),
          ),

          // BLACK PIECES TAKEN
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                itemCount: blackPiecesTaken.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8),
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) => DeadPiece(
                  imagePath: blackPiecesTaken[index].imagePath,
                  isWhite: false,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
