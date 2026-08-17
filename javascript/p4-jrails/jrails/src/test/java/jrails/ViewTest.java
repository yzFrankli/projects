package jrails;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import static org.hamcrest.Matchers.isEmptyString;
import static org.junit.Assert.*;

public class ViewTest {

    @Test
    public void empty() {
        assertThat(View.empty().toString(), isEmptyString());
    }

    @Test
    public void text() {
        Html text = View.t("1");
        assertEquals("1", text.toString());
    }

    @Test
    public void paragraph() {
        Html para = View.p(View.t("1"));
        assertEquals("<p>1</p>", para.toString());
    }

    @Test
    public void linkTo() {
        Html link = View.link_to("Tufts", "/tufts.edu");
        assertEquals("<a href=\"/tufts.edu\">Tufts</a>", link.toString());
    }

    @Test
    public void form() {
        Html form = View.form("/create", View.t("save"));
        assertEquals("<form action=\"/create\" accept-charset=\"UTF-8\" method=\"post\">save</form>",
                form.toString());
    }
}