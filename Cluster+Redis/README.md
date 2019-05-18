# IMPLEMENTASI MySQL CLUSTER DAN REDIS PADA WORDPRESS
Setelah sebelumnya melakukan implementasi MySQL Cluster (RDBMS) pada WordPress, sekarang akan mengimplementasikan Redis yang merupakan salah satu basis data NoSQL untuk meningkatkan peforma pengaksesan WordPress itu sendiri, terutama saat loading page. Berikut penjelasan implementasi dari RDBMS dan NoSQL yang saya gunakan.

## A. Kebutuhan
- Vagrant
- Cmder
- Bento/ubuntu18.04
- Build Essential
- Libjemalloc
- Virtual Box
- Apache2
- PHP dan Extension-nya
- WordPress
- Redis
- MySQL Cluster Community
- SQLYog (Optional)
- Plugin Redis Object Cache

## B. Arsitektur
Arsitektur yang digunakan tetap mengacu ke tugas sebelumnya, yaitu saat implementasi MySQL Cluster pertama kali. Tetap terdiri dari 6 cluster, hanya saja, pada clusterdb1-clusterdb3 akan di-install redis guna meningkatkan performa web. Berikut rinciannya:

| No | IP Address | Hostname | Deskripsi | RAM |
| --- | --- | --- | --- | --- |
| 1 | 192.168.33.11 | clusterdb1 | Node Manager dan Redis Master | 1024 MB |
| 2 | 192.168.33.12 | clusterdb2 | Data Node 1 dan Redis Slave 1 | 1024 MB |
| 3 | 192.168.33.13 | clusterdb3 | Data Node 2 dan Redis Slave 2 | 1024 MB |
| 4 | 192.168.33.14 | clusterdb4 | Server (API)/Service 1 | 1024 MB |
| 5 | 192.168.33.15 | clusterdb5 | Server (API)/Service 2 | 1024 MB |
| 6 | 192.168.33.16 | clusterdb6 | Load Balancer (ProxySQL) dan WordPress | 1024 MB |

