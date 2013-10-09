-- phpMyAdmin SQL Dump
-- version 3.4.5
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Jul 20, 2012 at 09:46 PM
-- Server version: 5.5.16
-- PHP Version: 5.3.8

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `gglab`
--

-- --------------------------------------------------------

--
-- Table structure for table `experiment`
--

CREATE TABLE IF NOT EXISTS `experiment` (
  `name` varchar(50) NOT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `comments` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Info about an experiment, defined as a "repository" of recordings.' AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `recording`
--

CREATE TABLE IF NOT EXISTS `recording` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `date` datetime NOT NULL,
  `experiment` int(11) DEFAULT NULL,
  `length` int(11) DEFAULT NULL COMMENT 'If NULL, it means that the video has not been finished yet.',
  `host` varchar(255) NOT NULL DEFAULT '127.0.0.1' COMMENT 'The local address of the machine where the current recording is',
  `path` varchar(255) NOT NULL,
  `codec` varchar(4) DEFAULT NULL,
  `chamber` int(11) DEFAULT NULL,
  `flies` int(11) DEFAULT NULL COMMENT 'Number of flies',
  `gender` int(11) DEFAULT NULL,
  `dob` date DEFAULT NULL COMMENT 'Date of Birth',
  `genotype` varchar(255) DEFAULT NULL,
  `comments` text,
  `name` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `experiment` (`experiment`,`chamber`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 COMMENT='Info about a single recording' AUTO_INCREMENT=8 ;

--
-- Dumping data for table `recording`
--

INSERT INTO `recording` (`id`, `date`, `experiment`, `length`, `host`, `path`, `codec`, `chamber`, `flies`, `gender`, `dob`, `genotype`, `comments`, `name`) VALUES
(1, '0000-00-00 00:00:00', NULL, 9, '155.198.235.210', 'H:\\workspace\\Fly\\src\\videos\\2012\\7\\Video_11_17-39-10_0.avi', '1482', NULL, 1, 7, NULL, 'xxx', 'Test!', 'Video_11_17-39-10_0.avi'),
(2, '2012-07-11 00:00:00', NULL, 4, '155.198.235.210', 'H:\\workspace\\Fly\\src\\videos\\2012\\7\\Video_11_18-43-37_0.avi', '1482', NULL, NULL, NULL, NULL, NULL, 'Test!', 'Video_11_18-43-37_0.avi'),
(3, '2012-07-12 00:00:00', NULL, 4, '155.198.235.210', 'H:\\workspace\\Fly\\src\\videos\\2012\\7\\Video_12_13-10-13_0.avi', '1482', NULL, NULL, NULL, NULL, NULL, 'Test!', 'Video_12_13-10-13_0.avi'),
(4, '2012-07-19 00:00:00', NULL, 2, '155.198.235.210', 'H:\\workspace\\Fly\\src\\videos\\2012\\7\\Video_19_15-41-51_0.avi', '1482', NULL, NULL, NULL, NULL, NULL, 'Test!', 'Video_19_15-41-51_0.avi'),
(5, '2012-07-20 00:00:00', NULL, 1696, '155.198.235.210', 'H:\\workspace\\Fly\\src\\videos\\2012\\7\\Video_20_16-50-28_0.avi', '1482', NULL, 1, 3, NULL, 'not known', 'hello!!!', 'Unknown video'),
(6, '2012-07-20 00:00:00', NULL, 5, '', 'H:\\workspace\\Fly\\src\\videos\\2012\\7\\Video_20_20-33-2_0.avi', '1482', NULL, NULL, NULL, NULL, NULL, 'Test!', 'Video_20_20-33-2_0.avi'),
(7, '2012-07-20 00:00:00', NULL, 3, '155.198.235.210', 'H:\\workspace\\Fly\\src\\videos\\2012\\7\\Video_20_20-46-0_0.avi', '1482', NULL, NULL, NULL, NULL, NULL, 'Test!', 'Video_20_20-46-0_0.avi');

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

CREATE TABLE IF NOT EXISTS `user` (
  `firstName` varchar(50) NOT NULL,
  `lastName` varchar(50) NOT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`),
  KEY `lastName` (`lastName`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Users that have access to the system' AUTO_INCREMENT=1 ;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
