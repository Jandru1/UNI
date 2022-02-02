package cbde.labs.hbase_mapreduce.reader;

import cbde.labs.hbase_mapreduce.writer.MyHBaseWriter_VerticalPartitioning;

import java.lang.reflect.Array;
import java.util.ArrayList;

public class MyHBaseReader_VerticalPartitioning extends MyHBaseReader {

	protected String[] scanFamilies() {
		return MyHBaseWriter_VerticalPartitioning.FAMILIES_FOR_QUERY.toArray(new String[0]);
	}
}