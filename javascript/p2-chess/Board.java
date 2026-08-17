import java.util.*;

public class Board {
    private Piece[][] pieces = new Piece[8][8];
    private static final Board board = new Board();  // Singleton
    private List<BoardListener> listeners = new LinkedList<>();

    private Board() {}

    public static Board theBoard() {
        return board;
    }

    private int colIndex(char col) {
        return col - 'a';
    }

    private int rowIndex(char row) {
        return row - '1';
    }

    private void checkBounds(String loc) {
        if (loc == null || loc.length() != 2)
            throw new IllegalArgumentException("Invalid location: " + loc);
        int c = colIndex(loc.charAt(0));
        int r = rowIndex(loc.charAt(1));
        if (c < 0 || c >= 8 || r < 0 || r >= 8)
            throw new IllegalArgumentException("Out-of-bounds location: " + loc);
    }

    public Piece getPiece(String loc) {
        checkBounds(loc);
        return pieces[colIndex(loc.charAt(0))][rowIndex(loc.charAt(1))];
    }

    public void addPiece(Piece p, String loc) {
        checkBounds(loc);
        int c = colIndex(loc.charAt(0));
        int r = rowIndex(loc.charAt(1));
        if (pieces[c][r] != null) {
            throw new IllegalStateException("Square already occupied at " + loc);
        }
        pieces[c][r] = p;
        // for (BoardListener bl : listeners) bl.onPieceAdded(p, loc);
    }

    public void movePiece(String from, String to) {
        checkBounds(from);
        checkBounds(to);
        int cf = colIndex(from.charAt(0));
        int rf = rowIndex(from.charAt(1));
        int ct = colIndex(to.charAt(0));
        int rt = rowIndex(to.charAt(1));

        Piece p = pieces[cf][rf];
        if (p == null) throw new IllegalStateException("No piece at " + from);

        pieces[ct][rt] = p;
        pieces[cf][rf] = null;
        // for (BoardListener bl : listeners) bl.onPieceMoved(p, from, to);
    }

    public void clear() {
        pieces = new Piece[8][8];
    }

    public void registerListener(BoardListener bl) {
        listeners.add(bl);
    }

    public void removeListener(BoardListener bl) {
        listeners.remove(bl);
    }

    public void removeAllListeners() {
        listeners.clear();
    }

    public void iterate(BoardInternalIterator bi) {
        for (int c = 0; c < 8; c++) {
            for (int r = 0; r < 8; r++) {
                if (pieces[c][r] != null) {
                    String loc = "" + (char)('a' + c) + (char)('1' + r);
                    bi.visit(loc, pieces[c][r]);
                }
            }
        }
    }
}
