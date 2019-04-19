# Registrasi dan Implementasi MongoDB

## 1. Resgistrasi MongoDB
Pertama-tama, kita harus registrasi terlebih dahulu di website [MongoDB](https://cloud.mongodb.com/user#/atlas/register/accountProfile). Untuk registrasi cukup mudah dan tidak memerlukan kartu kredit. Setelah berhasil registrasi, maka akan langsung diarahkan ke halaman pembuatan cluster sebagai berikut: 

![](https://github.com/abyan28/Distributed-Database/raw/master/NoSQL/MongoDB/screenshot/1.JPG)

Dalam pembuatan cluster baru, berhubung kita menggunakannya secara gratis, maka banyak fitur yang diretriksi dan fitur kita sudah diatur secara default. Hanya saja, kita bisa memodifikasi di bagian ``Cloud Provider & Region`` serta ``Cluster Name``. Pada bagian bagian ``Cloud Provider & Region``, saya memilih ``Google cloudPlatform`` dan memilih regional Singapura sebagai berikut: 

![](https://github.com/abyan28/Distributed-Database/raw/master/NoSQL/MongoDB/screenshot/2.JPG)

Selesai membuat cluster, maka sistem akan memproses untuk membuatkan cluster-nya dan membutuhkan waktu beberapa menit. Jika sudah, maka berikut tampilan awal dari MongoDB:

![](https://github.com/abyan28/Distributed-Database/raw/master/NoSQL/MongoDB/screenshot/3.JPG)

Dari sini kita bisa melakukan koneksi ke MongoDB dengan cara mengklik tombol ``CONNECT``, maka akan muncul halaman untuk men-set IP Address dan MongoDB User sebagai berikut:

![](https://github.com/abyan28/Distributed-Database/raw/master/NoSQL/MongoDB/screenshot/7.JPG)

Saya menggunakan 2 IP Address. Yang pertama yaitu ``0.0.0.0/0`` sehingga bisa diakses di mana pun walaupun riskan. Yang kedua menggunakan IP Address saya sendiri yaitu ``120.188.95.49/32 `` sebagai berikut:

![](https://github.com/abyan28/Distributed-Database/raw/master/NoSQL/MongoDB/screenshot/8.JPG)

Sedangkan saya hanya membuat satu user, yaitu user ``abyan`` sebagai berikut:

![](https://github.com/abyan28/Distributed-Database/raw/master/NoSQL/MongoDB/screenshot/9.JPG)

Selanjutnya adalah memilih metode koneksi. Di sini ada 3 pilihan metode koneksi yang bisa digunakan seperti yang bisa dilihat pada gambar:

![](https://github.com/abyan28/Distributed-Database/raw/master/NoSQL/MongoDB/screenshot/10.JPG)

Dalam hal ini saya akan menggunakan MongoDB Compass yang dapat di-download [di sini] (https://www.mongodb.com/download-center/community). Setelah di-download, lakukanlah instalasi seperti biasa dan langsung dijalankan programnya. Jika sudah, silahkan pilih koneksi dengan MongoDB Compass, lalu pilih ``I Have Compass`` dan salin string untuk koneksinya. Kemudian buka aplikasi Compass tadi maka aplikasi tersebut akan secara otomatis mendeteksi koneksi dari MongoDB yang kita buat sebagai berikut:

![](https://github.com/abyan28/Distributed-Database/raw/master/NoSQL/MongoDB/screenshot/11.JPG)

Klik ``Yes``, maka mayoritas data secara otomatis terisi, tinggal kita masukkan password dari user yang kita buat di MongoDB tadi seperti berikut ini:

![](https://github.com/abyan28/Distributed-Database/raw/master/NoSQL/MongoDB/screenshot/12.JPG)

Sehingga masuk ke halaman utama dari MongoDB Compass sebagai berikut:

![](https://github.com/abyan28/Distributed-Database/raw/master/NoSQL/MongoDB/screenshot/13.JPG)

(Maaf, sudah ada database ``starwars``, sebab ini saya ambil gambar setelah saya import dataset-nya karena sebelumnya kelupaan).

## 2. Import Dataset Bertipe JSON
Buka terminal/CMD/cmder, lalu arahkan ke direktori folder ``bin`` dari tempat di mana kita meng-install MongoDB Compass. Dalam hal ini, direktori ``bin`` saya berada di ``C:\Program Files\MongoDB\Server\4.0\bin``.

![](https://github.com/abyan28/Distributed-Database/raw/master/NoSQL/MongoDB/screenshot/14.JPG)

Untuk data set yang saya gunakan, saya ambil dari video tutorial yang diberikan melalui link [ini](https://public.tableau.com/s/sites/default/files/media/starwarscharacterdata.json). Silahkan langsung save as atau save halaman tersebut. Jika sudah, masukkan syntax sebagai berikut:

``
mongoimport --host cluster0-shard-00-00-qv2wn.gcp.mongodb.net:27017 --db starwars --type json --file C:\HashiCorp\BDT\NoSQL\MongoDB\starwarscharacterdata.json --jsonArray --authenticationDatabase admin --ssl --username abyan --password [isikan password di sini tanpa kurung]
``
~~~
--host			: host/server yang akan digunakan untuk import data
--db			: database yang akan digunakan untuk import data
--type			: tipe file yang digunakan
--file			: lokasi penyimpanan file yang akan di-import
authenticationDatabase	: autentikasi untuk import data di server kita
~~~

Jika berhasil, maka akan menghasilkan output sebagai berikut:

![](https://github.com/abyan28/Distributed-Database/raw/master/NoSQL/MongoDB/screenshot/4.JPG)

Sekarang kita cek di MongoDB Compass, untuk memastikan bahwa data yang kita import berhasil dilakukan:

![](https://github.com/abyan28/Distributed-Database/raw/master/NoSQL/MongoDB/screenshot/5.JPG)

Seperti yang bisa dilihat bahwa terdapat database baru berupa ``starwars`` dan isi dari database tersebut. Terkahir, kita akan mencoba melakukan query untuk mengambil data karakter yang memiliki jenis kelamin perempuan sebagai berikut:

![](https://github.com/abyan28/Distributed-Database/raw/master/NoSQL/MongoDB/screenshot/6.JPG)

Dan data berhasil ditampilkan yang hanya berjenis kelamin ``female`` saja.

## 3. Referensi
https://docs.mongodb.com/manual/                                                           
https://public.tableau.com/s/sites/default/files/media/starwarscharacterdata.json
https://www.youtube.com/watch?v=tpz-6Trd1UI 