--비교 연산자는 참, 거짓, NULL 세가지 항을 비교하는 삼항 논리 기반이다.

--조건문 함수를 이용하면 특정조건에 따라 컬럼 값이 달라지는, 특정한 조건을 갖는 컬럼을 만들 수 있다.
SELECT * FROM student_score;
--CASE함수를 이용하여 점수별로 등급 부여하기(다른 프로그래밍 언어에서 IF-ELSE문과 대응되는 것)
SELECT id, name, score,
CASE
	WHEN score <= 100 AND score >= 90 THEN 'A'
	WHEN score <= 89  AND score >= 80 THEN 'B'
	WHEN score <= 79  AND score >= 70 THEN 'C'
	WHEN score < 70 THEN 'F'
	END grade
FROM student_score;
--COALESCE()함수는 주로 NULL값을 다른 기본 값으로 대체할 때 사용한다.
INSERT INTO student_score(name, score)
VALUES ('Youjun', NULL),('Minjoo', NULL);

SELECT id, name, COALESCE(score, 0),
CASE
	WHEN score <= 100 AND score >= 90 THEN 'A'
	WHEN score <= 89  AND score >= 80 THEN 'B'
	WHEN score <= 79  AND score >= 70 THEN 'C'
	WHEN score < 70 THEN 'F'
	END grade
FROM student_score;

--NULLIF함수는 특정 값을 NULL값으로 바꾸고 싶을 때 사용하는 함수이다.
--NULL값이 되면 '나눌수 없음'이라고 값을 COALESCE 함수가 바꿈 & students 행의 값이 0이면 
--NULLIF함수가 NULL로 바꿈. 그리고 원래 integer이지만 char로 형변환 되고 share이라는 행으로 재정의
SELECT students, COALESCE((12/NULLIF(students,0))::char,'나눌 수 없음') AS share
FROM division_by_zero;

--배열 연산자에서 포함관계를 확인하는 방법으로 <@,@> 연산자를 사용한다.
--또한 원소 단위로 겹침 유무를 확인하는 && 연산자가 있다. 두 배열을 비교하여 하나라도 겹치는 원소가 있다면
--결과는 참을 반환한다.
--배열끼리 병합하고 싶을 때 또는 원소를 추가하고 싶을 때 || 연산자를 사용한다.

--2차원 배열은 대괄호를 두번 넣는 방법으로 선언할 수 있다. [][]
CREATE TABLE td_array(
	id serial,
	name varchar(30),
	schedule integer [][]
);

SELECT * FROM td_array;
--2차원 배열을 입력받는 방식에는 두가지가 있다. 첫번째 방법은 '' 사에에 중괄호{}를 사용하는 방법.
INSERT INTO td_array(name, schedule)
VALUES('9DAYS', '{{1,2,3},{4,5,6},{7,8,9}}');
--두번째 방법은 ARRAY[]를 활용하는 방법이다.
INSERT INTO td_array(name, schedule)
VALUES ('9DAYS', ARRAY[[1,2,3],[4,5,6],[7,8,9]]);

--배열 속에 원소를 추가하는 방법으로 || 연산자 외에 array_append() 함수나 
--array_prepend() 함수를 이용하여 추가시킬 수 있다.
--배열 속 원소를 삭제하는 방법으로는 array_remove() 함수를 사용한다.
--배열 속 원소를 다른 원소로 바꿀 때 array_replace() 함수를 사용한다. 
--array_replace함수는 세개의 매개변수를 입력받는다.
--배열과 배열을 합치는 함수로도, || 연산자 외에 array_cat() 함수를 이용하여 병합할 수 있다.

--JSON, JSONB 공통 연산자
--JSON오브젝트에 저장된 키 값으로 밸류 값을 가져오고 싶을 때는 아래와 같이 -> 연산자를 활용하면 된다
--형변환 해준건 데이터 타입이 정의된 컬럼의 데이터가 아니라서.
SELECT '{"p": {"1":"postgres"},"s": {"1":"sql"}}'::json -> 'p' AS result; 

--JSON 배열의 경우, 인덱스 번호를 활용하여 불러올 수 있다. 이때 인덱스 번호는 0부터 시작하니 주의~!
SELECT '[{"p": "postgres"},{"s": "sql"},{"m": "mongoDB"}]'::json -> 2 AS result;
--만약 인덱스 번호가 음수라면 아래의 경우 인덱스 0이 인덱스-3이 된다.  {"p": "postgres"}이 도출됨.
SELECT '[{"p": "postgres"},{"s": "sql"},{"m": "mongoDB"}]'::json -> -3 AS result;
--JSON오브젝트, JSON 배열 모두 TEXT로 불러오려면 ->> 연산자를 사용하면 된다.
SELECT '{"p": {"1":"postgres"},"s": {"1":"sql"}}'::json ->> 'p' AS result; 

--JSON이 만약 복잡한 다층의 구조로 이루어져 있을 때는 값을 불러올 때 #> 연산자를 쓴다... 이 연산자는
--특정한 경로를 지정해 데이터 값을 불러올 수 있다.
SELECT '{"i":{"read":{"book":"postgresql"}}}'::json #> '{"i","read","book"}' AS result;
--JSON배열이 중간에 끼어 있다면, 키 값 대신 인덱스 번호를 넣어주면 된다.
--여기서도 TEXT타입으로 값을 가져오고 싶으면 #>> 연산자를 사용하면 된다.
SELECT '{"post":[{"gre": {"sql":"do it"}},{"t":"sql"}]}'::json #>'{"post",0,"gre","sql"}'
AS result;

--*아쉽게도 JSONB가 아닌 JSON데이터 타입에서는 기본적인 연산자 <,>,<=,>=,=,<>는  사용할 수 없다*
--추가적인 JSONB 연산자