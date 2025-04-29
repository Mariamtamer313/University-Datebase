CREATE DATABASE University;

USE University;
GO

CREATE TABLE Professor
(
prof_id INT IDENTITY,
f_name NVARCHAR(15) NOT NULL,
last_name NVARCHAR(15) NOT NULL,
email NVARCHAR(100),
phonenumber NVARCHAR(20),

CONSTRAINT prof_id_pk PRIMARY KEY (prof_id),
CONSTRAINT uq_prof_email UNIQUE(email)
);


CREATE TABLE Department
(
dep_id INT IDENTITY,
dep_name NVARCHAR(30) NOT NULL, 
head_id INT NOT NULL,                -- NOT NULL

CONSTRAINT dep_id_pk PRIMARY KEY(dep_id),
CONSTRAINT dep_head_fk FOREIGN KEY(head_id) REFERENCES Professor(prof_id),
CONSTRAINT uq_dep_name UNIQUE (dep_name),
CONSTRAINT uq_dep_head UNIQUE(head_id)
);

CREATE TABLE Student 
(
std_id INT IDENTITY,
f_name NVARCHAR(15) NOT NULL,
last_name NVARCHAR(15) NOT NULL,
address NVARCHAR(200),
date_of_birth DATE NOT NULL,
email NVARCHAR(100),
total_credit_hours INT NOT NULL,
status NVARCHAR(10),
ssn NVARCHAR(20) NOT NULL,
dep_id INT,                  --  level-> derived from total completed hours & gpa-> derived form grades of completed courses

CONSTRAINT std_id_pk PRIMARY KEY (std_id),
CONSTRAINT std_dep_fk FOREIGN KEY (dep_id) REFERENCES Department(dep_id),
CONSTRAINT uq_std_ssn UNIQUE (ssn),
CONSTRAINT uq_std_email UNIQUE(email),
CONSTRAINT chk_status CHECK(status COLLATE Latin1_General_CI_AS IN ('active','graduate','suspended')),    /* COLLATE Latin1_General_CI_AS --> ensures active & Active are accepted (it ignores case when comparing strings) */
CONSTRAINT chk_total_credit_hours CHECK(total_credit_hours >= 0)
);

CREATE TABLE Course 
(
course_id INT IDENTITY,
title NVARCHAR(50) NOT NULL,
credit_hours INT NOT NULL,
course_code NVARCHAR(20 )NOT NULL,
dep_id INT,

CONSTRAINT course_id_pk PRIMARY KEY (course_id),
CONSTRAINT course_dep_fk FOREIGN KEY(dep_id) REFERENCES Department(dep_id),
CONSTRAINT uq_course_title UNIQUE(title),
CONSTRAINT uq_course_code UNIQUE(course_code),
CONSTRAINT chk_course_h CHECK(credit_hours IN (2,3))

);

CREATE TABLE Register_in
(
std_id INT,
course_id INT,
grade NVARCHAR(2) DEFAULT 'NA',
completed BIT DEFAULT 0,
year INT,
season NVARCHAR(6),

CONSTRAINT regester_in_pk PRIMARY KEY (std_id, course_id,year,season),
CONSTRAINT registerIn_std_fk FOREIGN KEY (std_id) REFERENCES Student(std_id),
CONSTRAINT registerIn_course_fk FOREIGN KEY (course_id) REFERENCES Course(course_id),
CONSTRAINT chk_grade CHECK(grade IN ('A','A-','B+','B', 'B-','C+','C','C-','D+','D','D-','F','NA')),
CONSTRAINT chk_course_season CHECK(season COLLATE Latin1_General_CI_AS  IN ('fall','summer','spring')),
CONSTRAINT chk_course_year CHECK (year >= 2015)
);

CREATE TABLE Prerequisite
(
course_id INT,
prerequisite_id INT,

CONSTRAINT prerequisite_pk PRIMARY KEY (course_id,prerequisite_id),
CONSTRAINT course_id_fk FOREIGN KEY(course_id) REFERENCES Course(course_id),
CONSTRAINT prerequisite_id_fk  FOREIGN KEY(prerequisite_id) REFERENCES Course(course_id),
CONSTRAINT  not_self_referecing CHECK(prerequisite_id != course_id)
);

CREATE TABLE Works_in
(
prof_id INT, 
dep_id INT, 

CONSTRAINT works_in_relation_pk PRIMARY KEY(prof_id,dep_id),
CONSTRAINT prof_work_in_fk FOREIGN KEY(prof_id) REFERENCES Professor(prof_id),
CONSTRAINT dep_has_prof_fk FOREIGN KEY (dep_id) REFERENCES Department(dep_id)
);

