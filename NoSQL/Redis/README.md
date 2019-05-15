# Implementasi Redis

## 1. Kebutuhan
- Vagrant
- Cmder
- Bento/ubuntu16.04
- Virtual Box
- Build Essential
- Libjemalloc

## 2. Arsitektur
Sesuai dengan tutorial yang diberikan (link ada di referensi), saya juga menggunakan 3 node degan detail sebagai berikut:

| No | IP Address | Hostname | Deskripsi | RAM |
| --- | --- | --- | --- | --- |
| 1 | 192.168.33.11 | redisMaster | Master Redis | 2046 MB |
| 2 | 192.168.33.12 | redisSlave2 | Slave Redis 1 | 1024 MB |
| 3 | 192.168.33.13 | redisSlave3 | Slave Redis 2 | 1024 MB |

Vagrantbox yang saya gunakan, menyesuaikan dengan yang ada di tutorial (UBUNTU  16.04). Berikut konfigurasinya:

~~~
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  #(1..2).each do |i|
    config.vm.define "redisMaster" do |node|
      node.vm.hostname = "redisMaster"
      node.vm.box = "bento/ubuntu-16.04"
      node.vm.network "private_network", ip: "192.168.33.11"

      # Opsional. Edit sesuai dengan nama network adapter di komputer
      # node.vm.network "public_network", bridge: "Qualcomm Atheros QCA9377 Wireless Network Adapter"
      
      node.vm.provider "virtualbox" do |vb|
        vb.name = "redisMaster"
        vb.gui = false
        vb.memory = "2046"
      end

      #node.vm.provision "shell", path: "provision/bootstrap.sh", privileged: false
    end
  #end


  (2..3).each do |i|
    config.vm.define "redisSlave#{i}" do |node|
      node.vm.hostname = "redisSlave#{i}"
      node.vm.box = "bento/ubuntu-16.04"
      node.vm.network "private_network", ip: "192.168.33.1#{i}"

      # Opsional. Edit sesuai dengan nama network adapter di komputer
      # node.vm.network "public_network", bridge: "Qualcomm Atheros QCA9377 Wireless Network Adapter"
      
      node.vm.provider "virtualbox" do |vb|
        vb.name = "redisSlave#{i}"
        vb.gui = false
        vb.memory = "1024"
      end

      #node.vm.provision "shell", path: "provision/bootstrap.sh", privileged: false
    end
  end
end
~~~

## 3. Instalasi
### 3.1. Instalasi Redis
Sebelum melakukan instalasi redis, kita harus meng-install kebutuhan redis pada tiap-tiap node sebagai berikut:
```
sudo apt-get update 
sudo apt-get install build-essential tcl
sudo apt-get install libjemalloc-dev  (Optional)
```

Selesai instalasi kebutuhan, baru kita akan meng-install redis pada tiap-tipa node:
```
curl -O http://download.redis.io/redis-stable.tar.gz
tar xzvf redis-stable.tar.gz
cd redis-stable
make
make test
sudo make install
```

Saat melakukan kompilasi dengan ``make``, membutuhkan waktu yang lumayan lama, jadi mohon bersabar. Jika saat proses kompilasi gagal, ada kemungkinan memori yang dialokasikan pada saat instalasi vagrantbox itu kurang mencukupi, jadi apabila menemui kasus demikian, maka lakukan instalasi ulang pada vagrantbox dengan memperbesar alokasi memori. Jika berhasil, maka pada masing-masing node terdapat folder ``redis-stable`` yang berisikan file ``redis.conf`` dan ``sentinel.conf``.

Pada redisMaster
![alt_text]()

Pada redisSlave2
![alt_text]()

Pada redisSlave3
![alt_text]()

### 3.2. Konfigurasi Redis
Lakukan konfigurasi firewall pada masing-masing node sebagai berikut:
```
sudo ufw allow 6379 (Default port Redis)
sudo ufw allow 26379 (Default port Sentinel)
sudo ufw allow from 192.168.33.11 (redisMaster)
sudo ufw allow from 192.168.33.12 (redisSlave2) 
sudo ufw allow from 192.168.33.13 (redisSlave3)
```

Konfigurasi firewall pada redisMaster
![alt_text]()
![alt_text]()
![alt_text]()

Konfigurasi firewall pada redisSlave2
![alt_text]()
![alt_text]()
![alt_text]()

Konfigurasi firewall pada redisSlave3
![alt_text]()
![alt_text]()
![alt_text]()

Kemudian lakukan konfigurasi pada file ``redis.conf`` pada masing-masing node sebagai berikut:
- Pada redisMaster :
```
protected-mode no
port 6379
dir .
logfile "/home/vagrant/redis-stable/redis.log"
```
![alt_text]()

