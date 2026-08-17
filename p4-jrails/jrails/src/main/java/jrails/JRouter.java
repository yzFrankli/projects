package jrails;

import java.lang.reflect.Method;
import java.util.*;

public class JRouter {

    private static final Set<String> VALID_VERBS = 
            Set.of("GET", "POST", "PUT", "DELETE");

    // Internal route storage
    private static class Route {
        String verb;
        String path;
        Class<?> controller;
        Method method;

        Route(String verb, String path, Class<?> controller, Method method) {
            this.verb = verb;
            this.path = path;
            this.controller = controller;
            this.method = method;
        }
    }

    private final List<Route> routes = new ArrayList<>();


    public void addRoute(String verb, String path, Class<?> clazz, String methodName) {

        // Validate verb
        if (!VALID_VERBS.contains(verb))
            throw new IllegalArgumentException("Invalid HTTP verb: " + verb);

        // Validate class is a controller
        if (clazz == null || !Controller.class.isAssignableFrom(clazz))
            throw new IllegalArgumentException(clazz + " is not a Controller");

        // Validate method exists with correct signature: Html method(Map<String,String>)
        Method found = null;
        for (Method m : clazz.getDeclaredMethods()) {
            if (m.getName().equals(methodName)) {
                Class<?>[] params = m.getParameterTypes();
                if (params.length == 1 && params[0] == Map.class && m.getReturnType() == Html.class) {
                    found = m;
                    break;
                }
            }
        }

        if (found == null)
            throw new IllegalArgumentException("Method " + methodName + " invalid in " + clazz);

        // store route
        routes.add(new Route(verb, path, clazz, found));
    }


    // Returns "ClassName#method" or null
    public String getRoute(String verb, String path) {
        return routes.stream()
                .filter(r -> r.verb.equals(verb) && r.path.equals(path))
                .findFirst()
                .map(r -> r.controller.getSimpleName() + "#" + r.method.getName())
                .orElse(null);
    }


    // Call matching controller and return result
    public Html route(String verb, String path, Map<String, String> params) {
        for (Route r : routes) {
            if (r.verb.equals(verb) && r.path.equals(path)) {
                try {
                    Object controllerInstance = r.controller.getDeclaredConstructor().newInstance();
                    return (Html) r.method.invoke(controllerInstance, params);
                } catch (Exception e) {
                    throw new RuntimeException(e);
                }
            }
        }
        throw new UnsupportedOperationException("No route for " + verb + " " + path);
    }
}
