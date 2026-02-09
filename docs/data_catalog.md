## Data Dictionary for Gold Layer

#### Overview
###### The Gold Layer is the business-level data respresentation, structured to support data reporting and analytical use cases. It consists of **dimensions** and **fact tables** for specific business metrics.
---

##### 1. `gold.dim_customers`
- **Purpose:** Stores customers details enriched with demographic and geographic data
- **Columns:**

| Column Name | Data Type | Description |
| :--- | :---: | :--- |
| customer_key | INT | Surrogate Key uniquely identifying each customer record in the dimension table |
| customer_id | INT | Unique numerical identifier assigned to each customer |   
| customer_number | NVARCHAR(50) | Alphanumeric identifier represnting the customer, used for tracking and referencing |
| first_name | NVARCHAR(50) | The customer's first name, as recorded in the system |
| last_name | NVARCHAR(50) | The customer's last name or family name |
| country | NVARCHAR(50) | The country of residence for the customer (e.g. 'Australia')  |
| marital_status | NVARCHAR(50) | The marital status of the customer (e.g. 'Married'), 'Single' |
| gender | NVARCHAR(50) | The gender of the customer (e.g. 'Male', 'Female', 'n/a') |
| birthdate | DATE | The date of the birth of the customer, formatted as YYYY-MM-DD (e.g. 1971-01-01) |
| create_date | DATE | The date and time when the customer record was created in the system |

---

##### 1. `gold.dim_products`
- **Purpose:** Provides products information and their attributes
- **Columns:**
| Column Name | Data Type | Description |
| :--- | :---: | :--- |
| product_key | INT | Surrogate Key uniquely identifying each customer record in the dimension table |
| product_id | INT | Unique numerical identifier assigned to each customer |   
| product_number | NVARCHAR(50) | Alphanumeric identifier represnting the customer, used for tracking and referencing |
| product_name | NVARCHAR(50) | The customer's first name, as recorded in the system |
| category_id | NVARCHAR(50) | The customer's last name or family name |
| category | NVARCHAR(50) | The country of residence for the customer (e.g. 'Australia')  |
| subcategory | NVARCHAR(50) | The marital status of the customer (e.g. 'Married'), 'Single' |
| maintenance | NVARCHAR(50) | The gender of the customer (e.g. 'Male', 'Female', 'n/a') |
| cost | INT | The date of the birth of the customer, formatted as YYYY-MM-DD (e.g. 1971-01-01) |
| product_line | NVARCHAR(50) | The date of the birth of the customer, formatted as YYYY-MM-DD (e.g. 1971-01-01) |
| start_date | DATE | The date and time when the customer record was created in the system |
