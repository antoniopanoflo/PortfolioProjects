

/*
Table misc.abc_bids contains the bids that people made on auctions of seller ABC
Table misc.abc_orders contains the orders from people who won the auctions of seller ABC
*/


-- How many bidders were there in October?
SELECT count(distinct bidder_id) 
FROM misc.abc_bids 
WHERE auction_date LIKE '%/10/%'


-- How many bids did each of these bidders make in October?
SELECT bidder_id, count(bid_id) AS count_of_bids
FROM  misc.abc_bids
WHERE MONTH(bid_date) = 10
GROUP BY bidder_id


-- What is the ratio of bids in Consumer Electronics vs. Apparel?
SELECT count(*), stock_category_name
FROM misc.abc_bids
WHERE stock_category_name LIKE '%Apparel%' OR
          stock_category_name LIKE '%Consumer%'
GROUP BY stock_category_name


-- How many bids were placed on Consumer Electronics & Furniture auctions, where the retail price was under $25,000?
-- The three distinct categories were Electronic, Furniture, and Apparel.
SELECT distinct(stock_category_name)
FROM misc.abc_orders

SELECT count(*)
FROM misc.abc_orders
WHERE stock_category_name NOT LIKE '%Apparel%'
AND retail_price < 25000


-- How many first-time bidders did we have in November? 
-- Selecting all bidder id's not found previously in the column before month 11.
SELECT count(bidder_id)
FROM misc.abc_bids
WHERE month(bid_date) = 11
AND bidder_id NOT IN (SELECT bidder_id
FROM misc.abc_bids
WHERE month(bid_date) < 11)

