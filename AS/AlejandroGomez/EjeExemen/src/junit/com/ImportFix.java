package junit.com;

public class ImportFix implements ImportStrategy {

	private int quant;
	private int potMin;

	public ImportFix(int i, int j) {
		quant = i;
		potMin = j;
	}

	@Override
	public int consultarImport(int i) {
		// TODO Auto-generated method stub
		if(i < potMin) return 0;
		return quant;
	}

}
