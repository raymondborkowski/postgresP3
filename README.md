# postgresP3
EECS484 P3 w/ PostgreSql
.
In this assignment, we will work with a small subset of an online e­commerce dataset called
Dell DVD Store (http://linux.dell.com/dvdstore/). This dataset has information about
customers, products, and orders. Although there are 8 tables in the dataset, our exercises will
focus on the following two tables (you can see the schema and indices on a table by doing
\d+ tablename):
Customers (customerid, firstname, lastname, city, state, country, …)
Orders (orderid, orderdate, customerid, netamount, tax, totalamount)
