Want to create a database and schemas where I want the below mentioned tables along with the columns in its suitable data type and scales
-RESTAURANTS (RESTAURANT_ID, RESTAURANT_NAME, CITY, CUISINE_TYPE, RATING)
- CUSTOMERS (CUSTOMER_ID, CUSTOMER_NAME, CITY, SIGNUP_DATE)
- FOOD_ORDERS (ORDER_ID, CUSTOMER_ID, RESTAURANT_ID, ORDER_DATE, 
  ORDER_AMOUNT, DELIVERY_FEE, DISCOUNT_AMOUNT, ORDER_STATUS, 
  PAYMENT_METHOD, DELIVERY_MINUTES)

I need to catch bad data before it flows downstream. The rules are:

1. Orders can't have an amount of 0 or less
2. ORDER_STATUS has to be one of: Pending, Confirmed, Preparing, Ready, 
   In Transit, Delivered, Cancelled — nothing else
3. Every RESTAURANT_ID on an order has to actually exist in the 
   RESTAURANTS table
4. If an order says "Delivered," it needs a DELIVERY_MINUTES value — 
   can't be null
5. No duplicate ORDER_IDs

Can you build me:

- A separate view for each rule that shows me exactly which rows are 
  breaking it (with a message explaining why)
- One summary view that just tells me pass/fail and how many violations 
  per rule, so I don't have to check five views every time
- A single "bad orders" report that shows each broken order once, with 
  whatever's most seriously wrong with it (duplicates and negative 
  amounts feel worse than a missing delivery time, so prioritize like that)
- A "clean" version of the orders table — same data, but deduped and with 
  all the bad rows filtered out, plus a net order value column 
  (amount + delivery fee - discount)
- A handful of dummy INSERTs so I can actually test this — a few normal 
  orders, and then one row that breaks each rule on purpose, labeled so I 
  know what's supposed to fail

This is Snowflake, so feel free to use Snowflake-specific stuff like 
QUALIFY or window functions instead of clunky subqueries where it makes 
things cleaner or faster.

One thing — if you notice my rules contradict each other, or contradict 
what I actually give you in code, don't just quietly pick one and fix it. 
Point it out to me first. I've made that mistake before where a comment 
said one thing and the code did another and nobody caught it for a while.-
