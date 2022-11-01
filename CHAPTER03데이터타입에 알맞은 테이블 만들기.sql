drop table if exists develop_book;

--TEXT == n을 쓰지 않은 VARCHAR
CREATE TABLE develop_book (
	book_id NUMERIC(6),
	book_name 
	name    VARCHAR(80),
	price   MONEY
);

drop table if exists develop_book;

--char로 작성한다면 모자란 문자열 수만큼 공백을 만들어줘야하므로, PostgreSQL에서는 CHAR가
--VARCHAR보다 성능이 느리다. 그래서 VARCHAR을 쓰는것이 적절한 선택이다.
CREATE TABLE develop_book (
	book_id    NUMERIC(6),
	book_name  VARCHAR(80),
	pub_date   INTEGER,
	price      MONEY
);

CREATE TABLE datetime_study (
	type_ts   TIMESTAMP,
	type_tstz TIMESTAMPTZ,
	type_date DATE,
	type_time TIME
);

--TIMESTAMPTZ(timestamp with time zone)으로 저장해두면 SET TIMEZONE으로 나라 바꿨을 때 자동으로
--그 나라시간대로 바꿔준다. 데이터 조회시, TIMESTAMPTZ는 +09까지 보임(TIMESTAMP는 +09 안보임)
INSERT INTO datetime_study (type_ts, type_tstz, type_date, type_time)
VALUES ('2020-07-26 20:00:25+09', '2020-07-26 20:00:25+09', '2020-07-26', '18:00:00');

SELECT * FROM datetime_study;

SHOW TIMEZONE;

--배열(Array)은 하나 이상의 여러 데이터를 저장할 수 있다.
CREATE TABLE contact_info(
	cont_id NUMERIC(3),
	name    VARCHAR(15),
	tel     INTEGER[],
	Email   VARCHAR
);

--1) "Array[]" 형태로 데이터 받기
INSERT INTO contact_info
VALUES (001, 'Postgres', Array[01012345678, 01033355555], 'Post@gmail.com');

--2) 작은 따옴표 안에 중괄호로 배열 데이터 타입을 입력
INSERT INTO contact_info
VALUES (002, 'Qosgres', '{01011112222,01022221111}', 'Qost@gmail.com');


CREATE TABLE develop_book_order(
	id         NUMERIC(3),
	order_info JSON         NOT NULL
);

--JSON 오브젝트의 구조: {"키 값": "밸류 값"}
--{"키 값": "밸류 값", "키 값" : {"키 값": "밸류 값"}} //아래 구조. 
--JSON 배열: [{"키 값": "밸류 값"}, {"키 값": "밸류 값"}]
INSERT INTO develop_book_order
VALUES(001, '{"customer":"Jaejin","books":{"product":"맛있는","qty":2}}'),
      (002, '{"customer":"Yunsang","books":{"product":"mongodb","qty":3}}'),
	  (003, '{"customer":"Sojung","books":{"product":"쉬운sql","qty":1}}')

SELECT * FROM develop_book_order;