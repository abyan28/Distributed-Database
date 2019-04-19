# Implementasi Cassandra Single Node

## 1. Kebutuhan
- Vagrant
- Cmder
- Bento/ubuntu14.04
- Oracle Java Virtual Machine
- Virtual Box

## 2. Penjelasan Cassandra
### 2.1. Pengertian Cassandra
APACHE CASSANDRA atau yang lebih dikenal dengan Cassandra adalah salah satu produk open source untuk menajemen database yang didistribusikan oleh Apache yang sangat scalable (dapat diukur) dan dirancang untuk mengelola data terstruktur yang berkapasitas sangat besar (Big Data) yang tersebar di banyak server. Cassandra merupakan salah satu implementasi dari NoSQL (Not Only SQL) seperti mongoDB. NoSQL merupakan konsep penyimpanan database dinamis yang tidak terikat pada relasi-relasi tabel yang kaku seperti RDBMS. Selain lebih scalable, NoSQL juga memiliki performa pengaksesan yang lebih cepat. Hal-hal itulah yang membuat NoSQL menjadi semakin populer beberapa tahun belakangan ini. 

Dalam memproses data, Cassandra menggunakan bahasa sendiri yang mirip dengan SQL yang dikenal dengan Cassandra Query Language (CQL). 

Saat ini Cassandra telah dipakai oleh beberapa situs terkenal antara lain Facebook, Twitter, Cisco, Rackspace, ebay, Twitter, Netflix, dan banyak lagi. Jadi secara implementasi Cassandra relatif teruji.

### 2.2. Perbedaan RDBMS dengan NoSQL
Berikut di antara perbedaan dari RDBMS dengan NoSQL:

