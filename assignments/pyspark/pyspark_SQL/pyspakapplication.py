from pyspark.sql import SparkSession

spark = SparkSession \
	.builder \
	.appName("Bank Marketing Data Analysis") \
	.config("spark.driver.cores", "2") \
	.getOrCreate()

df=spark.read.load("/home/rishi/futurense_hadoop-pyspark/labs/dataset/bankmarket/bankmarketdata.csv",format="csv",sep=";",inferSchema="True",header="True")

df.registerTempTable("bank")
spark.sql("select * from bank").show()

out=spark.sql("select (case when age<13 then 'Kids' when age<20 then 'Teenagers' when age < 31 then 'Young' when age<50 then 'MiddleAgers' else 'Seniors' end) as peopletype,count(*) from bank where y='yes' group by peopletype order by 2 desc")

out.write.parquet("/home/rishi/futurense_hadoop-pyspark/labs/dataset/bankmarket/parquet")

df1=spark.read.load("/home/rishi/futurense_hadoop-pyspark/labs/dataset/bankmarket/parquet", format="parquet")


df1.show()



out1=spark.sql("select (case when age<13 then 'Kids' when age<20 then 'Teenagers' \
           when age < 31 then 'Young' \
           when age<50 then 'MiddleAgers' else 'Seniors' end) as peopletype,count(age) as age from bank where y='yes' group by peopletype having count(age)>2000")



out1.select("peopletype","age").write.format("avro").save("/home/rishi/futurense_hadoop-pyspark/labs/dataset/bankmarket/avro1")

df2=spark.read.format("avro").load("/home/rishi/futurense_hadoop-pyspark/labs/dataset/bankmarket/avro1")





# 1] spark-submit bank-marketing-analysis.py => Runs in local mode
#spark-submit --packages org.apache.spark:spark-avro_2.12:3.3.2 /mnt/c/Users/miles.MILE-BL-4115-LA/Desktop/pysparkapplication.py



