package cbde.labs.hbase_mapreduce.writer;

public class MyHBaseWriter_KeyDesign extends MyHBaseWriter {

	protected String nextKey() {
		String region = this.data.get("region");
		String type = this.data.get("type");
		if(region.equals("0") && type.equals("type_3")) {
			return "a" + this.key;
		}
		else return "b" + this.key;
	}

}