![alt_text](https://github.com/abyan28/Distributed-Database/raw/master/NoSQL/Cassandra/SingleNode/screenshot/1.JPG)

## 3. Arsitektur Server
Cassandra didesain awal untuk menghandle Big Data yang terdiri dari banyak titik-titik (node) yang terpisah-pisah dan saling bekerjasama nyaris tanpa ada kesalahan. Cassandra memiliki peer-to-peer sistem terdistribusi di seluruh node, dan data didistribusikan di antara semua node dalam sebuah cluster.

Semua node dalam sebuah cluster memainkan peran yang sama. Setiap node independen dan pada saat yang sama saling berhubungan ke node lain. Setiap node dalam sebuah cluster dapat menerima membaca dan menulis permintaan, terlepas dari mana data sebenarnya terletak di cluster. Ketika sebuah node performanya turun, membaca permintaan / tulis dapat dilayani dari node lain dalam jaringan.

Replikasi data di Cassandra disebut dengan istilah Gossip Protocol dimana satu atau lebih node dalam sebuah Cluster sebagai replika untuk bagian tertentu dari data. Jika terdeteksi bahwa beberapa node datanya out of date, Cassandra akan mengembalikan nilai terbaru untuk klien. Setelah mendapatkan nilai kembalian terbaru, Cassandra melakukan perbaikan membaca di latar belakang untuk memperbarui nilai-nilai yang out of date.

Gambar berikut menunjukkan bagaimana Cassandra menggunakan replikasi data antara node dalam sebuah cluster untuk memastikan tidak ada satu titik yang mengalami kegagalan:

![alt_text](https://cdn-images-1.medium.com/max/640/1*9_H_ynm1MGT1TUgTxev0Cw.jpeg)

Untuk Cassandra yang akan saya implementasikan, saya hanya akan menggunakan satu node saja yang berperan sebagai server node sekaligus data node pada IP ``192.168.33.11``.

## 4. Instalasi Java Oracle Virtual Machine
Sebelum melakukan instalasi Cassandra, saya akan membuat ``virtual machine``-nya terlebih dahulu menggunakan ``Vagrant``. Untuk konfigurasi vagrant sebagai berikut:

![alt_text](https://github.com/abyan28/Distributed-Database/raw/master/NoSQL/Cassandra/SingleNode/screenshot/2.JPG)

Setelah dilakukan ``vagrant up`` dan masuk ke ``virtual machine`` yang telah dibuat, hal pertama yang harus dilakukan adalah membuat ``user`` baru terlebih dahulu sebagai berikut:

~~~
# Saya menambahkan user ``abyan``
sudo adduser abyan
# Grant Root Privilege
sudo gpasswd -a abyan sudo
~~~

Untuk beralih ke user ``abyan``, berikut command yang digunakan:

~~~
su abyan
# abyan=user
~~~

![alt_text](https://github.com/abyan28/Distributed-Database/raw/master/NoSQL/Cassandra/SingleNode/screenshot/4.JPG)

Setelah berhasil membuat user baru, sekarang kita instal ``Java Oracle Virtual Machine`` di user yang telah kita buat tadi. Pertama, update package database-nya:

~~~
sudo apt-get update
~~~

Agar paket Oracle JRE tersedia, kita harus menambahkan Personal Package Archives (PPA) menggunakan command berikut:

~~
sudo apt-get install software-properties-common
sudo add-apt-repository ppa:webupd8team/java
~~

Kemudian instal Oracle JRE. Dalam proses instalasinya, muncul sebuah license agreement, maka itu perlu di-accept. Ada beberapa tahapan yang harus dilaksanakan:

~~~
1. Tambahkan baris di bawah ini ke /etc/apt/sources.list:
deb http://debian.opennms.org/ stable main

2. Instal GPG key repositori
wget -O - http://debian.opennms.org/OPENNMS-GPG-KEY | sudo apt-key add -

3. Update package index
sudo apt-get update

4. Instal oracle-java8-installer deb package:
sudo apt-get install oracle-java8-installer
~~~

Proses instalasinya cukup lama, jika berhasil, maka saat dilakukan command ``java -version``, muncul seperti ini:

![alt_text](https://github.com/abyan28/Distributed-Database/raw/master/NoSQL/Cassandra/SingleNode/screenshot/5.JPG)

## 5. Instalasi Cassandra
Proses instalasi Cassandra menggunakan paket dari repositori resmi Apache Software Foundation, jadi diawali dengan penambahan repo sehingga paket tersebut tersedia. Dalam hal ini, saya menggunakan Cassandra versi 3.11:

~~~
echo "deb http://www.apache.org/dist/cassandra/debian 311x main" | sudo tee -a /etc/apt/sources.list.d/cassandra.sources.list

echo "deb-src http://www.apache.org/dist/cassandra/debian 311x main" | sudo tee -a /etc/apt/sources.list.d/cassandra.sources.list
~~~

![alt_text](https://github.com/abyan28/Distributed-Database/raw/master/NoSQL/Cassandra/SingleNode/screenshot/6.JPG)

Untuk menghindari warning selama pembaruan paket, kita perlu menambahkan tiga public key dari Apache Software Foundation yang terkait dengan repositori paket.

Tambahkan yang pertama menggunakan command berikut, yang harus dijalankan satu per satu:

~~~
gpg --keyserver pgp.mit.edu --recv-keys F758CE318D77295D
gpg --export --armor F758CE318D77295D | sudo apt-key add -
~~~
![alt_text](https://github.com/abyan28/Distributed-Database/raw/master/NoSQL/Cassandra/SingleNode/screenshot/7.JPG)

Kemudian tambahkan public key yang kedua:

~~~
gpg --keyserver pgp.mit.edu --recv-keys 2B5C1B00
gpg --export --armor 2B5C1B00 | sudo apt-key add -
~~~
![alt_text](https://github.com/abyan28/Distributed-Database/raw/master/NoSQL/Cassandra/SingleNode/screenshot/8.JPG)

Tambahkan public key yang ketiga:

~~~
gpg --keyserver pgp.mit.edu --recv-keys 0353B12C
gpg --export --armor 0353B12C | sudo apt-key add -
~~~
![alt_text](https://github.com/abyan28/Distributed-Database/raw/master/NoSQL/Cassandra/SingleNode/screenshot/9.JPG)

Update paketnya kembali:

~~~
sudo apt-get update
~~~

Terakhir, instal Cassandra:

~~~
sudo apt-get install cassandra
~~~

Jika berhasil, maka untuk mengeceknya apakah Cassandra berjalan atau tidak menggunakan command berikut:

~~~
sudo service cassandra status
~~~

Jika berjalan, maka sebagai berikut:

![alt_text](https://github.com/abyan28/Distributed-Database/raw/master/NoSQL/Cassandra/SingleNode/screenshot/10.JPG)

Jika sudah dipastikan berjalan, kita cek apakah sudah terhubung dengan Cluster atau belum dengan menggunakan command berikut:

~~~
sudo nodetool status
~~~

Output-nya sebagai berikut:

![alt_text](https://github.com/abyan28/Distributed-Database/raw/master/NoSQL/Cassandra/SingleNode/screenshot/11.JPG)

Dengan demikian, Cassandra telah berhasil diinstal dan dijalankan pada vagrant boxes ``cassandra1``.

## 6. Import Datasets
Untuk datasets, saya menggunakan datasets ``Heart Disease UCI`` yang saya ambil dari https://www.kaggle.com/ronitf/heart-disease-uci/version/1#heart.csv. Berikut penjelasan datasets yang saya gunakan:

![alt_text](https://github.com/abyan28/Distributed-Database/raw/master/NoSQL/Cassandra/SingleNode/screenshot/12.JPG)

Sebelum melakukan import datasets, kita harus masuk ke ``cqls``. Lalu buat keyspace (database) untuk melakukan import datasets-nya nanti:

~~~
CREATE KEYSPACE health WITH REPLICATION = {
'class' : 'NetworkTopologyStrategy', 
'datacenter1' : 1} ;
~~~
![alt_text](https://github.com/abyan28/Distributed-Database/raw/master/NoSQL/Cassandra/SingleNode/screenshot/13.JPG)

Saya menamai database saya dengan nama ``health``. Untuk penjelasan lebih lanjut mengenai ``keyspace``, bisa akses [disini](https://docs.datastax.com/en/cql/3.3/cql/cql_reference/cqlCreateKeyspace.html).

Gunakan database/keyspace tersebut.

~~~
use health;
~~~
![alt_text](https://github.com/abyan28/Distributed-Database/raw/master/NoSQL/Cassandra/SingleNode/screenshot/14.JPG)

Buat tabel untuk import data dari csv nanti, sebab csv tidak memiliki data type. Oleh karena itu harus dibuatkan tabel terlebih dahulu.

~~~
CREATE TABLE heart (no int, age int, sex int, cp int, 
trestbps int, chol int, fbs int, restecg int, thalach int, 
exang int, oldpeak float, slope int, ca int, thal int, target int, 
primary key(no));
~~~
![alt_text](https://github.com/abyan28/Distributed-Database/raw/master/NoSQL/Cassandra/SingleNode/screenshot/15.JPG)

Jika tabel berhasil dibuat, selanjutnya adalah mengimpor data dari file ``csv`` tersebut ke tabel yang telah kita buat. Untuk file ``.csv`` harus sudah di-download terlebih dahulu.

~~~
COPY heart(no, age, sex, cp, trestbps, chol, fbs, restecg, thalach, 
exang, oldpeak, slope, ca, thal, target) from 'heart.csv' with header=true;
~~~

Jika berhasil, maka output-nya sebagai berikut:

![alt_text](https://github.com/abyan28/Distributed-Database/raw/master/NoSQL/Cassandra/SingleNode/screenshot/16.JPG)

## 7. Operasi CRUD
1. Read Data

~~~
select * from heart;
~~~
![alt_text](https://github.com/abyan28/Distributed-Database/raw/master/NoSQL/Cassandra/SingleNode/screenshot/17.JPG)

2. Create Data

~~~
INSERT INTO heart(no, ca, chol, cp)VALUES(304,5,333,1);

select * from heart where no=304;
~~~
![alt_text](https://github.com/abyan28/Distributed-Database/raw/master/NoSQL/Cassandra/SingleNode/screenshot/18.JPG)

3. Update Data

~~~
update heart set age=21, exang=1, fbs=0, oldpeak=9.5, restecg=0, sex=1,
slope=2, target=1, t hal=3, thalach=177, trestbps=277 where no=304;

select * from heart where no=304;
~~~
![alt_text](https://github.com/abyan28/Distributed-Database/raw/master/NoSQL/Cassandra/SingleNode/screenshot/19.JPG)

4. Delete Data

~~~
delete from heart where no=304;

select * from heart where no=304;
~~~
![alt_text](https://github.com/abyan28/Distributed-Database/raw/master/NoSQL/Cassandra/SingleNode/screenshot/20.JPG)

## 8. Referensi
https://youtu.be/iDhIjrJ7hG0

https://www.digitalocean.com/community/tutorials/how-to-install-cassandra-and-run-a-single-node-cluster-on-ubuntu-14-04
                                                              
https://docs.datastax.com/en/cql/3.3/cql/cql_reference/cqlCreateKeyspace.html

https://medium.com/@danairwanda/pengenalan-cassandra-database-nosql-3d33a768a20

https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-14-04

http://lea.si.fti.unand.ac.id/2018/04/berkenalan-dengan-database-nosql-cassandra/

https://deb.pkgs.org/universal/opennms-stable-i386/oracle-java8-installer_8u131-1~webupd8~2_all.deb.html

https://www.kaggle.com/ronitf/heart-disease-uci/version/1#heart.csv

https://www.tutorialspoint.com/cassandra/cassandra_cql_datatypes.htm