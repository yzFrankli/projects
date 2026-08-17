import java.lang.reflect.AnnotatedParameterizedType;
import java.lang.reflect.AnnotatedType;
import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.lang.reflect.Modifier;
import java.lang.reflect.Parameter;
import java.util.*;
import java.lang.annotation.Annotation;


public class Unit {

        public static Map<String, Throwable> testClass(String name) {
    Map<String, Throwable> result = new HashMap<>();
    try {
        Class<?> c = Class.forName(name);
        Constructor<?> cons = c.getConstructor();
        Object instance = cons.newInstance();

        Method[] all = c.getDeclaredMethods();
        Arrays.sort(all, Comparator.comparing(Method::getName));

        // 1) Validate no method has more than one of the 5 framework annotations
        for (Method m : all) {
            int count = 0;
            if (m.isAnnotationPresent(Test.class))       count++;
            if (m.isAnnotationPresent(BeforeClass.class)) count++;
            if (m.isAnnotationPresent(Before.class))      count++;
            if (m.isAnnotationPresent(After.class))       count++;
            if (m.isAnnotationPresent(AfterClass.class))  count++;
            if (count > 1) throw new RuntimeException("Method has multiple test annotations: " + m.getName());
        }

        // 2) Partition methods (already alphabetically sorted)
        List<Method> befores      = new ArrayList<>();
        List<Method> afters       = new ArrayList<>();
        List<Method> beforeClass  = new ArrayList<>();
        List<Method> afterClass   = new ArrayList<>();
        List<Method> tests        = new ArrayList<>();

        for (Method m : all) {
            if (m.isAnnotationPresent(BeforeClass.class)) beforeClass.add(m);
            else if (m.isAnnotationPresent(AfterClass.class)) afterClass.add(m);
            else if (m.isAnnotationPresent(Before.class)) befores.add(m);
            else if (m.isAnnotationPresent(After.class)) afters.add(m);
            else if (m.isAnnotationPresent(Test.class)) tests.add(m);
        }

        // 3) Ensure @BeforeClass / @AfterClass are static
        for (Method m : beforeClass) {
            if (!Modifier.isStatic(m.getModifiers())) throw new RuntimeException("@BeforeClass must be static: " + m.getName());
        }
        for (Method m : afterClass) {
            if (!Modifier.isStatic(m.getModifiers())) throw new RuntimeException("@AfterClass must be static: " + m.getName());
        }

        // 4) Run @BeforeClass (rethrow on any Throwable)
        for (Method m : beforeClass) {
            try {
                m.invoke(null); // static
            } catch (InvocationTargetException ite) {
                throw new RuntimeException(ite.getCause());
            } catch (IllegalAccessException iae) {
                throw new RuntimeException(iae);
            }
        }

        // 5) Run tests (with @Before/@After around EACH test)
        for (Method test : tests) {
            String nameOnly = test.getName();
            // @Before
            for (Method b : befores) {
                try {
                    b.invoke(instance);
                } catch (InvocationTargetException ite) {
                    throw new RuntimeException(ite.getCause());
                } catch (IllegalAccessException iae) {
                    throw new RuntimeException(iae);
                }
            }

            // test (record Throwable cause or null)
            try {
                test.invoke(instance);
                result.put(nameOnly, null);
            } catch (InvocationTargetException ite) {
                Throwable cause = ite.getCause();
                result.put(nameOnly, cause);
            } catch (IllegalAccessException iae) {
                // treat reflection problems as test failure details
                result.put(nameOnly, iae);
            }

            // @After
            for (Method a : afters) {
                try {
                    a.invoke(instance);
                } catch (InvocationTargetException ite) {
                    throw new RuntimeException(ite.getCause());
                } catch (IllegalAccessException iae) {
                    throw new RuntimeException(iae);
                }
            }
        }

        // 6) Run @AfterClass (always, even if no tests)
        for (Method m : afterClass) {
            try {
                m.invoke(null); // static
            } catch (InvocationTargetException ite) {
                throw new RuntimeException(ite.getCause());
            } catch (IllegalAccessException iae) {
                throw new RuntimeException(iae);
            }
        }

                // 7) If there were NO @Test methods, spec says:
                //    - run @BeforeClass and @AfterClass (already done)
                //    - do NOT run @Before / @After (we didn't)

        } catch (ClassNotFoundException | NoSuchMethodException |
                InstantiationException | IllegalAccessException |
                InvocationTargetException e) {
                // Framework-level issues: surface as unchecked per spec guidance
                throw new RuntimeException(e instanceof InvocationTargetException ? ((InvocationTargetException)e).getCause() : e);
        }
        return result;
        }
//     public static Map<String, Throwable> testClass(String name) {
//         Map<String, Throwable> fail = new HashMap<>();

//         // takes the name of the class
//         // use reflection to load and get information about the class (ie. find
//         // the methods and annotation of the class anootated with @test)
//         // insert all the failed tests into the map with the name of the test
//         // cases and throwable when the tests case failed
//         try {
//                 //TODO: check if each method has only one annotation
//                 Class<?> c = Class.forName(name);
//                 Constructor<?> cons = c.getConstructor();
//                 Object instance = cons.newInstance();

//                 // sort the methods into alphabetical order
//                 Method[] methArr = c.getDeclaredMethods();
//                 Arrays.sort(methArr, Comparator.comparing(Method::getName));

//                 // @beforeclass should run before each esecution of a test method
//                 // in alphabetical order
//                 for (Method meth : methArr) {
//                         if (meth.isAnnotationPresent(BeforeClass.class)) {
//                                 if (!Modifier.isStatic(meth.getModifiers())) {
//                                         throw new UnsupportedOperationException();
//                                 }
//                                 meth.invoke(instance);

//                         }
//                 }

//                 // running test methods (should not run if no test methods)
//                 // *TODO: Question what if the after method comes before the test? 
//                 // *TODO: Does it execute after or test??
//                 for (Method meth : methArr) {
//                         if (meth.isAnnotationPresent(Before.class) | 
//                             meth.isAnnotationPresent(After.class)) {
//                                 meth.invoke(instance);
//                         } else if (meth.isAnnotationPresent(Test.class)) {
//                                 try {
//                                         meth.invoke(instance);
//                                 } catch (InvocationTargetException t) {
//                                         Throwable cause = t.getCause();
//                                         fail.put(meth.getName(), cause);
//                                 }
//                         }
//                 }

//                 // run @afterTest methods after testing
//                 for (Method meth : methArr) {
//                         if (meth.isAnnotationPresent(AfterClass.class)) {
//                                 if (!Modifier.isStatic(meth.getModifiers())) {
//                                         throw new UnsupportedOperationException();
//                                 }
//                                 meth.invoke(instance);
//                         }
//                 }

//         } catch (ClassNotFoundException | NoSuchMethodException | 
//                 InstantiationException | IllegalAccessException | 
//                 InvocationTargetException e) {
// 	        // throw new UnsupportedOperationException();

//         }
//         return fail;
        
//     }

