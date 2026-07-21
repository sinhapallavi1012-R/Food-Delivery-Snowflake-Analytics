CREATE OR REPLACE TABLE RAW.RESTAURANTS(
RESTAURANT_ID INT,
RESTAURANT_NAME STRING,
CITY STRING,
CUISINE_TYPE STRING,
RATING NUMBER(2,1));

CREATE OR REPLACE TABLE RAW.CUSTOMERS(
CUSTOMER_ID INT,
CUSTOMER_NAME STRING,
CITY STRING,
SIGNUP_DATE DATE);

CREATE OR REPLACE TABLE RAW.FOOD_ORDERS(
ORDER_ID INT,
CUSTOMER_ID INT,
RESTAURANT_ID INT,
ORDER_DATE DATE,
ORDER_AMOUNT NUMBER(10,2),
DELIVERY_FEE NUMBER(10,2),
DISCOUNT_AMOUNT NUMBER(10,2),
ORDER_STATUS STRING,
PAYMENT_METHOD STRING,
DELIVERY_MINUTES INT);

-- Add 15-20 inserts including duplicate and invalid records.

- RESTAURANTS: 5 clean rows
INSERT INTO RAW.RESTAURANTS (RESTAURANT_ID, RESTAURANT_NAME, CITY, CUISINE_TYPE, RATING) VALUES
(101, 'Spice Villa', 'Patna', 'Indian', 4.5),
(102, 'Pizza Point', 'Delhi', 'Italian', 4.2),
(103, 'Sushi Central', 'Mumbai', 'Japanese', 4.7),
(104, 'Burger Hub', 'Bangalore', 'American', 3.9),
(105, 'Curry House', 'Patna', 'Indian', 4.1);
-- NOTE: Deliberately no RESTAURANT_ID = 999 here, used below to trigger Rule 3.
 
-- CUSTOMERS: 5 clean rows
INSERT INTO RAW.CUSTOMERS (CUSTOMER_ID, CUSTOMER_NAME, CITY, SIGNUP_DATE) VALUES
(1, 'Aarav Sharma', 'Patna', '2023-01-15'),
(2, 'Priya Singh', 'Delhi', '2023-03-22'),
(3, 'Rohan Gupta', 'Mumbai', '2022-11-05'),
(4, 'Neha Verma', 'Bangalore', '2023-06-10'),
(5, 'Kabir Khan', 'Patna', '2024-02-01');
 
-- FOOD_ORDERS: mix of clean rows + one violation per rule
INSERT INTO RAW.FOOD_ORDERS
(ORDER_ID, CUSTOMER_ID, RESTAURANT_ID, ORDER_DATE, ORDER_AMOUNT, DELIVERY_FEE, DISCOUNT_AMOUNT, ORDER_STATUS, PAYMENT_METHOD, DELIVERY_MINUTES)
VALUES
-- Clean, valid rows
(1001, 1, 101, '2024-05-01', 450.00, 30.00, 0.00,  'Delivered', 'Card', 35),
(1002, 2, 102, '2024-05-02', 320.50, 25.00, 20.00, 'Preparing', 'UPI',  NULL),
(1003, 3, 103, '2024-05-03', 899.00, 40.00, 0.00,  'Pending',   'Cash', NULL),
(1004, 4, 104, '2024-05-04', 210.00, 20.00, 10.00, 'In Transit','Card', NULL),
(1005, 5, 105, '2024-05-05', 675.25, 35.00, 0.00,  'Confirmed', 'UPI',  NULL),
 
-- Rule 1 violation: ORDER_AMOUNT <= 0
(1006, 1, 102, '2024-05-06', -50.00, 20.00, 0.00,  'Pending',   'Cash', NULL),
(1007, 2, 103, '2024-05-06',   0.00, 20.00, 0.00,  'Pending',   'Card', NULL),
 
-- Rule 2 violation: invalid ORDER_STATUS
(1008, 3, 101, '2024-05-07', 300.00, 25.00, 0.00,  'Out_For_Delivery', 'UPI', NULL),
 
-- Rule 3 violation: RESTAURANT_ID does not exist in RESTAURANTS
(1009, 4, 999, '2024-05-08', 550.00, 30.00, 0.00,  'Pending',   'Card', NULL),
 
-- Rule 4 violation: DELIVERED with NULL DELIVERY_MINUTES
(1010, 5, 104, '2024-05-09', 400.00, 30.00, 0.00,  'Delivered', 'Cash', NULL),
 
-- Rule 5 violation: duplicate ORDER_ID (1001 repeated)
(1001, 2, 105, '2024-05-10', 150.00, 15.00, 0.00,  'Cancelled', 'UPI', NULL);
