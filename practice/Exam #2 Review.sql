Q: Show each employee and project including 
the number of hours they work on each project.

SELECT pe.last_name, pe.first_name, p.project_name, pe.hours_per_week
FROM (employee e INNER JOIN project_assignment pa
	 ON e.employeeid = pa.employeeid) pe
		INNER JOIN project p
				ON pe.project_number = p.project_id;

Q: See if there are any projects managed by a department 
but where the project location is different from 
the department location.

SELECT p.project_name, p.project_location, d.department_location
FROM project p INNER JOIN department d
ON p.departmentid = d.departmentid
WHERE p.project_location <> d.department_location;

Recursive Query

Q: Suppose we were interested in those students 
who do not tutor anyone? 
Tip: Use RIGHT JOIN

SELECT   DISTINCT tutors.name
FROM     students RIGHT JOIN students tutors
ON       students.student_tutorid = tutors.studentid
WHERE students.student_tutorid IS NULL;

Q: Provide a listing of each student and 
the name of their tutor

SELECT s.studentis, s.name, t.name
FROM students s LEFT JOIN students t
     ON s.student_tutorid = t.studentid;

Q: What is the largest number of students 
one person tutors?

SELECT TOP 1 t.name, COUNT(*) AS Tutored_stu
FROM students s RIGHT JOIN students t
ON s.student_tutorid = t.studentid
GROUP BY t.name
ORDER BY COUNT(*) DESC;

Subqueries

Q: Find the student with the highest grade using subqueries

SELECT name, grade 
FROM students
WHERE grade = 
	(SELECT MAX(students.grade) FROM students);

Inline Queries

Q: For each department, does there exist a matching Project 
that has a project location in New York?

SELECT department_name, project_id, project_name
FROM (SELECT d.department_name, p.project_id, p.project_name
			FROM department d LEFT JOIN project p
			ON d.departmentid = p.departmentid
			WHERE p.project_location IN ('NY')
			);

Q: What is the maximum number of people one person 
is tutoring using inline queries:

SELECT studentid, name, Tutor_Num
FROM (
		SELECT top 1 t.studentid, t.name, COUNT(*) AS Tutor_Num
		FROM students s RIGHT JOIN students t
		ON s.student_tutorid = t.studentid
		WHERE s.student_tutorid IS NOT NULL
		GROUP BY t.studentid, t.name
		);


LIKE operator

Note: characters within quotes are case sensitive

Q: Show all employees whose name contains the letter 'a' 
and the letter 'r' in that order:

SELECT   first_name, salary
FROM     employee
WHERE    first_name LIKE  '%a%r%';

Q: Show all employees whose name contains the letter 'a' 
and the letter 'r' in any order:

SELECT   first_name, salary
FROM     employee
WHERE    first_name LIKE  '%a%r%' OR
         first_name LIKE  '%r%a%';

HAVING Clause
HAVING is like WHERE except that 
it works on aggregate functions.

Q: get a total of salaries paid in each department but 
only want to show those with 
total salary greater than $50,000

SELECT d.department_name, SUM(e.salary) AS Total_Salary
FROM employee e INNER JOIN department d
	ON e.departmentid = d.departmentid
GROUP BY d.department_name
HAVING SUM(e.salary) > 50000;

Q: Show total of salaries paid by each department but only if 
the total is greater than the average paid by each department

SELECT d.department_name, SUM(e.salary) AS Total_Salary
FROM employee e INNER JOIN department d
	ON e.departmentid = d.departmentid
GROUP BY d.department_name
HAVING SUM(e.salary) > AVG(e.salary);

Q: the name of the department with the largest total salary

w/o using inline queries:
SELECT TOP 1 d.department_name, SUM(e.salary) AS Total_Salary
FROM employee e INNER JOIN department d
	ON e.departmentid = d.departmentid
GROUP BY d.department_name
ORDER BY SUM(e.salary) DESC;

DELETE

DELETE FROM employee
  WHERE departmentid IN
    (SELECT departmentid
     FROM   department
     WHERE  department_location = 'NY');

DELETE FROM employee
WHERE departmentid =
      (SELECT departmentid
      	FROM department
      	WHERE department_location = 'NY');

