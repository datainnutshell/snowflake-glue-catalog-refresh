resource "aws_athena_workgroup" "example" {
  name = "example-workgroup"
  configuration {
    result_configuration {
      output_location = "s3://${aws_s3_bucket.datalake.id}/athena_results/"
    }
  }
  force_destroy = true
  description = "Example Athena workgroup"
  state       = "ENABLED"
}

resource "aws_athena_named_query" "create_iceberg_table" {
  name      = "CreateIcebergTable"
  database  = aws_glue_catalog_database.catalog_sync_test.name
  query     = <<EOF
CREATE TABLE customers (
    customer_id BIGINT,
    customer_name STRING,
    email STRING,
    address STRING,
    phone STRING,
    created_at TIMESTAMP
)
LOCATION 's3://${aws_s3_bucket.datalake.bucket}/iceberg/customers/'
TBLPROPERTIES (
    'table_type' = 'ICEBERG',
    'format' = 'parquet'
);
EOF
  description = "Create an Iceberg table for customers data"
  workgroup   = aws_athena_workgroup.example.name
}

resource "aws_athena_named_query" "insert_into" {
  name      = "InsertIntoTest"
  database  = aws_glue_catalog_database.catalog_sync_test.name
  query     = <<EOF
INSERT INTO customers (customer_id, customer_name, email, address, phone, created_at)
VALUES
  (1, 'John Doe', 'john.doe@example.com', '123 Main St, Anytown, USA', '+1234567890', TIMESTAMP '2024-06-25 10:00:00'),
  (2, 'Jane Smith', 'jane.smith@example.com', '456 Elm St, Othertown, USA', '+1987654321', TIMESTAMP '2024-06-25 11:30:00'),
  (3, 'Michael Johnson', 'michael.johnson@example.com', '789 Oak St, Anycity, USA', '+1122334455', TIMESTAMP '2024-06-25 12:45:00'),
  (4, 'Emily Brown', 'emily.brown@example.com', '321 Pine St, Anothercity, USA', '+144332211', TIMESTAMP '2024-06-25 14:15:00');
EOF
  description = "Create an Iceberg table for customers data"
  workgroup   = aws_athena_workgroup.example.name
}