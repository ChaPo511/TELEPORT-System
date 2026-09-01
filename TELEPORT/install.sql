CREATE TABLE IF NOT EXISTS `TELEPORT_elevators` (
  `elevator_id` varchar(50) NOT NULL,
  `data` longtext NOT NULL,
  PRIMARY KEY (`elevator_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
