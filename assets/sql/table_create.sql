CREATE TABLE IF NOT EXISTS `task_data`(
    `id` INTEGER PRIMARY KEY AUTOINCREMENT,
    `create_time` INTEGER,
    `tag_id` INTEGER,
    `task_time` INTEGER,
    `content` TEXT,
    `is_finished` INTEGER,
    `remark` TEXT,
    `alarm_time` INTEGER,
    `time_type_code` INTEGER
);
CREATE TABLE IF NOT EXISTS `task_detail`(
    `id` INTEGER PRIMARY KEY,
    `create_time` INTEGER,
    `reminder_bitmap` INTEGER,
    `repeat_bitmap` INTEGER,
    `address` TEXT,
    `latitude` REAL,
    `longitude` REAL
);