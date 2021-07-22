

                               ----------BIKE STORE DATA ANALYSIS-----------

                                ----------I. Ad Hoc Requests-------------

--1.Our customer Kaylee English said she put an order on April 1st/2018, but has not yet received her order. Does that database show that we shipped the order? If so when?

Select order_date,order_status,shipped_date
From sales.orders
Where customer_id in
(
Select customer_id
From sales.customers 
Where first_name= 'kaylee' and
last_name='English' and 
order_date='2018-04-01'
);

--2. A new customer wants to buy 10 of our "Trek Slash 8 27.5-2016" product. do we have 10 of those currently in stock?

Select store_name,product_name,quantity
From production.stocks
Join production.products
On production.stocks.product_id=production.products.product_id
Join sales.stores
On sales.stores.store_id=production.stocks.store_id
Where Product_name='Trek Slash 8 27.5 - 2016';

--3. How much money total has Jeanie Kirkland spent at our stores?

Select first_name,last_name,order_date,total_purchase 
From sales.orders
Join 
(
  Select order_id,sum(quantity*list_price*(1-discount)) As total_purchase
From sales.order_items
Group by order_id
)As purchase_items
On sales.orders.order_id=purchase_items.order_id
Join sales.stores
On sales.stores.store_id=sales.orders.store_id
Join sales.customers
On sales.customers.customer_id=sales.orders.customer_id
Where  first_name='Jeanie'
And last_name='kirkland';

--4. How many of our "Electra Townie original 7D-2015/2016" did Margit Osborn order on 2/3/2016?

Select first_name,last_name,product_name, order_date,quantity 
From
sales.order_items
Join sales.orders
on sales.order_items.order_id=sales.orders.order_id
Join sales.customers
on sales.customers.customer_id=sales.orders.customer_id
Join production.products
On production.products.product_id=sales.order_items.product_id
Where product_name='Electra Townie original 7D - 2015/2016'
And order_date = '2016-02- 03'
And first_name='Margit'
And last_name='osborn';


            --------II.Quality Control Reports----------

--5.How much did Marcelene Boyer do in total sales for the month of april 2018?

 Select first_name, last_name,(quantity*list_price*(1-discount))As totalsale,order_date 
 From sales.orders
 Join sales.staffs
 On sales.orders.staff_id=sales.staffs.staff_id
 Join sales.order_items
 On sales.order_items.order_id=sales.orders.order_id
 Where order_date between '2018-04-01' And '2018-04-30' 
 And first_name='Marcelene' 
 And last_name='Boyer';

--6.I'd like to see a list of all orders that shipped after the required date, for each of our 3 stores.

   Select  so.order_id,item_id,store_name,required_date,shipped_date 
   From sales.orders As so
   Join sales.stores
   On so.store_id= sales.stores.store_id
   Join sales.order_items
   On sales.order_items.order_id=so.order_id
   Where required_date < shipped_date;

--7.Get me a list of all products of which we have less than five units in stock.

Select product_name,quantity
From production.stocks
Join production.products
On production.stocks.product_id=production.products.product_id
Where quantity < 5;

--8.I am seeing some prices that were entered incorrectly. Can you run a report of all products where the price is more than 5000?

Select product_id,product_name,model_year,list_price
From production.products
Where list_price>=5000
Order by list_price Desc;

--9.What are our top 10 best selling products.

Select top_ten.product_id,product_name,top_ten.toptenth 
From Production.products
Join
(
  select top 10 Sum(quantity*list_price*(1-discount))As toptenth,product_id
From sales.order_items
Group by product_id
)As top_ten
On production.products.product_id=top_ten.product_id;

--10. What is our average ship time each month at each of our stores?

Select store_name,order_date,shipped_date,datediff(dd,order_date,shipped_date)as delivery
From sales.orders
Join sales.stores
On sales.stores.store_id=sales.orders.store_id;

