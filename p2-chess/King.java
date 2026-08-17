import java.util.*;

public class King extends Piece {
    public King(Color c) { 
        color = c;
    }
    // implement appropriate methods

    public String toString() {
        String colorChar = color == Color.BLACK ? "b" : "w";
        return colorChar + "k";
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

    public List<String> moves(Board b, String loc) {
	List<String> moveList = new LinkedList<>();
        // king moves one adjacent square in any direction
        // get the row and col of the loc
        char col = loc.charAt(0); // letter
        char row = loc.charAt(1); // num

        // check for corners using ascii
        addloc(b, moveList, (char)((int)col), (char)((int)row + 1));
        addloc(b, moveList, (char)((int)col), (char)((int)row - 1));
        addloc(b, moveList, (char)((int)col + 1), (char)((int)row));
        addloc(b, moveList, (char)((int)col - 1), (char)((int)row));
        addloc(b, moveList, (char)((int)col - 1), (char)((int)row - 1));
        addloc(b, moveList, (char)((int)col + 1), (char)((int)row + 1));
         addloc(b, moveList, (char)((int)col - 1), (char)((int)row + 1));
          addloc(b, moveList, (char)((int)col + 1), (char)((int)row - 1));

        // check for same color pieces
        return moveList;
        
    }

}