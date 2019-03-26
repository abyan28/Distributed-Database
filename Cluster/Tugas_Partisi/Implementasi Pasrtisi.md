# Implementasi Partisi

## 1. Mengecek Plugin Partition

Sebelum mengecek apakah plugin partition sudah aktif atau belum, kita buat database terlebih dahulu untuk menyimpan tabel-tabel yang akan kita buat nanti.

![](/partition/Screenshot/1.JPG)

Sudah kita buat database ``Partisi`` pada Service.

Lalu kita berikan permission agar user ``abyan`` dapat mengakses database ``partisi`` dari ProxySQL.

![](/partition/Screenshot/2.JPG)

Setelah itu, baru kita cek plugin partition-nya, dengan menggunakan syntax berikut:

```
SHOW PLUGINS
```

Lalu kita persempit dengan mengambil data ``Storage Engine``-nya.

```
SELECT
    PLUGIN_NAME,
    PLUGIN_STATUS,
    PLUGIN_TYPE
    FROM INFORMATION_SCHEMA.PLUGINS
    WHERE PLUGIN_TYPE='STORAGE ENGINE';
```
 Output yang dihasilkan sebagai berikut :

![](/partition/Screenshot/3.JPG)

## 2. Membuat Partisi
Membuat tabel dengan menggunakan partisi.

### 2.a. Range Partition

Membuat tabel ``rc1`` sekaligus membuat partisi ``p0`` jika value < 5,12. Value selainnya akan dimasukan ke dalam ``p3``.

~~~
CREATE TABLE rc1 (
    a INT,
    b INT
)
PARTITION BY RANGE COLUMNS(a, b) (
    PARTITION p0 VALUES LESS THAN (5, 12),
    PARTITION p3 VALUES LESS THAN (MAXVALUE, MAXVALUE)
);
~~~

![](/partition/Screenshot/4.JPG)

Insert nilai ke dalam ``rc1``, nanti nilai tersebut akan otomatis dikategorikan ke dalam partisi yang telah kita buat.

~~~
INSERT INTO rc1 (a,b) VALUES (4,11);
INSERT INTO rc1 (a,b) VALUES (5,11);
INSERT INTO rc1 (a,b) VALUES (6,11);
INSERT INTO rc1 (a,b) VALUES (4,12);
INSERT INTO rc1 (a,b) VALUES (5,12);
INSERT INTO rc1 (a,b) VALUES (6,12);
INSERT INTO rc1 (a,b) VALUES (4,13);
INSERT INTO rc1 (a,b) VALUES (5,13);
INSERT INTO rc1 (a,b) VALUES (6,13);
~~~

![](/partition/Screenshot/5.JPG)

Kita lakukan query sebagai berikut:

~~~
SELECT *,'p0' FROM rc1 PARTITION (p0) UNION ALL SELECT *,'p3' FROM rc1 PARTITION (p3) ORDER BY a,b ASC;
~~~

![](/partition/Screenshot/6.JPG)

Seperti yang bisa dilihat, yang memiliki nilai <= 5,12 akan dikategorikan ke dalam ``p0``.

### 2.b. List Partition

Membuat tabel ``serverlogs`` sekaligus membuat partisi dalam bentuk pembagian kode area sesuai partisi yang dibuat.

~~~
CREATE TABLE serverlogs (
    serverid INT NOT NULL, 
    logdata BLOB NOT NULL,
    created DATETIME NOT NULL
)
PARTITION BY LIST (serverid)(
    PARTITION server_east VALUES IN(1,43,65,12,56,73),
    PARTITION server_west VALUES IN(534,6422,196,956,22)
);
~~~

![](/partition/Screenshot/7.JPG)

Insert nilai ke dalam ``serverlogs``, nanti nilai tersebut akan otomatis dikategorikan ke dalam partisi yang telah kita buat.

~~~
INSERT INTO serverlogs (serverid, logdata, created) VALUES (1,'Test','2019-03-01 17:00:47');
INSERT INTO serverlogs (serverid, logdata, created) VALUES (43,'Test','2019-03-01 17:00:47');
INSERT INTO serverlogs (serverid, logdata, created) VALUES (534,'Test','2019-03-01 17:00:47');
INSERT INTO serverlogs (serverid, logdata, created) VALUES (956,'Test','2019-03-01 17:00:47');
~~~

![](/partition/Screenshot/8.JPG)

Terus kita coba melakukan query sebagai berikut:

~~~
SELECT *,'server_east' FROM serverlogs PARTITION (server_east) UNION ALL SELECT *,'server_west' FROM serverlogs PARTITION (server_west) ORDER BY serverid,server_east ASC;
~~~

