package junit.com;

import static org.junit.Assert.*;

import org.junit.Before;
import org.junit.Test;

public class TestIntegration {

	 PayStation ps;

	@Test
	  public void shouldCalculateImpostFixe() throws NoEsPotCalcularImpost {
		ps = new PayStationImpl(new ImpostFix(10, 4)); 
		Impost imp = ps.impost(10000, 13);
	    assertEquals( "Should calculate 11 bought minuts for 25 coins", 
	                  10, imp.value()); 
	  }
	  
	
	@Test
	  public void shouldCalculateImpostProporcional() throws NoEsPotCalcularImpost {
		ps = new PayStationImpl(new ImpostProporcional(50,2,10)); 
		Impost imp = ps.impost(10000, 3);
	    assertEquals( "Should calculate 11 bought minuts for 25 coins", 
	                  50*10000+3*2, imp.value()); 
	  }

}
