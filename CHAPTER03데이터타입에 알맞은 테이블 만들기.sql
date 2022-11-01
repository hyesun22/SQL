drop table if exists develop_book;

--TEXT == n을 쓰지 않은 VARCHAR
CREATE TABLE develop_book (
	book_id NUMERIC(6),
	date    INTEGER,
	name    VARCHAR(80),
	price   MONEY
);