![](/partition/Screenshot/9.JPG)

Pada hasil diatas, value yang dimasukan akan otomatis dipindahkan sesuai partisi yang dibuat, seperti pada contoh, yang memiliki ``serverid`` 1,43 akan dikelompokan kedalam wilayah ``server_east``.

### 2.3 Hash Partition
~~~
CREATE TABLE serverlogs2 (
    serverid INT NOT NULL, 
    logdata BLOB NOT NULL,
    created DATETIME NOT NULL
)
PARTITION BY HASH (serverid)
PARTITIONS 10;
~~~

![](/tugas_2_implementasi-partisi/screenshoot/create_hash.PNG)

Melakukan create table ``serverlogs2`` serta melakukan partisi dengan menggunakan hash, partisi yang dibuat adalah sebanyak 10.

~~~
INSERT INTO serverlogs2 (serverid, logdata, created) VALUES (1,'Test','2019-03-01 17:00:47');
INSERT INTO serverlogs2 (serverid, logdata, created) VALUES (43,'Test','2019-03-02 17:00:48');
INSERT INTO serverlogs2 (serverid, logdata, created) VALUES (65,'Test','2019-03-01 17:00:47');
INSERT INTO serverlogs2 (serverid, logdata, created) VALUES (12,'Test','2019-03-01 17:00:47');
INSERT INTO serverlogs2 (serverid, logdata, created) VALUES (56,'Test','2019-03-01 17:00:47');
INSERT INTO serverlogs2 (serverid, logdata, created) VALUES (73,'Test','2019-03-01 17:00:47');
INSERT INTO serverlogs2 (serverid, logdata, created) VALUES (534,'Test','2019-03-01 17:00:47');
INSERT INTO serverlogs2 (serverid, logdata, created) VALUES (6422,'Test','2019-03-01 17:00:47');
INSERT INTO serverlogs2 (serverid, logdata, created) VALUES (196,'Test','2019-03-01 17:00:47');
INSERT INTO serverlogs2 (serverid, logdata, created) VALUES (956,'Test','2019-03-01 17:00:47');
INSERT INTO serverlogs2 (serverid, logdata, created) VALUES (22,'Test','2019-03-01 17:00:47');
~~~

![](/tugas_2_implementasi-partisi/screenshoot/insert_value_hash.PNG)

Melakukan insert value kedalam ``serverlogs2``, yang nantinya value tersebut akan otomatis dipindahkan kedalam partisi yang telah dibuat berdasarkan hash.

~~~
SELECT *,'p0' FROM serverlogs2 PARTITION (p0) UNION ALL 
SELECT *,'p1' FROM serverlogs2 PARTITION (p1) UNION ALL 
SELECT *,'p2' FROM serverlogs2 PARTITION (p2) UNION ALL 
SELECT *,'p3' FROM serverlogs2 PARTITION (p3) UNION ALL 
SELECT *,'p4' FROM serverlogs2 PARTITION (p4) UNION ALL 
SELECT *,'p5' FROM serverlogs2 PARTITION (p5) UNION ALL 
SELECT *,'p6' FROM serverlogs2 PARTITION (p6) UNION ALL 
SELECT *,'p7' FROM serverlogs2 PARTITION (p7) UNION ALL 
SELECT *,'p8' FROM serverlogs2 PARTITION (p8) UNION ALL 
SELECT *,'p9' FROM serverlogs2 PARTITION (p9)
ORDER BY serverid ASC;
~~~

![](/tugas_2_implementasi-partisi/screenshoot/result_value_hash.PNG)

Pada hasil diatas, value yang dimasukan akan otomatis dipindahkan sesuai partisi yang dibuat berdasarkan hash dari masing masing value yang dimasukan, dan akan dikelompokan berdasarkan jumlah partisi yang dibuat dan dengan menggunakan N = MOD(expr, num).

### 2.4 Key Partition
~~~
CREATE TABLE serverlogs4 (
    serverid INT NOT NULL, 
    logdata BLOB NOT NULL,
    created DATETIME NOT NULL,
    UNIQUE KEY (serverid)
)
PARTITION BY KEY()
PARTITIONS 5;
~~~

![](/tugas_2_implementasi-partisi/screenshoot/create_key.PNG)

Melakukan create table ``serverlogs4`` serta melakukan partisi dengan menggunakan key, partisi yang dibuat adalah sebanyak 5.

