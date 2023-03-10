CREATE TABLE `mgdgangbuilder_gangs` (`name` VARCHAR(50) NOT NULL , `label` VARCHAR(50) NOT NULL , `data` LONGTEXT NOT NULL , PRIMARY KEY (`name`));
ALTER TABLE `mgdgangbuilder_gangs` CONVERT TO CHARACTER SET utf8 COLLATE utf8_unicode_ci;
CREATE TABLE `mgdgangbuilder_gangs_grades` (`gang_name` VARCHAR(50) NOT NULL , `grade` INT NOT NULL , `name` VARCHAR(50) NOT NULL , `label` VARCHAR(50) NOT NULL , `permissions` LONGTEXT NOT NULL);
ALTER TABLE `mgdgangbuilder_gangs_grades` CONVERT TO CHARACTER SET utf8 COLLATE utf8_unicode_ci;
ALTER TABLE `mgdgangbuilder_gangs_grades` ADD UNIQUE (`gang_name`, `grade`);
ALTER TABLE `mgdgangbuilder_gangs_grades` ADD UNIQUE (`gang_name`, `name`);
INSERT INTO `mgdgangbuilder_gangs` (`name`, `label`, `data`) VALUES ('none', 'Aucun', '{}');
INSERT INTO `mgdgangbuilder_gangs_grades` (`gang_name`, `grade`, `name`, `label`, `permissions`) VALUES ('none', '0', 'none', 'Aucun', '{}');
ALTER TABLE `users` ADD `gang` VARCHAR(50) NULL DEFAULT 'none' AFTER `job_grade`, ADD `gang_grade` INT NOT NULL DEFAULT '0' AFTER `gang`;