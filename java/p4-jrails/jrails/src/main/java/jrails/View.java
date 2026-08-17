package jrails;

public class View {

    /** Empty Html */
    public static Html empty() {
        return new Html("");
    }

    /** Self-closing <br/> */
    public static Html br() {
        return new Html("<br/>");
    }

    /** Convert any object to text Html */
    public static Html t(Object o) {
        return new Html(o == null ? "" : o.toString());
    }

    // ------- Standard Tags ------- //

    public static Html p(Html child) {
        return new Html("<p>" + child.toString() + "</p>");
    }

    public static Html div(Html child) {
        return new Html("<div>" + child.toString() + "</div>");
    }

    public static Html strong(Html child) {
        return new Html("<strong>" + child.toString() + "</strong>");
    }

    public static Html h1(Html child) {
        return new Html("<h1>" + child.toString() + "</h1>");
    }

    public static Html tr(Html child) {
        return new Html("<tr>" + child.toString() + "</tr>");
    }

    public static Html th(Html child) {
        return new Html("<th>" + child.toString() + "</th>");
    }

    public static Html td(Html child) {
        return new Html("<td>" + child.toString() + "</td>");
    }

    public static Html table(Html child) {
        return new Html("<table>" + child.toString() + "</table>");
    }

    public static Html thead(Html child) {
        return new Html("<thead>" + child.toString() + "</thead>");
    }

    public static Html tbody(Html child) {
        return new Html("<tbody>" + child.toString() + "</tbody>");
    }

    /** textarea requires a name attribute */
    public static Html textarea(String name, Html child) {
        return new Html("<textarea name=\"" + name + "\">" + child.toString() + "</textarea>");
    }

    // ------- Special Helpers ------- //

    /** <a href="URL">TEXT</a> */
    public static Html link_to(String text, String url) {
        return new Html("<a href=\"" + url + "\">" + text + "</a>");
    }

    /** form wrapper with POST + UTF-8 */
    public static Html form(String action, Html child) {
        return new Html("<form action=\"" + action
                + "\" accept-charset=\"UTF-8\" method=\"post\">"
                + child.toString()
                + "</form>");
    }

    /** Submit button */
    public static Html submit(String value) {
        return new Html("<input type=\"submit\" value=\"" + value + "\"/>");
    }
}


// public class View {
//     public static Html empty() {
//         return new Html("");
//     }

//     public static Html br() {
//         throw new UnsupportedOperationException();
//     }

//     public static Html t(Object o) {
//         // Use o.toString() to get the text for this
//         throw new UnsupportedOperationException();
//     }

//     public static Html p(Html child) {
//         throw new UnsupportedOperationException();
//     }

//     public static Html div(Html child) {
//         throw new UnsupportedOperationException();
//     }

//     public static Html strong(Html child) {
//         throw new UnsupportedOperationException();
//     }

//     public static Html h1(Html child) {
//         throw new UnsupportedOperationException();
//     }

//     public static Html tr(Html child) {
//         throw new UnsupportedOperationException();
//     }

//     public static Html th(Html child) {
//         throw new UnsupportedOperationException();
//     }

//     public static Html td(Html child) {
//         throw new UnsupportedOperationException();
//     }

//     public static Html table(Html child) {
//         throw new UnsupportedOperationException();
//     }

//     public static Html thead(Html child) {
//         throw new UnsupportedOperationException();
//     }

//     public static Html tbody(Html child) {
//         throw new UnsupportedOperationException();
//     }

//     public static Html textarea(String name, Html child) {
//         throw new UnsupportedOperationException();
//     }

//     public static Html link_to(String text, String url) {
//         throw new UnsupportedOperationException();
//     }

//     public static Html form(String action, Html child) {
//         throw new UnsupportedOperationException();
//     }

//     public static Html submit(String value) {
//         throw new UnsupportedOperationException();
//     }
// }