~~~
INSERT INTO serverlogs4 (serverid, logdata, created) VALUES (1,'Test','2019-03-01 17:00:47');
INSERT INTO serverlogs4 (serverid, logdata, created) VALUES (43,'Test','2019-03-02 17:00:48');
INSERT INTO serverlogs4 (serverid, logdata, created) VALUES (65,'Test','2019-03-01 17:00:47');
INSERT INTO serverlogs4 (serverid, logdata, created) VALUES (12,'Test','2019-03-01 17:00:47');
INSERT INTO serverlogs4 (serverid, logdata, created) VALUES (56,'Test','2019-03-01 17:00:47');
INSERT INTO serverlogs4 (serverid, logdata, created) VALUES (73,'Test','2019-03-01 17:00:47');
INSERT INTO serverlogs4 (serverid, logdata, created) VALUES (534,'Test','2019-03-01 17:00:47');
INSERT INTO serverlogs4 (serverid, logdata, created) VALUES (6422,'Test','2019-03-01 17:00:47');
INSERT INTO serverlogs4 (serverid, logdata, created) VALUES (196,'Test','2019-03-01 17:00:47');
INSERT INTO serverlogs4 (serverid, logdata, created) VALUES (956,'Test','2019-03-01 17:00:47');
INSERT INTO serverlogs4 (serverid, logdata, created) VALUES (22,'Test','2019-03-01 17:00:47');
INSERT INTO serverlogs4 (serverid, logdata, created) VALUES (5543,'Test','2019-03-01 17:00:47');
~~~

![](/tugas_2_implementasi-partisi/screenshoot/insert_value_key.PNG)

Melakukan insert value kedalam ``serverlogs4``, yang nantinya value tersebut akan otomatis dipindahkan kedalam partisi yang telah dibuat berdasarkan key.

~~~
SELECT *,'p0' FROM serverlogs4 PARTITION (p0) UNION ALL 
SELECT *,'p1' FROM serverlogs4 PARTITION (p1) UNION ALL 
SELECT *,'p2' FROM serverlogs4 PARTITION (p2) UNION ALL 
SELECT *,'p3' FROM serverlogs4 PARTITION (p3) UNION ALL 
SELECT *,'p4' FROM serverlogs4 PARTITION (p4)
ORDER BY serverid ASC;
~~~

![](/tugas_2_implementasi-partisi/screenshoot/result_value_key.PNG)

Pada hasil diatas, value yang dimasukan akan otomatis dipindahkan sesuai partisi yang dibuat berdasarkan key dari masing masing value yang dimasukan, dan akan dikelompokan berdasarkan jumlah partisi yang dibuat, pada partisi key ini memiliki kesamaan dengan hash, hanya saja berdasarkan unique key yang dibuat pada saat create table.

## 3. Testing "A Typical Use Case: Time Series Data"

### Using Explain

![](/tugas_2_implementasi-partisi/screenshoot/explain_measures.PNG)

Hasil explain pada table measure.

![](/tugas_2_implementasi-partisi/screenshoot/explain_measures_partition.PNG)

Hasil explain pada table measure partitioned.

### The SELECT Queries Benchmark

![](/tugas_2_implementasi-partisi/screenshoot/select_measures.PNG)

Hasil select pada table measure.

![](/tugas_2_implementasi-partisi/screenshoot/select_measures_partition.PNG)

Hasil select pada table measure partitioned.

### The Big Delete Benchmark

~~~
ALTER TABLE `tugas2`.`measures` 
ADD INDEX `index1` (`measure_timestamp` ASC);

ALTER TABLE `tugas2`.`partitioned_measures` 
ADD INDEX `index1` (`measure_timestamp` ASC);
~~~

Mencoba penghapusan besar-besaran data lama dan melihat berapa lama, sebelum itu melakukan penambahan indeks kembali pada kedua table.

![](/tugas_2_implementasi-partisi/screenshoot/delete_measures.PNG)

Hasil delete pada table measure.

![](/tugas_2_implementasi-partisi/screenshoot/delete_measures_partition.PNG)

Hasil delete pada table measure partitioned.

![](/tugas_2_implementasi-partisi/screenshoot/delete_measures2.PNG)

Hasil delete pada table measure membutuhkan waktu lebih dari 2 menit.

![](/tugas_2_implementasi-partisi/screenshoot/delete_measures_partition2.PNG)

Hasil delete pada table measure partitioned waktu sangat cepat tidak mencapai 5 detik.

#### Conclusion

Kesimpulan pada penggunaan partisi ini, data akan lebih cepat dan dalam pencarian akan lebih mudah, karena data sudah di bagi kedalam beberapa partisi yang telah di atur sesuai partisi yang dibutuhkan.


# 4. Referensi
https://www.vertabelo.com/blog/technical-articles/everything-you-need-to-know-about-mysql-partitions