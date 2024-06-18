-- INSERT
-- 테이블 구조를 빠르게 확인하는 방법
DESC DEPARTMENTS;

-- 1ST
INSERT INTO DEPARTMENTS VALUES(280, 'DEVELOPER', NULL, 1700);  -- *****

SELECT * FROM DEPARTMENTS; -- *****
-- DML문은 트래낵션이 항상 기록되는데, ROLLBACK을 이용해서 되돌릴 수 있음
ROLLBACK;

-- 2ND (컬럼명만 지정가능)
INSERT INTO DEPARTMENTS(DEPARTMENT_ID, DEPARTMENT_NAME, LOCATION_ID) VALUES(280, 'DEVELOPER', 1700);

-------------------------------------------------------------------------------------------------------------------------

-- INSERT구문도 서브쿼리가 됨 (단일값)
INSERT INTO DEPARTMENTS(DEPARTMENT_ID, DEPARTMENT_NAME) VALUES((SELECT MAX(DEPARTMENT_ID) + 10 FROM DEPARTMENTS), 'DEV');
ROLLBACK;

-- INSERT구문의 서브쿼리 (여러행)
CREATE TABLE EMPS AS (SELECT * FROM EMPLOYEES WHERE 1 = 2); -- 테이블 구조 복사

SELECT * FROM EMPS; -- 이 테이블에 원본테이블의 특정 데이터를 퍼다 나름

INSERT INTO EMPS(EMPLOYEE_ID, LAST_NAME, EMAIL, HIRE_DATE, JOB_ID)
(SELECT EMPLOYEE_ID, LAST_NAME, EMAIL, HIRE_DATE, JOB_ID FROM EMPLOYEES WHERE JOB_ID = 'SA_MAN');

COMMIT; -- 트랜잭션을 반영함

-------------------------------------------------------------------------------------------------------------------------
-- UPDATE
SELECT * FROM EMPS;

-- 업데이트 구문을 사용하기 전에는 SELECT로 해당값이 고유한 행인지 확인하고, 업데이트 처리해야 함
UPDATE EMPS SET SALARY = 1000, COMMISSION_PCT = 0.1 WHERE EMPLOYEE_ID = 148; -- KEY를 조건에 적는게 일반적임 
UPDATE EMPS SET SALARY = NVL(SALARY, 0) + 1000 WHERE EMPLOYEE_ID >= 145;

-- 업데이트 구문의 서브쿼리절
-- 1ST(단일값 서브쿼리)
UPDATE EMPS SET SALARY = (SELECT SALARY FROM EMPLOYEES WHERE EMPLOYEE_ID = 100) WHERE EMPLOYEE_ID = 148;

-- 2ND(여러값 서브쿼리)
UPDATE EMPS SET (SALARY, COMMISSION_PCT, MANAGER_ID, DEPARTMENT_ID)
                = (SELECT SALARY, COMMISSION_PCT, MANAGER_ID, DEPARTMENT_ID FROM EMPLOYEES WHERE EMPLOYEE_ID = 100)
                   WHERE EMPLOYEE_ID = 148;

-- 3ND (WHERE절에도 됨)
UPDATE EMPS
SET SALARY = 1000
WHERE EMPLOYEE_ID IN (SELECT EMPLOYEE_ID FROM EMPLOYEES WHERE JOB_ID = 'IT_PROG');

-------------------------------------------------------------------------------------------------------------------------
-- DELETE구문
-- 트랜잭션이 있긴하지만, 삭제하기전에 SELECT문으로 삭제 조건에 해당하는 데이터를 꼭 확인하는 습관
SELECT * FROM EMPS WHERE EMPLOYEE_ID = 148;

DELETE FROM EMPS WHERE EMPLOYEE_ID = 148; -- KEY를 통해서 지우는 편이 좋음

-- DELETE구문도 서브쿼리
DELETE FROM EMPS WHERE EMPLOYEE_ID IN (SELECT EMPLOYEE_ID FROM EMPLOYEES WHERE DEPARTMENT_ID = 80);
ROLLBACK;

-------------------------------------------------------------------------------------------------------------------------
-- DELETE문이 전부 실행되는 것은 아님
-- 테이블이 연관관계(FK)제약을 가지고 있다면, 지워지지 않음 (참조무결성 제약)
SELECT * FROM EMPLOYEES;
SELECT * FROM DEPARTMENTS;
DELETE FROM DEPARTMENTS WHERE DEPARTMENT_ID = 100; -- EMPLOYEES에서 100번 데이터를 FK로 사용하고 있어서, 지울 수 없음

