-- =============================================================================
-- Create Fact Table: gold.fact_sales
-- =============================================================================

CREATE VIEW gold.fact_sales AS
SELECT
	sd.sls_ord_num AS order_number,
	pr.product_key,
	cu.customer_key,
	sd.sls_order_dt AS order_date,
	sd.sls_ship_dt AS shipping_date,
	sd.sls_due_dt AS due_date,
	sd.sls_sales AS sales_amount,
	sd.sls_quantity AS quantity,
	sd.sls_price AS price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr --including surrogate keys from relevant tables
ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu
ON sd.sls_cust_id = cu.customer_id

/*
Starting code was the following and went through the following steps to get to the final code:

SELECT
	sd.sls_ord_num,
	sd.sls_prd_key,
	sd.sls_cust_id,
	sd.sls_order_dt,
	sd.sls_ship_dt,
	sd.sls_due_dt,
	sd.sls_sales,
	sd.sls_quantity,
	sd.sls_price
FROM silver.crm_sales_details sd


==========
Step 1:
==========
Is this a dimension or fact? This table connects multiple dimensions with keys and has numeric measures so it is a fact table.

==========
Step 2:
==========
Include surrogate keys from the dimensions to connect facts to dimensions. Uses left joins.

==========
Step 3:
==========
Rename columns and reorder to Dimension keys first, then dates, then measures. Also follow naming convention.

==========
Step 4:
==========
create view in gold layer.
*/

-- =============================================================================
-- Create Dimension: gold.dim_customers
-- =============================================================================

CREATE VIEW gold.dim_customers AS
SELECT
	ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key, -- surrogate key
	ci.cst_id AS customer_id,
	ci.cst_key AS customer_number,
	ci.cst_firstname AS first_name,
	ci.cst_lastname AS last_name,
	ci.cst_marital_status AS marital_status,
	CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
		ELSE COALESCE(ca.gen, 'n/a') 
	END AS gender, -- combines the two gender informations from crm and erp to create a more complete column. crm is master.
	ca.bdate AS birth_date,
	ci.cst_create_date AS create_date,
	la.cntry AS country
FROM silver.crm_cust_info ci 
LEFT JOIN silver.erp_cust_az12 ca
ON		ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON		ci.cst_key = la.cid

/* 
Starting code was the following and went through the following steps to get to the final code:

SELECT
	ci.cst_id,
	ci.cst_key,
	ci.cst_firstname,
	ci.cst_lastname,
	ci.cst_marital_status,
	ci.gndr
	ci.cst_create_date,
	ca.bdate,
	ca.gen,
	la.cntry
FROM silver.crm_cust_info ci 
LEFT JOIN silver.erp_cust_az12 ca
ON		ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON		ci.cst_key = la.cid


==========
Step 1:
==========
-- Wrap query in SELECT cst_id, COUNT(*) FROM (
-- QUERY
-- )t GROUP BY cst_id HAVING COUNT(*) > 1 to find duplicates coming from the left join.

==========
Step 2:
==========
Gender appears twice so we merge them to create a combined column with better data quality.
In this cast the crm is the master table, so the erp table info will only write to the new col if crm is n/a

CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
		ELSE COALESCE(ca.gen, 'n/a') 
	END AS new_gen

==========
Step 3:
==========
Rename & reorder the columns to something user friendly while maintaining naming conventions:
	- snake_case
	- english for all names
	- avoid SQL reserved words
==========
Step 4:
==========
Generate a surrogate key assigned for each record in the table. This acts as a primary key although it is system generated and has no 
business use or information. 

==========
Step 5:
==========
Create this table as a view. A view will update automatically when underlying tables update and is easy to use for analytics 
and reporting without worrying about the underlying structure.
CREATE VIEW gold.dim_customers AS
*/

-- =============================================================================
-- Create Dimension: gold.dim_products
-- =============================================================================

CREATE VIEW gold.dim_products AS
SELECT
	ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key, -- surrogate key
	pn.prd_id AS product_id,
	pn.prd_key AS product_number,
	pn.prd_nm AS product_name,
	pn.cat_id AS category_id,
	pc.cat AS category,
	pc.subcat AS subcategory,
	pc.maintenance,
	pn.prd_cost AS cost,
	pn.prd_line AS product_line,
	pn.prd_start_dt AS start_date
FROM SILVER.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON pn.cat_id = pc.id
WHERE pn.prd_end_dt IS NULL -- Filters out historical data. 


/*
Starting code was the following and went through the following steps to get to the final code:

SELECT
	pn.prd_id,
	pn. cat_id,
	pn.prd_key,
	pn.prd_nm,
	pn.prd_cost,
	pn.prd_line,
	pn.prd_start_dt,
	pn.prd_end_dt
FROM SILVER.crm_prd_info pn

==========
Step 1:
==========
Filter out historical data by adding WHERE prd_end_dt IS NULL

==========
Step 2:
==========
Add the left join to include data from the erp.px_cat_g1v2 table

==========
Step 3:
==========
Check for duplicates by wrapping the query in 
SELECT prd_id, COUNT(*) FROM (
QUERY
) t 
GROUP BY prd_id HAVING COUNT(*) > 1. 

==========
Step 4:
==========
Rename and reorder columns to be more user friendly while following naming convention. 

==========
Step 5:
==========
Decide if dimension or fact. It is a dimension because it has descriptive attributes. 

==========
Step 6:
==========
Create surrogate key.

==========
Step 7:
==========
Create View
*/
