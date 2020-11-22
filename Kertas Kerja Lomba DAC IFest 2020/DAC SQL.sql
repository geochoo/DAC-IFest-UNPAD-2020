# mendapatkan data penjualan per bulan dari 2019-2020
select EXTRACT(YEAR_MONTH FROM created_at) as tahun_bulan, count(1) as jumlah_transaksi, sum(total) as total_nilai_transaksi
from orders
where created_at>='2019-01-01'
group by 1
order by 1;

#mendapatkan data penjualan per tahun 2019-2020
select EXTRACT(YEAR FROM created_at) as tahun, count(1) as jumlah_transaksi, sum(total) as total_nilai_transaksi
from orders
where created_at>='2019-01-01'
group by 1
order by 1;

# Mencari top 5 product terlaris
select category, sum(quantity) as total_quantity, sum(price*quantity) as total_price from orders
inner join order_details using(order_id)
inner join products using(product_id)
where created_at >= '2019-01-01'
and delivery_at IS NOT NULL
group by 1
order by 2 desc
limit 5

# Mencari top 5 category revenue
select category, sum(quantity) as total_quantity, sum(price*quantity) as total_price from orders
inner join order_details using(order_id)
inner join products using(product_id)
where created_at >= '2019-01-01'
and delivery_at IS NOT NULL
group by 1
order by 3 desc
limit 5

# Pembeli Dropshipper
SELECT nama_user as nama_pembeli, COUNT(1) as jumlah_transaksi, COUNT(DISTINCT orders.kodepos) as distinct_kodepos, SUM(total) as total_nilai_transaksi, AVG(total) as avg_nilai_transaksi
FROM orders
INNER JOIN users on buyer_id = user_id
where created_at >= '2019-01-01'
and delivery_at IS NOT NULL
GROUP BY user_id, nama_user
HAVING COUNT(1) >=10 AND COUNT(1) = COUNT(DISTINCT orders.kodepos)
ORDER BY 2 DESC

# Mencari reseller offline
SELECT nama_user AS nama_pembeli, COUNT(1) as jumlah_transaksi, SUM(total) as total_nilai_transaksi, AVG(total) as avg_nilai_transaksi, AVG(total_quantity) as avg_quantity_per_transaksi
FROM orders
INNER JOIN users ON buyer_id = user_id
INNER JOIN (SELECT order_id, SUM(quantity) as total_quantity FROM order_details GROUP BY 1) as summary_order USING (order_id)
WHERE orders.kodepos = users.kodepos
GROUP BY user_id, nama_user
HAVING COUNT(1)>=8 AND AVG(total_quantity)>10
ORDER BY 3 DESC

# Mencari pembeli sekaligus penjual
SELECT nama_user AS nama_pengguna, jumlah_transaksi_beli, jumlah_transaksi_jual
FROM users
INNER JOIN (SELECT buyer_id, COUNT(1) AS jumlah_transaksi_beli
FROM orders GROUP BY 1) AS buyer on buyer_id = user_id
INNER JOIN (SELECT seller_id, COUNT(1) AS jumlah_transaksi_jual
FROM orders GROUP BY 1) AS seller on seller_id = user_id
WHERE jumlah_transaksi_beli >= 7 ORDER BY 1

# Lama transaksi dibayar
select EXTRACT(YEAR_MONTH FROM created_at) as tahun_bulan, count(1) as jumlah_transaksi,
avg(DATEDIFF(paid_at, created_at)) as avg_lama_dibayar,
min(DATEDIFF(paid_at, created_at)) min_lama_dibayar,
max(DATEDIFF(paid_at, created_at)) max_lama_dibayar
from orders
where paid_at is not null
group by 1
order by 1