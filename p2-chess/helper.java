public class helper {
        public static String locToString(int col, int row) {
                char colStr = "abcdefg".charAt(col);
                char rowStr = "12345678".charAt(row);
                return "" + colStr + rowStr;
        }
}
