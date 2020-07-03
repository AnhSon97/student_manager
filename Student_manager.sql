CREATE DATABASE manager_student;
USE manager_student;


-- Tạo table với các ràng buộc và kiểu dữ liệu  Thêm ít nhất 3 bản ghi vào table

DROP TABLE IF EXISTS Student;
CREATE TABLE Student (
RN 			TINYINT AUTO_INCREMENT PRIMARY KEY,
`Name` 		VARCHAR(40) NOT NULL,
Age 		TINYINT NOT NULL,
Gender 		ENUM('0','1',"null")
);
INSERT INTO Student
VALUE 	(1,"Nguyen Anh Son",23,'0'),
		(2,"Nguyen Phuong Thao",23,'1'),
        (3,"Nguyen Dac Trung",18,"null");
        
        
        
DROP TABLE IF EXISTS `Subject`;        
CREATE TABLE `Subject`(
sID 	VARCHAR(20) PRIMARY KEY,
sName 	VARCHAR(50) NOT NULL
);
INSERT INTO `Subject`
VALUE 		('s001','MySQL'),
			('s002','JavaCore'),
            ('s003','JavaAdvanced');
            
            
DROP TABLE IF EXISTS StudentSubject;
CREATE TABLE StudentSubject(
RN 		TINYINT NOT NULL,
sID 	VARCHAR(20) NOT NULL,
Mark 	TINYINT NOT NULL,
`Date`	DATETIME DEFAULT NOW(),
		PRIMARY KEY(RN,sID)
);
INSERT INTO StudentSubject
VALUE  		(1,'s001',7,'2020-9-25'),
			(2,'s002',8,'2019-7-10'),
            (3,'s003',9,'2018-9-2');
            
-- b) Viết lệnh để             
-- a. Lấy tất cả các môn học không có bất kì điểm nào

SELECT sName FROM `subject` 
WHERE sID NOT IN 
(SELECT sID FROM studentsubject);


-- b.Lấy danh sách các môn học có ít nhất 2 điểm 

SELECT 		S.sName, COUNT(ST.Mark) FROM  `subject` S
JOIN  		studentsubject ST
ON 			S.sID = ST.sID
GROUP BY 	ST.Mark
HAVING 		COUNT(ST.Mark) = 2;


-- c) Tạo "StudentInfo" view 

CREATE VIEW StudentInfo AS
SELECT S.RN,S.`Name`,S.Age,SS.sID,SS.Mark, SS.`Date`,SU.sName,
CASE 	WHEN Gender = '0' 		THEN 'Male'
		WHEN Gender = '1' 		THEN 'FeMale'
		WHEN Gender = 'null' 	THEN 'UnKnow'
END AS Gioi_Tinh
FROM		Student S, `Subject` SU, StudentSubject SS
WHERE		(S.RN=SS.RN) AND (SS.sID=SU.sID);


-- d) Tạo trigger cho table Subject:

-- Trigger CasUpdate
-- khi thay đổi data của cột sID, thì giá trị của cột sID của table StudentSubject cũng thay đổi theo

DELIMITER $$
CREATE TRIGGER 	CasUpdate
AFTER UPDATE ON `subject`
FOR EACH ROW
BEGIN

UPDATE 	studentsubject
SET 	sID = NEW.sID
WHERE 	sID = OLD.sID;

END $$
DELIMITER ;

-- Trigger casDel
-- Khi xóa 1 student, các dữ liệu của table StudentSubject cũng sẽ bị xóa theo 


DELIMITER $$
 CREATE TRIGGER casDel
 AFTER DELETE ON student
 FOR EACH ROW

 BEGIN
 
 DELETE FROM studentsubject
 WHERE RN = OLD.RN;
 
 END $$
 DELIMITER ;
 
-- Viết 1 thủ tục (có 2 parameters: student name, mark). Thủ tục sẽ xóa tất cả
-- các thông tin liên quan tới học sinh có cùng tên như parameter và tất cả
-- các điểm nhỏ hơn của các học sinh đó.
-- Trong trường hợp nhập vào "*" thì thủ tục sẽ xóa tất cả các học sinh

DELIMITER $$
CREATE PROCEDURE delete_student(IN in_name VARCHAR(40), IN in_mark TINYINT)
BEGIN

IF (in_name = '*') THEN
TRUNCATE TABLE student;

ELSE

DELETE FROM student
WHERE `Name` = in_name AND RN IN 
(SELECT SS.RN FROM studentsubject SS JOIN student S ON SS.RN = S.RN WHERE Mark < in_mark);
END IF;

END $$
DELIMITER ;

