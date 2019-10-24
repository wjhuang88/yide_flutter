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