package cbde.labs.hbase_mapreduce.writer;

import java.util.Arrays;
import java.util.List;

//Creem una family per cada atribut de la query. La resta seran "all" per defecte
//create 'wines2', 'type', 'region', 'alc', 'all'
public class MyHBaseWriter_VerticalPartitioning extends MyHBaseWriter {

	//Llista constant de les families que farem servir en aquest exercici. La clase reader també accedira a aquesta llista
	public final static List<String> FAMILIES_FOR_QUERY = Arrays.asList("type", "region", "alc");

	protected String toFamily(String attribute) {
		if(FAMILIES_FOR_QUERY.contains(attribute)) return attribute;
		else return "all";
	}
}