--11.What products have we not sold at all since January 1st,2017?

Select product_id,product_name 
From production.products
Where product_id not in
(
  Select product_id
From sales.orders
Join sales.order_items
On sales.order_items.order_id=sales.orders.order_id
Where order_date>='2017-01-01'
)

--12.can you give me a list of all of the orders that haven't been shipped yet for each store?

  Select n_shipped.order_id,Product_name,n_shipped.store_name,n_shipped.shipped_date  
  From sales.order_items
  Join
  (
    Select order_id,store_name,shipped_date
  From sales.orders
  Join sales.stores
  On sales.orders.store_id=sales.stores.store_id
  Where order_status=3
  ) As n_shipped
  On n_shipped.order_id=sales.order_items.order_id
  join production.products
  on production.products.product_id=sales.order_items.product_id;

                             -----------III. Performance Reports/Dashboards------------
--13.What are our monthly sales numbers for each store.

   Select store_name,order_date,sales.total_sale
   From sales.orders
   Join
   (
     Select order_id,Sum(quantity*list_price*(1-discount))As total_sale
   From sales.order_items
   Group by order_id
   ) As sales
   On sales.order_id=sales.orders.order_id
   Join sales.stores
   On sales.stores.store_id=sales.orders.store_id



--14.I'd like to see a report of each employee's total sales for the years 2017 and 2018?

  Select ss.staff_id, ss.first_name,ss.last_name,sales.order_id,sales.total_sale  
  From sales.orders
  Join
  (
    Select order_id,Sum(list_price*quantity*(1-discount))As total_sale
  From sales.order_items 
  Group by order_id
  ) As sales
  On sales.order_id=sales.orders.order_id
  Join sales.staffs As ss
  On ss.staff_id=sales.orders.staff_id
  Where order_date between '01-01-2017' and '2018-12-31'
  Order by first_name;

--15.I'd like to see each store's average order value each month for the last 12 months?

Select store_name,(list_price*quantity*(1-discount)) As order_value ,order_date
From sales.orders
Join sales.order_items
On sales.orders.order_id=sales.order_items.order_id
Join sales.stores
On sales.stores.store_id=sales.orders.store_id
Order by store_name;

--16. I would  like to see a report of the top 20 zip codes with the greatest total sales.

Select sales.orders.order_id,zip_code,order_date,items.order_value
From sales.orders
Join
(
Select top 20 Sum (list_price*quantity*(1-discount)) As  order_value,order_id
From sales.order_items
Group by order_id
)As items
On sales.orders.order_id=items.order_id
Join sales.customers
On sales.customers.customer_id=sales.orders.customer_id
Order by  order_value Desc;   

--17.show me how much each store is giving in discounts each month? store name.

Select total_discount.order_id,store_name,total_discount.sales_discount,order_date
From sales.orders
join
(
  Select order_id,Sum(discount*quantity*list_price) As sales_discount 
From sales.order_items
Group by order_id
)As total_discount
On total_discount.order_id=sales.orders.order_id
Join sales.stores
On sales.stores.store_id=sales.orders.store_id
Order by store_name;

--18.How much did we sell of each product branded per year?

Select bn.brand_name,order_date,(quantity*list_price*(1-discount))as sales
From sales.order_items   soi
join
(
  Select  pb.brand_id,brand_name,product_id
From production.brands     pb
Join production.products   pp
On pb.brand_id=pp.brand_id
) As bn
On soi.product_id=bn.product_id
Join sales.orders so
On so.order_id=soi.order_id

--19.I'd like to see the share of total sales of each product catagory.

Select category_name ,grand_total.product_id,grand_total.total_sales
From production.products
Join
(
  Select product_id,sum(quantity*list_price*(1-discount)) As total_sales
From sales.order_items
Group by product_id
)As grand_total
On grand_total.product_id=production.products.product_id
Join
production.categories
On 
production.products.category_id=production.categories.category_id


















