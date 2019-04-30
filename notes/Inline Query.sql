INLINE SQL Queries


The result of a query is a table. 
Normally the results are shown to the user. 
However we can use the results of a query as the basis for 
another query. That is, the subquery becomes a table we 
can select FROM. For example:

SELECT first_name, salary
FROM   (SELECT employee.first_name, employee.salary, department.department_location
        FROM    employee, department
        WHERE   employee.departmentid = department.departmentid
        AND     department.department_location = 'NY'
        )
WHERE   salary > 35000

Recall this example:
SELECT   s1.name AS TutorName,
         COUNT(tutors.student_tutorid) AS NumberTutored
FROM     students s1, students tutors
WHERE    s1.studentid = tutors.student_tutorid
GROUP BY s1.name;

Q: We might be interested in the maximum number of people 
one person is tutoring:

SELECT TutorName, NumberTutored
FROM   (SELECT   s1.name AS TutorName,
                 COUNT(tutors.student_tutorid) AS NumberTutored
         FROM     students s1, students tutors
         WHERE    s1.studentid = tutors.student_tutorid
         GROUP BY s1.name
       )
WHERE NumberTutored =
    (SELECT MAX(NumberTutored)
     FROM (SELECT   s1.name AS TutorName,
                 COUNT(tutors.student_tutorid) AS NumberTutored
         FROM     students s1, students tutors
         WHERE    s1.studentid = tutors.student_tutorid
         GROUP BY s1.name
       )
     )
----------------------------------------------------------
modified:

SELECT TutorName, MAX(NumberTutored)
    FROM(
        SELECT s1.Name As TutorName, COUNT(s2.student_tutorid) 
               AS NumberTutored
        FROM students s1, students s2
        WHERE s1.studentID = s2.student_tutorid
        GROUP BY s1.Name)
GROUP BY TutorName;

