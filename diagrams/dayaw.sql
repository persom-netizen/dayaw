-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Oct 31, 2025 at 03:32 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `dayaw`
--

-- --------------------------------------------------------

--
-- Table structure for table `alaala`
--

CREATE TABLE `alaala` (
  `id` int(11) NOT NULL,
  `salita` varchar(255) NOT NULL,
  `depinisyon` text NOT NULL,
  `bigkas` varchar(255) DEFAULT NULL,
  `etimolohiya` text DEFAULT NULL,
  `gamit` text DEFAULT NULL,
  `kontekstong_kultural` text DEFAULT NULL,
  `petsa` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `chat_history`
--

CREATE TABLE `chat_history` (
  `id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `user_message` longtext NOT NULL,
  `ai_response` longtext NOT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `chat_history`
--

INSERT INTO `chat_history` (`id`, `username`, `user_message`, `ai_response`, `created_at`) VALUES
(5, 'test', 'why are you not working', 'Error calling OpenAI: Error code: 429 - {\'error\': {\'message\': \'You exceeded your current quota, please check your plan and billing details. For more information on this error, read the docs: https://platform.openai.com/docs/guides/error-codes/api-errors.\', \'type\': \'insufficient_quota\', \'param\': None, \'code\': \'insufficient_quota\'}}', '2025-10-28 12:41:57'),
(6, 'test7', 'sino ka', 'Error calling OpenAI: Error code: 429 - {\'error\': {\'message\': \'You exceeded your current quota, please check your plan and billing details. For more information on this error, read the docs: https://platform.openai.com/docs/guides/error-codes/api-errors.\', \'type\': \'insufficient_quota\', \'param\': None, \'code\': \'insufficient_quota\'}}', '2025-10-28 13:00:13');

-- --------------------------------------------------------

--
-- Table structure for table `chat_threads`
--

CREATE TABLE `chat_threads` (
  `id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `title` varchar(255) NOT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `login`
--

CREATE TABLE `login` (
  `id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `login`
--

INSERT INTO `login` (`id`, `username`, `email`, `password`) VALUES
(1, 'test', 'test@gmail.com', '60fa35ee73acc3f4d01ef9ab37a654ba08e8861af9b3af82a350e3cb9a965995'),
(2, 'test2', 'test2@gmail.com', '60fa35ee73acc3f4d01ef9ab37a654ba08e8861af9b3af82a350e3cb9a965995'),
(3, 'test4', 'test4@gmail.com', '60fa35ee73acc3f4d01ef9ab37a654ba08e8861af9b3af82a350e3cb9a965995'),
(4, 'test6', 'test6@gmail.com', '60fa35ee73acc3f4d01ef9ab37a654ba08e8861af9b3af82a350e3cb9a965995'),
(5, 'test7', 'test7@gmail.com', '60fa35ee73acc3f4d01ef9ab37a654ba08e8861af9b3af82a350e3cb9a965995');

-- --------------------------------------------------------

--
-- Table structure for table `salita`
--

CREATE TABLE `salita` (
  `id` int(11) NOT NULL,
  `salita` varchar(255) NOT NULL,
  `depinisyon` text NOT NULL,
  `bigkas` varchar(255) DEFAULT NULL,
  `etimolohiya` text DEFAULT NULL,
  `gamit` text DEFAULT NULL,
  `kontekstong_kultural` text DEFAULT NULL,
  `source` varchar(50) DEFAULT 'local',
  `created_at` datetime DEFAULT current_timestamp(),
  `is_active` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `salita`
--

INSERT INTO `salita` (`id`, `salita`, `depinisyon`, `bigkas`, `etimolohiya`, `gamit`, `kontekstong_kultural`, `source`, `created_at`, `is_active`) VALUES
(1, 'Bagay', 'isang konkretong o abstraktong entidad; isang bagay na maaaring makita o maramdaman', 'bah-GAY', 'mula sa wikang Tagalog', 'Ang aklat ay isang bagay na naglalaman ng kaalaman.', 'Ginagamit sa pang-araw-araw na pag-uusap upang tukuyin ang anumang tao, lugar, o bagay.', 'local', '2025-10-28 20:45:45', 1),
(2, 'Diwa', 'kahulugan o pangunahing kaalaman; ang espiritu o bokabularyo ng isang bagay', 'DEE-wah', 'mula sa Wika at kultura ng Pilipinas', 'Ang diwa ng batas ay nagbibigay ng gabay sa lipunan.', 'Mahalaga sa pag-unawa ng mga tradisyon at halaga ng Pilipinas.', 'local', '2025-10-28 20:45:45', 0),
(3, 'Karunungan', 'mataas na antas ng kaalaman at pag-iisip; ang kakayahang gumawa ng tamang desisyon', 'kah-roo-NOO-ngan', 'mula sa Sansikrit at Tagalog', 'Ang karunungan ng matanda ay gabay natin sa buhay.', 'Ito ay isa sa pinakamahalagang halaga sa kulturang Pilipino.', 'local', '2025-10-28 20:45:45', 0),
(4, 'Pag-asa', 'ang paniniwala na may magandang kinabukasan; pag-ilong ng mabuti', 'pahg-AH-sah', 'mula sa Tagalog', 'Kahit gaano kahirap, ang pag-asa ay laging nandito.', 'Sentro ng Filipino resilience at optimism sa harap ng pagsusulong.', 'local', '2025-10-28 20:45:45', 0),
(5, 'Kapwa', 'ang kakilanilan na pareho tayong tao; pakikipag-ugnayan sa ibang tao nang may intindi at pagpapahalaga', 'KAP-wah', 'mula sa Tagalog', 'Ang kapwa natin ay nararapat pahalagahan at respetuhin.', 'Pinagkakatiwalaan bilang pundasyon ng Filipino ethics at community.', 'local', '2025-10-28 20:45:45', 0);

-- --------------------------------------------------------

--
-- Table structure for table `sign_up`
--

CREATE TABLE `sign_up` (
  `id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `confirm_password` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `sign_up`
--

INSERT INTO `sign_up` (`id`, `username`, `email`, `password`, `confirm_password`) VALUES
(1, 'test', 'test@gmail.com', '60fa35ee73acc3f4d01ef9ab37a654ba08e8861af9b3af82a350e3cb9a965995', '60fa35ee73acc3f4d01ef9ab37a654ba08e8861af9b3af82a350e3cb9a965995'),
(2, 'test2', 'test2@gmail.com', '60fa35ee73acc3f4d01ef9ab37a654ba08e8861af9b3af82a350e3cb9a965995', '60fa35ee73acc3f4d01ef9ab37a654ba08e8861af9b3af82a350e3cb9a965995'),
(3, 'test4', 'test4@gmail.com', '60fa35ee73acc3f4d01ef9ab37a654ba08e8861af9b3af82a350e3cb9a965995', '60fa35ee73acc3f4d01ef9ab37a654ba08e8861af9b3af82a350e3cb9a965995'),
(4, 'test6', 'test6@gmail.com', '60fa35ee73acc3f4d01ef9ab37a654ba08e8861af9b3af82a350e3cb9a965995', '60fa35ee73acc3f4d01ef9ab37a654ba08e8861af9b3af82a350e3cb9a965995'),
(5, 'test7', 'test7@gmail.com', '60fa35ee73acc3f4d01ef9ab37a654ba08e8861af9b3af82a350e3cb9a965995', '60fa35ee73acc3f4d01ef9ab37a654ba08e8861af9b3af82a350e3cb9a965995');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `username` varchar(50) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `password_hash` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `email`, `password_hash`) VALUES
(1, 'rain', 'rain@gmail.com', 'rain@gmail.com');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `alaala`
--
ALTER TABLE `alaala`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `chat_history`
--
ALTER TABLE `chat_history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_username` (`username`);

--
-- Indexes for table `chat_threads`
--
ALTER TABLE `chat_threads`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_thread_username` (`username`);

--
-- Indexes for table `login`
--
ALTER TABLE `login`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `salita`
--
ALTER TABLE `salita`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `sign_up`
--
ALTER TABLE `sign_up`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `alaala`
--
ALTER TABLE `alaala`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `chat_history`
--
ALTER TABLE `chat_history`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `chat_threads`
--
ALTER TABLE `chat_threads`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `login`
--
ALTER TABLE `login`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `salita`
--
ALTER TABLE `salita`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `sign_up`
--
ALTER TABLE `sign_up`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
