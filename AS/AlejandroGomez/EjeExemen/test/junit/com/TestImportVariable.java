package junit.com;

import static org.junit.Assert.*;

import org.junit.Before;
import org.junit.Test;

public class TestImportVariable {
	ImportStrategy is;
	@Before
	public void setUp() throws Exception {
		is = new ImportVariable(10,200);
	}

	@Test(expected = NoEsPotCalcularImport.class)
	public void TestImportVariableExpectedOurException() throws NoEsPotCalcularImport {
		is.consultarImport(300);
	}
	
	@Test
	public void TestImportVariable() throws NoEsPotCalcularImport {
		assertEquals("Should display 50*10 ",50*10 ,is.consultarImport(50));
	}

}
