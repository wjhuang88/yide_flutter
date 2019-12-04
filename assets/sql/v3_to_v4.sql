ALTER TABLE `task_data` RENAME TO `_task_data_temp`;
CREATE TABLE IF NOT EXISTS `task_data`(
    `id` INTEGER PRIMARY KEY AUTOINCREMENT,
    `create_time` INTEGER,
    `tag_id` INTEGER,
    `task_time` INTEGER,
    `content` TEXT,
    `is_finished` INTEGER,
    `remark` TEXT,
    `alarm_time` INTEGER
);
INSERT INTO `task_data` (`create_time`, `tag_id`, `task_time`, `content`, `is_finished`, `remark`, `alarm_time`) SELECT `create_time`, `tag_id`, `task_time`, `content`, `is_finished`, `remark`, `alarm_time` FROM `_task_data_temp`;
DROP TABLE `_task_data_temp`;