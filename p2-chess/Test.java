import java.util.*;

public class Test {

    // Run "java -ea Test" to run with assertions enabled (If you run
    // with assertions disabled, the default, then assert statements
    // will not execute!)

    public static void test1() {
        // Simple tests to get started
        Board b = Board.theBoard();
        Piece.registerPiece(new PawnFactory());
        Piece p = Piece.createPiece("bp");
        b.addPiece(p, "a3");
        assert b.getPiece("a3") == p;

        try {
            Piece.createPiece("nonsense"); // should throw exception
            assert false;
        } catch (Exception e) {
            // exception was thrown
        }

        try {
            b.addPiece(p, "nonsense"); // should throw exception
            assert false;
        } catch (Exception e) {
            // exception was thrown
        }

        String[] args = {"layout1", "moves1"};
        Chess.main(args);
    }
    // test pawn and move from b2 to a4 and pawn position
    public static void pawn_move_test() {
        Board b = Board.theBoard();
        Piece.registerPiece(new PawnFactory());
        Piece.registerPiece(new PawnFactory());
        Piece p = Piece.createPiece("bp");
        b.addPiece(p, "b2");
        assert b.getPiece("b2") == p;
        b.movePiece("b2", "a4");
        List<String> list = new LinkedList<>();
        list = p.moves(b, "a7");
        System.out.println(list.size());
    }

    // test rook
    public static void rook_move_test() {
        Board b = Board.theBoard();
        b.clear();
        Piece.registerPiece(new RookFactory());
        Piece p = Piece.createPiece("br");
        b.addPiece(p, "a1");
        List<String> list = new LinkedList<>();
        list = p.moves(b, "a1");
        System.out.println(list.size());
    }

    // test queen
    public static void queen_test() {
        Board b = Board.theBoard();
        b.clear();
        Piece.registerPiece(new QueenFactory());
        Piece p = Piece.createPiece("wq");
        b.addPiece(p, "d1");
        List<String> list = new LinkedList<>();
        list = p.moves(b, "d1");
        System.out.println(list.size());
    }
    
    // test bishop with queen in b2
    public static void bishop_test() {
        Board b = Board.theBoard();
        b.clear();
        Piece.registerPiece(new QueenFactory());
        Piece q = Piece.createPiece("wq");
        Piece.registerPiece(new BishopFactory());
         b.addPiece(q, "b2");
        Piece p = Piece.createPiece("wb");
        b.addPiece(p, "c1");
        List<String> list = new LinkedList<>();
        list = p.moves(b, "c1");
        System.out.println(list.size());
    }
    
    // test knight
    public static void knight_test() {
        Board b = Board.theBoard();
        b.clear();
        Piece.registerPiece(new KnightFactory());
        Piece p = Piece.createPiece("wn");
        b.addPiece(p, "d3");
        List<String> list = new LinkedList<>();
        list = p.moves(b, "d3");
        System.out.println(list.size());
    }
    
    // king test
    public static void king_test() {
        Board b = Board.theBoard();
        b.clear();

        // Piece.registerPiece(new BishopFactory());
        Piece.registerPiece(new KingFactory());
        Piece p = Piece.createPiece("wk");
        // Piece bi = Piece.createPiece("wb");
        // b.addPiece(bi, "e2");
        b.addPiece(p, "f5");
        List<String> list = new LinkedList<>();
        list = p.moves(b, "f5");
        System.out.println(list.size());
    }

    
    public static void main(String[] args) {
        // test1();
        // rook_move_test();
        // rook_move_test();
        // queen_test();
        // bishop_test();
        // knight_test();
        king_test();
    }

}