package junit.com;

import static org.junit.Assert.*;

import org.junit.Before;
import org.junit.Test;

public class TestImportFix {
	ImportStrategy is;
	@Before
	public void setUp() throws Exception {
		is = new ImportFix(10, 200);
	}

	@Test
	public void TestImportFixAnysMenorAjuntament() throws NoEsPotCalcularImport {
		assertEquals("Should display 0", 0, is.consultarImport(100));
	}
	
	@Test
	public void TestImportFix() throws NoEsPotCalcularImport {
		assertEquals("Should display quant", 10, is.consultarImport(300));
	}
}
