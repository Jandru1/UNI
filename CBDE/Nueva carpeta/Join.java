package cbde.labs.hbase_mapreduce;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.NullWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.input.SequenceFileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;

import java.io.IOException;
import java.util.ArrayList;

public class Join extends JobMapReduce {

	public static class CartesianMapper extends Mapper<Text, Text, IntWritable, Text> {

		private static int N = 100;

		public void map(Text key, Text value, Mapper.Context context) throws IOException, InterruptedException {
			String cartesian = context.getConfiguration().getStrings("cartesian")[0];
			String external = context.getConfiguration().getStrings("external")[0];
			String internal = context.getConfiguration().getStrings("internal")[0];
			String[] arrayValues = value.toString().split(",");
			String cartesianValue = Utils.getAttribute(arrayValues, cartesian);
			if (cartesianValue.equals(external)) {
				int newKey = (int)(Math.random()*N);
				context.write(new IntWritable(newKey), value);
			}
			else if (cartesianValue.equals(internal)) {
				for (int newKey = 0; newKey < N; newKey++) {
					context.write(new IntWritable(newKey), value);
				}
			}
		}
	}
	public Join() {
		this.input = null;
		this.output = null;
	}

	public static class JoinReducer extends Reducer<IntWritable, Text, NullWritable, Text> {

		public void reduce(IntWritable key, Iterable<Text> values, Context context) throws IOException, InterruptedException {
			String cartesian = context.getConfiguration().getStrings("cartesian")[0];
			String external = context.getConfiguration().getStrings("external")[0];
			ArrayList<String> externals = new ArrayList<String>();
			ArrayList<String> internals = new ArrayList<String>();
			for (Text value : values) {
				String[] arrayValues = value.toString().split(",");
				String cartesianValue = Utils.getAttribute(arrayValues, cartesian);
				if (cartesianValue.equals(external)) externals.add(value.toString());
				else internals.add(value.toString());
			}
			for (int i = 0; i < externals.size(); i++) {
				for (int j = 0; j < internals.size(); j++) {
					String[] arrayInternal = internals.get(j).split(",");
					String[] arrayExternal = externals.get(i).split(",");
					String regionInternal = Utils.getAttribute(arrayInternal, "region");
					String regionExternal = Utils.getAttribute(arrayExternal, "region");
					if(regionInternal.equals(regionExternal)) {
						context.write(NullWritable.get(), new Text(externals.get(i) + "<->" + internals.get(j)));
					}
				}
			}
		}

	}
	public boolean run() throws IOException, ClassNotFoundException, InterruptedException {
		Configuration configuration = new Configuration();
		Job job = Job.getInstance(configuration, "Join");
		Join.configureJob(job, this.input, this.output);
	    return job.waitForCompletion(true);
	}

	public static void configureJob(Job job, String pathIn, String pathOut) throws IOException, ClassNotFoundException, InterruptedException {
        job.setJarByClass(Join.class);

		job.setMapperClass(CartesianMapper.class);
		job.setMapOutputKeyClass(IntWritable.class);
		job.setMapOutputValueClass(Text.class);

		job.setReducerClass(JoinReducer.class);

		job.setOutputKeyClass(NullWritable.class);
		job.setOutputValueClass(Text.class);
		job.setInputFormatClass(SequenceFileInputFormat.class);

		FileInputFormat.addInputPath(job, new Path(pathIn));
		FileOutputFormat.setOutputPath(job, new Path(pathOut));

		job.getConfiguration().setStrings("cartesian", "type");
		job.getConfiguration().setStrings("external", "type_1");
		job.getConfiguration().setStrings("internal", "type_2");


    }
}
