package cbde.labs.hbase_mapreduce.reader;

public class MyHBaseReader_KeyDesign extends MyHBaseReader {

	protected String scanStart() {
		return "a";
	}

	protected String scanStop() {
		return "b";
	}

}