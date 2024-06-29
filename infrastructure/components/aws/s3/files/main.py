from pyspark.sql import SparkSession
from pyspark.sql import functions as F
spark = SparkSession.builder.appName("Read CSV with PySpark").getOrCreate()
 
spark.conf.set("spark.sql.legacy.timeParserPolicy", "LEGACY")
df = spark.read.csv(r"C:\Users\CHETHAN\Documents\ecommerce-data-analysis-main\infrastructure\components\aws\s3\files\olist_public_dataset.csv", header=True)
df.printSchema()
# df.show()
 
df = df.withColumn(
    "order_purchase_timestamp_new", F.split("order_purchase_timestamp", " ")[0]
)
df = df.withColumn(
    "order_purchase_timestamp_new",
    F.to_timestamp("order_purchase_timestamp_new", "dd/MM/yy"),
)
df = df.withColumn("day", F.dayofmonth("order_purchase_timestamp_new"))
df = df.withColumn("week", F.weekofyear("order_purchase_timestamp_new"))
 
df.createOrReplaceTempView("ecommerce_table")

# by city
 #1
df1 = spark.sql(
    """ select id, order_status,sum(order_products_value),sum(order_freight_value),customer_city,day
               from ecommerce_table group by id, order_status,customer_city,day"""
)
# save df1
df1.show()
#2
df1 = spark.sql(
    """ select id, order_status,sum(order_products_value),sum(order_freight_value),customer_city,day
               from ecommerce_table group by id, order_status,customer_city,day"""
)
# save df1
df1.show()


#2
df1 = spark.sql(
    """ select id,
order_status,sum(order_products_value),sum(order_freight_value),customer_city,day
from ecommerce_table group by id, order_status,customer_city,day; 
"""
)
# save df1
df1.show()


#3
df1 = spark.sql(
    """ select id,
order_status,sum(order_products_value),sum(order_freight_value),customer_city,day
from ecommerce_table group by id, order_status,customer_city,day"""
)
# save df1
df1.show()


#4
df1 = spark.sql(
    """ select id,
order_status,sum(order_products_value),sum(order_freight_value),customer_city,week
from ecommerce_table group by id, order_status,customer_city,week"""
)
# save df1
df1.show()

# By state
#5
df1 = spark.sql(
    """ select id,
order_status,sum(order_products_value),sum(order_freight_value),customer_state,day
from ecommerce_table group by id, order_status,customer_state,day"""
)
# save df1
df1.show()

#6
df1 = spark.sql(
    """ select id,
order_status,sum(order_products_value),sum(order_freight_value),customer_state,week
from ecommerce_table group by id, order_status,customer_state,week"""
)
# save df1
df1.show()

#7
df1 = spark.sql(
    """ select id,
order_status,sum(order_products_value),sum(order_freight_value),customer_state,day
from ecommerce_table group by id, order_status,customer_state,day"""
)
# save df1
df1.show()

print("last")
#8
df1 = spark.sql(
    """ select id,
order_status,sum(order_products_value),sum(order_freight_value),customer_state,day
from ecommerce_table group by id, order_status,customer_state,day"""
)
# save df1
df1.show()


