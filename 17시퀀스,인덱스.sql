-- ������ (���������� �����ϴ� ��)
-- �ַ� pk�� ����� �� ����
SELECT * FROM USER_SEQUENCES;

-- ������ ���� *****
CREATE SEQUENCE DEPTS_SEQ
       INCREMENT BY 1 
       START WITH 1
       MAXVALUE 10
       NOCACHE -- ĳ�ÿ� �������� ���� �ʴ´�
       NOCYCLE; -- �ִ밪�� �������� �� ���� X
       
-- ����
DROP TABLE DEPTS;
CREATE TABLE DEPTS (
       DEPT_NO NUMBER(2) PRIMARY KEY,
       DEPT_NAME VARCHAR(30)
);

-- ������ ����� 2��
SELECT DEPTS_SEQ.CURRVAL FROM DUAL; -- ���� ������ (NEXTVAL�� ���� �Ǿ����)
SELECT DEPTS_SEQ.NEXTVAL FROM DUAL; -- ���� ������ ��������ŭ ����

-- ������ ����
INSERT INTO DEPTS VALUES(DEPTS_SEQ.NEXTVAL,'EXAMPLE');

-- ������ ����
ALTER SEQUENCE DEPTS_SEQ MAXVALUE 1000;
ALTER SEQUENCE DEPTS_SEQ INCREMENT BY 10;

-- �������� �̹� ���ǰ� �ִٸ�, DROP�ϸ� �ȵ�
-- ���� �������� �ʱ�ȭ �ؾ��Ѵٸ�?
-- �������� �������� ������ ���� �ʱ�ȭ �ΰ�ó�� �� �� ����
SELECT DEPTS_SEQ.CURRVAL FROM DUAL;

--1. �������� ������ (���簪 - 1) ������ �ٲ�
ALTER SEQUENCE DEPTS_SEQ INCREMENT BY -89;

--2. ���� �������� ����
SELECT DEPTS_SEQ.NEXTVAL FROM DUAL;

--3. �ٽ� �������� 1�� ����
ALTER SEQUENCE DEPTS_SEQ INCREMENT BY 1;

-----------------------------------------------------
-- ������ ���� (���߿� ���̺��� ������ ��, �����Ͱ� ���ٸ� PK�� �������� ��� ���)
-- ���ڿ� PK (�⵵�� - �Ϸù�ȣ)
-- �⵵�� �ٲ�� �������� �ʱ�ȭ

CREATE TABLE DPETS2 (
       DEPT_NO VARCHAR2(20) PRIMARY KEY,
       DEPT_NAME VARCHAR2(20)
);

INSERT INTO DPETS2 VALUES(TO_CHAR(SYSDATE, 'YYYY-MM-') || LPAD(DEPTS_SEQ.NEXTVAL, 6, 0), 'EXAMPLE');
SELECT * FROM DPETS2;

-- ������ ����
DROP SEQUENCE ��������;

------------------------------------------------------------------------------------------------------
-- INDEX
-- INDEX�� PK, UNIQUE�� �ڵ����� �����ǰ�, ��ȸ�� ������ �ϴ� HINT������ �մϴ�.
-- INDEX������ �����ε���, �����ε����� �ֽ��ϴ�.
-- UNIQUE�� �÷����� UNIQUE�ε���(����) �ε����� ����
-- �Ϲ��÷����� ����� �ε����� ������ �� ����
-- INDEX�� ��ȸ�� ������ ������, DML������ ���� ���Ǵ� �÷��� ������ �������ϸ� �θ� ���� ����

-- �ε��� ����
CREATE TABLE EMPS_IT AS (SELECT * FROM EMPLOYEES);

-- �ε����� ���� �� ��ȸ
SELECT * FROM EMPS_IT WHERE FIRST_NAME = 'Nancy';

-- ����� �ε��� ����
CREATE INDEX EMPS_IT_IX ON EMPS_IT (FIRST_NAME);

-- �ε��� ���� �� FIRST_NAME���� �ٽ� ��ȸ
SELECT * FROM EMPS_IT WHERE FIRST_NAME = 'Nancy';

-- �ε��� ���� (�ε����� �����ϴ��� ���̺� ������ ��ġ�� ����)
DROP INDEX EMPS_IT_IX;

-- �����ε��� (������ �÷��� ���ÿ� �ε����� ����, ù��° �� �÷��� �ε��� ������ ���� �� ����)
CREATE INDEX EMPS_IT_IX ON EMPS_IT (FIRST_NAME, LAST_NAME);

SELECT * FROM EMPLOYEES WHERE FIRST_NAME = 'Nancy'; -- ��Ʈ ����
SELECT * FROM EMPLOYEES WHERE FIRST_NAME = 'Nancy' AND LAST_NAME = 'Greenberg';
SELECT * FROM EMPLOYEES WHERE LAST_NAME = 'Greenberg';

-- �����ε��� (PK, UNIQUE���� �ڵ�������)
-- CREATE UNIQUE INDEX �ε����� ~~~


