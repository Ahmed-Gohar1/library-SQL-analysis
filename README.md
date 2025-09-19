# Library Management System using SQL

A professional SQL project for robust database design, CRUD operations, and advanced analysis of library operations. This README provides best-practice schema design (with explicit foreign keys), comprehensive data validation, and real-world query solutions for a library management system.

---

## Entity-Relationship Diagram

Below is the ERD showing table structures and relationships:

![Entity Relationship Diagram](image1)

---

## Project Overview

- **Project Title**: Library Management System  
- **Level**: Intermediate  
- **Database**: `library_db`

This project demonstrates a full-featured Library Management System using SQL. It includes normalized schema creation, referential integrity, CRUD operations, CTAS, and advanced SQL queries for reporting and analytics.

---

## Table Schema

```sql
-- Branch Table
CREATE TABLE branch (
    branch_id      VARCHAR(10) PRIMARY KEY,
    manager_id     VARCHAR(10),
    branch_address VARCHAR(30),
    contact_no     VARCHAR(15)
);

-- Employees Table
CREATE TABLE employees (
    emp_id     VARCHAR(10) PRIMARY KEY,
    emp_name   VARCHAR(30),
    position   VARCHAR(30),
    salary     DECIMAL(10,2),
    branch_id  VARCHAR(10),
    FOREIGN KEY (branch_id) REFERENCES branch(branch_id)
);

-- Members Table
CREATE TABLE members (
    member_id      VARCHAR(10) PRIMARY KEY,
    member_name    VARCHAR(30),
    member_address VARCHAR(30),
    reg_date       DATE
);

-- Books Table
CREATE TABLE books (
    isbn          VARCHAR(50) PRIMARY KEY,
    book_title    VARCHAR(80),
    category      VARCHAR(30),
    rental_price  DECIMAL(10,2),
    status        VARCHAR(10),
    author        VARCHAR(30),
    publisher     VARCHAR(30)
);

-- Issued Status Table
CREATE TABLE issued_status (
    issued_id          VARCHAR(10) PRIMARY KEY,
    issued_member_id   VARCHAR(30),
    issued_book_name   VARCHAR(80),
    issued_date        DATE,
    issued_book_isbn   VARCHAR(50),
    issued_emp_id      VARCHAR(10),
    FOREIGN KEY (issued_member_id) REFERENCES members(member_id),
    FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id),
    FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn)
);

-- Return Status Table
CREATE TABLE return_status (
    return_id         VARCHAR(10) PRIMARY KEY,
    issued_id         VARCHAR(30),
    return_book_name  VARCHAR(80),
    return_date       DATE,
    return_book_isbn  VARCHAR(50),
    FOREIGN KEY (issued_id) REFERENCES issued_status(issued_id),
    FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
);
```

---

## CRUD Operations & Examples

### Create

```sql
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
```

### Read

```sql
SELECT * FROM books;
```

### Update

```sql
UPDATE members
SET member_address = '125 Oak St'
WHERE member_id = 'C103';
```

### Delete

```sql
DELETE FROM issued_status
WHERE issued_id = 'IS121';
```

---

## Advanced SQL & Reporting

### 1. Retrieve All Books Issued by a Specific Employee

```sql
SELECT * FROM issued_status
WHERE issued_emp_id = 'E101';
```

### 2. List Members Who Have Issued More Than One Book

```sql
SELECT issued_member_id, COUNT(*) AS book_count
FROM issued_status
GROUP BY issued_member_id
HAVING COUNT(*) > 1;
```

### 3. Create Book Issue Count Summary Table

```sql
CREATE TABLE book_issued_cnt AS
SELECT b.isbn, b.book_title, COUNT(ist.issued_id) AS issue_count
FROM issued_status as ist
JOIN books as b ON ist.issued_book_isbn = b.isbn
GROUP BY b.isbn, b.book_title;
```

### 4. Retrieve All Books in a Specific Category

```sql
SELECT * FROM books
WHERE category = 'Classic';
```

### 5. Find Total Rental Income by Category

```sql
SELECT b.category, SUM(b.rental_price), COUNT(*)
FROM issued_status as ist
JOIN books as b ON b.isbn = ist.issued_book_isbn
GROUP BY 1;
```

### 6. List Members Registered in the Last 180 Days

```sql
SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days';
```

### 7. List Employees with Their Branch Manager & Branch Details

```sql
SELECT 
    e1.emp_id,
    e1.emp_name,
    e1.position,
    e1.salary,
    b.*,
    e2.emp_name as manager
FROM employees as e1
JOIN branch as b ON e1.branch_id = b.branch_id    
JOIN employees as e2 ON e2.emp_id = b.manager_id;
```

### 8. Create Table of Expensive Books

```sql
CREATE TABLE expensive_books AS
SELECT * FROM books
WHERE rental_price > 7.00;
```

### 9. Retrieve Books Not Yet Returned

```sql
SELECT * FROM issued_status as ist
LEFT JOIN return_status as rs ON rs.issued_id = ist.issued_id
WHERE rs.return_id IS NULL;
```

### 10. Identify Members with Overdue Books

```sql
SELECT 
    ist.issued_member_id,
    m.member_name,
    bk.book_title,
    ist.issued_date,
    CURRENT_DATE - ist.issued_date as over_dues_days
FROM issued_status as ist
JOIN members as m ON m.member_id = ist.issued_member_id
JOIN books as bk ON bk.isbn = ist.issued_book_isbn
LEFT JOIN return_status as rs ON rs.issued_id = ist.issued_id
WHERE rs.return_date IS NULL AND (CURRENT_DATE - ist.issued_date) > 30
ORDER BY 1;
```

### 11. Update Book Status on Return (PL/pgSQL Example)

```sql
CREATE OR REPLACE PROCEDURE add_return_records(p_return_id VARCHAR(10), p_issued_id VARCHAR(10), p_book_quality VARCHAR(10))
LANGUAGE plpgsql
AS $$
DECLARE
    v_isbn VARCHAR(50);
    v_book_name VARCHAR(80);
BEGIN
    INSERT INTO return_status(return_id, issued_id, return_date, book_quality)
    VALUES (p_return_id, p_issued_id, CURRENT_DATE, p_book_quality);

    SELECT issued_book_isbn, issued_book_name INTO v_isbn, v_book_name
    FROM issued_status WHERE issued_id = p_issued_id;

    UPDATE books SET status = 'yes' WHERE isbn = v_isbn;
    RAISE NOTICE 'Thank you for returning the book: %', v_book_name;
END;
$$;
```

---

## Essential KPIs

- **Total Number of Books**
    ```sql
    SELECT COUNT(*) AS book_count FROM books;
    ```
- **Total Members**
    ```sql
    SELECT COUNT(*) AS member_count FROM members;
    ```
- **Total Books Issued**
    ```sql
    SELECT COUNT(*) AS issued_count FROM issued_status;
    ```
- **Total Books Returned**
    ```sql
    SELECT COUNT(*) AS returned_count FROM return_status;
    ```
- **Unique Categories**
    ```sql
    SELECT COUNT(DISTINCT category) AS category_count FROM books;
    ```

---

## Getting Started

1. **Clone the Repository**:  
   ```sh
   git clone https://github.com/Ahmed-Gohar1/library-SQL-analysis.git
   ```
2. **Set Up the Database**:  
   Run the schema and sample data scripts from this README.
3. **Run and Explore**:  
   Use and adapt the queries above for your own analysis or business needs.

---
