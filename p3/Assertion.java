public class Assertion {

    public static CompareObj assertThat(Object o) {
        return new CompareObj(o);
    }

    public static CompareObj assertThat(String s) {
        return new CompareObj(s);
    }

    public static CompareObj assertThat(boolean b) {
        return new CompareObj(b);
    }

    public static CompareObj assertThat(int i) {
        return new CompareObj(i);
    }
}

// --------------------------------------------------

