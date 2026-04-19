-- Stored Procedures

DELIMITER //

-- Create new task
CREATE PROCEDURE create_task(
    IN p_title VARCHAR(200),
    IN p_description TEXT,
    IN p_priority ENUM('low', 'medium', 'high'),
    IN p_due_date DATE,
    IN p_user_id INT,
    IN p_category_id INT
)
BEGIN
    INSERT INTO tasks (title, description, priority, due_date, user_id, category_id)
    VALUES (p_title, p_description, p_priority, p_due_date, p_user_id, p_category_id);
    
    INSERT INTO activity_log (action, entity_type, entity_id, user_id)
    VALUES ('create', 'task', LAST_INSERT_ID(), p_user_id);
    
    SELECT * FROM tasks WHERE id = LAST_INSERT_ID();
END //

-- Complete task
CREATE PROCEDURE complete_task(IN p_task_id INT, IN p_user_id INT)
BEGIN
    UPDATE tasks 
    SET status = 'completed', 
        completed_at = NOW()
    WHERE id = p_task_id AND user_id = p_user_id;
    
    INSERT INTO activity_log (action, entity_type, entity_id, user_id)
    VALUES ('complete', 'task', p_task_id, p_user_id);
END //

-- Delete task with cleanup
CREATE PROCEDURE delete_task(IN p_task_id INT, IN p_user_id INT)
BEGIN
    INSERT INTO activity_log (action, entity_type, entity_id, user_id)
    VALUES ('delete', 'task', p_task_id, p_user_id);
    
    DELETE FROM task_tags WHERE task_id = p_task_id;
    DELETE FROM comments WHERE task_id = p_task_id;
    DELETE FROM attachments WHERE task_id = p_task_id;
    DELETE FROM tasks WHERE id = p_task_id AND user_id = p_user_id;
END //

-- Get dashboard statistics
CREATE PROCEDURE get_dashboard_stats(IN p_user_id INT)
BEGIN
    SELECT 
        (SELECT COUNT(*) FROM tasks WHERE user_id = p_user_id) AS total,
        (SELECT COUNT(*) FROM tasks WHERE user_id = p_user_id AND status = 'pending') AS pending,
        (SELECT COUNT(*) FROM tasks WHERE user_id = p_user_id AND status = 'completed') AS completed,
        (SELECT COUNT(*) FROM tasks WHERE user_id = p_user_id AND due_date = CURDATE()) AS due_today,
        (SELECT COUNT(*) FROM tasks WHERE user_id = p_user_id AND due_date < CURDATE() AND status != 'completed') AS overdue;
END //

-- Add comment to task
CREATE PROCEDURE add_comment(
    IN p_content TEXT,
    IN p_task_id INT,
    IN p_user_id INT
)
BEGIN
    INSERT INTO comments (content, task_id, user_id)
    VALUES (p_content, p_task_id, p_user_id);
    
    INSERT INTO activity_log (action, entity_type, entity_id, user_id)
    VALUES ('comment', 'task', p_task_id, p_user_id);
    
    SELECT * FROM comments WHERE id = LAST_INSERT_ID();
END //

DELIMITER ;