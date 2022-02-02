package junit.com;

import static org.junit.Assert.*;

import org.junit.Before;
import org.junit.Test;

public class TestImpostFix {
	ImpostStrategy is;
	@Before
	public void setUp() throws Exception {
		is = new ImpostFix(10,4);
	}

	@Test
	public void TestAmbImpostFixeNoAnys() throws NoEsPotCalcularImpost {
		assertEquals("should display 0", 0, is.consultaImpost(10000,3));
		}
	@Test
	public void TestAmbImpostFixe() throws NoEsPotCalcularImpost {
		assertEquals("should display 10",10 , is.consultaImpost(10000,13));
		}

}