- Pada redisSlave2 dan redisSlave3:
```
protected-mode no
port 6379
dir .
slaveof 192.168.33.11 6379
logfile "/home/vagrant/redis-stable/redis.log"
```
![alt_text]()

Setelah itu, sekarang giliran file ``sentinel.conf`` pada masing-masing node kita lakukan konfigurasi sebagai berikut:

```
protected-mode no
port 26379
logfile "/home/vagrant/redis-stable/sentinel.log"
sentinel monitor mymaster 192.168.33.11 6379 2
sentinel down-after-milliseconds mymaster 5000
sentinel failover-timeout mymaster 10000
```
![alt_text]()

Jangan lupa untuk menaruh logfile-nya berdasarkan path pada root. Selesai konfigurasi di atas, kita akan mengaktifkan redis sebagai berikut:

```
src/redis-server redis.conf &
src/redis-server sentinel.conf --sentinel &
```

### 3.3. Uji Konfigurasi Redis
Jika terdapat masalah saat melakukan eksekusi command di atas, coba cek path penempatan log kalian pada root. Apabila sudah benar tapi masih bermasalah, coba untuk backup file ``redis.conf`` dan ``sentinel.conf`` kemudian buat file ``redis.conf`` dan ``sentinel.conf`` yang baru lalu diisikan konfigurasi sesuai yang dijabarkan di atas. 2 langkah tersebut berhasil mengatasi permasalahan yang saya hadapi. Apabila sudah berhasil, untuk melakukan mengecek status coba ketikkan ``ps -ef | grep redis`` maka akan muncul sebagai berikut:

Pada redisMaster
![]()

Pada redisSlave2
![]()

Pada redisSlave3
![]()

Apabila pengecekan sesuai dengan yang di atas, maka seharusnya testing ping dari masing masing node akan berjalan dengan lancar. Untuk command-nya, bisa dipilih salah satu dari berikut:

```
redis-cli ping
atau
redis-cli -h IP_Address ping (IP_Address: Alamat IP masing-masing node)
```

Akan muncul ``pong`` apabila berhasil melakukan ping.
![]()

Jika testing ping berhasil, maka seharusnya semua node sudah saling terhubung. Oleh karena itu, kita akan cek logfile ``redis.log`` dan ``sentinel.log`` dari masing-masing node:

``redis.log`` pada redisMaster:
![]()

``sentinel.log`` pada redisMaster:
![]()

``redis.log`` pada redisSlave2:
![]()

``sentinel.log`` pada redisSlave2:
![]()

``redis.log`` pada redisSlave2:
![]()

``sentinel.log`` pada redisSlave2:
![]()

Pada file ``sentinel.conf`` di masing-masing node otomatis akan ada konfigurasi baru sebagai berikut:

Pada redisMaster:
![]()

Pada redisSlave2:
![]()

Pada redisSlave3:
![]()

## 4. Uji Coba Redis
Kita akan melakukan uji coba Redis dengan melihat info Redis pada tiap-tiap node, kemudian pada node redisMaster kita set demokey dengan memasukkan nilai ``Halo, 2 slave yang lain... :)``. Seharusnya, apabila uji konfigurasi di atas berhasil dilakukan semua, maka demokey yang telah di-set pada redisMaster akan bisa dibaca oleh semua node sebagai berikut:

Pada redisMaster:
![]()

Pada redisSlave2:
![]()

Pada redisSlave3:
![]()

Dengan demikian, redis berhasil melakukan replikasi pada tiap-tiap node/slave.

## 5. Uji Coba Fail Over Redis
Saya akan mematikan redisMaster dengan salah satu command sebagai berikut:

```
kill -9 <process id>
atau
redis-cli -p 6379 DEBUG sleep 30
atau
redis-cli -p 6379 DEBUG SEGFAULT
```

Saya akan menggunakan command ``redis-cli -p 6379 DEBUG sleep 30`` untuk menonaktifkan redisMaster selama 30 detik.
redisMaster
![]()

redisMaster berhasil dimatikan, maka salah satu slave akan menjadi master saat terjadi demikian:

redisSlave2 tetap menjadi slave.
![]()

redisSlave3 berubah role menjadi master.
![]()

Dengan demikian, uji coba failover pada redis sukses dilakukan. Untuk node redisMaster saat sudah menyala kembali, role yang dia dapatkan adalah sebagai slave, bukan menjadi master. Untuk role master tetap pada redisSlave3.

## 6. Referensi
https://medium.com/@amila922/redis-sentinel-high-availability-everything-you-need-to-know-from-dev-to-prod-complete-guide-deb198e70ea6