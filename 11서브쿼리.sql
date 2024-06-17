-- 서브쿼리 (SELECT 구문들의 특정위치에 다시 SELECT가 들어가는 문장)
-- 단일행 서브쿼리 - 서브쿼리의 결과가 1행인 서브쿼리

-- 낸시보다 급여가 높은사람
-- 1. 낸시의 급여를 찾는다
-- 2. 찾은 급여를 WHERE절에 넣는다.
SELECT * 
FROM EMPLOYEES
WHERE SALARY >= (SELECT SALARY FROM EMPLOYEES WHERE FIRST_NAME= 'Nancy');

-- 103번과 직업이 같은사람
SELECT JOB_ID FROM EMPLOYEES WHERE EMPLOYEE_ID = 103;

SELECT *
FROM EMPLOYEES
WHERE JOB_ID = (SELECT JOB_ID FROM EMPLOYEES WHERE EMPLOYEE_ID = 103);

-- 주의할점 - 비교할 컬럼은 정확히 한개여야 함
SELECT *
FROM EMPLOYEES
WHERE JOB_ID = (SELECT * FROM EMPLOYEES WHERE EMPLOYEE_ID = 103);

-- 주의할점 - 여러행이 나오는 구문이라면, 다중행 서브쿼리 연산자를 써줘야 함
SELECT SALARY FROM EMPLOYEES WHERE FIRST_NAME = 'Steven';

SELECT *
FROM EMPLOYEES
WHERE SALARY >= (SELECT SALARY FROM EMPLOYEES WHERE FIRST_NAME = 'Steven');

---------------------------------------------------------------------------
-- 다중행 서브쿼리 - 서브쿼리의 결과가 여러행 리턴되는 경우 IN, ANY, ALL
SELECT *
FROM EMPLOYEES
WHERE FIRST_NAME = 'David'; -- 4800, 6800, 9500

-- 데이비드의 최소급여보다 많이받는 사람
-- 4800보다 큰
SELECT *
FROM EMPLOYEES
WHERE SALARY > ANY(SELECT SALARY FROM EMPLOYEES WHERE FIRST_NAME = 'David');

-- 데이비드의 최대급여보다 적게받는 사람
-- 9500보다 작은
SELECT *
FROM EMPLOYEES
WHERE SALARY < ANY(SELECT SALARY FROM EMPLOYEES WHERE FIRST_NAME = 'David');

-- 데이비드의 최대급여보다 많이받는 사람
-- 9500보다 큰
SELECT *
FROM EMPLOYEES
WHERE SALARY > ALL(SELECT SALARY FROM EMPLOYEES WHERE FIRST_NAME = 'David');

-- 데이비드의 최소급여보다 적게받는 사람
-- 4800보다 작은
SELECT *
FROM EMPLOYEES
WHERE SALARY < ALL(SELECT SALARY FROM EMPLOYEES WHERE FIRST_NAME = 'David'); 

-- IN 다중행 데이터중, 일치하는 데이터
-- 데이비드와 부서가 같은
SELECT *
FROM EMPLOYEES
WHERE DEPARTMENT_ID IN (SELECT DEPARTMENT_ID
                        FROM EMPLOYEES WHERE FIRST_NAME = 'David');

----------------------------------------------------------------------------
-- 스칼라 쿼리 - SELECT문의 서브쿼리가 들어가는 경우(JOIN을 대체함)
SELECT FIRST_NAME,
       DEPARTMENT_NAME
FROM EMPLOYEES E
LEFT JOIN DEPARTMENTS D
ON E.DEPARTMENT_ID = D.DEPARTMENT_ID;

-- 스칼라로 바꿔보면 (LEFT JOIN과 같음)
SELECT FIRST_NAME,
       (SELECT DEPARTMENT_NAME FROM DEPARTMENTS D WHERE D.DEPARTMENT_ID = E.DEPARTMENT_ID) AS DEPARTMENT_NAME
FROM EMPLOYEES E;

