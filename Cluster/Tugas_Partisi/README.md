# Implementasi Partisi

## 1. Mengecek Plugin Partition

Sebelum mengecek apakah plugin partition sudah aktif atau belum, kita buat database terlebih dahulu untuk menyimpan tabel-tabel yang akan kita buat nanti.

![](https://github.com/abyan28/Distributed-Database/raw/master/Cluster/Tugas_Partisi/Screenshot/1.JPG)

Sudah kita buat database ``Partisi`` pada Service.

Lalu kita berikan permission agar user ``abyan`` dapat mengakses database ``partisi`` dari ProxySQL.

![](https://github.com/abyan28/Distributed-Database/raw/master/Cluster/Tugas_Partisi/Screenshot/2.JPG)

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

![](https://github.com/abyan28/Distributed-Database/raw/master/Cluster/Tugas_Partisi/Screenshot/3.JPG)

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

![](https://github.com/abyan28/Distributed-Database/raw/master/Cluster/Tugas_Partisi/Screenshot/4.JPG)

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

![](https://github.com/abyan28/Distributed-Database/raw/master/Cluster/Tugas_Partisi/Screenshot/5.JPG)

Kita lakukan query sebagai berikut:

~~~
SELECT *,'p0' FROM rc1 PARTITION (p0) UNION ALL SELECT *,'p3' FROM rc1 PARTITION (p3) ORDER BY a,b ASC;
~~~

![](https://github.com/abyan28/Distributed-Database/raw/master/Cluster/Tugas_Partisi/Screenshot/6.JPG)

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

![](https://github.com/abyan28/Distributed-Database/raw/master/Cluster/Tugas_Partisi/Screenshot/7.JPG)

Insert nilai ke dalam ``serverlogs``, nanti nilai tersebut akan otomatis dikategorikan ke dalam partisi yang telah kita buat.

~~~
insert  into `serverlogs`(`serverid`,`logdata`,`created`) values (12,'transaksi','2019-03-18 13:34:23'),(56,'view','2019-03-19 16:09:30'),(43,'transaksi','2019-03-19 08:58:17'),(22,'download','2019-03-18 14:26:09'),(6422,'transaksi','2019-03-20 23:40:22'),(196,'upload','2019-03-20 01:33:56');

~~~

![](https://github.com/abyan28/Distributed-Database/raw/master/Cluster/Tugas_Partisi/Screenshot/8.JPG)

Terus kita coba melakukan query sebagai berikut:

~~~
SELECT *,'server_east' FROM serverlogs PARTITION (server_east) UNION ALL SELECT *,'server_west' FROM serverlogs PARTITION (server_west) ORDER BY server_east ASC;
~~~

![](https://github.com/abyan28/Distributed-Database/raw/master/Cluster/Tugas_Partisi/Screenshot/9.JPG)

Seperti yang bisa dilihat, yang memiliki ``serverid`` 1,43 akan dikategorikan ke wilayah ``server_east``.

### 2.c. Hash Partition

Membuat tabel ``serverlogs2`` sekaligus membuat partisi dalam bentuk pembagian kode area sesuai partisi yang dibuat.

~~~
CREATE TABLE serverlogs2 (
    serverid INT NOT NULL, 
    logdata BLOB NOT NULL,
    created DATETIME NOT NULL
)
PARTITION BY HASH (serverid)
PARTITIONS 10;
~~~

![](https://github.com/abyan28/Distributed-Database/raw/master/Cluster/Tugas_Partisi/Screenshot/10.JPG)

Insert nilai ke dalam ``serverlogs2``, nanti nilai tersebut akan otomatis dikategorikan ke dalam partisi yang telah kita buat.

~~~
insert  into `serverlogs2`(`serverid`,`logdata`,`created`) values (12,'transaksi','2019-03-18 13:34:23'),(22,'download','2019-03-18 14:26:09'),(6422,'transaksi','2019-03-20 23:40:22'),(43,'transaksi','2019-03-19 08:58:17'),(56,'view','2019-03-19 16:09:30'),(196,'upload','2019-03-20 01:33:56');

~~~

![](https://github.com/abyan28/Distributed-Database/raw/master/Cluster/Tugas_Partisi/Screenshot/11.JPG)

Terus kita coba melakukan query sebagai berikut:

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

![](https://github.com/abyan28/Distributed-Database/raw/master/Cluster/Tugas_Partisi/Screenshot/12.JPG)

Seperti yang bisa dilihat, nilai yang diinputkan ke dalam database akan secara otomatis dikategorikan sesuai partisi yang dibuat dari hash.



### 2.d. Key Partition

Membuat tabel ``serverlogs4`` sekaligus membuat partisi dalam bentuk pembagian kode area sesuai partisi yang dibuat.

~~~
CREATE TABLE serverlogs4 (
    serverid INT NOT NULL, 
    logdata BLOB NOT NULL,
    created DATETIME NOT NULL,
    UNIQUE KEY (serverid)
)
PARTITION BY KEY()
PARTITIONS 10;
~~~

![](https://github.com/abyan28/Distributed-Database/raw/master/Cluster/Tugas_Partisi/Screenshot/13.JPG)

Insert nilai ke dalam ``serverlogs4``, nanti nilai tersebut akan otomatis dikategorikan ke dalam partisi yang telah kita buat.

~~~
insert  into `serverlogs4`(`serverid`,`logdata`,`created`) values (12,'transaksi','2019-03-18 13:34:23'),(22,'download','2019-03-18 14:26:09'),(56,'view','2019-03-19 16:09:30'),(196,'upload','2019-03-20 01:33:56'),(43,'transaksi','2019-03-19 08:58:17'),(6422,'transaksi','2019-03-20 23:40:22');
~~~

![](https://github.com/abyan28/Distributed-Database/raw/master/Cluster/Tugas_Partisi/Screenshot/14.JPG)

Terus kita coba melakukan query sebagai berikut:

~~~
SELECT *,'p0' FROM serverlogs4 PARTITION (p0) UNION ALL 
SELECT *,'p1' FROM serverlogs4 PARTITION (p1) UNION ALL 
SELECT *,'p2' FROM serverlogs4 PARTITION (p2) UNION ALL 
SELECT *,'p3' FROM serverlogs4 PARTITION (p3) UNION ALL 
SELECT *,'p4' FROM serverlogs4 PARTITION (p4) UNION ALL
SELECT *,'p0' FROM serverlogs4 PARTITION (p5) UNION ALL 
SELECT *,'p1' FROM serverlogs4 PARTITION (p6) UNION ALL 
SELECT *,'p2' FROM serverlogs4 PARTITION (p7) UNION ALL 
SELECT *,'p3' FROM serverlogs4 PARTITION (p8) UNION ALL 
SELECT *,'p4' FROM serverlogs4 PARTITION (p9)
ORDER BY serverid ASC;
~~~

![](https://github.com/abyan28/Distributed-Database/raw/master/Cluster/Tugas_Partisi/Screenshot/15.JPG)

Seperti yang bisa dilihat, nilai yang diinputkan ke dalam database akan secara otomatis dikategorikan sesuai partisi yang dibuat dari key berdasarkan unique key.

## 3. Testing "A Typical Use Case: Time Series Data"

### Using Explain

Hasil explain pada tabel measure.

![](https://github.com/abyan28/Distributed-Database/raw/master/Cluster/Tugas_Partisi/Screenshot/17.JPG)

Hasil explain pada tabel measure partitioned.

![](https://github.com/abyan28/Distributed-Database/raw/master/Cluster/Tugas_Partisi/Screenshot/18.JPG)


### The SELECT Queries Benchmark

Hasil select pada tabel measure.

![](https://github.com/abyan28/Distributed-Database/raw/master/Cluster/Tugas_Partisi/Screenshot/19.JPG)

Hasil select pada tabel measure partitioned.

![](https://github.com/abyan28/Distributed-Database/raw/master/Cluster/Tugas_Partisi/Screenshot/20.JPG)

### The Big Delete Benchmark

~~~
ALTER TABLE `tugas2`.`measures` 
ADD INDEX `index1` (`measure_timestamp` ASC);

ALTER TABLE `tugas2`.`partitioned_measures` 
ADD INDEX `index1` (`measure_timestamp` ASC);
~~~

![](https://github.com/abyan28/Distributed-Database/raw/master/Cluster/Tugas_Partisi/Screenshot/21.JPG)

Hasil delete pada tabel measure.

![](https://github.com/abyan28/Distributed-Database/raw/master/Cluster/Tugas_Partisi/Screenshot/22.JPG)

Hasil delete pada tabel measure partitioned.

![](https://github.com/abyan28/Distributed-Database/raw/master/Cluster/Tugas_Partisi/Screenshot/23.JPG)

Hasil delete pada tabel measure membutuhkan waktu lebih dari 7 menit.

![](https://github.com/abyan28/Distributed-Database/raw/master/Cluster/Tugas_Partisi/Screenshot/24.JPG)

Hasil delete pada tabel measure partitioned membutuhkan waktu kurang dari 3 detik.

![](https://github.com/abyan28/Distributed-Database/raw/master/Cluster/Tugas_Partisi/Screenshot/25.JPG)

# 4. Referensi
https://www.vertabelo.com/blog/technical-articles/everything-you-need-to-know-about-mysql-partitions
