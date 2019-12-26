CREATE TABLE IF NOT EXISTS `task_recurring`(
    `id` INTEGER PRIMARY KEY AUTOINCREMENT,
    `task_id` INTEGER,
    `repeat_mode` INTEGER,
    `repeat_max_num` INTEGER,
    `days_of_week_code` INTEGER,
    `days_of_month_code` INTEGER,
    `months_of_year_code` INTEGER,
    `task_time` INTEGER,
    `create_time` INTEGER
);