--Raymond Borkowski(rborkows)/Ryan Wolande(rynwola)
--1A.
\d+ customers

--1B.
SELECT relname,relkind,relpages FROM pg_class where relkind='r' order by relpages desc;
SELECT relname,relkind,relpages FROM pg_class where relkind='i' order by relpages desc;

--1C.
select n_distinct, attname from pg_stats where tablename='customers';
select count(*) from customers;

--1D.
SELECT count(DISTINCT customerid ),
 count(DISTINCT firstname ),
 count(DISTINCT lastname ),
 count(DISTINCT address1 ),
 count(DISTINCT address2 ),
 count(DISTINCT city ),
 count(DISTINCT state ),
 count(DISTINCT zip ),
 count(DISTINCT country ),
 count(DISTINCT region ),
 count(DISTINCT email ),
 count(DISTINCT phone ),
 count(DISTINCT creditcardtype ),
 count(DISTINCT creditcard ),
 count(DISTINCT creditcardexpiration ),
 count(DISTINCT username ),
 count(DISTINCT password ),
 count(DISTINCT age ),
 count(DISTINCT income ),
 count(DISTINCT gender ) FROM Customers;

--#2A.
EXPLAIN SELECT * FROM customers WHERE country = 'Japan';
SELECT * FROM customers WHERE country = 'Japan';

--#2B.
SELECT relpages, reltuples FROM pg_class WHERE relname = 'customers';

--#3A.

--#Given
\i setup_db.sql;
VACUUM;
ANALYZE;
CREATE INDEX customers_country ON customers(country);
VACUUM;
ANALYZE;

SELECT relpages FROM pg_class WHERE relname = 'customers_country';

--#3B.
EXPLAIN select * from customers where country = 'Japan';

--#3D.

--#Given
CLUSTER customers_country ON customers;
VACUUM;
ANALYZE;

EXPLAIN SELECT * FROM customers WHERE country = 'Japan';

--#4A.
--#given
\i setup_db.sql;
VACUUM;
ANALYZE;

EXPLAiN SELECT totalamount FROM Customers C, Orders O WHERE C.customerid=O.customerid AND C.country='Japan';

--#4B.
EXPLAIN SELECT totalamount FROM Customers C, Orders O WHERE C.customerid=O.customerid AND C.country='Japan';

--#4C.
--#told to do this
SET enable_hashjoin = off;

EXPLAIN SELECT totalamount FROM Customers C, Orders O WHERE C.customerid = O.customerid AND C.country = 'Japan';


--#4D
--#told to do this
SET enable_mergejoin = off;

EXPLAIN SELECT totalamount FROM Customers C, Orders O WHERE C.customerid = O.customerid AND C.country = 'Japan';

--#5A.
--#Told to do this
\i setup_db.sql;
VACUUM;
ANALYZE;
SET enable_hashjoin = on;
SET enable_mergejoin = on;

EXPLAIN SELECT AVG(totalamount) as avgOrder, country FROM Customers C, Orders O WHERE C.customerid = O.customerid GROUP BY country ORDER BY avgOrder;
SET enable_hashjoin = off;
EXPLAIN SELECT AVG(totalamount) as avgOrder, country FROM Customers C, Orders O WHERE C.customerid = O.customerid GROUP BY country ORDER BY avgOrder;

--#5B.

SET enable_hashjoin = on;
EXPLAIN SELECT * FROM Customers C, Orders O WHERE C.customerid = O.customerid ORDER BY C.customerid;
SET enable_mergejoin = off;
EXPLAIN SELECT * FROM Customers C, Orders O WHERE C.customerid = O.customerid ORDER BY C.customerid;

--#6A.
--#told to do this
SET enable_hashjoin = on;
SET enable_mergejoin = on;
\i setup_db.sql;
VACUUM;
ANALYZE;

Explain SELECT C.customerid, C.lastname FROM Customers C WHERE 4 < ( SELECT COUNT(*) FROM Orders O WHERE O.customerid = C.customerid);

