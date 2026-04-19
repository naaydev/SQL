-- Task Queries

-- Get all tasks for a user with category
SELECT 
    t.*,
    c.name AS category_name,
    c.color AS category_color
FROM tasks t
LEFT JOIN categories c ON t.category_id = c.id
WHERE t.user_id = ?
ORDER BY 
    CASE t.priority 
        WHEN 'high' THEN 1 
        WHEN 'medium' THEN 2 
        WHEN 'low' THEN 3 
    END,
    t.created_at DESC;

-- Get tasks by status
SELECT * FROM tasks 
WHERE user_id = ? AND status = ?
ORDER BY due_date ASC;

-- Get overdue tasks
SELECT t.*, u.email AS user_email
FROM tasks t
JOIN users u ON t.user_id = u.id
WHERE t.due_date < CURDATE() 
    AND t.status != 'completed'
    AND t.user_id = ?;

-- Get task count by priority
SELECT priority, COUNT(*) as count
FROM tasks
WHERE user_id = ?
GROUP BY priority;

-- Get tasks due today
SELECT * FROM tasks
WHERE user_id = ? 
    AND due_date = CURDATE()
    AND status != 'completed';

-- Get tasks with comments count
SELECT 
    t.*,
    COUNT(c.id) AS comments_count
FROM tasks t
LEFT JOIN comments c ON t.id = c.task_id
WHERE t.user_id = ?
GROUP BY t.id;

-- Get category statistics
SELECT 
    c.name,
    COUNT(t.id) AS total_tasks,
    SUM(CASE WHEN t.status = 'completed' THEN 1 ELSE 0 END) AS completed,
    SUM(CASE WHEN t.status = 'pending' THEN 1 ELSE 0 END) AS pending
FROM categories c
LEFT JOIN tasks t ON c.id = t.category_id
WHERE c.user_id = ?
GROUP BY c.id;

-- Search tasks
SELECT * FROM tasks
WHERE user_id = ?
    AND (title LIKE ? OR description LIKE ?)
ORDER BY created_at DESC;

-- Get recent activity
SELECT 
    al.*,
    u.username
FROM activity_log al
JOIN users u ON al.user_id = u.id
WHERE al.user_id = ?
ORDER BY al.created_at DESC
LIMIT 20;