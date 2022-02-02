package junit.com;

public class ImpostProporcional implements ImpostStrategy {

	private int perc;
	private int increment;
	private int anysMax;

	public ImpostProporcional(int d, int i, int j) {
		perc = d;
		increment = i;
		anysMax = j;
		// TODO Auto-generated constructor stub
	}

	@Override
	public int consultaImpost(int i, int j) throws NoEsPotCalcularImpost {
		// TODO Auto-generated method stub
		if(j > anysMax) throw new NoEsPotCalcularImpost();
		else return (perc*i+(increment*j));
	}

}