-- 스칼라쿼리는 다른테이블의 1개의 컬럼을 가지고 올 때, JOIN보다 구문이 깔끔함
SELECT FIRST_NAME,
       JOB_ID,
       (SELECT JOB_TITLE FROM JOBS J WHERE J.JOB_ID = E.JOB_ID) AS JOB_TITLE
FROM EMPLOYEES E;

-- 한번에 하나의 컬럼을 가져오기 때문에, 많은 열을 가지고 올때는 오히려 JOIN구문 가독성이 좋을 수 있음

SELECT FIRST_NAME,
       JOB_ID,
       (SELECT JOB_TITLE FROM JOBS J WHERE J.JOB_ID = E.JOB_ID) AS JOB_TITLE,
       (SELECT MIN_SALARY FROM JOBS J WHERE J.JOB_ID = E.JOB_ID) AS MIN_SALARY
FROM EMPLOYEES E;

--
-- FIRST_NAME컬럼, DEPARTMENT_NAME, JOB_TITLE을 동시에 SELECT
SELECT E.FIRST_NAME,
       J.JOB_TITLE,
       D.DEPARTMENT_NAME
FROM EMPLOYEES E
LEFT JOIN JOBS J ON E.JOB_ID = J.JOB_ID
LEFT JOIN DEPARTMENTS D ON E.DEPARTMENT_ID = D.DEPARTMENT_ID;

SELECT FIRST_NAME,
       (SELECT JOB_TITLE FROM JOBS J WHERE J.JOB_ID = E.JOB_ID),
       (SELECT DEPARTMENT_NAME FROM DEPARTMENTS D WHERE E.DEPARTMENT_ID = D.DEPARTMENT_ID)
FROM EMPLOYEES E;

----------------------------------------------------------------------------
-- 인라인 뷰 - FROM절 하위에 서브쿼리절이 들어감
-- 인라인 뷰에서 (가상컬럼)을 만들고, 그 컬럼에 대해서 조회해 나갈때 사용함
SELECT * FROM(SELECT *
              FROM EMPLOYEES);
              
-- ROWNUM은 조회된 순서에 대해 번호가 붙음
SELECT ROWNUM,
       FIRST_NAME,
       SALARY
FROM EMPLOYEES
ORDER BY SALARY DESC;

-- ORDER를 먼저 시킨 결과에 대해서 재조회
SELECT ROWNUM,
       FIRST_NAME,
       SALARY
FROM(SELECT FIRST_NAME,
            SALARY
    FROM EMPLOYEES
    ORDER BY SALARY DESC
)
WHERE ROWNUM BETWEEN 11 AND 20; -- ROWNUM은 반드시 1부터 시작해야함 (결과가 X)

-- ORDER를 먼저 시킨 결과를 만들고, ROWNUM을 가상열로 다시 만들고, 재조회
SELECT *
FROM (
    SELECT ROWNUM AS RN, --가상열(인위적으로 생성된 열)
           FIRST_NAME,
           SALARY
    FROM (
         SELECT FIRST_NAME,
                SALARY
         FROM EMPLOYEES
         ORDER BY SALARY DESC
         )
)
WHERE RN BETWEEN 11 AND 20; -- 안에서 RN으로 만들어진 가상열을 밖에서 사용할 수 있음

-- 예시
-- 근속년수 5년째 되는 사람들만 출력함
SELECT *
FROM (
        SELECT FIRST_NAME,
               HIRE_DATE,
        TRUNC((SYSDATE - HIRE_DATE) / 365 ) AS 근속년수 -- 안에서 만든 가상열에 대해서 재조회 해낼때 인라인뷰가 사용됨
    FROM EMPLOYEES
    ORDER BY 근속년수 DESC
)
WHERE MOD(근속년수, 5) = 0;

-- 인라인뷰에서 테이블 엘리어스로 조회
SELECT ROWNUM AS RN,
       A.*
FROM(
     SELECT E.*,
            TRUNC((SYSDATE - HIRE_DATE) / 365 ) AS 근속년수
     FROM EMPLOYEES E
     ORDER BY 근속년수 DESC
) A;







