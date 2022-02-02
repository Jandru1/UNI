package junit.com;

public class ImportVariable implements ImportStrategy {

	private int recarrecPot;
	private int potMax;

	public ImportVariable(int i, int j) {
		recarrecPot = i;
		potMax = j;
		// TODO Auto-generated constructor stub
	}

	@Override
	public int consultarImport(int i) throws NoEsPotCalcularImport {
		// TODO Auto-generated method stub
		if(i > potMax) throw new NoEsPotCalcularImport();
		return recarrecPot*i;
	}

}
