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

--CAST형 연산자

CREATE TABLE contact(
	id    INTEGER,
	name  VARCHAR,
	phone NUMERIC(11)
);

INSERT INTO contact VALUES(11, '홍길동', 01011111111);

SELECT name, phone FROM contact;
SELECT name, CAST (phone AS VARCHAR) FROM contact;

--범위 무결성(Domain integrity)
--무결성이란, 데이터베이스 내에 정확하고 유효한 데이터만을 유지시키는 속성이다. 즉 불필요한 데이터는 최대한
--제거하고 합칠 수 있는 데이터는 최대한 합치자는 것이다.
CREATE DOMAIN phoneint AS integer CHECK(VALUE > 0 AND VALUE < 9);

CREATE TABLE domain_type_study(
	id phoneint
);

INSERT INTO domain_type_study VALUES(1);
INSERT INTO domain_type_study VALUES(5);
--실패
INSERT INTO domain_type_study VALUES(10);
INSERT INTO domain_type_study VALUES(-1);


--컬럼값 제한하기 for 무결성 유지하기

--1) NOT NULL
DROP TABLE IF EXISTS contact_info;
CREATE TABLE contact_info(
	cont_id NUMERIC(3)  NOT NULL,
	name    VARCHAR(15) NOT NULL,
	tel     INTEGER[]   NOT NULL,
	Email   VARCHAR
);

--2) UNIQUE (이 제약조건에 해당하는 컬럼 값을 테이블 내에서 유일한 값을 가져야 한다.)
DROP TABLE IF EXISTS contact_info;
CREATE TABLE contact_info(
	cont_id NUMERIC(3) UNIQUE NOT NULL,
	name    VARCHAR(15) NOT NULL,
	tel     INTEGER[]   NOT NULL,
	email   VARCHAR
);

DROP TABLE IF EXISTS contact_info;
--UNIQUE 제약조건이 여러개인 경우 다음과 같이 새로운 줄에 적는 형식으로 선언할 수 있다
CREATE TABLE contact_info(
	cont_id NUMERIC(3)  NOT NULL,
	name    VARCHAR(15) NOT NULL,
	tel     INTEGER[]   NOT NULL,
	email   VARCHAR,
	UNIQUE (cont_id, tel, email)
);

--3) 프라이머리 키(UNIQUE해야하며 NOT NULL해야한다.)
DROP TABLE IF EXISTS contact_info;
CREATE TABLE contact_info(
	cont_id SERIAL    NOT NULL PRIMARY KEY,
	name    VARCHAR   NOT NULL,
	tel     INTEGER[] NOT NULL,
    email   VARCHAR
);
--프라이머리 키는 일반적으로 한 테이블에 하나지만, 이후에 나올 외래키 제약 조건으로 인해 프라이머리 키가
--여러개일 경우, UNIQUE 제약조건과 유사하게 다음과 같은 형태로 여러 개의 프라이머리 키를 선언할 수 있다
CREATE TABLE book(
	book_id   SERIAL      NOT NULL,
	name      VARCHAR(15) NOT NULL,
	admin_no  SERIAL      NOT NULL REFERENCES contact_info(cont_id),
	email     VARCHAR,
	PRIMARY KEY(book_id, admin_no)
);

--4) 외래 키
--외래 키 제약조건은 다음과 같은 네가지 규칙을 가진다.
--a. 부모 테이블이 자식 테이블보다 먼저 생성되어야 한다.
--b. 부모 테이블은 자식 테이블과 같은 데이터 타입을 가져야 한다.
--c. 부모 테이블에서 참조 된 컬럼의 값만 자식 테이블에서 입력 가능하다.
--d. 참조되는 컬럼은 모두 프라이머리 키이거나 UNIQUE 제약조건 형식이어야 한다.

--부모 테이블
CREATE TABLE subject(
	subj_id   NUMERIC(5)  NOT NULL PRIMARY KEY,
	subk_name VARCHAR(60) NOT NULL
);

INSERT INTO subject
VALUES(00001, 'mathematics'),
      (00002, 'science'),
	  (00003, 'programming');
	  
--자식 테이블 (*NUMERIC)
CREATE TABLE teacher(
	teac_id            NUMERIC(5)  NOT NULL PRIMARY KEY,
	teac_name          VARCHAR(20) NOT NULL,
	subj_id            NUMERIC(5)  REFERENCES subject,
	teac_certifi_date  DATE
);

INSERT INTO teacher values (00011, '정선생', 00001, '2017-03-11');
INSERT INTO teacher values (00021, '홍선생', 00002, '2017-04-12');
INSERT INTO teacher values (00031, '박선생', 00003, '2017-04-13');
--실패
INSERT INTO teacher values (00099, '소선생', 00004, '2022-11-05');

--만약 외래키가 여러개라면 아래와 같은 방법으로 외래키를 설정할 수 있다
DROP TABLE IF EXISTS teacher;
DROP TABLE IF EXISTS subject;
CREATE TABLE subject(
	subj_id    NUMERIC(5)  NOT NULL PRIMARY KEY,
	subj_name  VARCHAR(60) NOT NULL,
	stud_count NUMERIC(20) NOT NULL,
	UNIQUE(subj_id, subj_name)
);

INSERT INTO subject
VALUES (00001, 'mathmatics', 60),
       (00002, 'science', 42),
	   (00003, 'programming', 70);
	   
