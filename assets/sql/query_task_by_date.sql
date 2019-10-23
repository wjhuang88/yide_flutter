SELECT *
FROM `task_data` 
WHERE `task_time` >= ? AND `task_time` < ?
ORDER BY `task_time`;