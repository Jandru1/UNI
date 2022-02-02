package junit.com;

import static org.junit.Assert.*;

import org.junit.Before;
import org.junit.Test;

public class TestImpostProporcional {
	ImpostStrategy is;
	@Before
	public void setUp() throws Exception {
		is = new ImpostProporcional(50, 2, 10);
	}

	@Test(expected = NoEsPotCalcularImpost.class)
	public void TestImpostProporcionalActivaExcepcio() throws NoEsPotCalcularImpost {
		is.consultaImpost(10000, 13);
	}
	
	@Test
	public void TestImpostProporcional() throws NoEsPotCalcularImpost {
		assertEquals("Should display  ", 10000*50+2*3, is.consultaImpost(10000, 3));
	}

}
