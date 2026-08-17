import java.io.File;
import java.io.FileNotFoundException;
import java.util.*;

import javax.naming.OperationNotSupportedException;

public class Chess {
    public static void main(String[] args) {
        if (args.length != 2) {
            System.out.println("Usage: java Chess layout moves");
        }
        Piece.registerPiece(new KingFactory());
        Piece.registerPiece(new QueenFactory());
        Piece.registerPiece(new KnightFactory());
        Piece.registerPiece(new BishopFactory());
        Piece.registerPiece(new RookFactory());
        Piece.registerPiece(new PawnFactory());
        Board.theBoard().registerListener(new Logger());
        // args[0] is the layout file name
        // args[1] is the moves file name
        // Put your code to read the layout file and moves files
        // here.

        // reading the layout file
        File layoutFile = new File(args[0]);

        if (layoutFile.length() != 0) {
               try (Scanner myReader = new Scanner(layoutFile)) {
                while (myReader.hasNextLine()) {
                        String data = myReader.nextLine();
                        // ignore comments
                        if (data.charAt(0) == '#') {
                                continue;
                        }
                        if (data.length() != 5) {
                                throw new UnsupportedOperationException();
                        }
                        // check for requirements         
                        if (!(data.charAt(0) >= 'a' && data.charAt(0) <= 'h') ||
                            !(data.charAt(1) >= '1' && data.charAt(1) <= '8') ||
                            !(data.charAt(3) == 'b' || data.charAt(3) == 'w') ||
                            !(data.charAt(4) == 'k' || data.charAt(4) == 'q'  || 
                            data.charAt(4) == 'n' || data.charAt(4) == 'b' || data.charAt(4) == 'r' 
                            || data.charAt(4) == 'p'))
                        {
                                throw new UnsupportedOperationException();
                        }
                        String splitArray[] = data.split("=", 2);
                        Piece piece = Piece.createPiece(splitArray[1]);
                        Board.theBoard().addPiece(piece, splitArray[0]);
                
                }
                } catch (FileNotFoundException e) {
                        throw new UnsupportedOperationException();
                } 
        }
        //TODO: check if layout doesn't have duplicates and moves are all valid per spec provided
        File movFile = new File(args[1]);

        if (movFile.length() != 0) {
                try (Scanner myReader = new Scanner(movFile)) {
                while (myReader.hasNextLine()) {
                        String data = myReader.nextLine();
                        // ignore comments
                        if (data.charAt(0) == '#') {
                                continue;
                        }
                        if (data.length() != 5) {
                                throw new UnsupportedOperationException();
                        }
                        // check for requirements
                        if (!(data.charAt(0) >= 'a' && data.charAt(0) <= 'h') || 
                            !(data.charAt(3) >= 'a' && data.charAt(3) <= 'h') ||
                            !(data.charAt(1) >= '1' && data.charAt(1) <= '8') ||
                            !(data.charAt(4) >= '1' && data.charAt(4) <= '8')) 
                        {
                                throw new UnsupportedOperationException();
                        }

                        String splitArray[] = data.split("-", 2);
                        Board.theBoard().movePiece(splitArray[0], splitArray[1]);
                }
                } catch (FileNotFoundException e) {
                        throw new UnsupportedOperationException();
                } 
        }
        
        

        // Leave the following code at the end of the simulation:
        System.out.println("Final board:");
        Board.theBoard().iterate(new BoardPrinter());
        // IMPORTANT: Do not clean up or otherwise reset the board state here.
   }
}