--#6B.
CREATE VIEW OrderCount AS
SELECT C.customerid, count(C.customerid) AS numorders
FROM Customers C, Orders O WHERE O.customerid = C.customerid GROUP BY C.customerid ORDER BY count(C.customerid) desc;

--#6C.
SELECT C.lastname, C.customerid
	FROM Customers C, OrderCount
	WHERE 4 < OrderCount.numorders AND C.customerid = OrderCount.customerid;

--#6D.
EXPLAIN SELECT C.lastname, C.customerid FROM Customers C, OrderCount WHERE 4 <  OrderCount.numorders AND C.customerid = OrderCount.customerid;

--#7A.
--#told to do this
\i setup_db.sql;
VACUUM;
ANALYZE;

EXPLAIN SELECT customerid, lastname, numorders FROM ( SELECT 	C.customerid, C.lastname, count(*) as numorders FROM Customers C, Orders O WHERE 	C.customerid = O.customerid AND C.country = 'Japan' GROUP BY C.customerid, lastname) AS 	ORDERCOUNTS1 WHERE 5 >= (SELECT count(*) FROM ( SELECT C.customerid, C.lastname, 	count(*) as numorders FROM Customers C, Orders O WHERE C.customerid=O.customerid 	AND C.country = 'Japan' GROUP BY C.customerid, lastname) AS ORDERCOUNTS2 WHERE 	ORDERCOUNTS1.numorders < ORDERCOUNTS2.numorders) ORDER BY customerid;

--#7B
CREATE VIEW OrderCountJapan AS
SELECT C.customerid, C.lastname, count(*) AS numorders
FROM Customers C, Orders O WHERE C.country = 'Japan' AND O.customerid = C.customerid GROUP BY C.customerid, C.lastname;

CREATE VIEW MoreFrequentJapanCustomers AS
SELECT B.customerid, (SELECT count(A.numorders)
FROM OrderCountJapan A WHERE A.numorders > B.numorders) as oRank
FROM OrderCountJapan B;

--#7c
SELECT O.customerid, O.lastname, O.numorders
FROM OrderCountJapan O INNER JOIN MoreFrequentJapanCustomers F
ON O.customerid = F.customerid
WHERE 5 >= F.oRank ORDER BY customerid;

--#7D.
EXPLAIN SELECT O.customerid, O.lastname, O.numorders
FROM OrderCountJapan O INNER JOIN MoreFrequentJapanCustomers F
ON O.customerid = F.customerid
WHERE 5 >= F.oRank ORDER BY customerid;

--#8A.
\i setup_db.sql;
VACUUM;
ANALYZE;
CREATE TABLE CustomerOrders AS
SELECT Customers.customerid,
Customers.firstname,
Customers.lastname,
Customers.address1,
Customers.address2,
Customers.city,
Customers.state,
Customers.zip,
Customers.country,
Customers.region,
Customers.email,
Customers.phone,
Customers.creditcardtype,
Customers.creditcard,
Customers.creditcardexpiration,
Customers.username,
Customers.password,
Customers.age,
Customers.income,
Customers.gender,
Orders.orderid,
Orders.orderdate,
Orders.netamount,
Orders.tax,
Orders.totalamount FROM Customers JOIN Orders
ON Customers.customerid = Orders.customerid;

VACUUM;
ANALYZE;

--#8B.
SELECT Order_Count.lastname, Order_Count.numorders
FROM (
SELECT CustomerOrders.lastname, count(CustomerOrders.customerid) AS numorders
FROM CustomerOrders WHERE CustomerOrders.customerid = CustomerOrders.customerid GROUP BY CustomerOrders.customerid, CustomerOrders.lastname HAVING count(CustomerOrders.customerid) > 4 ORDER BY count(CustomerOrders.customerid) desc
) AS Order_Count;

--#8C.
EXPLAIN SELECT Order_Count.lastname, Order_Count.numorders
FROM (
SELECT CustomerOrders.lastname, count(CustomerOrders.customerid) AS numorders
FROM CustomerOrders WHERE CustomerOrders.customerid = CustomerOrders.customerid GROUP BY CustomerOrders.customerid, CustomerOrders.lastname ORDER BY count(CustomerOrders.customerid) desc
) AS Order_Count;



