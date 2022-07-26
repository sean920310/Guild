CREATE TABLE `guild_list` (
	`name` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_bin',
	`chairman` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_bin',
	`level` INT(11) NULL DEFAULT '1',
	`point` INT(11) NULL DEFAULT '0',
	`money` INT(11) NULL DEFAULT '0',
	`players` INT(11) NULL DEFAULT '0',
	`skillPoint` INT(11) NULL DEFAULT '0',
	`skill` LONGTEXT NULL DEFAULT '{"XP":0,"attack":0,"treasure":0,"defense":0,"recoverHP":0,"recoverMP":0}' COLLATE 'utf8mb4_bin',
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
	`shop` LONGTEXT NULL DEFAULT '{"green_material":0,"blue_material":0,"purple_material":0,"gold_material":0,"red_material":0}' COLLATE 'utf8mb4_bin',
	`mission` LONGTEXT NULL DEFAULT '{"hard":[],"medium":[],"easy":[]}' COLLATE 'utf8mb4_bin',
	`point` INT(11) NULL DEFAULT '0',
	`grade` INT(11) NULL DEFAULT '0',
	PRIMARY KEY (`identifier`) USING BTREE
)
COLLATE='utf8mb4_bin'
ENGINE=InnoDB
;
