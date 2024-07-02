from pyspark.sql import SparkSession
from pyspark.sql import functions as F


def main(bucket: str) -> None:
    print("Running my code")
    spark = SparkSession.builder.appName("BigDataApp").getOrCreate()

    spark.conf.set("spark.sql.legacy.timeParserPolicy", "LEGACY")

    # Define the S3 path
    s3_input_path = f"s3://{bucket}/olist_public_dataset.csv"
    s3_output_path = f"s3://{bucket}/output/"

    df = spark.read.csv(s3_input_path, header=True)

    # Read CSV from S3
    df = spark.read.csv(s3_input_path, header=True)
    df.printSchema()

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

    def write_to_s3(df, file_name):
        df.write.parquet(s3_output_path + file_name)

    # By city
    # 1
    df1 = spark.sql(
        """select id, order_status, sum(order_products_value) as sum_order_products_value, sum(order_freight_value) as sum_order_freight_value, customer_city, day
            from ecommerce_table group by id, order_status, customer_city, day"""
    )
    write_to_s3(df1, "orderstatusgroupedbycityandday.parquet")

    # 2
    df1 = spark.sql(
        """select id, order_status, sum(order_products_value) as sum_order_products_value, sum(order_freight_value) as sum_order_freight_value, customer_city, week
            from ecommerce_table group by id, order_status, customer_city, week"""
    )
    write_to_s3(df1, "orderstatusgroupedbycityandweek.parquet")

    # By state
    # 3
    df1 = spark.sql(
        """select id, order_status, sum(order_products_value) as sum_order_products_value, sum(order_freight_value) as sum_order_freight_value, customer_state, day
            from ecommerce_table group by id, order_status, customer_state, day"""
    )
    write_to_s3(df1, "orderstatusgroupedbystateandday.parquet")

    # 4
    df1 = spark.sql(
        """select id, order_status, sum(order_products_value) as sum_order_products_value, sum(order_freight_value) as sum_order_freight_value, customer_state, week
            from ecommerce_table group by id, order_status, customer_state, week"""
    )

    write_to_s3(df1, "orderstatusgroupedbystateandweek.parquet")

    print("Finished")


if __name__ == "__main__":
    BUCKET = "data-analysis-ecommerce"
    main(BUCKET)
