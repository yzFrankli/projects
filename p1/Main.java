import java.util.*;

public class Main {

    // Run "java -ea Main" to run with assertions enabled (If you run
    // with assertions disabled, the default, then assert statements
    // will not execute!)
    
    // test adding single node
    public static void AddNode_test() {
      Graph g = new ListGraph();
      assert g.addNode("a") == true;
      assert g.hasNode("a");
    }

    // test adding the same node twice
    public static void AddNode_double_test() {
      Graph g = new ListGraph();
      assert g.addNode("a");
      assert g.addNode("a") == false;
      assert g.hasNode("a");
    }

    // test adding and checking edge
    public static void AddEdges_test() {
      Graph g = new ListGraph();
      // assert g.addEdge("a", "b");
      assert g.addNode("a");
      assert g.addNode("b");
      assert g.addEdge("a", "b");
      assert g.hasEdge("a", "b");
    }

    // test removing nodes
    public static void RemoveNode_test() {
      Graph g = new ListGraph();
      assert g.removeNode("a") == false;
      assert g.addNode("a");
      assert g.removeNode("a");
    }
    
    // test removing edges
    public static void RemoveEdge_test() {
      Graph g = new ListGraph();
      assert g.addNode("a");
      assert g.addNode("b");
      assert g.addEdge("a", "b");
      assert g.removeEdge("a", "b");
      assert g.removeEdge("b", "a") == false;
    }

    // test getting the nodes list
    public static void NodeList_test() {
      Graph g = new ListGraph();
      // add nodes to the graph
      assert g.addNode("a");
      assert g.addNode("b");
      assert g.hasNode("a");
      assert g.hasNode("b");
      // get the list of the nodes in the graph as an array
      List<String> NodeList = new LinkedList<String>();
      NodeList = g.nodes();
      // check if the size is correct
      assert NodeList.size() == 2;
    }

    // test getting successive nodes for n as a list
    public static void GetSucc_test() {
      Graph g = new ListGraph();
      g.addNode("a");
      g.addNode("b");
      g.addNode("c");
      g.addEdge("a", "b");
      g.addEdge("a", "c");
      List<String> list = g.succ("a");
      assert list.size() == 2;

      // try getting an error
      try {
        g.succ("d");
      }
      catch(Exception NoSuchElementException) {}
    }

    // test getting the predecessors of n as a list 
    public static void GetPred_test() {
      Graph g = new ListGraph();
      g.addNode("a");
      g.addNode("b");
      g.addNode("c");
      g.addEdge("a", "b");
      g.addEdge("c", "b");
      List<String> list = g.pred("b");
      // for (int i = 0; i < list.size(); i++) {
        // System.out.println(list.get(i));
      // }
    }

    // test union 
    public static void Union_test() {
      Graph g1 = new ListGraph();
      Graph g2 = new ListGraph();
      g1.addNode("a");
      g1.addNode("b");
      g1.addNode("c");
      g2.addNode("d");
      g2.addNode("e");
      g1.addEdge("a", "b");
      g1.addEdge("c", "b");
      g2.addEdge("d", "e");

      Graph g3 = g1.union(g2);
      assert g3.hasNode("a");
      assert g3.hasNode("b");
      assert g3.hasNode("c");
      assert g3.hasNode("d");
      assert g3.hasNode("e");
      assert g3.hasEdge("a", "b");
      assert g3.hasEdge("d", "e");
    }

    // test subgraph
    public static void Subgraph_test() {
      Graph g = new ListGraph();
      g.addNode("a");
      g.addNode("b");
      g.addNode("c");
      g.addEdge("a", "b");
      g.addEdge("c", "b");
      Set<String> set = new HashSet<>();
      set.add("a");
      set.add("b");
      Graph newG = new ListGraph();
      newG = g.subGraph(set);
      assert newG.hasNode("a");
      assert newG.hasNode("b");
      assert newG.hasEdge("a", "b");
      assert newG.hasNode("c") == false;
    }


