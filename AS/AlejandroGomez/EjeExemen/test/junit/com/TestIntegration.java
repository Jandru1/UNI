package junit.com;

import static org.junit.Assert.*;

import org.junit.Before;
import org.junit.Test;

public class TestIntegration {
	PayStation ps;
	@Test
	public void TestForImportFix() throws NoEsPotCalcularImport {
		ps = new PayStationImpl(new ImportFix(10,200));
		assertEquals("Should display quant", 10, ps.consultarImporte(300));
		
	}

	@Test
	public void TestForImportVariable() throws NoEsPotCalcularImport  {
		ps = new PayStationImpl(new ImportVariable(10,200));
		assertEquals("Should display 10*50", 10*50, ps.consultarImporte(50));
		
	}
	@Test(expected = NoEsPotCalcularImport.class)
	public void TestForImportVariableThrowException() throws NoEsPotCalcularImport {
		ps = new PayStationImpl(new ImportVariable(10,200));
		ps.consultarImporte(300);
	}
}
