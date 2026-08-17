
import java.util.*;

class LL {  //linkedlist
  private Cell head;

  private static class Cell {  // inner class; static bounds the scope of var to inside the class
    int elt;
    Cell next;
    static int num; // global variable; only one copy exists and shared by all instances
    Cell(int elt, Cell next) {
      this.elt = elt; this.next = next;
    }
  }

  public void insert(int x) {
    Cell c = new Cell(x, head);
    // c.elt = x;
    // c.next = head;
    head = c;
  }

  public int size() {
    int cnt = 0; //count **important: local variables need initialization
    // Cell cur = head;
    // while (cur != null) {
    //   cnt++;
    //   cur = cur.next;
    // }
    for (Cell cur = head; cur != null; cur = cur.next) {
      cnt++;
    }
    return cnt;
  }

  public boolean equals(LL oth) {
    Cell curr1 = head;
    Cell curr2 = oth.head;

    while(curr1 != null && curr2 != null) {
      if (curr1.elt != curr2.elt) {
        return false;
      }
      curr1 = curr1.next;
      curr2 = curr2.next;
    }
    return (curr1 == null && curr2 == null);
    }
}

class Foo {
  public static void main(String[] args) {
    LL L = new LL();
    L.insert(1);
    L.insert(3);
    System.out.println(L.size());

    LL L2 = new LL();
    L2.insert(1);
    L2.insert(3);
    System.out.println(L == L2); // pointer (physical) equality, false
    System.out.println(L.equals(L2));

    LL L3 = new LL();
    L2.insert(2);
    L3.insert(3);
    
  }
}

class Bar {
  public static void main(String[] args) {
    String s1 = "Hello";
    System.out.println(s1.length());
    String s2 = "world";
    System.out.println(s1.concat(s2));
    String s3 = "Hello";
    System.out.println(s1 == s3);
    System.out.println(s1 == s2);

  }
}

// Java has Garbage collection, automatic memory management


class Boz {
  public static void main(String[] args) {
    LinkedList<Integer> l = new LinkedList<>();
    l.add(2);
    l.add(3);
    System.err.println(l.size());
  }
}