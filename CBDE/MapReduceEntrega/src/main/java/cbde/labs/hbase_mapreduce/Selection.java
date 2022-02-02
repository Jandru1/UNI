package cbde.labs.hbase_mapreduce;

import java.io.IOException;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.input.SequenceFileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;

public class Selection extends JobMapReduce {

	public static class SelectionMapper extends Mapper<Text, Text, Text, Text> {

		public void map(Text key, Text value, Context context) throws IOException, InterruptedException {
			String[] selection = context.getConfiguration().getStrings("selection");
			String[] values = value.toString().split(",");
			String projectionValue = Utils.getAttribute(values, selection[0]);
			if(Utils.getAttribute(values, selection[0]).equals("type_1")) {
				StringBuilder newValue = new StringBuilder(projectionValue);
				System.out.println("projValue: "+projectionValue);
				for (int i = 1; i < selection.length; i++) {
					System.out.println("esto es: "+selection[i]);
					newValue.append("," + Utils.getAttribute(values, selection[i]));
				}
				context.write(key, new Text(newValue.toString()));
			}
		}
	}
	public Selection() {
		this.input = null;
		this.output = null;
	}
	
	public boolean run() throws IOException, ClassNotFoundException, InterruptedException {
		Configuration configuration = new Configuration();
		// Define the new job and the name it will be given
		Job job = Job.getInstance(configuration, "Selection");
		configureJob(job,this.input, this.output);
	    // Let's run it!
	    return job.waitForCompletion(true);
	}


	public static void configureJob(Job job, String pathIn, String pathOut) throws IOException, ClassNotFoundException, InterruptedException {
		job.setJarByClass(Selection.class);

		job.setMapperClass(SelectionMapper.class);
		job.setMapOutputKeyClass(Text.class);
		job.setMapOutputValueClass(Text.class);

		job.setOutputKeyClass(Text.class);
		job.setOutputValueClass(Text.class);

		job.setInputFormatClass(SequenceFileInputFormat.class);
		FileInputFormat.addInputPath(job, new Path(pathIn));
		FileOutputFormat.setOutputPath(job, new Path(pathOut));

		job.getConfiguration().setStrings("selection", "type", "region", "alc", "m_acid","ash","alc_ash","mgn","t_phenols", "flav","nonflav_phenols","proant","col","hue","od2800d315","proline");
	}
}
