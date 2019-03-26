/*
SQLyog Ultimate v8.6 Beta2
MySQL - 5.5.30 : Database - Partisi
*********************************************************************
*/

/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
CREATE DATABASE /*!32312 IF NOT EXISTS*/`Partisi` /*!40100 DEFAULT CHARACTER SET latin1 */;

USE `Partisi`;

/*Table structure for table `serverlogs4` */

DROP TABLE IF EXISTS `serverlogs4`;

CREATE TABLE `serverlogs4` (
  `serverid` int(11) NOT NULL,
  `logdata` blob NOT NULL,
  `created` datetime NOT NULL,
  UNIQUE KEY `serverid` (`serverid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1
/*!50100 PARTITION BY KEY ()
PARTITIONS 10 */;

/*Data for the table `serverlogs4` */

insert  into `serverlogs4`(`serverid`,`logdata`,`created`) values (12,'transaksi','2019-03-18 13:34:23'),(22,'download','2019-03-18 14:26:09'),(56,'view','2019-03-19 16:09:30'),(196,'upload','2019-03-20 01:33:56'),(43,'transaksi','2019-03-19 08:58:17'),(6422,'transaksi','2019-03-20 23:40:22');

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
