package jrails;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import books.Book;

import static org.hamcrest.core.IsNull.notNullValue;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertThat;
import static org.junit.Assert.assertTrue;

public class ModelTest {

    private Model model;

    @Before
    public void setUp() throws Exception {
        model = new Model(){};
    }

    @Test
    public void id() {
        assertThat(model.id(), notNullValue());
    }

    @After
    public void tearDown() throws Exception {
    }

    @Test
    public void trySQLite() {
        Model.sample();
        System.out.println("model id " + model.id());
    }

    // @Test
    // public void save() {
    //     Model.reset();
    //     Book b = new Book();
    //     b.title = "Java is so fun";
    //     b.author = "sina";
    //     b.num_copies = 20;

    //     b.save();
    // }

//     @Test
//     public void getId() {
//         Model.reset();
//         Book b = new Book();
//         b.title = "Java is so fun";
//         b.author = "sina";
//         b.num_copies = 20;
//         b.save();
//         System.out.println("b.id " + model.id());
//         Book compareTo = Model.find(Book.class, b.id());
//         System.out.println("compareto.id " + compareTo.id());
//         // assertEquals(b.id(), compareTo.id());
//     }

        @Test
        public void change() {
            // creat a new instance and save it
            System.out.println("executing change");
            Model.reset();
            Book b = new Book();
            b.title = "love java!";
            b.author = "myself";
            b.num_copies = 20;
            b.save();

            //
            assertTrue(b.id() > 0);

            Book newb = Model.find(Book.class, b.id());
            assertNotNull(newb);
            assertEquals("love java!", newb.title);
            assertEquals("myself", newb.author);
            assertEquals(20, newb.num_copies);
            assertEquals(b.id(), newb.id());


            // modify fields
            newb.title = "hate java!";
            newb.author = "not myself";
            newb.save();

            // check
            assertNotNull(newb);
            assertEquals("hate java!", newb.title);
            assertEquals("not myself", newb.author);
            assertEquals(20, newb.num_copies);
            assertEquals(b.id(), newb.id());
            b.destroy();



        }


//     @Test
//     public void reset() {
//         Model.reset();
        
//     }
}