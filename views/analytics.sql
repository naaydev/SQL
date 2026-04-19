-- Views

-- Task Overview View
CREATE VIEW v_task_overview AS
SELECT 
    t.id,
    t.title,
    t.description,
    t.priority,
    t.status,
    t.due_date,
    t.created_at,
    t.completed_at,
    u.username,
    c.name AS category_name,
    c.color AS category_color,
    DATEDIFF(IFNULL(t.completed_at, CURDATE()), t.created_at) AS days_in_progress
FROM tasks t
JOIN users u ON t.user_id = u.id
LEFT JOIN categories c ON t.category_id = c.id;

-- User Statistics View
CREATE VIEW v_user_statistics AS
SELECT 
    u.id,
    u.username,
    u.email,
    COUNT(t.id) AS total_tasks,
    SUM(CASE WHEN t.status = 'completed' THEN 1 ELSE 0 END) AS completed_tasks,
    SUM(CASE WHEN t.status = 'pending' THEN 1 ELSE 0 END) AS pending_tasks,
    SUM(CASE WHEN t.priority = 'high' THEN 1 ELSE 0 END) AS high_priority,
    AVG(DATEDIFF(t.completed_at, t.created_at)) AS avg_completion_days
FROM users u
LEFT JOIN tasks t ON u.id = t.user_id
GROUP BY u.id;

-- Category Progress View
CREATE VIEW v_category_progress AS
SELECT 
    c.id,
    c.name,
    c.color,
    u.username,
    COUNT(t.id) AS total_tasks,
    SUM(CASE WHEN t.status = 'completed' THEN 1 ELSE 0 END) AS completed,
    ROUND(SUM(CASE WHEN t.status = 'completed' THEN 1 ELSE 0 END) / COUNT(t.id) * 100, 1) AS completion_rate
FROM categories c
JOIN users u ON c.user_id = u.id
LEFT JOIN tasks t ON c.id = t.category_id
GROUP BY c.id;

-- Activity Timeline View
CREATE VIEW v_activity_timeline AS
SELECT 
    al.id,
    al.action,
    al.entity_type,
    al.entity_id,
    al.created_at,
    u.username,
    CASE 
        WHEN al.entity_type = 'task' AND al.action = 'create' THEN 'created a task'
        WHEN al.entity_type = 'task' AND al.action = 'complete' THEN 'completed a task'
        WHEN al.entity_type = 'task' AND al.action = 'comment' THEN 'commented on a task'
        ELSE al.action
    END AS description
FROM activity_log al
JOIN users u ON al.user_id = u.id;