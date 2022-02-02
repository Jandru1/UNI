package bdm.labs;

import java.io.IOException;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.DoubleWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.input.SequenceFileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;

public class Selection extends JobMapReduce {

	public static class SelectionMapper extends Mapper<Text, Text, Text, Text> {

		public void map(Text key, Text value, Context context) throws IOException, InterruptedException {
			// Obtain the parameters sent during the configuration of the job
			String[] projection = context.getConfiguration().getStrings("selection");
			String[] native_C = context.getConfiguration().getStrings("native");

			System.out.println("projection: " + projection[0]);
			// Since the value is a CSV, just get the lines split by commas
			String[] values = value.toString().split(",");
			System.out.println("values: " + values.toString());
			String projectionValue = Utils.getAttribute(values, projection[0]);
			System.out.println("projVal: "+projectionValue);
			// Get the CSV position of the attributes, do the projection and emit it
			if(Utils.getAttribute(values, projection[2]).equals("Canada")) {
				StringBuilder newValue = new StringBuilder(projectionValue);
				for (int i = 1; i < projection.length; i++) {
					System.out.println("projection1: " + projection[1]);
					System.out.println("projection2: " + projection[2]);
					System.out.println("projection i: " + projection[i]);

					System.out.println("UtilsRaro: " + Utils.getAttribute(values, projection[i]));
					newValue.append("," + Utils.getAttribute(values, projection[i]));

				}
				System.out.println("El texto es : " + new Text(newValue.toString()));
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
		// Set the mapper class it must use
		job.setMapperClass(Selection.SelectionMapper.class);
		job.setMapOutputKeyClass(Text.class);
		job.setMapOutputValueClass(Text.class);
		// No combiner or reducer classes for this example
		// The output will be LongWritable and Text
		job.setOutputKeyClass(Text.class);
		job.setOutputValueClass(Text.class);
		// The files and formats the job will read from/write to
		job.setInputFormatClass(SequenceFileInputFormat.class);
		FileInputFormat.addInputPath(job, new Path(pathIn));
		FileOutputFormat.setOutputPath(job, new Path(pathOut));
		// These are the parameters that we are sending to the job
		job.getConfiguration().setStrings("selection", "age", "relationship", "native_country");
		job.getConfiguration().setStrings("native", "native_country");

	}
}