-------------------------------------------------------------------------------------------------------------------------
-- MERGE문 - 타겟테이블 데이터가 있으면 UPDATE, 없으면 INSERT구문을 수행하는 병합
-- 1ST
MERGE INTO EMPS A -- 타겟테이블
USING (SELECT * FROM EMPLOYEES WHERE JOB_ID = 'IT_PROG') B -- 합칠테이블
ON (A.EMPLOYEE_ID = B.EMPLOYEE_ID) -- 연결할 키
WHEN MATCHED THEN -- 일치하는 경우 
     UPDATE SET A.SALARY = B.SALARY,
                A.COMMISSION_PCT = B.COMMISSION_PCT,
                A.HIRE_DATE = SYSDATE
                -- ....생략
WHEN NOT MATCHED THEN -- 일치하지 않는 경우
         INSERT /*INTO*/ (EMPLOYEE_ID, LAST_NAME, EMAIL, HIRE_DATE, JOB_ID)
         VALUES(B.EMPLOYEE_ID, B.LAST_NAME, B.EMAIL, B.HIRE_DATE, B.JOB_ID);
         
SELECT * FROM EMPS;

-- 2ND - 서브쿼리절로 다른테이블을 가져오는게 아니라, 직접 값을 넣을때 DUAL을 쓸 수도 있음
MERGE INTO EMPS A
USING DUAL 
ON(A.EMPLOYEE_ID = 107) -- 조건
WHEN MATCHED THEN -- 일치하는 경우 
     UPDATE SET A.SALARY = 10000,
                A.COMMISSION_PCT = 0.1,
                A.DEPARTMENT_ID = 100
WHEN NOT MATCHED THEN -- 일치하지 않는 경우
     INSERT (EMPLOYEE_ID, LAST_NAME, EMAIL, HIRE_DATE, JOB_ID)
     VALUES (107, 'EXAMPLE', 'HONG', SYSDATE, 'DBA');
-------------------------------------------------------------------------------------------------------------------------
DROP TABLE EMPS;

--CTAS - 테이블 구조 복사
CREATE TABLE EMPS AS (SELECT * FROM EMPLOYEES); -- 데이터까지 복사

CREATE TABLE EMPS AS (SELECT * FROM EMPLOYEES WHERE 1 = 2); -- 구조만 복사 

SELECT * FROM EMPS;

-------------------------------------------------------------------------------------------------------------------------
-- 문제 1.
-- DEPTS테이블을 데이터를 포함해서 생성하세요.
-- DEPTS테이블의 다음을 INSERT 하세요.
   
   CREATE TABLE DEPTS AS (SELECT * FROM DEPARTMENTS);
   
   INSERT INTO DEPTS VALUES(280, '개발', NULL, 1800);
   INSERT INTO DEPTS VALUES(290, '회계부', NULL, 1800);
   INSERT INTO DEPTS VALUES(300, '재정', 301, 1800);
   INSERT INTO DEPTS VALUES(310, '인사', 302, 1800);
   INSERT INTO DEPTS VALUES(320, '영업', 303, 1700);
   
   SELECT * FROM DEPTS;
   
   -- ROLLBACK;
   
-- 문제 2.
-- DEPTS테이블의 데이터를 수정합니다
-- 1. department_name 이 IT Support 인 데이터의 department_name을 IT bank로 변경

   SELECT * FROM DEPTS WHERE DEPARTMENT_NAME = 'IT Support';
   UPDATE DEPTS SET DEPARTMENT_NAME = 'IT Bank' WHERE DEPARTMENT_NAME = 'IT Support';

-- 2. department_id가 290인 데이터의 manager_id를 301로 변경

   UPDATE DEPTS SET MANAGER_ID = 301 WHERE DEPARTMENT_ID = 290;
   SELECT * FROM DEPTS;
   
-- 3. department_name이 IT Helpdesk인 데이터의 부서명을 IT Help로 , 매니저아이디를 303으로, 지역아이디를
--    1800으로 변경하세요

   UPDATE DEPTS SET DEPARTMENT_NAME = 'IT Help',
                    MANAGER_ID = 303,
                    LOCATION_ID = 1800
   WHERE DEPARTMENT_NAME = 'IT Helpdesk';