    public static Map<String, Object[]> quickCheckClass(String name) {
        Map<String, Object[]> results = new HashMap<>();

        try {
            Class<?> c = Class.forName(name);
            Constructor<?> cons = c.getConstructor();
            Object instance = cons.newInstance();

            Method[] methods = c.getDeclaredMethods();
            Arrays.sort(methods, Comparator.comparing(Method::getName));

            for (Method m : methods) {
                if (!m.isAnnotationPresent(Property.class)) continue;

                Parameter[] params = m.getParameters();
                List<List<Object>> allArgs = new ArrayList<>();

                for (Parameter p : params) {
                    Annotation[] ann = p.getAnnotations();
                    if (ann.length != 1) {
                        throw new RuntimeException("Parameter must have exactly one annotation");
                    }

                    Annotation a = ann[0];

                    if (a instanceof IntRange) {
                        IntRange range = (IntRange) a;
                        List<Object> ints = new ArrayList<>();
                        for (int i = range.min(); i <= range.max(); i++) {
                            ints.add(Integer.valueOf(i));
                        }
                        allArgs.add(ints);

                    } else if (a instanceof StringSet) {
                        StringSet set = (StringSet) a;
                        // avoid varargs ambiguity: wrap explicitly
                        String[] vals = set.strings();
                        List<Object> strList = new ArrayList<>();
                        for (String s : vals) strList.add(s);
                        allArgs.add(strList);

                    } else if (a instanceof ListLength) {
                        ListLength len = (ListLength) a;
                        AnnotatedType type = p.getAnnotatedType();
                        IntRange inner = findInnerIntRange(type);
                        if (inner == null) {
                            throw new RuntimeException("List element missing @IntRange annotation");
                        }

                        List<Object> lists = new ArrayList<>();
                        for (int l = len.min(); l <= len.max(); l++) {
                            lists.addAll(generateIntLists(l, inner.min(), inner.max()));
                        }
                        allArgs.add(lists);

                    } else if (a instanceof ForAll) {
                        ForAll fa = (ForAll) a;
                        Method gen = c.getMethod(fa.name());
                        List<Object> generated = new ArrayList<>();
                        for (int i = 0; i < fa.times(); i++) {
                            generated.add(gen.invoke(instance));
                        }
                        allArgs.add(generated);

                    } else {
                        throw new RuntimeException("Invalid annotation type: " + a.annotationType());
                    }
                }

                // --- Cartesian product of all arguments ---
                List<Object[]> combinations = cartesianProduct(allArgs);
                int runs = 0;
                Object[] failureArgs = null;

                for (Object[] args : combinations) {
                    if (runs++ >= 100) break;
                    try {
                        boolean ok = (boolean) m.invoke(instance, args);
                        if (!ok) {
                            failureArgs = args;
                            break;
                        }
                    } catch (Throwable t) {
                        failureArgs = args;
                        break;
                    }
                }

                results.put(m.getName(), failureArgs);
            }

        } catch (Throwable e) {
            throw new RuntimeException(e);
        }

        return results;
    }