## C. Instalasi MySQL Cluster
Instalasi dan konfigurasi MySQL Cluster yang saya lakukan bisa dilihat pada dokumentasi [ini](https://github.com/abyan28/Distributed-Database/raw/master/Cluster/Muhammad%20Abyan%20Dzaka.pdf). Apabila berhasil menginstal MySQL Cluster dan dapat berjalan dengan baik, langkah selanjutnya adalah instalasi WordPress.

## D. Instalasi WordPress
Untuk langkah-langkah instalasi WordPress pada MySQL Cluster dapat dilihat pada dokumentasi [di sini](https://github.com/abyan28/Distributed-Database/tree/master/Cluster/Tugas_ETS_Wordpress).

Untuk tambahan konfigurasinya, agar sistem dapat mengakses plugin redis pada WordpRess yang telah di-install nantinya, perlu ditambahkan konfigurasi pada clusterdb6 di file ``/var/www/html/wordpress/wp-config.php`` sebagai berikut:

~~~
define( 'WP_REDIS_CLIENT', 'predis' );
define( 'WP_REDIS_SENTINEL', 'mymaster' );
define( 'WP_REDIS_SERVERS', [
    'tcp://192.168.33.11:26379?alias=redisMaster',
    'tcp://192.168.33.12:26379?alias=redisSlave1',
    'tcp://192.168.33.13:26379?alias=redisSlave2',
] );
~~~ 

![]() 

## E. Instalasi Redis
Instalasi redis saya lakukan di clusterdb1, clusterdb2, dan clusterdb3. Untuk proses dan langkah-langkahnya persis dengan yang sudah saya dokumentasikan pada tugas sebelumnya dan dapat dilihat [di sini](https://github.com/abyan28/Distributed-Database/tree/master/NoSQL/Redis).

Setelah dilakukan instalasi, jangan lupa juga untuk konfigurasi firewall pada clusterdb6 yang notabene tempat instalasi WordPress:

~~~
sudo ufw allow 6379 (Default port Redis)
sudo ufw allow 26379 (Default port Sentinel)
sudo ufw allow from 192.168.33.11 (redisMaster)
sudo ufw allow from 192.168.33.12 (redisSlave2) 
sudo ufw allow from 192.168.33.13 (redisSlave3)
~~~

## F. Instalasi Redis Object Cache
Pastikan bahwa WordPress berjalan dengan baik pada MySQL Cluster dan Redis yang diinstal pada clusterdb1-clusterdb3 dapat berkomunikasi. Jika sudah, langkah selanjutnya adalah masuk ke dalam dashboard WordPress. Pilih menu ``Plugin`` dan klik ``Add New``. Ketikkan pada pencarian ``redis``, maka ``Redis Object Cache`` muncul pada bagian paling atas.

![]()

Klik ``install now``. Jika diminta untuk melakukan koneksi dengan ftp, maka kita harus mengubah ``owner`` dari file-file yang ada di folder ``/var/www/html/wordpress`` dengan cara:

~~~
sudo chown -Rf www-data.www-data *
~~~

![]()

Silahkan refresh lagi browser-nya, maka tidak ada permintaan koneksi dengan ftp lagi, melainkan akan melakukan instalasi langsung. Jika berhasil, pada menu plugin akan muncul sebagai berikut:

![]()

Klik ``activate`` lalu klik ``settings``, maka akan di-redirect ke menu Settings untuk Redis.

![]()

Langsung klik ``Enable Object Cache``, maka Redis pada WordPress akan terkoneksi dengan node redis yang telah kita install.

![]()

Terlihat bahwa statusnya ``Connected``. Sekarang WordPress telah dibekali dengan MySQL CLuster dan Redis. 

## G. Failover Test
Untuk failover test pada MySQL Cluster di WordPress, bisa dilihat [di sini](https://github.com/abyan28/Distributed-Database/tree/master/Cluster/Tugas_ETS_Wordpress).

Untuk failover test pada Redis di WordPress, kita dapat menggunakan command ``redis-cli monitor`` pada clusterdb1, clusterdb2, dan clusterdb3. Dengan mengeksekusi command tersebut, kita dapat mengetahui aktifitas yang sedang berjalan pada Redis. Saya akan mengeksekusi command tersebut, setelah itu saya akan me-refresh WordPress-nya. Sebelumnya, untuk mengetahui yang mana clusterdb1 dengan yang lainnya, bisa dilihat dari tab yang sedang berjalan. Tab tersebut berurutan dari kiri ke kanan dengan clusterdb1 paling kiri dan clusterdb6 paling kanan.

![]()

![]()

![]()

Terlihat bahwa ada aktifitas WordPress yang berjalan di clusterdb3 atau redisSlave2. Sekarang kita akan coba matikan redis-nya pada clusterdb3/redisSlave2 dan redis mana yang akan mencatat aktifitas WordPress.

![]()

![]()

![]()

Ternyata pada clusterdb2/redisSlave1 yang menggantikan peran redisSlave2 yang telah dinonaktifkan tadi. Bagaimana jika 2 slave redis mati semua? 

![]()

![]()

Redis masih tetap bisa berjalan dan di-handle langsung oleh redisMaster/clusterdb1. Lalu bagaimana jika semua redis mati?

![]()

![]()

Maka status Redis pada WordPress langsung menampilkan ``Not Connected``. Jika kita coba nyalakan lagi semua redis, maka status ``Not Connected`` berubah menjadi ``Connected``.

![]()

![]()

## G. Referensi
https://wordpress.org/plugins/redis-cache/
                                
https://scalegrid.io/blog/using-redis-object-cache-to-speed-up-your-wordpress-installation/

https://www.youtube.com/watch?v=qhyRl2aFlNQ