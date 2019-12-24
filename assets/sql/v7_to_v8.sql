ALTER TABLE `task_data` ADD COLUMN `finish_time` INTEGER;
UPDATE `task_data` SET 
    `finish_time` = `task_time`
WHERE `is_finished` = 1;