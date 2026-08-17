import java.util.*;

public class Rook extends Piece {
    public Rook(Color c) { 
        color = c;
    }
    // implement appropriate methods
    private void addLoc(List<String> list, int col_add, 
                        int row_add, String loc, Board b) 
        {
        char col = loc.charAt(0);
        char row = loc.charAt(1);

        while (true) {
                col += col_add;
                row += row_add;
                if (col < 'a' || col > 'h' || row < '1' || row > '8') {
                break;
                }
                Piece piece = b.getPiece("" + col + row);
                if (piece == null) {
                list.add("" + col + row);
                } else {
                if (piece.color() != color) {
                        list.add("" + col + row); // can capture
                }
                break; // stop regardless of color
                }
        }
    }

//     private boolean checkLoc(Board b, char col, char row) {
//         Piece piece = b.getPiece("" + col + row);
//         if (piece == null) {
//                 return true;
//         }
//         return piece.color() != color;
//     }

    public String toString() {
	String colorChar = color == Color.BLACK ? "b" : "w";
        return colorChar + "r";
    }

    public List<String> moves(Board b, String loc) {
        List<String> moveList = new LinkedList<>();
        // vertical
        addLoc(moveList, 0, 1, loc, b);
        addLoc(moveList, 0, -1, loc, b);

        // horizontal
        addLoc(moveList, 1, 0, loc, b);
        addLoc(moveList, -1, 0, loc, b);

	return moveList;
    }

}