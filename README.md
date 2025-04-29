# University-Datebase
🎓 University Database Management System
📌 Project Overview
This project implements a comprehensive relational database system for a university. It includes full database schema design, business rule enforcement through constraints and triggers, and SQL queries to derive insights like student GPA and academic level.

 Objectives
Design a normalized relational database model that reflects core university operations.

Implement business rules using constraints and triggers.

Populate the database with sample data.

Derive meaningful metrics such as student GPA and academic levels using SQL.

 Key Features
Relational database schema with tables for Students, Professors, Courses, Departments, Registrations, etc.

Triggers to ensure business logic like credit hour thresholds and automatic credit hour updates.

Derived fields such as academic level and GPA computed using SQL queries.

Constraints for data integrity including unique values, check conditions, and foreign keys.

 Database Structure
Professor

Student

Department

Course

Register_in

Prerequisite

Works_in

Teaching

Student_phoneNumber

Department_contact_details

 Business Logic Implemented
A student’s level is automatically determined by total credit hours.

GPA is computed based on course grades and credit hours.

Triggers:

Enforce credit hour limits per semester (17–20 hours).

Auto-update student total credit hours when course registration changes.

 Technologies Used
SQL Server (T-SQL)

Relational Database Design

ER Diagrams

Normalization (Up to 3NF)

 Sample Queries Included
Student academic level classification.

GPA calculation based on completed courses.

Data retrieval with JOINs across major entities.

 How to Run
Use Microsoft SQL Server Management Studio (SSMS) or any T-SQL compatible client.

Execute the script to create the database and all associated tables.

Add sample data (not included in script above).

Run analysis queries to retrieve GPA, level, and relational insights.

 Team Collaboration
This project was developed collaboratively within a team, ensuring shared responsibilities in database design, SQL scripting, and validation of business logic.
