INSERT INTO `task_data` (
    `create_time`,
    `tag_id`,
    `task_time`,
    `content`,
    `is_finished`,
    `remark`,
    `alarm_time`,
    `time_type_code`,
    `finish_time`
) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);