UPDATE `task_recurring` SET 
    `task_id` = ?,
    `repeat_mode` = ?,
    `repeat_max_num` = ?,
    `days_of_week_code` = ?,
    `days_of_month_code` = ?,
    `months_of_year_code` = ?,
    `task_time` = ?,
    `create_time` = ?,
    `next_time` = ?
WHERE `task_id` = ?;