-- 4. 이사, 부장, 과장, 대리 의 매니저아이디를 301로 한번에 변경하세요.

   UPDATE DEPTS SET MANAGER_ID = 301
   WHERE DEPARTMENT_ID IN (290, 300, 310, 320);

-- 문제 3.
-- 삭제의 조건은 항상 primary key로 합니다, 여기서 primary key는 department_id라고 가정합니다.
-- 1. 부서명 영업부를 삭제 하세요

   SELECT * FROM DEPTS WHERE DEPARTMENT_NAME = '영업';
   DELETE FROM DEPTS WHERE DEPARTMENT_ID = 320; -- (SELECT * FROM DEPTS WHERE DEPARTMENT_NAME = '영업')

-- 2. 부서명 NOC를 삭제하세요
   
   SELECT * FROM DEPTS WHERE DEPARTMENT_NAME = 'NOC';
   DELETE FROM DEPTS WHERE DEPARTMENT_ID = 220;
   
-- 문제4
-- 1. Depts 사본테이블에서 department_id 가 200보다 큰 데이터를 삭제해 보세요.
   
   DELETE FROM DEPTS WHERE DEPARTMENT_ID > 200;

-- 2. Depts 사본테이블의 manager_id가 null이 아닌 데이터의 manager_id를 전부 100으로 변경하세요.

   UPDATE DEPTS SET MANAGER_ID = 100 WHERE MANAGER_ID IS NOT NULL;
   SELECT * FROM DEPTS;

-- 3. Depts 테이블은 타겟 테이블 입니다.
-- 4. Departments테이블은 매번 수정이 일어나는 테이블이라고 가정하고 Depts와 비교하여
--    일치하는 경우 Depts의 부서명, 매니저ID, 지역ID를 업데이트 하고, 새로유입된 데이터는 그대로 추가해주는 merge문을 작성하세요.

   MERGE INTO DEPTS D
   USING(SELECT * FROM DEPARTMENTS) D2
   ON(D1.DEPARTMENT_ID = D2.DEPARTMENT_ID)
   WHEN MATCHED THEN
        UPDATE SET D1.DEPARTMENT_NAME = D2.DEPARTMENT_NAME,
                   D1.MANAGER_ID = D2.MANAGER_ID,
                   D1.LOCATION_ID = D2.LOCATION_ID
   WHEN NOT MATCHED THEN
   INSERT VALUES (D2.DEPARTMENT_ID,
                  D2.DEPARTMENT_NAME,
                  D2.MANAGER_ID,
                  D2.LOCATION_ID);

-- 문제 5
-- 1. jobs_it 사본 테이블을 생성하세요 (조건은 min_salary가 6000보다 큰 데이터만 복사합니다)

   CREATE TABLE JOBS_IT AS (SELECT * FROM JOBS WHERE MIN_SALARY > 6000);
   
-- 2. jobs_it 테이블에 아래 데이터를 추가하세요
   
   INSERT INTO JOBS_IT VALUES('IT_DEV', '아이티개발팀', 6000, 20000);
   INSERT INTO JOBS_IT VALUES('NET_DEV', '네트워크개발팀', 5000, 20000);
   INSERT INTO JOBS_IT VALUES('SEC_DEV', '보안개발팀', 6000, 20000);
   
   SELECT * FROM JOBS_IT;
   
-- 3. obs_it은 타겟 테이블 입니다
-- jobs테이블은 매번 수정이 일어나는 테이블이라고 가정하고 jobs_it과 비교하여
-- min_salary컬럼이 0보다 큰 경우 기존의 데이터는 min_salary, max_salary를 업데이트 하고 새로 유입된
-- 데이터는 그대로 추가해주는 merge문을 작성하세요.

   MERGE INTO JOBS_IT J1
   USING (SELECT * FROM JOBS WHERE MIN_SALARY > 0) J2
   ON (J1.JOB_ID = J2.JOB_ID)
   WHEN MATCHED THEN
        UPDATE SET J1.MIN_SALARY = J2.MIN_SALARY,
                   J1.MAX_SALARY = J2.MAX_SALARY
   WHEN NOT MATCHED THEN
            INSERT VALUES (J2.JOB_ID,
                           J2.JOB_TITLE,
                           J2.MIN_SALARY,
                           J2.MAX_SALARY);
                           
   SELECT * FROM JOBS_IT;                       
  

   

