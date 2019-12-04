INSERT INTO `task_detail` (
    `id`,
    `create_time`,
    `reminder_bitmap`,
    `repeat_bitmap`,
    `address`,
    `latitude`,
    `longitude`
) VALUES (?, ?, ?, ?, ?, ?, ?);