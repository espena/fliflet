-- MySQL dump 10.13  Distrib 5.7.14, for Linux (x86_64)
--
-- Host: localhost    Database: fiflet
-- ------------------------------------------------------
-- Server version	5.7.14

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `testJournal`
--

DROP TABLE IF EXISTS `testJournal`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `testJournal` (
  `id_journal` bigint(20) unsigned NOT NULL DEFAULT '0',
  `id_supplier` int(10) unsigned NOT NULL,
  `sakstittel` text,
  `doktittel` text,
  `saksaar` char(4) DEFAULT NULL,
  `saksnr` int(10) unsigned DEFAULT NULL,
  `doknr` int(10) unsigned DEFAULT NULL,
  `virksomhet` varchar(30) DEFAULT NULL,
  `dokdato` date DEFAULT NULL,
  `jourdato` date DEFAULT NULL,
  `pubdato` date DEFAULT NULL,
  `annenpart` text,
  `unntaksgrunnlag` varchar(150) DEFAULT NULL,
  `scrapetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `testJournal`
--

LOCK TABLES `testJournal` WRITE;
/*!40000 ALTER TABLE `testJournal` DISABLE KEYS */;
INSERT INTO `testJournal` VALUES
(11,82,'Personhenvendelse - Jobbsøking i Norge','Enquiry concerning the Norwegian labour market','2016',2564,3,'AD','2016-01-01','2016-01-11','2016-01-26','TIL:            Jithin John',' ','2016-08-12 18:37:26'),
(12,82,'Personhenvendelse - Jobbsøking i Norge','Personhenvendelse - Spørsmål om  jobbsøking i Norge','2016',2564,4,'AD','2016-01-21','2016-01-31','2016-03-11','FRA:            Jithin John',' ','2016-08-12 18:37:26'),
(13,82,'Spørsmål til skriftlig besvarelse nr 1421/2016 fra stortingsrepresentant Geir Pollestad - Kronologisk oversikt over informasjon politisk ledelse har hatt underveis om det feilslåtte IKT-prosjektet Grindgut','Stortinget - Spørsmål til skriftlig besvarelse nr. 1421','2016',2589,2,'AD','2016-08-05','2016-08-05','2016-08-12','Internt',' ','2016-08-12 18:37:26'),
(14,82,'Departementsforeleggelse','Departementetsforeleggelse','2016',2593,1,'AD','2016-01-04','2016-01-09','2016-01-19','FRA: Kommunal- og moderniseringsdepartementet','Offl. § 15 1. ledd første punktum ','2016-08-12 18:37:26'),
(15,82,'Tiltak mot sosial dumping og tolkning av direktiv 96/71 og direktiv 2014/67','Oversendelse av brev fra Norsk Transportarbeiderforbund - tiltak mot sosial dumping og  tolkning av direktiv 96/71 og direktiv 2014/67','2016',2594,1,'AD','2016-08-04','2016-08-05','2016-08-12','FRA: Samferdselsdepartementet',' ','2016-08-12 18:37:26'),
(16,82,'Pleiepenger - Forespørsel om møte','Forespørsel om møte med politisk ledelse - Pleiepenger','2016',2595,1,'AD','2016-08-04','2016-08-05','2016-08-12','FRA: Norsk Epilepsiforbund',' ','2016-08-12 18:37:26'),
(17,82,'Utkast til r-notat','Utkast til r-notat','2016',2596,1,'AD','2016-08-04','2016-08-05','2016-08-12','FRA: Barne- og likestillingsdepartementet','Offl. § 14 1. ledd ','2016-08-12 18:37:26'),
(18,82,'Høring - Endringer i landtransportforskriften','Høring - Endringer i landtransportforskriften','2016',2597,1,'AD','2016-08-02','2016-08-05','2016-08-12','FRA: Direktoratet for samfunnssikkerhet og beredskap',' ','2016-08-12 18:37:26'),
(19,82,'Personhenvendelse - Klage på NAV Svolvær','Personhenvendelse - Klage på NAV Svolvær','2016',2599,1,'AD','2016-07-28','2016-08-05','2016-08-12','FRA:            Avskjermet','Offl. § 14 1. ledd ','2016-08-12 18:37:26'),
(20,82,'Utkast til fire r-notater','Utkast til fire r-notater','2016',2600,1,'AD','2016-08-05','2016-08-05','2016-08-12','FRA: Samferdselsdepartementet','Offl. § 14 1. ledd ','2016-08-12 18:37:26');
/*!40000 ALTER TABLE `testJournal` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `testSupplier`
--

DROP TABLE IF EXISTS `testSupplier`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `testSupplier` (
  `id_supplier` int(10) unsigned NOT NULL,
  `navn` varchar(150) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `testSupplier`
--

LOCK TABLES `testSupplier` WRITE;
/*!40000 ALTER TABLE `testSupplier` DISABLE KEYS */;
INSERT INTO `testSupplier` VALUES (77,'Barne- og likestillingsdepartementet'),(78,'Kulturdepartementet'),(79,'Forsvarsdepartementet'),(80,'Olje- og energidepartementet'),(82,'Arbeids- og sosialdepartementet'),(84,'Kunnskapsdepartementet'),(85,'Finansdepartementet'),(86,'Helse- og omsorgsdepartementet'),(89,'Samferdselsdepartementet'),(90,'Landbruks- og matdepartementet'),(91,'Justis- og beredskapsdepartementet'),(92,'Klima- og miljødepartementet'),(93,'Utenriksdepartementet'),(198,'Nærings- og fiskeridepartementet'),(199,'Kommunal- og moderniseringsdepartementet');
/*!40000 ALTER TABLE `testSupplier` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2016-08-15  9:19:47
