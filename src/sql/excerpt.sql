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
-- Table structure for table `journal`
--

DROP TABLE IF EXISTS `journal`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `journal` (
  `id_journal` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
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
  `scrapetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_journal`),
  UNIQUE KEY `uidx_dokidentitet` (`virksomhet`,`saksaar`,`saksnr`,`doknr`)
) ENGINE=InnoDB AUTO_INCREMENT=646715 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `journal`
--

LOCK TABLES `journal` WRITE;
/*!40000 ALTER TABLE `journal` DISABLE KEYS */;
INSERT INTO `journal` VALUES (11,82,'Personhenvendelse - Jobbsøking i Norge','Enquiry concerning the Norwegian labour market','2016',2564,3,'AD','2016-08-04','2016-08-05','2016-08-12','TIL:            Jithin John',' ','2016-08-12 18:37:26'),(12,82,'Personhenvendelse - Jobbsøking i Norge','Personhenvendelse - Spørsmål om  jobbsøking i Norge','2016',2564,4,'AD','2016-08-04','2016-08-05','2016-08-12','FRA:            Jithin John',' ','2016-08-12 18:37:26'),(13,82,'Spørsmål til skriftlig besvarelse nr 1421/2016 fra stortingsrepresentant Geir Pollestad - Kronologisk oversikt over informasjon politisk ledelse har hatt underveis om det feilslåtte IKT-prosjektet Grindgut','Stortinget - Spørsmål til skriftlig besvarelse nr. 1421','2016',2589,2,'AD','2016-08-05','2016-08-05','2016-08-12','Internt',' ','2016-08-12 18:37:26'),(14,82,'Departementsforeleggelse','Departementetsforeleggelse','2016',2593,1,'AD','2016-08-04','2016-08-05','2016-08-12','FRA: Kommunal- og moderniseringsdepartementet','Offl. § 15 1. ledd første punktum ','2016-08-12 18:37:26'),(15,82,'Tiltak mot sosial dumping og tolkning av direktiv 96/71 og direktiv 2014/67','Oversendelse av brev fra Norsk Transportarbeiderforbund - tiltak mot sosial dumping og  tolkning av direktiv 96/71 og direktiv 2014/67','2016',2594,1,'AD','2016-08-04','2016-08-05','2016-08-12','FRA: Samferdselsdepartementet',' ','2016-08-12 18:37:26'),(16,82,'Pleiepenger - Forespørsel om møte','Forespørsel om møte med politisk ledelse - Pleiepenger','2016',2595,1,'AD','2016-08-04','2016-08-05','2016-08-12','FRA: Norsk Epilepsiforbund',' ','2016-08-12 18:37:26'),(17,82,'Utkast til r-notat','Utkast til r-notat','2016',2596,1,'AD','2016-08-04','2016-08-05','2016-08-12','FRA: Barne- og likestillingsdepartementet','Offl. § 14 1. ledd ','2016-08-12 18:37:26'),(18,82,'Høring - Endringer i landtransportforskriften','Høring - Endringer i landtransportforskriften','2016',2597,1,'AD','2016-08-02','2016-08-05','2016-08-12','FRA: Direktoratet for samfunnssikkerhet og beredskap',' ','2016-08-12 18:37:26'),(19,82,'Personhenvendelse - Klage på NAV Svolvær','Personhenvendelse - Klage på NAV Svolvær','2016',2599,1,'AD','2016-07-28','2016-08-05','2016-08-12','FRA:            Avskjermet','Offl. § 14 1. ledd ','2016-08-12 18:37:26'),(20,82,'Utkast til fire r-notater','Utkast til fire r-notater','2016',2600,1,'AD','2016-08-05','2016-08-05','2016-08-12','FRA: Samferdselsdepartementet','Offl. § 14 1. ledd ','2016-08-12 18:37:26'),(21,82,'Personhenvendelse - Spørsmål om rettigheter i arbeidslivet','Personhenvendelse - Spørsmål om rettigheter i arbeidslivet','2016',2601,1,'AD','2016-08-05','2016-08-05','2016-08-12','FRA:            Lukas Jakubonis',' ','2016-08-12 18:37:26'),(22,82,'Bistand til anskaffelse av FOU-oppdrag ved åpen konkurranse','Oversendelse av rapport - En komparativ analyse av effekter av innsats for å inkludere utsatte unge i arbeid i Norden','2014',1180,12,'AD','2016-08-04','2016-08-04','2016-08-11','FRA: Institutt for samfunnsforskning',' ','2016-08-12 18:37:26'),(23,82,'Personhenvendelse - Klage på NAV Frøya - Arbeidsavklaringspenger','Personhenvendelse - Klage på NAV - Diskriminering - Umenneskelig behandling og urettferdighet','2015',1572,16,'AD','2016-08-04','2016-08-04','2016-08-11','FRA:            Avskjermet','Offl. § 13 1. ledd, jf. fvl. § 13 1. ledd nr. 1 ','2016-08-12 18:37:26'),(24,82,'Høring - Utkast til Nasjonal CBRNE-strategi','Svar på departementsforeleggelse','2016',2076,3,'AD','2016-08-02','2016-08-04','2016-08-11','TIL: Justis- og beredskapsdepartementet','Offl. § 15 1. ledd første punktum ','2016-08-12 18:37:26'),(25,82,'Personhenvendelse - Dagpenger, studier, arbeid mv','Personhenvendelse om dagpenger og utdanning - Saksbehandlingstid NAV','2016',2224,6,'AD','2016-08-04','2016-08-04','2016-08-11','FRA: Avskjermet','Offl. § 13 1. ledd, jf. fvl. § 13 1. ledd nr. 1 ','2016-08-12 18:37:26'),(26,82,'Personhenvendelse - Fratatt uførepensjon','Personhenvendelse - Fratatt uførepensjon - Spørsmål','2016',2511,6,'AD','2016-08-04','2016-08-04','2016-08-11','FRA:            Avskjermet','Offl. § 13 1. ledd, jf. fvl. § 13 1. ledd nr. 1 ','2016-08-12 18:37:26'),(27,82,'Henvendelse om avslag på innsyn i dokumenter til underliggende etat','Svar på henvendelse vedrørende avslag på innsyn i dokumenter til underliggende etat','2016',2568,2,'AD','2016-08-04','2016-08-04','2016-08-11','TIL: Dagens Næringsliv',' ','2016-08-12 18:37:26'),(28,82,'Klage på innsyn - 16/830 - Arbeids- og velferdsdirektoratet - Rapport 2016','Klage på innsyn 16/830-2','2016',2586,1,'AD','2016-08-03','2016-08-04','2016-08-11','FRA:            Lars Thorvaldsen',' ','2016-08-12 18:37:26'),(29,82,'Klage på innsyn - 16/830 - Arbeids- og velferdsdirektoratet - Rapport 2016','Klage på innsyn - 16/830-3','2016',2586,2,'AD','2016-08-03','2016-08-04','2016-08-11','FRA:            Lars Thorvaldsen',' ','2016-08-12 18:37:26'),(30,82,'Klage på innsyn - 16/830 - Arbeids- og velferdsdirektoratet - Rapport 2016','Klage på innsyn 16/830-4','2016',2586,3,'AD','2016-08-03','2016-08-04','2016-08-11','FRA:            Lars Thorvaldsen',' ','2016-08-12 18:37:26'),(31,82,'Klage på innsyn - 16/830 - Arbeids- og velferdsdirektoratet - Rapport 2016','Klage på innsyn 16/830-5','2016',2586,4,'AD','2016-08-03','2016-08-04','2016-08-11','FRA:            Lars Thorvaldsen',' ','2016-08-12 18:37:26'),(32,82,'Klage på innsyn - 16/830 - Arbeids- og velferdsdirektoratet - Rapport 2016','Klage på innsyn16/830-6','2016',2586,5,'AD','2016-08-03','2016-08-04','2016-08-11','FRA:            Lars Thorvaldsen',' ','2016-08-12 18:37:26'),(33,82,'Klage på innsyn - 16/830 - Arbeids- og velferdsdirektoratet - Rapport 2016','Klage på innsyn - 16/830-7','2016',2586,6,'AD','2016-08-03','2016-08-04','2016-08-11','FRA:            Lars Thorvaldsen',' ','2016-08-12 18:37:26'),(34,82,'Klage på innsyn - 16/830 - Arbeids- og velferdsdirektoratet - Rapport 2016','Klage på innsyn 16/830-8','2016',2586,7,'AD','2016-08-03','2016-08-04','2016-08-11','FRA:            Lars Thorvaldsen',' ','2016-08-12 18:37:26'),(35,82,'Personhenvendelse - Kvalitetssikring av NAV','Personhenvendelse - Kvalitetssikring av NAV - Spørsmål / tilbud','2016',2587,1,'AD','2016-08-03','2016-08-04','2016-08-11','FRA:            Avskjermet','Offl. § 13 1. ledd, jf. fvl. § 13 1. ledd nr. 1 ','2016-08-12 18:37:26'),(36,82,'AAP-saker for NAV','Kopi av brev - To AAP-saker for NAV','2016',2588,1,'AD','2016-08-02','2016-08-04','2016-08-11','FRA: Advokat Inga Kjernlie','Offl. § 13 1. ledd, jf. fvl. § 13 1. ledd nr. 1 ','2016-08-12 18:37:26'),(37,82,'Spørsmål til skriftlig besvarelse nr 1421/2016 fra stortingsrepresentant Geir Pollestad - Kronologisk oversikt over informasjon politisk ledelse har hatt underveis om det feilslåtte IKT-prosjektet Grindgut','Spørsmål til skriftlig besvarelse nr 1421/2016 fra stortingsrepresentant Geir Pollestad - Kronologisk oversikt over informasjon politisk ledelse har hatt underveis om det feilslåtte IKT-prosjektet Grindgut','2016',2589,1,'AD','2016-08-04','2016-08-04','2016-08-11','FRA: Stortinget',' ','2016-08-12 18:37:26'),(38,82,'Kjøp av kommunikasjonstjenster','Spørsmål om kjøp av kommunikasjonstjenester','2016',2590,1,'AD','2016-08-03','2016-08-04','2016-08-11','FRA: Kruse Larsen AS',' ','2016-08-12 18:37:26'),(39,82,'Avlastningsreiser for psykisk utviklingshemmede og deres pårrøende','Spørsmål om informasjon om støtteordninger - Oppstart av prosjekt - Avlastningsreiser for psykisk utviklingshemmede barn og deres pårørende','2016',2592,1,'AD','2016-08-02','2016-08-04','2016-08-11','FRA:            Leif Åge Vestbø',' ','2016-08-12 18:37:26'),(40,82,'Personhenvendelse - NAV Haugesund og stans av stønad i forbindelse med utenlandsopphold','Personhenvendelse - Klage på saksbehandler hos NAV - Stans i utbetaling av sosialhjelp','2016',2609,2,'AD','2016-08-03','2016-08-04','2016-08-11','FRA:            Avskjermet','Offl. § 13 1. ledd, jf. fvl. § 13 1. ledd nr. 1 ','2016-08-12 18:37:26'),(41,82,'Befalets fellesorganisa