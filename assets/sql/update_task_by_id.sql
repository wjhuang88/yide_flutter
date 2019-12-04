UPDATE `task_data` SET 
    `create_time` = ?,
    `tag_id` = ?,
    `task_time` = ?,
    `content` = ?,
    `is_finished` = ?,
    `remark` = ?,
    `alarm_time` = ?
WHERE `id` = ?;