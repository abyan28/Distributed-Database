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

/*Table structure for table `serverlogs` */

DROP TABLE IF EXISTS `serverlogs`;

CREATE TABLE `serverlogs` (
  `serverid` int(11) NOT NULL,
  `logdata` blob NOT NULL,
  `created` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1
/*!50100 PARTITION BY LIST (serverid)
(PARTITION server_east VALUES IN (1,43,65,12,56,73) ENGINE = InnoDB,
 PARTITION server_west VALUES IN (534,6422,196,956,22) ENGINE = InnoDB) */;

/*Data for the table `serverlogs` */

insert  into `serverlogs`(`serverid`,`logdata`,`created`) values (12,'transaksi','2019-03-18 13:34:23'),(56,'view','2019-03-19 16:09:30'),(43,'transaksi','2019-03-19 08:58:17'),(22,'download','2019-03-18 14:26:09'),(6422,'transaksi','2019-03-20 23:40:22'),(196,'upload','2019-03-20 01:33:56');

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
