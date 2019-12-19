SELECT 
    `task_data`.`id` as `id`,
    `task_data`.`create_time` as `create_time`,
    `task_data`.`tag_id` as `tag_id`,
    `task_data`.`task_time` as `task_time`,
    `task_data`.`content` as `content`,
    `task_data`.`is_finished` as `is_finished`,
    `task_data`.`remark` as `remark`,
    `task_data`.`alarm_time` as `alarm_time`,
    `task_data`.`time_type_code` as `time_type_code`,
    `task_tag`.`background_color` as `background_color`,
    `task_tag`.`icon_color` as `icon_color`,
    `task_tag`.`name` as `tag_name`
FROM `task_data`
LEFT OUTER JOIN `task_tag`
ON `task_data`.`tag_id` = `task_tag`.`id`
WHERE `task_data`.`task_time` >= ? AND `task_data`.`task_time` < ? AND `task_data`.`time_type_code` != 2
ORDER BY `task_data`.`time_type_code` ASC, `task_data`.`task_time` ASC;