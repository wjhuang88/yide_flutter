DELETE FROM `task_data` WHERE `id` = ?;
DELETE FROM `task_detail` WHERE `id` = ?;
DELETE FROM `task_recurring` WHERE `task_id` = ?;