CREATE TABLE IF NOT EXISTS `task_detail`(
    `id` INTEGER PRIMARY KEY,
    `create_time` INTEGER,
    `reminder_bitmap` INTEGER,
    `repeat_bitmap` INTEGER,
    `address` TEXT,
    `latitude` REAL,
    `longitude` REAL
);
CREATE TABLE IF NOT EXISTS `task_tag`(
    `id` INTEGER PRIMARY KEY AUTOINCREMENT,
    `background_color` INTEGER,
    `icon_color` INTEGER,
    `name` TEXT
);
DELETE FROM `task_tag`;
INSERT INTO `task_tag` (`background_color`, `icon_color`, `name`) VALUES (4291797871, 4291797871, '休息');
INSERT INTO `task_tag` (`background_color`, `icon_color`, `name`) VALUES (4289688053, 4289688053, '生活');
INSERT INTO `task_tag` (`background_color`, `icon_color`, `name`) VALUES (4284668635, 4284668635, '工作');
INSERT INTO `task_tag` (`background_color`, `icon_color`, `name`) VALUES (4293975078, 4293975078, '健康');