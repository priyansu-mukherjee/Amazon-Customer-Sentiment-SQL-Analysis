/*
PROJECT: Amazon Customer Reviews Analysis & Applications

I have conducted Exploratory Data Analysis(EDA) on customer reviews, rating patterns,
and temporal satisfaction trends to identify actionable product enhancement
and market segment oppurtunities.

Created by Priyansu Mukherjee
Date: August 2026     
*/     

          
create database projects;

use projects;

create table Amazon_Reviews
(
Reviewer_Name varchar(255),
Profile_Link varchar(255),
Country varchar(255),
Review_Count varchar(255),
Review_Date datetime,
Rating varchar(255),
Review_Title varchar(255),
Review_Text varchar(255),
Date_Of_Experience varchar(255)
);

LOAD DATA LOCAL INFILE 'C:/Users/there/Downloads/Amazon_Reviews.csv'
INTO TABLE Amazon_Reviews
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

select * from Amazon_Reviews limit 22000;



-- 1. Sentiment Analysis of Customers
select 
case
when trim(Rating) like '%4 out of 5%' or trim(rating) like '%5 out of 5%' then 'Positive'
when trim(Rating) like '%3 out of 5%' then 'Neutral'
when trim(Rating) like '%2 out of 5%' or trim(rating) like '%1 out of 5%' then 'Negative'
else 'Unrated'
End as 'Sentiment',
Count(*) as Total_Reviews,
ROUND((COUNT(*) * 100.0)/ (SELECT COUNT(*) FROM Amazon_Reviews),2) as Percentage
from Amazon_Reviews
group by Sentiment
order by Total_Reviews desc

/*
Task 1 Insights:
- Negative: 68.15% (Most customers are unhappy with 1-2 star ratings)
- Positive: 27.64% (About a quarter of reviews are happy with 4-5 stars)
- Neutral : 4.20% (Small group of 3-star ratings)
  
Takeaway: Urgent attention needed to fix issues in negative reviews.
*/
;



-- 2. Customer Satisfaction Tracking Over Time

select 
date_format(Review_Date, '%Y-%m') as review_month,
count(*) as total_reviews,
round(avg(
case 
when trim(Rating) like 'Rated 5%' then 5
when trim(Rating) like 'Rated 4%' then 4
when trim(Rating) like 'Rated 3%' then 3
when trim(Rating) like 'Rated 2%' then 2
when trim(Rating) like 'Rated 1%' then 1
else null 
end), 2) as avg_satisfaction_score
from Amazon_Reviews
where Review_Date is not null
group by review_month
order by review_month asc;

/*
Customer Satisfaction Analysis
-Historical Highs (2008–2013):
The data reflects strong historical customer satisfaction, featuring 13 
months where average satisfaction scores reached a peak of 5.0.
-Recent Performance Decline (2020–2024):
Recent years show a significant downturn in user sentiment, with 55 
months recording average ratings below 2.0.

Customer experience has experienced a notable multi-year decline. 
It is recommended to investigate post-2020 operational or product-level 
changes to identify the primary drivers behind this trend.
*/




/* 3. Product Improvement

I am typing the below syntax to find out keywords I can use for better analysis
*/ 

select 
lower(Review_Title) as popular_complaint_titles, 
count(*) as count
from Amazon_Reviews
where (trim(Rating) like 'Rated 1%' or trim(Rating) like 'Rated 2%')
group by lower(Review_Title)
order by count desc
;

-- Let's see where we can improve
select 
case 
-- 1. Customer Service & Support
when lower(concat(ifnull(Review_Title, ''), ' ', ifnull(Review_Text, ''))) regexp 'service|support|agent|chat|phone|help|call|rep|representative|contact|email|response'
then 'Customer Service & Support Issues'
        
-- 2. Delivery & Shipping
when lower(concat(ifnull(Review_Title, ''), ' ', ifnull(Review_Text, ''))) regexp 'deliver|ship|packag|courier|mail|tracking|late|delay|arriv|never received|transit|box'
then 'Delivery & Shipping Issues'
        
-- 3. Refunds, Returns & Billing
when lower(concat(ifnull(Review_Title, ''), ' ', ifnull(Review_Text, ''))) regexp 'refund|return|money|charge|paid|cost|price|bill|expensive|scam|ripoff|stole|cheat'
then 'Refund, Billing & Pricing Issues'
        
-- 4. Product Quality, Damage & Defects
when lower(concat(ifnull(Review_Title, ''), ' ', ifnull(Review_Text, ''))) regexp 'quality|cheap|broken|damage|crack|defect|faulty|work|junk|garbage|trash|fake|plastic|item'
then 'Product Quality & Damage Issues'

-- 5. General Platform / Overall Dissatisfaction (Catches general rant words)
when lower(concat(ifnull(Review_Title, ''), ' ', ifnull(Review_Text, ''))) regexp 'amazon|zero star|never again|worst|terrible|horrible|awful|disappoint|bad|poor|useless|hate|avoid|suck'
then 'General Experience & Brand Frustration'

else 'Other Unclassified Complaints'
end as complaint_theme,
count(*) as issue_count,
round(count(*) * 100.0 / (select count(*) from Amazon_Reviews where trim(Rating) like 'Rated 1%' or trim(Rating) like 'Rated 2%'), 2) as percentage
from Amazon_Reviews
where trim(Rating) like 'Rated 1%' or trim(Rating) like 'Rated 2%'
group by complaint_theme
order by issue_count desc;

/*
Task 3 Verdict (Product & Service Improvement):
  
- Main Problem (55.3%): More than half of all bad reviews come from poor customer service and unhelpful support.
- Second Big Issue (24.3%): Almost a quarter of complaints are about late deliveries, shipping delays, and damaged packages.
- Billing & Refunds (8.7%): A smaller chunk of customers are upset about refund delays or pricing issues.
- Product Quality (2.9%): Very few people actually complain about the physical items being bad or broken.
  
Takeaway: The products themselves aren't the main issue—the real problem is how customer service and delivery are being managed. 
Fixing support response times and shipping reliability should be the top priority.
*/



-- Market Segmentation

select 
    trim(Country) as country,
    count(*) as total_reviews,
    round(count(*) * 100.0 / (select count(*) from Amazon_Reviews), 2) as market_share_percentage
from Amazon_Reviews
where Country is not null 
  and trim(Country) != ''
group by country
order by total_reviews desc;


/*
Task 4 Verdict (Market Segmentation):
  
- The US (44.1%) and the UK/GB (34.6%) make up nearly 80% of all customer reviews combined.
- Canada (3.4%) and India (3.0%) form the next layer of customer volume.
- Rest are very minor, >1%
  
  Takeaway: Marketing strategies, regional customer support, and inventory planning should prioritize the US and UK first, as they represent the vast majority of the customer base.
*/





/*
 Conclusion & Next Steps

 While overall product quality remains high, customer satisfaction has suffered 
 a severe multi-year drop driven almost entirely by post-purchase friction. The 
 vast majority of negative feedback points directly to unhelpful customer support 
 and shipping delays rather than product defects. Moving forward, priority must 
 be given to overhauling customer support response times and improving logistics 
 reliability, specifically targeting the US and UK markets to protect nearly 80% 
 of the active customer base.
*/