CREATE TABLE teacher(
	teac_id    NUMERIC(5)  NOT NULL PRIMARY KEY,
	teac_name  VARCHAR(20) NOT NULL,
	subj_code  NUMERIC(5)  NOT NULL,
	subj_name  VARCHAR(60) NOT NULL,
	teac_certifi_date DATE NOT NULL,
	FOREIGN KEY(subj_code, subj_name) REFERENCES subject (subj_id, subj_name)
);

--기본적으로 부모 테이블은 자식테이블보다 먼저 삭제 또는 수정할 수 없다. 
--부모테이블 지울 때 자식테이블도 같이 삭제하려면 ON DELETE CASCADE조건을 추가하자. 
-- <-> ON DELETE RESTRICT
DROP TABLE IF EXISTS teacher;
DROP TABLE IF EXISTS subject;

CREATE TABLE subject(
	subj_id   NUMERIC(5)  NOT NULL PRIMARY KEY,
	subj_name VARCHAR(60) NOT NULL
);

INSERT INTO subject
VALUES (00001, 'mathematics'),
       (00002, 'science'),
	   (00003, 'progamming');
	   
CREATE TABLE teacher(
	teac_id   NUMERIC(5)  NOT NULL PRIMARY KEY,
	teac_name VARCHAR(20) NOT NULL,
	subj_id   NUMERIC(5)  REFERENCES subject ON DELETE CASCADE,
	teac_certifi_date DATE 
);

INSERT INTO teacher
VALUES (00011, '정선생', 00001, '2017-03-11'),
       (00021, '홍선생', 00002, '2017-04-12'),
	   (00031, '박선생', 00003, '2017-04-13');
	   
SELECT * FROM teacher;

DELETE FROM subject WHERE subj_id = 00002;
SELECT * FROM teacher;

--ON DELETE SET NULL : 부모테이블에서 참조된 행이 삭제될 때 자식 테이블의 참조 행에서 해당 컬럼의 값을
--자동으로 NULL로 세팅한다.
DROP TABLE IF EXISTS teacher;
DROP TABLE IF EXISTS subject;

CREATE TABLE subject(
	subj_id   NUMERIC(5)  NOT NULL PRIMARY KEY,
	subj_name VARCHAR(60) NOT NULL
);

INSERT INTO subject
VALUES (00001, 'mathematics'),
       (00002, 'science'),
	   (00003, 'progamming');
	   
CREATE TABLE teacher(
	teac_id   NUMERIC(5)  NOT NULL PRIMARY KEY,
	teac_name VARCHAR(20) NOT NULL,
	subj_id   NUMERIC(5)  REFERENCES subject ON DELETE SET NULL,
	teac_certifi_date DATE 
);

INSERT INTO teacher
VALUES (00011, '정선생', 00001, '2017-03-11'),
       (00021, '홍선생', 00002, '2017-04-12'),
	   (00031, '박선생', 00003, '2017-04-13');
	   
SELECT * FROM teacher;

DELETE FROM subject WHERE subj_id = 00002;
SELECT * FROM teacher;

--ON DELETE SET DEFAULT : 부모테이블에서 참조된 행이 삭제될 때 자식 테이블의 컬럼값이 DEFAULT값으로
--대체된다. (자식 테이블 CREATE할 때 설정된 DEFAULT값으로. 주의해야할 점은 디폴트로 설정된 값도
--외래 키 제약조건을 만족해야 한다는 것이다.)
DROP TABLE IF EXISTS teacher;
DROP TABLE IF EXISTS subject;

CREATE TABLE subject(
	subj_id   NUMERIC(5)  NOT NULL PRIMARY KEY,
	subj_name VARCHAR(60) NOT NULL
);

INSERT INTO subject
VALUES (00001, 'mathematics'),
       (00002, 'science'),
	   (00003, 'progamming');
	   
CREATE TABLE teacher(
	teac_id   NUMERIC(5)  NOT NULL PRIMARY KEY,
	teac_name VARCHAR(20) NOT NULL,
	subj_id   NUMERIC(5)  DEFAULT 1 REFERENCES subject ON DELETE SET DEFAULT,
	teac_certifi_date DATE 
);

INSERT INTO teacher
VALUES (00011, '정선생', 00001, '2017-03-11'),
       (00021, '홍선생', 00002, '2017-04-12'),
	   (00031, '박선생', 00003, '2017-04-13');
	   
SELECT * FROM teacher;

DELETE FROM subject WHERE subj_id = 00002;
SELECT * FROM teacher;

--CHECK (이 제약조건을 두고 도메인 데이터 타입을 쓰는 이유는 CHECK 제약 조건 속으로 들어가는
--쿼리문이 길어지면 가독성을 해칠 수 있기에 이때 도메인 데이터 타입을 함수처럼 따로 떼어내어 사용한다면
--더 효율적으로 코드 분석이 가능하기 때문이다.)
CREATE TABLE order_info(
	order_no  INTEGER NOT NULL PRIMARY KEY,
	cust_name VARCHAR(100),
    price     MONEY,
	order_qty INTEGER CHECK(order_qty > 0)
);

DROP TABLE order_info;
CREATE DOMAIN qtyint AS integer CHECK(VALUE > 0);
CREATE TABLE order_info(
	order_no  INTEGER NOT NULL PRIMARY KEY,
	cust_name VARCHAR(100),
    price     MONEY,
	order_qty qtyint
);

INSERT INTO order_info 
VALUES(0001, '홍길동', 1000000, 1);

SELECT * FROM order_info;

--실패
INSERT INTO order_info 
VALUES(0002, '홍길동', 1000000, 0);


--ALTER table