# Implementasi WordPress pada MySQL Cluster

## A. Arsitektur
Untuk MySQL Cluster yang digunakan adalah MySQL Cluster dari tugas sebelumnya. Oleh karena itu, desain arsitektur MySQL Cluster tetap sama, yaitu terdiri dari 6 cluster. Hanya saja, pada Load Balancer, di-install WordPress guna mengakomodasi pengaplikasian menggunakan WordPress. Berikut rinciannya:

| No | IP Address | Hostname | Deskripsi |
| --- | --- | --- | --- |
| 1 | 192.168.33.11 | clusterdb1 | Node Manager |
| 2 | 192.168.33.12 | clusterdb2 | Data Node 1 |
| 3 | 192.168.33.13 | clusterdb3 | Data Node 2 |
| 4 | 192.168.33.14 | clusterdb4 | Server (API)/Service 1 |
| 5 | 192.168.33.15 | clusterdb5 | Server (API)/Service 1 |
| 6 | 192.168.33.16 | clusterdb6 | Load Balancer (ProxySQL) dan WordPress |

## B. Instalasi Wordpress
1. Install Apache2 pada ``clusterdb6`` yang merupakan ProxySQL serta PHP sebagai kebutuhan WordPress.

~~~
sudo apt-get install apache2
~~~

Berikut gambar bahwa Apache2 telah ter-install.

