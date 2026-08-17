import java.util.*;

abstract public class Piece {
    protected Color color;
    private static final HashMap<Character, PieceFactory> pieceFactories = new HashMap<>();

//     protected Piece(Color color) {
//         this.color = color;
//     }

    public static void registerPiece(PieceFactory pf) {
	// throw new UnsupportedOperationException();
        Character key = pf.symbol();
        pieceFactories.put(key, pf);
    }

    public static Piece createPiece(String name) {
        // check length
        if (name.length() != 2) {
	        throw new UnsupportedOperationException();
        }
        Color color;
        if (name.charAt(0) == 'w') {
                color = Color.WHITE;
        } else if (name.charAt(0) == 'b') {
                color = Color.BLACK;
        } else {
                throw new UnsupportedOperationException();
        }
        // check if key is registered
        char key = name.charAt(1);
        if (!pieceFactories.containsKey(key)) {
                throw new UnsupportedOperationException();
        }
        return pieceFactories.get(key).create(color);
    }

    public Color color() {
	// You should write code here and just inherit it in
	// subclasses. For this to work, you should know
	// that subclasses can access superclass fields.
        return color;

    }

    abstract public String toString();

    abstract public List<String> moves(Board b, String loc);
}