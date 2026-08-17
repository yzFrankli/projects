import java.util.Map;

        public class main {
                public static void main(String[] args) {
                // System.out.println("=== Running testClass ===");
                // Map<String, Throwable> fails = Unit.testClass("ForAll");
                // System.out.println("Failures: " + fails);

                // System.out.println("\n=== Running quickCheckClass ===");
                // Map<String, Object[]> checks = Unit.quickCheckClass("MyProperties");
                // System.out.println("QuickCheck results: " + checks);
        //     }

                if (Assertion.assertThat(null).isNotNull() != null) {
                        System.out.println("true");
                }
        }

}