    // test connect path
    public static void Connect_test() {
      Graph g = new ListGraph();
      g.addNode("a");
      g.addNode("b");
      g.addNode("c");
      g.addNode("d");
      g.addEdge("a", "b");
      g.addEdge("c", "d");
      g.addEdge("a", "c");
      assert g.connected("a", "c");
      assert g.connected("c", "a") == false;
      assert g.connected("a", "d");
      g.removeEdge("a", "b");
      g.removeEdge("c", "d");
      g.removeEdge("a", "c");

      Graph g2 = new ListGraph();
      g.addNode("a");
      g.addNode("b");
      g.addNode("c");
      assert g.hasNode("a");
      // g2.addEdge("a", "a");
      g2.addEdge("b", "b");
      g2.addEdge("c", "c");
      assert g.connected("a", "a");
      assert g.connected("a", "b") == false;
      assert g.connected("c", "c");
    }

    // test adding single node
    public static void AddNode_Edge_test() {
      Graph g = new ListGraph();
      EdgeGraphAdapter eg = new EdgeGraphAdapter(g);
      Edge e = new Edge("a", "b");
      eg.addEdge(e);
      assert eg.hasEdge(e);
      assert eg.hasNode("a");
      assert eg.hasNode("b");
    }

    // test union on two graphs
    public static void Union_Edge_test() {
      Graph g = new ListGraph();
      EdgeGraphAdapter eg = new EdgeGraphAdapter(g);

      Graph g2 = new ListGraph();
      EdgeGraphAdapter eg2 = new EdgeGraphAdapter(g2);
      Edge e = new Edge("a", "b");
      Edge e2 = new Edge("b", "c");
      Edge e3 = new Edge("c", "d");

      eg.addEdge(e);
      eg.addEdge(e2);
      eg2.addEdge(e3);
      EdgeGraph eg3 = eg.union(eg2);
      assert eg3.hasEdge(e);
      assert eg3.hasEdge(e2);
      assert eg3.hasEdge(e3);
    }

    // remove edge
    public static void Remove_Edge_test() {
      Graph g = new ListGraph();
      EdgeGraphAdapter eg = new EdgeGraphAdapter(g);

      // test removing the last two nodes
      Edge e = new Edge("a", "b");
      Edge e2 = new Edge("b", "c");
      assert eg.addEdge(e);
      assert eg.removeEdge(e);
      assert eg.hasNode("a") == false;
      assert eg.hasNode("b") == false;
      assert eg.hasEdge(e) == false;
      assert eg.hasEdge(e) == false;

      assert eg.addEdge(e);
      assert eg.addEdge(e2);

      assert eg.removeEdge(e2);
      assert eg.removeEdge(e);

      // test edget to itself
      Edge e3 = new Edge("a", "a");
      assert eg.addEdge(e3);
      assert eg.removeEdge(e3);
      assert eg.hasEdge(e3) == false;
    }

    // test connect 
    public static void Connect_Edge_test() {
      Graph g = new ListGraph();
      EdgeGraphAdapter eg = new EdgeGraphAdapter(g);
     
      Edge e = new Edge("a", "b");
      Edge e2 = new Edge("a", "c");
      List<Edge> edgeList = new LinkedList<>();
      assert eg.addEdge(e);
      assert edgeList.add(e);
      assert edgeList.add(e2);
      try {
        eg.hasPath(edgeList);
      } catch (Exception BadPath) {}
    }

    public static void Large_Union_Edge_test() {
     
    }


    public static void main(String[] args) {
      /* ListGraph tests */
//       AddNode_test();
//       AddNode_double_test();
//       AddEdges_test();
//       RemoveNode_test();
//       NodeList_test();
//       GetSucc_test();
//       GetPred_test();
//       Union_test();
//       Subgraph_test();
//       Connect_test();

//       /* EdgeGraph tests */
//       AddNode_Edge_test();
//       Union_Edge_test();
//       Connect_Edge_test();
//       Remove_Edge_test();

    }

}