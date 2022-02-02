package junit.com;

public class ImpostFix implements ImpostStrategy {

	private int importe;
	private int anysMin;

	public ImpostFix(int i, int j) {
		importe = i;
		anysMin = j;	
		}

	@Override
	public int consultaImpost(int i, int j) {
		// TODO Auto-generated method stub
		if(j < anysMin) return 0;
		return importe;
	}




}
