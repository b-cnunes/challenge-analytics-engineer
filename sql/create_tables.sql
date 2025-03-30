/*O exercicio foi feito e testado no Bigquery, por isso
as chaves [PRIMARY KEY] e [FOREIGN KEY] estao comentadas apenas para referencia*/ 

CREATE OR REPLACE TABLE `project.schema.customer` (
    customer_id INT64, -- PRIMARY KEY
    email STRING,
    first_name STRING,
    last_name STRING,
    gender STRING,
    birth_date STRING,
    address INT64,
    phone_number STRING,
    status STRING,
    is_seller BOOL,
    is_buyer BOOL
);

CREATE OR REPLACE TABLE `project.schema.item` (
    tem_id INT64, --PRIMARY KEY
    category_id INT64,
    product_name STRING,
    description STRING,
    status STRING,
    price FLOAT64,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    deleted_at TIMESTAMP,
    is_deleted BOOL
    --FOREIGN KEY (category_id) REFERENCES category(category_id)
);

CREATE OR REPLACE TABLE `project.schema.category` (
    category_id INT64, --PRIMARY KEY
    category_name STRING,
    status STRING,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE OR REPLACE TABLE `project.schema.orders` (
    order_id INT64 --PRIMARY KEY,
    cutomer_seller_id INT64,
    cutomer_buyer_id INT64,
    item_id INT64,
    quantity INT64, 
    value FLOAT64,
    status STRING,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
    --FOREIGN KEY (cutomer_seller_id) REFERENCES customer(cliente_id)
    --FOREIGN KEY (cutomer_buyer_id) REFERENCES customer(customer_id)
    --FOREIGN KEY (item_id) REFERENCES item(item_id)
);
