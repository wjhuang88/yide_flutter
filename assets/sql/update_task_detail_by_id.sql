UPDATE `task_detail` SET 
    `create_time` = ?,
    `reminder_bitmap` = ?,
    `repeat_bitmap` = ?,
    `address` = ?,
    `latitude` = ?,
    `longitude` = ?
WHERE `id` = ?;