    // --------------------- Helper functions ---------------------

    private static List<Object[]> cartesianProduct(List<List<Object>> lists) {
        List<Object[]> result = new ArrayList<>();
        if (lists.isEmpty()) {
            result.add(new Object[0]);
            return result;
        }
        backtrack(lists, 0, new Object[lists.size()], result);
        return result;
    }

    private static void backtrack(List<List<Object>> lists, int depth, Object[] current, List<Object[]> result) {
        if (depth == lists.size()) {
            result.add(current.clone());
            return;
        }
        for (Object o : lists.get(depth)) {
            current[depth] = o;
            backtrack(lists, depth + 1, current, result);
        }
    }

    private static IntRange findInnerIntRange(AnnotatedType type) {
        if (type == null) return null;
        IntRange range = type.getAnnotation(IntRange.class);
        if (range != null) return range;
        if (type instanceof AnnotatedParameterizedType) {
            AnnotatedParameterizedType apt = (AnnotatedParameterizedType) type;
            for (AnnotatedType arg : apt.getAnnotatedActualTypeArguments()) {
                IntRange inner = findInnerIntRange(arg);
                if (inner != null) return inner;
            }
        }
        return null;
    }

    private static List<List<Integer>> generateIntLists(int len, int min, int max) {
        List<List<Integer>> lists = new ArrayList<>();
        if (len == 0) {
            lists.add(new ArrayList<Integer>());
            return lists;
        }
        int[] nums = new int[len];
        Arrays.fill(nums, min);
        while (true) {
            List<Integer> list = new ArrayList<>();
            for (int x : nums) list.add(x);
            lists.add(list);
            int i = len - 1;
            while (i >= 0 && nums[i] == max) i--;
            if (i < 0) break;
            nums[i]++;
            for (int j = i + 1; j < len; j++) nums[j] = min;
        }
        return lists;
    }











//     public static Map<String, Object[]> quickCheckClass(String name) {
//         Map<String, Object[]> check = new HashMap<>();

//         try {
//                 //TODO: implement the mapping by using try or if false and insert the error cases in array type to map check!!
//                 Class<?> c = Class.forName(name);
//                 Constructor<?> cons = c.getConstructor();
//                 Object instance = cons.newInstance();

//                 Method[] methArr = c.getDeclaredMethods();
//                 Arrays.sort(methArr, Comparator.comparing(Method::getName));

//                 // run all the methods with @property
//                 for (Method meth : methArr) {
//                         if (meth.isAnnotationPresent(Property.class)) {
//                                 // look through the annotations for the parameters
//                                 Parameter paramArr[] = meth.getParameters();
//                                 for (Parameter param : paramArr) {
//                                         // check intRange
//                                         IntRange range = param.getAnnotation(IntRange.class);
//                                         if (range != null) {
//                                                 // test the func from min to max
//                                                 for (int i = range.min(); i <= range.max(); i++) {
//                                                         meth.invoke(instance, i);
//                                                 }
                                                
//                                         }

//                                         // check string set
//                                         StringSet rangeStr = param.getAnnotation(StringSet.class);
//                                         if (rangeStr != null) {
//                                                 // test each string
//                                                 for (int i = 0; i < rangeStr.strings().length; i++) {
//                                                         meth.invoke(instance, rangeStr.strings()[i]);
//                                                 }
                                                
//                                         }

//                                         // check list
//                                         ListLength listLen = param.getAnnotation(ListLength.class);
//                                         if (listLen != null) {
//                                                 // get the set of list length
//                                                 int counter = 0;
//                                                 AnnotatedType annotatedType = param.getAnnotatedType();
//                                                 if (annotatedType instanceof AnnotatedParameterizedType) {
//                                                         AnnotatedParameterizedType apt = (AnnotatedParameterizedType) annotatedType;
//                                                         AnnotatedType innerType = apt.getAnnotatedActualTypeArguments()[0];
//                                                         IntRange intRange = findInnerIntRange(innerType);
//                                                         int depth = getListDepth(innerType);
//                                                         if (intRange != null) {
//                                                         for (int len = listLen.min(); len <= listLen.max(); len++) {
//                                                                 for (int val = intRange.min(); val < intRange.max() && counter < 10; val++) {
//                                                                         Object testArg = buildTestList(depth, len, val);
//                                                                         meth.invoke(instance, testArg);
//                                                                         counter++;
//                                                                 }
//                                                         }
//                                                 }                                                

                                                
//                                         }

//                                         // check object
//                                         ForAll obj = param.getAnnotation(ForAll.class);
//                                         if (obj != null) {
//                                                 Parameter parameters[] = meth.getParameters();
//                                                 String methName = parameters[0].getName();
//                                                 String times = parameters[1].getName();
//                                                 Method method = c.getMethod(methName, String.class, Integer.class);
//                                                 for (int i = 0; i < Integer.parseInt(times); i++) {
//                                                         method.invoke(instance);
//                                                 }
//                                         }
                                        
//                                 }
                                
//                         }
//                 }

//         }

//         } catch (ClassNotFoundException | NoSuchMethodException | 
//                 InstantiationException | IllegalAccessException | 
//                 InvocationTargetException e) {
// 	        // throw new UnsupportedOperationException();

//         }

//         return check;

//     }

//     private static IntRange findInnerIntRange(AnnotatedType type) {
//         if (type == null) return null;

//         IntRange range = type.getAnnotation(IntRange.class);
//         if (range != null) return range;

//         if (type instanceof AnnotatedParameterizedType) {
//                 AnnotatedParameterizedType apt = (AnnotatedParameterizedType) type;
//                 for (AnnotatedType arg : apt.getAnnotatedActualTypeArguments()) {
//                 IntRange found = findInnerIntRange(arg);
//                 if (found != null) return found;
//                 }
//         }

//         return null;
//    }

//    private static int getListDepth(AnnotatedType type) {
//         if (!(type instanceof AnnotatedParameterizedType)) return 0; 
//         AnnotatedParameterizedType apt = (AnnotatedParameterizedType) type;

//         AnnotatedType[] args = apt.getAnnotatedActualTypeArguments();
//         if (args.length == 0) return 1;
//         return 1 + getListDepth(args[0]);
//    }

//    private static Object buildTestList(int depth, int len, int val) {
//         if (depth == 1) {
//                 List<Integer> list = new ArrayList<>();
//                 for (int i = 0; i < len; i++) list.add(val);
//                 return list;
//         } else {
//                 List<Object> outer = new ArrayList<>();
//                 for (int i = 0; i < len; i++) {
//                         outer.add(buildTestList(depth - 1, len, val));
//                 }
//                 return outer;
//         }
//    }
}