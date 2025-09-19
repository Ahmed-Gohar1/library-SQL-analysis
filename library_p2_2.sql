SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM members;
SELECT * FROM return_status;

-- 2. CRUD Operations
-- Create: Inserted sample records into the books table.
-- Read: Retrieved and displayed data from various tables.
-- Update: Updated records in the employees table.
-- Delete: Removed records from the members table as needed.

-- Task 1. Create a New Book Record 
-- "'978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.'"

SELECT * FROM books;

INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')
SELECT * 
FROM books;

-- Task 2: Update an Existing Member's 

SELECT * FROM members;

UPDATE members
SET member_address = '125 Oak St'
WHERE member_id = 'C103';

-- Task 3: Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

SELECT * FROM issued_status;


DELETE 
FROM issued_status
WHERE issued_id = 'IS121';

-- Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT * FROM issued_status;

SELECT *
FROM issued_status
WHERE issued_emp_id = 'E101';

-- Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.

SELECT * FROM issued_status;

SELECT issued_member_id, COUNT(issued_member_id) AS coun_book
FROM issued_status
GROUP BY issued_member_id
HAVING COUNT(issued_member_id) > 1;

-- CTAS (Create Table As Select)
-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**
SELECT * FROM issued_status;
SELECT * FROM books;

CREATE TABLE book_issued_cnt AS
SELECT b.isbn, b.book_title, COUNT(ist.issued_id) AS issue_count
FROM issued_status as ist
LEFT JOIN books as b
ON ist.issued_book_isbn = b.isbn
GROUP BY b.isbn, b.book_title;

SELECT * FROM book_issued_cnt;

-- 4. Data Analysis & Findings
-- The following SQL queries were used to address specific questions:

-- Task 7: Retrieve All Books in a Specific Category:

SELECT * FROM books
WHERE category = 'Classic';

-- Task 8: Find Total Rental Income by Category:

SELECT category, SUM(rental_price)
FROM books
GROUP BY category;

-- Task 9: List Members Who Registered in the Last 180 Days:

SELECT * FROM members;

SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days';

-- Task 10: List Employees with Their Branch Manager's Name and their branch details:

SELECT * FROM branch;
SELECT * FROM employees;

SELECT b.branch_address, b.contact_no, b.manager_id, e.emp_id, e.emp_name
FROM employees AS e
LEFT JOIN branch AS b
ON b.branch_id = e.branch_id
WHERE manager_id <> emp_id;

-- Task 11: Create a Table of Books with Rental Price Above a Certain Threshold:

SELECT * FROM books;

CREATE TABLE expensive_book AS
SELECT * 
FROM books
WHERE rental_price > 7.00;

SELECT * FROM expensive_book;

-- Task 12: Retrieve the List of Books Not Yet Returned

SELECT * FROM return_status;
SELECT * FROM issued_status;

SELECT * 
FROM issued_status as ist
LEFT JOIN return_status as rs
ON rs.issued_id = ist.issued_id
WHERE rs.return_id IS NULL;

