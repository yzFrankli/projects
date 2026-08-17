import java.util.*;

public class Knight extends Piece {
    public Knight(Color c) { 
        color = c;
    }

    // implement appropriate methods
    private void addloc(Board b, List<String> list, char col, char row) {
        // check if col and row are out of bounds
        if (col > 'h' || col < 'a') {
                return;
        }
        if (row > '8' || row < '1') {
                return;
        }
        // check if there is a piece (same color) there
        Piece target = b.getPiece("" + col + row);
        if (target != null && target.color() == color) {
                return;
        }

        // add to list
        list.add("" + col + row);
    }

    public String toString() {
	String colorChar = color == Color.BLACK ? "b" : "w";
        return colorChar + "n";
    }

    public List<String> moves(Board b, String loc) {
	List<String> moveList = new LinkedList<>();
        char col = loc.charAt(0);
        char row = loc.charAt(1);

        addloc(b, moveList, (char)((int)col + 2), (char)((int)row + 1));
        addloc(b, moveList, (char)((int)col + 2), (char)((int)row - 1));

        addloc(b, moveList, (char)((int)col + 1), (char)((int)row + 2));
        addloc(b, moveList, (char)((int)col + 1), (char)((int)row - 2));

        addloc(b, moveList, (char)((int)col - 2), (char)((int)row + 1));
        addloc(b, moveList, (char)((int)col - 2), (char)((int)row - 1));

        addloc(b, moveList, (char)((int)col - 1), (char)((int)row + 2));
        addloc(b, moveList, (char)((int)col - 1), (char)((int)row - 2));
        
        return moveList;
    }

}