![](https://github.com/abyan28/Distributed-Database/raw/master/Cluster/Tugas_ETS_Wordpress/screenshot/1.JPG)

Kemudian kita install PHP beserta extension-nya.

~~~
sudo apt-get install php
sudo apt-get install php-mysql
sudo apt-get install -y php-gd php-imap php-ldap php-odbc php-pear php-xml php-xmlrpc php-mbstring php-snmp php-soap php-tidy curl
~~~

Berikut gambar bahwa PHP telah ter-install.

![](https://github.com/abyan28/Distributed-Database/raw/master/Cluster/Tugas_ETS_Wordpress/screenshot/2.JPG)

2. Download Aplikasi WordPress pada Load Balacer Node.

```
wget https://wordpress.org/wordpress-5.1.1.tar.gz
```

![](https://github.com/abyan28/Distributed-Database/raw/master/Cluster/Tugas_ETS_Wordpress/screenshot/3.JPG)

3. Untar WordPress yang telah di-download lalu pindahkan ke ``/var/www/html/``.

```
tar -xvf wordpress-5.1.1.tar.gz
sudo mv wordpress /var/www/html/ 
```

![](https://github.com/abyan28/Distributed-Database/raw/master/Cluster/Tugas_ETS_Wordpress/screenshot/4.JPG)

4. Buat database baru ``wordpress`` pada salah satu service node dan jangan lupa berikan hak akses terhadap user ``abyan`` pada kedua service node.

~~~
GRANT ALL PRIVILEGES on wordpress.* to 'abyan'@'%';
FLUSH PRIVILEGES;
~~~

![](https://github.com/abyan28/Distributed-Database/raw/master/Cluster/Tugas_ETS_Wordpress/screenshot/5.JPG)

5. Ubah nama ``wp-config-sample.php`` menjadi ``wp-config.php`` sebagai berikut:

~~~
sudo mv wp-config-sample.php wp-config.php 
~~~

![](https://github.com/abyan28/Distributed-Database/raw/master/Cluster/Tugas_ETS_Wordpress/screenshot/6.JPG)

6. Ubah konfigurasi database pada ``wp-config.php`` sebagai berikut:
~~~
/** The name of the database for WordPress */
define( 'DB_NAME', 'wordpress' );

/** MySQL database username */
define( 'DB_USER', 'abyan' );

/** MySQL database password */
define( 'DB_PASSWORD', 'password' );

/** MySQL hostname */
define( 'DB_HOST', '192.168.33.16:6033' );
~~~

![](https://github.com/abyan28/Distributed-Database/raw/master/Cluster/Tugas_ETS_Wordpress/screenshot/7.JPG)

7. Ubah engine menjadi ``NDB`` pada ``wordpress\wp-admin\includes\schema.php`` di tiap-tiap tabelnya. Salah satunya sebagai berikut :

![](https://github.com/abyan28/Distributed-Database/raw/master/Cluster/Tugas_ETS_Wordpress/screenshot/27.JPG)

8. Sekarang coba buka browser ``http://192.168.33.16/wordpress`` maka akan muncul tampilan instalasi ``wordpress`` :

![](https://github.com/abyan28/Distributed-Database/raw/master/Cluster/Tugas_ETS_Wordpress/screenshot/8.JPG)

Kemudian silahkan ikuti langkah pengisian form untuk meng-install ``wordpress``. Jika sudah, maka aka di-redirect ke halaman login dan silahkan masuk dengan menggunakan username dan password yang telah diisikan pada form sebelumnya:

![](https://github.com/abyan28/Distributed-Database/raw/master/Cluster/Tugas_ETS_Wordpress/screenshot/9.JPG)

Setelah berhasil login, maka muncul dashboard WordPress:

![](https://github.com/abyan28/Distributed-Database/raw/master/Cluster/Tugas_ETS_Wordpress/screenshot/10.JPG)

9. Sekarang kita cek melalui SQLYog, apakah Schema WordPress yang dibuat sudah tersimpan dalam Data Node atau belum:

![](https://github.com/abyan28/Distributed-Database/raw/master/Cluster/Tugas_ETS_Wordpress/screenshot/11.JPG)

Dan ternyata Data Node-nya sudah berhasil menyimpan Schema WordPress yang telah di-install tadi. 

## C. Simulasi Fail Over
Saya menggunakan Data Node untuk mensimulasikan fail over pada aplikasi WordPress ini. Sebelumnya, kita cek terlebih dahulu koneksi pada service node:

![](https://github.com/abyan28/Distributed-Database/raw/master/Cluster/Tugas_ETS_Wordpress/screenshot/13.JPG)

Semua node terkoneksi dengan baik. Lalu saya coba matikan Data Node 1, setelah itu saya akan membuat postingan di WordPress:

![](https://github.com/abyan28/Distributed-Database/raw/master/Cluster/Tugas_ETS_Wordpress/screenshot/14.JPG)

![](https://github.com/abyan28/Distributed-Database/raw/master/Cluster/Tugas_ETS_Wordpress/screenshot/15.JPG)

![](https://github.com/abyan28/Distributed-Database/raw/master/Cluster/Tugas_ETS_Wordpress/screenshot/16.JPG)

Terlihat bahwa saya tetap bisa memposting sesuatu walaupun Data Node 1 tidak aktif, sebab masih ada Data Node 2 yang aktif. Sekarang coba kita ganti untuk menonaktifkan Data Node 2, lalu kita lihat apakah postingan tadi bisa diakses atau tidak:

![](https://github.com/abyan28/Distributed-Database/raw/master/Cluster/Tugas_ETS_Wordpress/screenshot/17.JPG)

![](https://github.com/abyan28/Distributed-Database/raw/master/Cluster/Tugas_ETS_Wordpress/screenshot/18.JPG)

Ternyata saya tetap bisa melihat postingan tadi walaupun Data Node 1 tidak aktif, sebab ketika Data Node 1 dinyalakan dia langsung mereplikasi data yang ada di Data Node 2, sehingga ketika Data Node 2 dimatikan, data masih tetap sama dan dapat diakses. Artinya, MySQL Cluster berhasil saling mereplikasi.

Lalu bagaimana jika kedua Data Node mati? Mari kita lihat:

![](https://github.com/abyan28/Distributed-Database/raw/master/Cluster/Tugas_ETS_Wordpress/screenshot/20.JPG)

![](https://github.com/abyan28/Distributed-Database/raw/master/Cluster/Tugas_ETS_Wordpress/screenshot/21.JPG)

Jadi, ketika kedua Data Node mati, service juga akan mati, sebab service tidak dapat mengakses Data Node manapun.

## D. Pengukuran Response Time (Load Test) Dengan JMeter
Ada beberapa step yang harus dilakukan untuk menggunakan aplikasi JMeter. Dalam kasus ini, saya gunakan melalui Windows. Jadi kita harus download terlebih dahulu melalui situs https://www-us.apache.org/dist//jmeter/binaries/apache-jmeter-5.1.1.zip. Untuk menjalankan aplikasinya, silahkan diekstrak terlebih dahulu lalu jalankan file ``jmeter.bat`` di dalam folder ``bin``.  Dalam Melakukan load test menggunakan JMeter, ada beberapa langkah yang harus dilakukan sebagaimana berikut:

### D.1. Add Thread Group
1. Klik Kanan Test Plan
2. Add >Threads ( Users ) > Thread Group
3. Dalam kontrol panel Thread Group, Entri pada Thread Properties :
– Number of threads (users) : Isi berapa user/visitor yang akan mengakses web. Saya isi 180 users.
– Ramp-Up period ( in seconds ) : Isi berapa waktu delay antara user satu dengan yang lainnya dalam mengakses web. Saya isi 30 seconds.
– Loop Count : Waktu eksekusi, bertahap atau seterusnya. Saya isi 10.

![](https://github.com/abyan28/Distributed-Database/raw/master/Cluster/Tugas_ETS_Wordpress/screenshot/22.JPG)

### D.2. Add JMeter Element
Menambahkan web server/IP Address yang akan ditest. Caranya :
1. Klik Kanan Threads Group
2. Add > Config Element > HTTP Request Defaults
3. Pada Web Server, isi Server Name atau IP dan Portnya atau website/url yang akan dites. Jika diisi URL, maka harus berformat ``http://www.``.

![](https://github.com/abyan28/Distributed-Database/raw/master/Cluster/Tugas_ETS_Wordpress/screenshot/23.JPG)

4. Jika tidak hanya halaman utama yang di test, kita bisa menambahkan path/foldernya, caranya :
- Klik Kanan Threads Group
- Add > Sampler > HTTP Request
- Isi web server, port dan path

![](https://github.com/abyan28/Distributed-Database/raw/master/Cluster/Tugas_ETS_Wordpress/screenshot/24.JPG)

### D.3. Add Listener
Menampilkan proses dan hasil test secara grafis atau bentuk tabel. Caranya :
1. Klik Kanan Test Plan
2. Add > Listener > Graph Result
3. Add > Listener > View Results in Table

### D.4. Run Test
Menjalankan Test secara otomatis. Caranya :
1. Simpan terlebih dahulu Test Plan yang telah kita buat di File > Save ( Ctrl + S ).
2. Klik Run atau Ctrl + R, JMeter akan mulai mensimulasi sejumlah user dalam mengakses web server yang telah ditentukan.

Berikut adalah hasil dalam bentuk Graph yang dilakukan dalam pengujian load test menggunakan JMeter:

![](https://github.com/abyan28/Distributed-Database/raw/master/Cluster/Tugas_ETS_Wordpress/screenshot/26.JPG)

Berikut adalah hasil dalam bentuk Tabel yang dilakukan dalam pengujian load test menggunakan JMeter:

![](https://github.com/abyan28/Distributed-Database/raw/master/Cluster/Tugas_ETS_Wordpress/screenshot/25.JPG)
