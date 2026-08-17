public class CompareObj {
    private final Object o;

    public CompareObj(Object o) {
        this.o = o;
    }

    public CompareObj isNotNull() {
        if (o == null) {
            throw new RuntimeException();
        }
        return this;
    }

    public CompareObj isNull() {
        if (o != null) {
            throw new RuntimeException();
        }
        return this;
    }

    public CompareObj isEqualTo(Object o2) {
        if (o == null && o2 == null) return this;
        if (o == null || !o.equals(o2)) {
            throw new RuntimeException();
        }
        return this;
    }

    public CompareObj isNotEqualTo(Object o2) {
        if (o == null || o.equals(o2)) {
            throw new RuntimeException();
        }
        return this;
    }

    public CompareObj isInstanceOf(Class<?> c) {
        if (!c.isInstance(o)) {
            throw new RuntimeException();
        }
        return this;
    }

    public CompareObj startsWith(String s2) {
        if (!(o instanceof String) || !((String) o).startsWith(s2)) {
            throw new RuntimeException();
        }
        return this;
    }

    public CompareObj isEmpty() {
        if (!(o instanceof String) || !((String) o).isEmpty()) {
            throw new RuntimeException();
        }
        return this;
    }

    public CompareObj contains(String s2) {
        if (!(o instanceof String) || !((String) o).contains(s2)) {
            throw new RuntimeException();
        }
        return this;
    }

    public CompareObj isEqualTo(boolean b2) {
        if (!(o instanceof Boolean) || ((Boolean) o) != b2) {
            throw new RuntimeException();
        }
        return this;
    }

    public CompareObj isTrue() {
        if (!(o instanceof Boolean) || !((Boolean) o)) {
            throw new RuntimeException();
        }
        return this;
    }

    public CompareObj isFalse() {
        if (!(o instanceof Boolean) || ((Boolean) o)) {
            throw new RuntimeException();
        }
        return this;
    }

    public CompareObj isEqualTo(int i2) {
        if (!(o instanceof Integer) || ((Integer) o) != i2) {
            throw new RuntimeException();
        }
        return this;
    }

    public CompareObj isLessThan(int i2) {
        if (!(o instanceof Integer) || ((Integer) o) >= i2) {
            throw new RuntimeException();
        }
        return this;
    }

    public CompareObj isGreaterThan(int i2) {
        if (!(o instanceof Integer) || ((Integer) o) <= i2) {
            throw new RuntimeException();
        }
        return this;
    }
}

