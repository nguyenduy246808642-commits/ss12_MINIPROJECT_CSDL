CREATE DATABASE social_network_ss12;
use social_network_ss12;

CREATE TABLE users(
	user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE posts (
	post_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id  INT,
    content  TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)  ON DELETE CASCADE
);

CREATE TABLE comments (
	comment_id INT PRIMARY KEY AUTO_INCREMENT,
    post_id INT ,
    user_id INT ,
    content TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP, 

    FOREIGN KEY (post_id) REFERENCES  posts(post_id) ON DELETE CASCADE,
	FOREIGN KEY (user_id) REFERENCES  users(user_id) ON DELETE CASCADE
);

CREATE TABLE friends(
	user_id INT ,
    friend_id INT, 
    status VARCHAR(20) CHECK (status IN ('pending','accepted')),
    PRIMARY KEY (user_id, friend_id),
    FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE,
    FOREIGN KEY (friend_id) REFERENCES users (user_id) ON DELETE CASCADE,
    CHECK (user_id != friend_id)
);

CREATE TABLE likes(
	user_id INT ,
    post_id INT ,
    PRIMARY KEY (user_id,post_id),
	FOREIGN KEY (user_id)  REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (post_id)  REFERENCES posts(post_id) ON DELETE CASCADE
);

INSERT INTO users(username,password, email) 
VALUES 
('Vu Anh Duc','123','vuanhduc@gmail.com'),
('Nguyen Hai Duong','123','haiduong@gmail.com'),
('Minh Hieu','123','minhhieu@gmail.com');

-- Posts
INSERT INTO posts(user_id, content) VALUES
(1, 'Hello world'),
(2, 'My first post'),
(3, 'Good morning');

-- Likes
INSERT INTO likes(user_id, post_id) VALUES
(2,1),
(3,1),
(1,2);

-- Comments
INSERT INTO comments(user_id, post_id, content) VALUES
(2,1,'Nice'),
(3,1,'Great'),
(1,2,'Cool');

-- Friends
INSERT INTO friends(user_id, friend_id, status) VALUES
(1,2,'accepted'),
(1,3,'accepted'),
(2,3,'pending');

-- REQ-01: Hiển thị hồ sơ người dùng an toàn
create view vw_UserInfo
as 
select user_id, username, email, created_at
from users;

select * from vw_UserInfo;

-- REQ-02: Báo cáo tương tác bài viết

create view vw_PostStatistics
as
select post_id, content, username, count(user_id), count(comment_id)
from posts p
inner join users u
on u.users_id = p. users_id
left join likes l
on l.post_id = p.post_id
left join comments c
on c.post_id = p.post_id
group by p.post_id;

-- REQ_03
DELIMITER $$
CREATE PROCEDURE RegisterUser(
    IN p_username VARCHAR(50),
    IN p_password VARCHAR(255),
    IN p_email VARCHAR(100),
    OUT message VARCHAR(100)
)
BEGIN
    IF p_email IN (
        SELECT email 
        FROM users
    ) THEN
        SET message = 'Email đã được sử dụng';

    ELSE
        INSERT INTO users(username, password, email)
        VALUES(p_username, p_password, p_email);
        SET message = 'Đăng ký thành công';
    END IF;
END $$
DELIMITER ;

-- REQ_04
DELIMITER $$

CREATE PROCEDURE CreatePost(
    IN p_user_id INT,
    IN p_content TEXT,
    OUT p_post_id INT
)
BEGIN

    -- Thêm bài viết mới
    INSERT INTO posts(user_id, content)
    VALUES(p_user_id, p_content);

    -- Lấy post_id vừa tạo
    SET p_post_id = LAST_INSERT_ID();

END $$

DELIMITER ;

-- REQ 05

DELIMITER $$
CREATE PROCEDURE GetFriendList(
    IN p_user_id INT,
    IN p_limit INT,
    IN p_offset INT
)
BEGIN
    SELECT 
        u.username,
        u.email
    FROM friends f
    INNER JOIN users u
	ON u.user_id = f.friend_id
    WHERE f.user_id = p_user_id
	AND f.status = 'accepted'
    LIMIT p_limit
    OFFSET p_offset;
END $$

-- REQ 6
CREATE INDEX idx_post_created_at
ON posts(created_at);
DELIMITER ;


