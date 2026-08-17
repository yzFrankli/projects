import java.util.*;

public class Pawn extends Piece {
    public Pawn(Color c) { 
        color = c;
    }

    private boolean checkLoc(Board b, char col, char row) {
        if (!inBounds(col, row)) return false;
        return b.getPiece("" + col + row) == null;
    }

    private boolean checkColor(Board b, char col, char row) {
        if (!inBounds(col, row)) return false;
        Piece target = b.getPiece("" + col + row);
        return target != null && target.color() != color;
    }

    private boolean inBounds(char col, char row) {
        return col >= 'a' && col <= 'h' && row >= '1' && row <= '8';
    }

    public String toString() {
        return (color == Color.BLACK ? "b" : "w") + "p";
    }

    public List<String> moves(Board b, String loc) {
        List<String> moveList = new LinkedList<>();
        char col = loc.charAt(0);
        char row = loc.charAt(1);

        if (color == Color.BLACK) {
            if (checkLoc(b, col, (char)(row - 1))) moveList.add("" + col + (char)(row - 1));
            if (checkColor(b, (char)(col + 1), (char)(row - 1))) moveList.add("" + (char)(col + 1) + (char)(row - 1));
            if (checkColor(b, (char)(col - 1), (char)(row - 1))) moveList.add("" + (char)(col - 1) + (char)(row - 1));
            if (row == '7') moveList.add("" + (char)(col)+ (char)(row - 2));
        } else {
            if (checkLoc(b, col, (char)(row + 1))) moveList.add("" + col + (char)(row + 1));
            if (checkColor(b, (char)(col + 1), (char)(row + 1))) moveList.add("" + (char)(col + 1) + (char)(row + 1));
            if (checkColor(b, (char)(col - 1), (char)(row + 1))) moveList.add("" + (char)(col - 1) + (char)(row + 1));
            if (row == '2') moveList.add("" + (char)(col) + (char)(row + 2));
        }

        return moveList;
    }
}
