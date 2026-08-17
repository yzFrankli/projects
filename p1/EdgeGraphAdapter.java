import java.util.*;

public class EdgeGraphAdapter implements EdgeGraph {

    private Graph g;

    public EdgeGraphAdapter(Graph g) { this.g = g; }

    public boolean addEdge(Edge e) {
      String src = e.getSrc();
      String dst = e.getDst();
      g.addNode(src);
      g.addNode(dst);
      return g.addEdge(src, dst);
    }

    public boolean hasNode(String n) {
      return g.hasNode(n);
    }

    public boolean hasEdge(Edge e) {
      String src = e.getSrc();
      String dst = e.getDst();
	    return g.hasEdge(src, dst);
    }

    public boolean removeEdge(Edge e) {
    String src = e.getSrc();
    String dst = e.getDst();
    // check if both nodes exist
    if (!g.hasNode(src) || !g.hasNode(dst)) {
        return false;
    }
    // try to remove the edge
    boolean removed = g.removeEdge(src, dst);
    if (!removed) {
        return false; // edge didn't exist
    }
    // optionally remove isolated nodes
    if (g.succ(src).isEmpty() && g.pred(src).isEmpty()) {
        g.removeNode(src);
    }
    if (g.succ(dst).isEmpty() && g.pred(dst).isEmpty()) {
        g.removeNode(dst);
    }
    return true;
}

    
    public List<Edge> outEdges(String n) {
      List<Edge> edgeList = new LinkedList<>();
      List<String> strList = new LinkedList<>();
      // get all succ nodes from n
      strList = g.succ(n);
      for (int i = 0; i < strList.size(); i++) {
        Edge e = new Edge(n, strList.get(i));
        edgeList.add(e);
      }
      return edgeList;
    }

    public List<Edge> inEdges(String n) {
      List<Edge> edgeList = new LinkedList<>();
      List<String> strList = new LinkedList<>();
      // get all pred nodes from n
      strList = g.pred(n);
      for (int i = 0; i < strList.size(); i++) {
        Edge e = new Edge(strList.get(i), n);
        edgeList.add(e);
      }
      return edgeList;
    }

    // *TODO: fix this
    public List<Edge> edges() {
      List<String> nodeList = new LinkedList<>();
      List<Edge> edgeList = new LinkedList<>();
      // go through all the nodes
      nodeList = g.nodes();
      for (int i = 0; i < nodeList.size(); i++) {
        // get succ nodes and add to the edgeList
        List<String> succList = new LinkedList<>();
        succList = g.succ(nodeList.get(i));
        for (int j = 0; j < succList.size(); j++) {
          Edge e = new Edge(nodeList.get(i), succList.get(j));
          edgeList.add(e);
        }
      }
      return edgeList;
    }
    // *TODO: fix this
    public EdgeGraph union(EdgeGraph g) {
      Graph graph = new ListGraph();

      // convert edge graph g to graph
      Graph temp = new ListGraph();
      List<Edge>EdgeList = new LinkedList<>();
      EdgeList = g.edges();
      // adding all the edges to temp graph
      for (int i = 0; i < EdgeList.size(); i++) {
        Edge e = EdgeList.get(i);
        temp.addNode(e.getSrc());
        temp.addNode(e.getDst());
        temp.addEdge(e.getSrc(), e.getDst());
      }

      // use union on them
      graph = this.g.union(temp);

      // covert the graph back to edge graph
      EdgeGraph eg = new EdgeGraphAdapter(graph);

      return eg;
    }

    public boolean hasPath(List<Edge> e) {
	    for (int i = 0; i < e.size(); i++) {
        // check if the edges are in the graph
        if (g.hasEdge(e.get(i).getSrc(), e.get(i).getDst()) != true) {
          return false;
        }
        // check if every edge is a path
        if (i != e.size() - 1) {
          if (!e.get(i).getDst().equals(e.get(i+1).getSrc())) {
            throw new BadPath();
          }
        }
      }
      return true;
    }

}