CREATE TABLE Teaching
(
prof_id INT,
course_id INT,

CONSTRAINT teaching_relation_pk PRIMARY KEY(prof_id,course_id),
CONSTRAINT prof_teaching_fk FOREIGN KEY(prof_id) REFERENCES Professor(prof_id),
CONSTRAINT prof_course_fk FOREIGN KEY (course_id) REFERENCES Course(course_id)
);

CREATE TABLE Student_phoneNumber
(
std_id INT,
phone_number varchar(30),

CONSTRAINT std_phone_pk PRIMARY KEY(std_id,phone_number),
CONSTRAINT std_phone_fk FOREIGN KEY (std_id) REFERENCES Student(std_id)
);

CREATE TABLE Department_contact_details
(
contact_details INT,
dep_id INT,

CONSTRAINT dep_contact_details_pk PRIMARY KEY(contact_details,dep_id),
CONSTRAINT dep_contact_fk FOREIGN KEY (dep_id) REFERENCES Department(dep_id)
);
  
ALTER TABLE Register_in
ADD CONSTRAINT chk_completed_grade CHECK((completed = 0 AND grade = 'NA') OR
										(completed = 1 AND grade IN ('A','A-','B+','B', 'B-','C+','C','C-','D+','D','D-','F') ));

------------------------------------------------------------------------------------------------------------------------------------

CREATE TRIGGER 
	valid_total_courses_per_semester
ON 
	Register_in
AFTER	
	INSERT, UPDATE 
AS
BEGIN
	IF EXISTS 
	(
	SELECT
		SUM(c.credit_hours) AS total_credit_hours
	FROM 
		Course c JOIN Register_in r ON r.course_id = c.course_id
	WHERE	 
		grade NOT IN ('NA','F')
	GROUP BY 
		r.std_id, r.season, r.year
	HAVING 
		SUM(credit_hours) NOT BETWEEN 17 AND 20
	)
	BEGIN
		RAISERROR('total credit hours per semester must be between 20 and 17',16,1);
		ROLLBACK TRANSACTION
	END
END;
GO

CREATE TRIGGER update_credit_hours
ON Register_in
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @new_total_hours INT; -- Variable to store the total credit hours for the student

    -- Calculate the total credit hours for the student (completed courses)
    SELECT @new_total_hours = SUM(c.credit_hours)
    FROM Course c
    JOIN Register_in ri ON c.course_id = ri.course_id
    WHERE ri.std_id IN (SELECT std_id FROM inserted) AND ri.completed = 1;

    -- Update the student's total credit hours in the Student table
    UPDATE Student
    SET total_credit_hours = @new_total_hours
    WHERE std_id IN (SELECT std_id FROM inserted);
END;
GO

SELECT 
    std_id, 
    f_name, 
    last_name, 
    total_credit_hours,
    CASE
        WHEN total_credit_hours BETWEEN 0 AND 28 THEN 1
        WHEN total_credit_hours BETWEEN 29 AND 64 THEN 2
        WHEN total_credit_hours BETWEEN 65 AND 98 THEN 3
        WHEN total_credit_hours >= 99 THEN 4
    END AS level
FROM Student;

SELECT 
    s.std_id,
    s.f_name,
    s.last_name,
    SUM(
        CASE 
            WHEN ri.grade = 'A' THEN 4.0
            WHEN ri.grade = 'A-' THEN 3.7
            WHEN ri.grade = 'B+' THEN 3.3
            WHEN ri.grade = 'B' THEN 3.0
            WHEN ri.grade = 'B-' THEN 2.7
            WHEN ri.grade = 'C+' THEN 2.3
            WHEN ri.grade = 'C' THEN 2.0
            WHEN ri.grade = 'C-' THEN 1.7
            WHEN ri.grade = 'D+' THEN 1.3
            WHEN ri.grade = 'D' THEN 1.0
            WHEN ri.grade = 'F' THEN 0.0
            ELSE 0.0  -- Default case for NA or invalid grades
        END * c.credit_hours
    ) / SUM(c.credit_hours) AS GPA
FROM 
    Student s
JOIN 
    Register_in ri ON s.std_id = ri.std_id
JOIN 
    Course c ON ri.course_id = c.course_id
WHERE 
    ri.completed = 1  -- Only completed courses
GROUP BY 
    s.std_id, s.f_name, s.last_name;




