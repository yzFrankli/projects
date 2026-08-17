import java.util.*;

public class ListGraph implements Graph {
    private HashMap<String, LinkedList<String>> nodes = new HashMap<>();

    // add a node with string n as a key to the hashmap
    public boolean addNode(String n) {
      // get the key; if exist return false
      if (nodes.get(n) != null) {
        return false;
      } 
      // otherwise add key and return true
      else {
        LinkedList<String> valList = new LinkedList<String>();
        nodes.put(n, valList);
        return true;
      }
    }

    // add an edge to the graph from n1 to n2
    public boolean addEdge(String n1, String n2) {
	    // check if source node already exist; 
      LinkedList<String> srcEdges = nodes.get(n1);
      LinkedList<String> dstEdges = nodes.get(n2);
      if (srcEdges == null || dstEdges == null) {
        throw new NoSuchElementException();
      }
      // if edge already exist return false; otherwise true
        for (int i = 0; i < srcEdges.size(); i++) {
          // if edge exist, return false
          if (srcEdges.get(i).equals(n2)) {
            return false;
          }
        }
        // if edge doesn't exist, add edge
        srcEdges.add(n2);
        return true;
    }

    // check if the graph has the node n
    public boolean hasNode(String n) {
      // return true if it is in the hashtable
      if (nodes.get(n) != null) {
        return true;
      } 
	    // otherwise return false
      else {
        return false;
      }
    }

    // check if the graph has an edge from n1 to n2
    public boolean hasEdge(String n1, String n2) {
	    // check if the node exists
      LinkedList<String> edges = nodes.get(n1);
      if (edges != null) {
      // if exists, check if edge exists
        for (int i = 0; i < edges.size(); i++) {
          // if edge exist, return true
          if (edges.get(i) == n2) {
            return true;
          }
        }
        return false;
      } else {
        return false;
      }
    }
    // remove the node n from the graph
    public boolean removeNode(String n) {
	    // check if node exist; remove if exist, return false if not
      if (nodes.get(n) != null) {
        // check if there is any predecessor nodes before removing
        for (LinkedList<String> list : nodes.values()) {
          // loop thru the list and remove any n nodes
          Iterator<String> it = list.iterator();
          while (it.hasNext()) {
              if (it.next().equals(n)) {
                  it.remove();
              }
            }
        }
        nodes.remove(n);
        return true;
      } else {
        return false;
      }
    }


    // remove the edge n1 to n2 from the graph
    public boolean removeEdge(String n1, String n2) {
      LinkedList<String> srcEdges = nodes.get(n1);
      LinkedList<String> dstEdges = nodes.get(n2);
      if (srcEdges == null || dstEdges == null) {
        throw new NoSuchElementException();
      }
	    // if edge exists remove it, otherwise return false
      for (int i = 0; i < srcEdges.size(); i++) {
        if (srcEdges.get(i) == n2) {
          srcEdges.remove(i);
          return true;
        }
      }
      return false;
    }

    // return a list of nodes in the graph as an array
    public List<String> nodes() {
      // initialize a list to store the keys
      List<String> list = new LinkedList<String>();
      // initialize a set to store the keys
      Set<String> s = new HashSet<>();
      s = nodes.keySet();
      // iterate through the set & add keys to the list
      for (String node : s) {
        list.add(node);
      }
	    return list;
    }


    public List<String> succ(String n) {
      LinkedList<String> list = new LinkedList<>();
	    // check if n is a node; throw exception if not
      list = nodes.get(n);
      if (list == null) {
        throw new NoSuchElementException();
      }
      return list;
    }

    public List<String> pred(String n) {
      // exit if node is not found
      if (nodes.get(n) == null) {
        throw new NoSuchElementException();
      }
      LinkedList<String> list = new LinkedList<>();
      // traverse each of the node
      for (String node : nodes.keySet()) {
        LinkedList<String> vals = new LinkedList<>();
        vals = nodes.get(node);
        // if the node has no edge, continue
        if (vals == null) {
          continue;
        } 
        // traverse the vals 
        for (int i = 0; i < vals.size(); i++) {
          // if the vals list has the node n as an edge, add key to list
          if (vals.get(i) == n) {
            list.add(node);
          }
        }
      }
      return list;

    }

    // add nodes and edges from curr graph to g and return g
    public Graph union(Graph g) {
      // add to current nodes Hashmap
      List<String> glist = g.nodes();
      
      // check if node is same as g; add if not exist
      for (String node : nodes.keySet()) {
        LinkedList<String> currList = nodes.get(node);
        if (glist.contains(node) != true) {
          // add to glist
          g.addNode(node);
          // add edges
          for (int i = 0; i < currList.size(); i++) {
            g.addNode(currList.get(i));
            g.addEdge(node, currList.get(i));
          }
        }
        else {
          // compare edges of a specific node in curr graph
          for (int i = 0; i < currList.size(); i++) {
            if (g.hasEdge(node, currList.get(i)) != true) {
              // add edge to g
              g.addEdge(node, currList.get(i));
            }
          }
        }
      }
      return g;
    }

    // return a graph that only has the nodes and edges from the nodes set given
    public Graph subGraph(Set<String> nodes) {
      Graph newG = new ListGraph();
	    // go thru curr graph, if graph has nodes in the set check edges
      for (String node : this.nodes.keySet()) {
        if (nodes.contains(node) == true) {
          // check edges
          LinkedList<String> currSuccList = this.nodes.get(node);
          for (int i = 0; i < currSuccList.size(); i++) {
            if (nodes.contains(currSuccList.get(i)) != true) {
              currSuccList.remove(i);
            }
          }
          // if edges are all in the set, add to the new graph
          newG.addNode(node);
          
          // add edges
          for (int i = 0; i < currSuccList.size(); i++) {
            newG.addNode(currSuccList.get(i));
            newG.addEdge(node, currSuccList.get(i));
          }
        }
      }
      return newG;
    }

    // see if there is a path between n1 and n2 nodes
    public boolean connected(String n1, String n2) {
      if (!nodes.containsKey(n1) || !nodes.containsKey(n2)) {
        throw new NoSuchElementException();
    }

    Queue<String> queue = new LinkedList<>();
    Set<String> visited = new HashSet<>();

    queue.add(n1);
    visited.add(n1);

    while (!queue.isEmpty()) {
        String curr = queue.poll();
        if (curr.equals(n2)) return true;

        for (String neighbor : nodes.get(curr)) {
            if (!visited.contains(neighbor)) {
                visited.add(neighbor);
                queue.add(neighbor);
            }
        }
    }
    return false;
    }
}
