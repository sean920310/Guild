CREATE TABLE `guild_list` (
	`name` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_bin',
	`level` INT(11) NULL DEFAULT '1',
	`point` INT(11) NULL DEFAULT '0',
	`players` INT(11) NULL DEFAULT '0',
	`comment` LONGTEXT NULL DEFAULT '' COLLATE 'utf8mb4_bin',
	PRIMARY KEY (`name`) USING BTREE
)
COLLATE='utf8mb4_general_ci'
ENGINE=InnoDB
;

CREATE TABLE `guild_player` (
	`identifier` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_bin',
	`name` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_bin',
	`guild` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_bin',
	`point` INT(11) NULL DEFAULT '0',
	`grade` INT(11) NULL DEFAULT '0',
	PRIMARY KEY (`identifier`) USING BTREE
)
COLLATE='utf8mb4_bin'
ENGINE=InnoDB
;
