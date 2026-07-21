-- ===================================
-- Invalid orders report
-- ===================================
CREATE OR REPLACE VIEW INVALID_ORDERS_REPORT AS
WITH order_flags AS (
    SELECT 
        fo.ORDER_ID,
        fo.CUSTOMER_ID,
        fo.RESTAURANT_ID,
        fo.ORDER_DATE,
        fo.ORDER_AMOUNT,
        fo.ORDER_STATUS,
        fo.DELIVERY_MINUTES,
        r.RESTAURANT_ID AS MATCHED_RESTAURANT_ID,
        COUNT(*) OVER (PARTITION BY fo.ORDER_ID) AS ORDER_ID_OCCURRENCES
    FROM 
        FOOD_DELIVERY_DB.RAW.FOOD_ORDERS fo
    LEFT JOIN 
        FOOD_DELIVERY_DB.RAW.RESTAURANTS r 
        ON fo.RESTAURANT_ID = r.RESTAURANT_ID
)
SELECT 
    ORDER_ID,
    CUSTOMER_ID,
    RESTAURANT_ID,
    ORDER_DATE,
    ORDER_AMOUNT,
    ORDER_STATUS,
    DELIVERY_MINUTES,
    CASE
        WHEN ORDER_ID_OCCURRENCES > 1 THEN 'CRITICAL: Duplicate ORDER_ID detected'
        WHEN ORDER_AMOUNT < 0 THEN 'CRITICAL: Negative ORDER_AMOUNT detected'
        WHEN ORDER_STATUS NOT IN ('Pending', 'Confirmed', 'Preparing', 'Ready', 'In Transit', 'Delivered', 'Cancelled')
            THEN 'CRITICAL: Unsupported ORDER_STATUS value'
        WHEN MATCHED_RESTAURANT_ID IS NULL THEN 'CRITICAL: Invalid RESTAURANT_ID - restaurant does not exist'
        WHEN ORDER_STATUS = 'Delivered' AND DELIVERY_MINUTES IS NULL
            THEN 'WARNING: Missing DELIVERY_MINUTES for delivered order'
        ELSE 'OK'
    END AS VALIDATION_MESSAGE,
    CURRENT_TIMESTAMP() AS VALIDATION_TIMESTAMP
FROM 
    order_flags
WHERE 
    ORDER_ID_OCCURRENCES > 1
    OR ORDER_AMOUNT < 0
    OR ORDER_STATUS NOT IN ('Pending', 'Confirmed', 'Preparing', 'Ready', 'In Transit', 'Delivered', 'Cancelled')
    OR MATCHED_RESTAURANT_ID IS NULL
    OR (ORDER_STATUS = 'Delivered' AND DELIVERY_MINUTES IS NULL)
ORDER BY 
    ORDER_ID;

-- ===================================
-- Clean staging view 
-- ===================================
CREATE OR REPLACE VIEW CLEAN_ORDERS_STAGING AS
SELECT 
    fo.ORDER_ID,
    fo.CUSTOMER_ID,
    fo.RESTAURANT_ID,
    fo.ORDER_DATE,
    fo.ORDER_AMOUNT,
    fo.DELIVERY_FEE,
    fo.DISCOUNT_AMOUNT,
    (fo.ORDER_AMOUNT + fo.DELIVERY_FEE - fo.DISCOUNT_AMOUNT) AS NET_ORDER_VALUE,
    fo.ORDER_STATUS,
    fo.PAYMENT_METHOD,
    fo.DELIVERY_MINUTES,
    CURRENT_TIMESTAMP() AS STAGING_LOAD_TIMESTAMP
FROM 
    FOOD_DELIVERY_DB.RAW.FOOD_ORDERS fo
LEFT JOIN 
    FOOD_DELIVERY_DB.RAW.RESTAURANTS r 
    ON fo.RESTAURANT_ID = r.RESTAURANT_ID
QUALIFY 
    -- Keep only the first occurrence of each ORDER_ID (dedupe)
    ROW_NUMBER() OVER (PARTITION BY fo.ORDER_ID ORDER BY fo.ORDER_DATE) = 1
WHERE 
    fo.ORDER_AMOUNT >= 0
    AND fo.ORDER_STATUS IN ('Pending', 'Confirmed', 'Preparing', 'Ready', 'In Transit', 'Delivered', 'Cancelled')
    AND r.RESTAURANT_ID IS NOT NULL
    AND NOT (fo.ORDER_STATUS = 'Delivered' AND fo.DELIVERY_MINUTES IS NULL)
ORDER BY 
    fo.ORDER_ID;
