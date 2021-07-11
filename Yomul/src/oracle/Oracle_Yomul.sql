-- 제약 조건 명명 규칙
-- '제약조건 축약어'_Y_'자기테이블 축약어'_['상대테이블 축약어']_속성명

-- DB 초기화
-- 테이블 삭제----------------------------------------------------------------------------------------------------------------------------------
DROP TABLE YOMUL_MEMBERS CASCADE CONSTRAINTS;
DROP TABLE YOMUL_PRODUCTS CASCADE CONSTRAINTS;
DROP TABLE YOMUL_FAVORITE_LISTS CASCADE CONSTRAINTS;
DROP TABLE YOMUL_TRADE_HISTORY CASCADE CONSTRAINTS;
DROP TABLE YOMUL_CHATS CASCADE CONSTRAINTS;
DROP TABLE YOMUL_TOWN_ARTICLES CASCADE CONSTRAINTS;
DROP TABLE YOMUL_NEAR_ARTICLES CASCADE CONSTRAINTS;
DROP TABLE YOMUL_VENDORS CASCADE CONSTRAINTS;
DROP TABLE YOMUL_VENDOR_NEWS CASCADE CONSTRAINTS;
DROP TABLE YOMUL_VENDOR_CUSTOMERS CASCADE CONSTRAINTS;
DROP TABLE YOMUL_VENDOR_REVIEWS CASCADE CONSTRAINTS;
DROP TABLE YOMUL_NOTICES CASCADE CONSTRAINTS;
DROP TABLE YOMUL_FAQ_CATEGORIES CASCADE CONSTRAINTS;
DROP TABLE YOMUL_FAQ_ARTICLES CASCADE CONSTRAINTS;
DROP TABLE YOMUL_QNA_CATEGORIES CASCADE CONSTRAINTS;
DROP TABLE YOMUL_QNA_ARTICLES CASCADE CONSTRAINTS;
DROP TABLE YOMUL_FILES CASCADE CONSTRAINTS;
DROP TABLE YOMUL_COMMENTS CASCADE CONSTRAINTS;
DROP TABLE YOMUL_LIKES CASCADE CONSTRAINTS;
DROP TABLE YOMUL_REPORTS CASCADE CONSTRAINTS;
-- 시퀀스 삭제----------------------------------------------------------------------------------------------------------------------------------
DROP SEQUENCE YOMUL_MEMBERS_NO_SEQ;
DROP SEQUENCE YOMUL_PRODUCTS_NO_SEQ;
DROP SEQUENCE YOMUL_TRADE_HISTORY_NO_SEQ;
DROP SEQUENCE YOMUL_CHATS_NO_SEQ;
DROP SEQUENCE YOMUL_TOWN_ARTICLES_NO_SEQ;
DROP SEQUENCE YOMUL_NEAR_ARTICLES_NO_SEQ;
DROP SEQUENCE YOMUL_VENDORS_NO_SEQ;
DROP SEQUENCE YOMUL_VENDOR_NEWS_NO_SEQ;
DROP SEQUENCE YOMUL_VENDOR_REVIEWS_NO_SEQ;
DROP SEQUENCE YOMUL_NOTICES_NO_SEQ;
DROP SEQUENCE YOMUL_FAQ_ARTICLES_NO_SEQ;
DROP SEQUENCE YOMUL_QNA_ARTICLES_NO_SEQ;
DROP SEQUENCE YOMUL_FILES_NO_SEQ;
DROP SEQUENCE YOMUL_COMMENTS_NO_SEQ;
-- 테이블 생성----------------------------------------------------------------------------------------------------------------------------------
-- 회원
CREATE TABLE YOMUL_MEMBERS(
    NO VARCHAR2(10), -- 회원번호
    EMAIL VARCHAR2(100) CONSTRAINT NN_Y_M_EMAIL NOT NULL CONSTRAINT U_Y_M_EMAIL UNIQUE, -- 이메일
    PW VARCHAR2(50) CONSTRAINT NN_Y_M_PW NOT NULL, -- 비밀번호
    NICKNAME VARCHAR2(50) CONSTRAINT NN_Y_M_NICKNAME NOT NULL CONSTRAINT U_Y_M_NICKNAME UNIQUE, -- 별명
    HASHSALT VARCHAR2(100) CONSTRAINT NN_Y_M_HASHSALT NOT NULL, -- 해쉬 솔트
    PHONE VARCHAR2(30), -- 전화번호
    GENDER VARCHAR2(5) CONSTRAINT C_Y_M_GENDER CHECK (GENDER IN('F', 'M')), -- 성별
    INTRO VARCHAR2(500), -- 자기소개
    KAKAO_TOKEN VARCHAR2(100) CONSTRAINT U_Y_M_KAKAO_TOKEN UNIQUE, -- 카카오 로그인 토큰
    AUTHORITY VARCHAR2(10) DEFAULT 'USER' CONSTRAINT NN_Y_M_AUTHORITY NOT NULL CONSTRAINT C_Y_M_AUTHORITY CHECK (AUTHORITY IN('USER', 'ADMIN')), -- 권한
    WITHDRAWAL NUMBER(1) DEFAULT 0 CONSTRAINT C_Y_M_WITHDRAWAL CHECK (WITHDRAWAL IN(0, 1)) CONSTRAINT NN_Y_M_WITHDRAWAL NOT NULL, -- 탈퇴 요청 여부
    MDATE DATE DEFAULT SYSDATE CONSTRAINT NN_Y_M_MDATE NOT NULL, -- 가입 일자
    SUBSCRIBE VARCHAR2(3) DEFAULT 'off' CONSTRAINT NN_Y_M_SUBSCRIBE NOT NULL CONSTRAINT C_Y_M_SUBSCRIBE CHECK (SUBSCRIBE IN ('on', 'off')), -- 구독, OFF: 구독안함, ON: 구독함
    CONSTRAINT PK_Y_M_NO PRIMARY KEY(NO)
);

-- 물건 정보
CREATE TABLE YOMUL_PRODUCTS(
    NO VARCHAR2(10), -- 물건 번호
    SELLER VARCHAR2(10) CONSTRAINT NN_Y_P_SELLER NOT NULL, -- 등록자
    TITLE VARCHAR2(100) CONSTRAINT NN_Y_P_TITLE NOT NULL, -- 글 제목
    CONTENT VARCHAR2(500) CONSTRAINT NN_Y_P_CONTENT NOT NULL, -- 글 내용
    PRICE NUMBER(20) CONSTRAINT NN_Y_P_PRICE NOT NULL CONSTRAINT C_Y_P_PRICE CHECK (PRICE >= 0), -- 가격
    STATE VARCHAR2(20) CONSTRAINT NN_Y_P_STATE NOT NULL CONSTRAINT C_Y_P_STATE CHECK (STATE IN('SELLING', 'SOLD')), -- 물건 상태
    HITS NUMBER(10) DEFAULT 0 CONSTRAINT NN_Y_P_HITS NOT NULL CONSTRAINT C_Y_P_HITS CHECK (HITS >= 0), -- 조회수
    CONSTRAINT PK_Y_P_NO PRIMARY KEY(NO),
    CONSTRAINT FK_Y_P_M_SELLER FOREIGN KEY (SELLER) REFERENCES YOMUL_MEMBERS(NO) ON DELETE CASCADE
);

-- 찜 목록
CREATE TABLE YOMUL_FAVORITE_LISTS(
  MEMBER_NO VARCHAR2(10) CONSTRAINT NN_Y_FL_EMAIL NOT NULL, -- 찜한 유저
  PRODUCT_NO VARCHAR2(10) CONSTRAINT NN_Y_FL_PRODUCT_NO NOT NULL, -- 찜 된 물건
  CONSTRAINT FK_Y_FL_M_EMAIL FOREIGN KEY (MEMBER_NO) REFERENCES YOMUL_MEMBERS(NO) ON DELETE CASCADE,
  CONSTRAINT FK_Y_FL_P_NO FOREIGN KEY (PRODUCT_NO) REFERENCES YOMUL_PRODUCTS(NO) ON DELETE CASCADE
);

-- 물건 거래 내역
CREATE TABLE YOMUL_TRADE_HISTORY(
  NO VARCHAR2(10), -- 거래 번호
  PRODUCT_NO VARCHAR2(10)  CONSTRAINT NN_Y_T_H_NO NOT NULL, -- 물건 번호
  SELLER VARCHAR2(10)  CONSTRAINT NN_Y_TH_SELLER NOT NULL, -- 판매자
  BUYER VARCHAR2(10) CONSTRAINT NN_Y_TH_BUYER NOT NULL,  -- 구매자
  TRADE_DATE DATE DEFAULT SYSDATE CONSTRAINT NN_Y_TH_TDATE NOT NULL, -- 거래일시
  CONSTRAINT PK_Y_TH_NO PRIMARY KEY(NO),
  CONSTRAINT FK_Y_TH_PRODUCTS FOREIGN KEY(PRODUCT_NO) REFERENCES YOMUL_PRODUCTS(NO) ON DELETE CASCADE,
  CONSTRAINT FK_Y_TH_M_SELLER FOREIGN KEY(SELLER) REFERENCES YOMUL_MEMBERS(NO) ON DELETE CASCADE,
  CONSTRAINT FK_Y_TH_M_BUYER FOREIGN KEY(BUYER) REFERENCES YOMUL_MEMBERS(NO) ON DELETE CASCADE
);

-- 채팅
CREATE TABLE YOMUL_CHATS(
    NO VARCHAR2(10), -- 채팅 번호 
    CHAT_FROM VARCHAR2(10) CONSTRAINT NN_Y_C_CHAT_FROM NOT NULL, -- 채팅 발신자
    CHAT_TO VARCHAR2(10) CONSTRAINT NN_Y_C_CHAT_TO NOT NULL, -- 채팅 수신자
    CONTENT VARCHAR2(500) CONSTRAINT NN_Y_C_CONTENT NOT NULL, -- 채팅 내용
    CDATE DATE DEFAULT SYSDATE CONSTRAINT NN_Y_C_CDATE NOT NULL, -- 채팅 전송 시간
    IMG VARCHAR2(100), -- 전송 이미지
    CONSTRAINT PK_Y_CH_NO PRIMARY KEY(NO) ,
    CONSTRAINT FK_Y_CH_M_CHAT_FROM FOREIGN KEY (CHAT_FROM) REFERENCES YOMUL_MEMBERS(NO) ON DELETE CASCADE,
    CONSTRAINT FK_Y_CH_M_CHAT_TO FOREIGN KEY (CHAT_TO) REFERENCES YOMUL_MEMBERS(NO) ON DELETE CASCADE
);

-- 동네생활 게시글
CREATE TABLE YOMUL_TOWN_ARTICLES(
    NO VARCHAR2(10), -- 게시글 번호
    TAGS VARCHAR2(10) CONSTRAINT NN_Y_TA_TAGS NOT NULL, -- 태그
    TITLE VARCHAR2(100) CONSTRAINT NN_Y_TA_TITLE NOT NULL, -- 제목
    CONTENT VARCHAR2(500) CONSTRAINT NN_Y_TA_CONTENT NOT NULL, -- 내용
    HITS NUMBER(10) DEFAULT 0 CONSTRAINT NN_Y_TA_HITS NOT NULL CONSTRAINT C_Y_TA_HITS CHECK (HITS >= 0), -- 조회수
    CONSTRAINT PK_Y_TA_NO PRIMARY KEY(NO)
);

-- 내 근처 게시글
CREATE TABLE YOMUL_NEAR_ARTICLES(
    NO VARCHAR2(10), --상품 게시글 번호
    WRITER VARCHAR2(10) CONSTRAINT NN_Y_NA_EMAIL NOT NULL, -- 작성자
    TITLE VARCHAR2(50) CONSTRAINT NN_Y_NA_TITLE NOT NULL, -- 상품 제목
    CATEGORY VARCHAR2(20) CONSTRAINT NN_Y_NA_CATEGORY NOT NULL, -- 카테고리
    PRICE NUMBER(30) CONSTRAINT C_Y_NA_PRICE CHECK (PRICE >= 0), --가격(선택)
    HP VARCHAR2(50), --핸드폰 번호(선택)
    CONTENT VARCHAR2(1000) CONSTRAINT NN_Y_NA_CONTENT NOT NULL, --본문 내용
    NDATE DATE DEFAULT SYSDATE CONSTRAINT NN_Y_NA_NDATE NOT NULL, --작성 일자
    CHATCHECK NUMBER(1) DEFAULT 0 CONSTRAINT NN_Y_NA_CHATCHECK NOT NULL CONSTRAINT C_Y_NA_CHATCHECK CHECK (CHATCHECK IN(0, 1)),  -- 채팅 금지 여부 DEFAULT 0 
    HITS NUMBER(10) DEFAULT 0 CONSTRAINT NN_Y_NA_HITS NOT NULL CONSTRAINT C_Y_NA_HITS CHECK (HITS >= 0), -- 조회수
    CONSTRAINT PK_Y_NA_NO PRIMARY KEY(NO),
    CONSTRAINT FK_Y_NA_EMAIL FOREIGN KEY (WRITER) REFERENCES YOMUL_MEMBERS(NO) ON DELETE CASCADE
);

-- 업체정보
CREATE TABLE YOMUL_VENDORS(
    NO VARCHAR2(10) CONSTRAINT NN_Y_V_NO NOT NULL CONSTRAINT U_Y_V_NO UNIQUE, --회원번호
    NAME VARCHAR2(50), --업체명
    CATEGORY VARCHAR2(20) CONSTRAINT NN_Y_V_CATEGORY NOT NULL, --카테고리 
    INFO VARCHAR2(200) CONSTRAINT NN_Y_V_INFO NOT NULL, --정보 
    TEL VARCHAR2(30) CONSTRAINT NN_Y_V_TEL NOT NULL, --전화번호 
    ADDR VARCHAR2(50) CONSTRAINT NN_Y_V_ADDR NOT NULL, --주소 
    IMG VARCHAR2(200) DEFAULT '이미지준비중.jpg' CONSTRAINT NN_Y_V_IMG NOT NULL, --프로필 이미지
    CONSTRAINT PK_Y_V_NAME PRIMARY KEY (NAME),
    CONSTRAINT FK_Y_V_NO FOREIGN KEY (NO) REFERENCES YOMUL_MEMBERS(NO)
);

-- 업체 소식 (업체명 이용하여 업체 프필이미지 가져오기)
CREATE TABLE YOMUL_VENDOR_NEWS(
    NO NUMBER(10), --소식 번호
    NAME VARCHAR2(50) CONSTRAINT NN_Y_VN_NAME NOT NULL,  --업체명
    CATEGORY VARCHAR2(20) CONSTRAINT NN_Y_VN_CATEGORY NOT NULL, --카테고리
    TITLE VARCHAR2(50) CONSTRAINT NN_Y_VN_TITLE NOT NULL,  --소식 타이틀
    CONTENT VARCHAR2(500) CONSTRAINT NN_Y_VN_CONTENT NOT NULL, --소식 내용
    IMG VARCHAR2(200),  --소식 이미지
    PRICE VARCHAR2(20) DEFAULT 0 CONSTRAINT NN_Y_VN_PRICE NOT NULL CONSTRAINT C_Y_VN_PRICE CHECK (PRICE >= 0),  --가격
    HITS NUMBER(10) DEFAULT 0 CONSTRAINT NN_Y_VN_HITS NOT NULL CONSTRAINT C_Y_VN_HITS CHECK (HITS >= 0), --조회수
    VDATE DATE DEFAULT SYSDATE CONSTRAINT NN_Y_VN_VDATE NOT NULL, --날짜
    CONSTRAINT PK_Y_VN_NO PRIMARY KEY (NO),
    CONSTRAINT FK_Y_VN_NAME FOREIGN KEY (NAME) REFERENCES YOMUL_VENDORS(NAME)
);

-- 업체 단골 (회원번호 이용하여 단골 프필이미지, 닉네임 가져오기)
CREATE TABLE YOMUL_VENDOR_CUSTOMERS(
    NAME VARCHAR2(50), --업체명
    NO VARCHAR2(10), --회원번호
    CONSTRAINT FK_Y_VC_NAME FOREIGN KEY (NAME) REFERENCES YOMUL_VENDORS(NAME),
    CONSTRAINT FK_Y_VC_NO FOREIGN KEY (NO) REFERENCES YOMUL_MEMBERS(NO)
);

-- 업체 후기 (회원번호 이용하여 단골 프필이미지, 닉네임 가져오기)
CREATE TABLE YOMUL_VENDOR_REVIEWS(
    NO NUMBER(10), --후기 번호
    NAME VARCHAR2(50) CONSTRAINT NN_Y_VR_NAME NOT NULL,  --업체명
    MEMBER_NO VARCHAR2(10)CONSTRAINT NN_Y_VR_MEMBER_NO NOT NULL, --회원번호
    CONTENT VARCHAR2(500) CONSTRAINT NN_Y_VR_CONTENT NOT NULL, --후기 내용
    HITS NUMBER(10) DEFAULT 0 CONSTRAINT NN_Y_VR_HITS NOT NULL CONSTRAINT C_Y_VR_HITS CHECK (HITS >= 0), --조회수
    VDATE DATE DEFAULT SYSDATE CONSTRAINT NN_Y_VR_VDATE NOT NULL, --날짜
    CONSTRAINT PK_Y_VR_NO PRIMARY KEY (NO),
    CONSTRAINT FK_Y_VR_NAME FOREIGN KEY (NAME) REFERENCES YOMUL_VENDORS(NAME),
    CONSTRAINT FK_Y_VR_MEMBER_NO FOREIGN KEY (MEMBER_NO) REFERENCES YOMUL_MEMBERS(NO)
);

-- 공지사항
CREATE TABLE YOMUL_NOTICES(
    NO VARCHAR2(10), -- 글 번호
    WRITER VARCHAR2(10) CONSTRAINT NN_Y_N_EMAIL NOT NULL, -- 작성자
    TITLE VARCHAR2(100) CONSTRAINT NN_Y_N_TITLE NOT NULL, -- 제목
    CONTENT VARCHAR2(400) CONSTRAINT NN_Y_N_CONTENT NOT NULL, -- 내용
    NDATE DATE DEFAULT SYSDATE CONSTRAINT NN_Y_N_NDATE NOT NULL, -- 작성일자
    HITS NUMBER(10) DEFAULT 0 CONSTRAINT NN_Y_N_HITS NOT NULL CONSTRAINT C_Y_N_HITS CHECK (HITS >= 0), -- 조회수
    CONSTRAINT PK_Y_N_NO PRIMARY KEY(NO),
    CONSTRAINT FK_Y_N_MEMBERS FOREIGN KEY (WRITER) REFERENCES YOMUL_MEMBERS(NO) ON DELETE CASCADE
);

-- FAQ 카테고리
CREATE TABLE YOMUL_FAQ_CATEGORIES(
    NO NUMBER(4), -- 카테고리 코드
    CONTENT VARCHAR2(100) CONSTRAINT NN_Y_FC_CONTENT NOT NULL, -- 카테고리 내용
    CONSTRAINT PK_Y_FC_NO PRIMARY KEY (NO)
);

-- FAQ 게시글
CREATE TABLE YOMUL_FAQ_ARTICLES(
    NO VARCHAR2(10), -- 글 번호
    CATEGORY NUMBER(4) CONSTRAINT NN_Y_FA_CATEGORY NOT NULL, -- 카테고리
    TITLE VARCHAR2(100) CONSTRAINT NN_Y_FA_TITLE NOT NULL, -- 제목
    CONTENT VARCHAR2(500) CONSTRAINT NN_Y_FAQ_ARTICLES_CONTENT NOT NULL, -- 내용
    HITS NUMBER(10) DEFAULT 0 CONSTRAINT NN_Y_FA_HITS NOT NULL CONSTRAINT C_Y_FA_HITS CHECK (HITS >= 0), -- 조회수
    CONSTRAINT PK_Y_FA_NO PRIMARY KEY (NO),
    CONSTRAINT FK_Y_FA_FAQ_CATEGORIES FOREIGN KEY (CATEGORY) REFERENCES YOMUL_FAQ_CATEGORIES(NO) ON DELETE CASCADE
);

-- QNA 카테고리
CREATE TABLE YOMUL_QNA_CATEGORIES(
    NO NUMBER(4), -- 코드
    CONTENT VARCHAR2(100) CONSTRAINT NN_Y_Q_CATEGORIES NOT NULL, -- 카테고리 내용
    CONSTRAINT PK_Y_QC_NO PRIMARY KEY (NO)
);

-- QNA 게시글
CREATE TABLE YOMUL_QNA_ARTICLES(
    NO VARCHAR2(10), -- 글 번호
    WRITER VARCHAR2(10) CONSTRAINT NN_Y_QA_WRITER NOT NULL, -- 작성자 회원번호
    WDATE DATE DEFAULT SYSDATE CONSTRAINT NN_Y_QA_WDATE NOT NULL, -- 작성 일자
    CATEGORY NUMBER(4) CONSTRAINT NN_Y_QA_CATEGORY NOT NULL, -- 작성 글 카테고리
    TITLE VARCHAR2(100) CONSTRAINT NN_Y_QA_TITLE NOT NULL, -- 제목
    CONTENT VARCHAR2(500) CONSTRAINT NN_Y_QA_CONTENT NOT NULL, -- 내용
    RDATE DATE, -- 답변 날짜
    RWRITER VARCHAR2(10), -- 답변 작성자 회원번호
    REPLY VARCHAR2(500), -- 답변 작성 내용
    HITS NUMBER(10) DEFAULT 0 CONSTRAINT NN_Y_QA_HITS NOT NULL CONSTRAINT C_Y_QA_HITS CHECK (HITS >= 0), -- 조회수
    CONSTRAINT PK_Y_QA_NO PRIMARY KEY (NO),
    CONSTRAINT FK_Y_QA_M_WRITER FOREIGN KEY (WRITER) REFERENCES YOMUL_MEMBERS(NO) ON DELETE CASCADE,
    CONSTRAINT FK_Y_QA_M_RWRITER FOREIGN KEY (RWRITER) REFERENCES YOMUL_MEMBERS(NO) ON DELETE CASCADE,
    CONSTRAINT FK_Y_QA_QC_CATEGORY FOREIGN KEY (CATEGORY) REFERENCES YOMUL_QNA_CATEGORIES(NO) ON DELETE CASCADE
);

-- 업로드 된 파일 
-- 실제로 저장된 파일 명은 ('게시글 번호'_'파일 번호'_'파일 명') 식으로 저장 ex(n001_1_example_jpg)
CREATE TABLE YOMUL_FILES(
    ARTICLE_NO VARCHAR2(10) CONSTRAINT NN_Y_F_ARTICLE_NO NOT NULL, -- 작성된 게시글 번호
    NO NUMBER(10), -- 파일 번호
    FILENAME VARCHAR2(100) CONSTRAINT NN_Y_F_FILENAME NOT NULL, -- 파일 명
    CONSTRAINT PK_Y_F_NO PRIMARY KEY (NO)
);

-- 댓글
CREATE TABLE YOMUL_COMMENTS(
  NO NUMBER(10), -- 댓글 번호 
  ARTICLE_NO VARCHAR2(10) CONSTRAINT NN_Y_CO_ARTICLE_NO NOT NULL, -- 작성된 게시글 번호
  WRITER VARCHAR2(10) CONSTRAINT NN_Y_CO_EMAIL NOT NULL, -- 작성자 회원번호
  CONTENT VARCHAR2(1000) CONSTRAINT NN_Y_CO_CONTENT NOT NULL, -- 작성 내용
  WDATE DATE DEFAULT SYSDATE CONSTRAINT NN_Y_CO_WDATE NOT NULL, -- 작성일자
  LIKES NUMBER(10) DEFAULT 0 CONSTRAINT NN_Y_CO_LIKES NOT NULL CONSTRAINT C_Y_CO_LIKES CHECK (LIKES >= 0), -- 좋아요 수 
  REPORTS NUMBER(10) DEFAULT 0 CONSTRAINT NN_Y_CO_REPORTS NOT NULL CONSTRAINT C_Y_CO_REPORTS CHECK (REPORTS >= 0), -- 신고 수
  CONSTRAINT PK_Y_CO_NO PRIMARY KEY (NO),
  CONSTRAINT FK_Y_CO_M_EMAIL FOREIGN KEY(WRITER) REFERENCES YOMUL_MEMBERS(NO) ON DELETE CASCADE
);

-- 게시글, 댓글 좋아요 테이블
CREATE TABLE YOMUL_LIKES(
    ARTICLE_NO VARCHAR2(10), -- 좋아요 눌린 게시글 번호
    MEMBER_NO VARCHAR2(10),  -- 좋아요 누른 사람
    CONSTRAINT PK_Y_L PRIMARY KEY (ARTICLE_NO, MEMBER_NO)
);

-- 신고
CREATE TABLE YOMUL_REPORTS(
    ARTICLE_NO VARCHAR2(10), -- 신고 눌린 게시글 번호
    MEMBER_NO VARCHAR2(10), -- 신고 누른 사람
    CONSTRAINT PK_Y_R PRIMARY KEY (ARTICLE_NO, MEMBER_NO)
);
-- 테이블 생성 끝----------------------------------------------------------------------------------------------------------------------------------

-- 시퀀스 생성----------------------------------------------------------------------------------------------------------------------------------
-- 회원 번호 시퀀스 생성, 1부터 시작, 1씩 증가, 메모리에 미리 올려 놓을 인덱스 개수 2
CREATE SEQUENCE YOMUL_MEMBERS_NO_SEQ START WITH 1 INCREMENT BY 1 CACHE 2; 

-- 물건 번호 시퀀스 생성
CREATE SEQUENCE YOMUL_PRODUCTS_NO_SEQ START WITH 1 INCREMENT BY 1 CACHE 2;

-- 거래 번호 시퀀스 생성
CREATE SEQUENCE YOMUL_TRADE_HISTORY_NO_SEQ START WITH 1 INCREMENT BY 1 CACHE 2;

-- 채팅 번호 시퀀스 생성
CREATE SEQUENCE YOMUL_CHATS_NO_SEQ START WITH 1 INCREMENT BY 1 CACHE 2;

-- 동네생활 글 번호 시퀀스 생성
CREATE SEQUENCE YOMUL_TOWN_ARTICLES_NO_SEQ START WITH 1 INCREMENT BY 1 CACHE 2;

-- 내 근처 게시글 시퀀스 생성
CREATE SEQUENCE YOMUL_NEAR_ARTICLES_NO_SEQ START WITH 1 INCREMENT BY 1 CACHE 2;

-- 업체 번호 시퀀스 생성, 1부터 시작, 1씩 증가 
CREATE SEQUENCE YOMUL_VENDORS_NO_SEQ START WITH 1 INCREMENT BY 1 CACHE 2;

-- 업체 소식 번호 시퀀스 생성, 1부터 시작, 1씩 증가 
CREATE SEQUENCE YOMUL_VENDOR_NEWS_NO_SEQ START WITH 1 INCREMENT BY 1 CACHE 2;

-- 업체 후기 번호 시퀀스 생성, 1부터 시작, 1씩 증가 
CREATE SEQUENCE YOMUL_VENDOR_REVIEWS_NO_SEQ START WITH 1 INCREMENT BY 1 CACHE 2;

-- 공지사항 번호 시퀀스 생성, 1부터 시작, 1씩 증가 
CREATE SEQUENCE YOMUL_NOTICES_NO_SEQ START WITH 1 INCREMENT BY 1 CACHE 2;

-- FAQ 글 번호 시퀀스 생성, 1부터 시작, 1씩 증가 
CREATE SEQUENCE YOMUL_FAQ_ARTICLES_NO_SEQ START WITH 1 INCREMENT BY 1 CACHE 2;

-- QNA 글 번호 시퀀스 생성, 1부터 시작, 1씩 증가 
CREATE SEQUENCE YOMUL_QNA_ARTICLES_NO_SEQ START WITH 1 INCREMENT BY 1 CACHE 2;

-- 파일 번호 시퀀스 생성, 1부터 시작, 1씩 증가, 메모리에 미리 올려 놓을 인덱스 개수 2
CREATE SEQUENCE YOMUL_FILES_NO_SEQ START WITH 1 INCREMENT BY 1 CACHE 2; 

-- 댓글 번호 시퀀스 생성, 1부터 시작, 1씩 증가 
CREATE SEQUENCE YOMUL_COMMENTS_NO_SEQ START WITH 1 INCREMENT BY 1 CACHE 2;
-- 시퀀스 생성 끝----------------------------------------------------------------------------------------------------------------------------------


-- 데이터 입력 시작----------------------------------------------------------------------------------------------------------------------------------
-- 회원 목록 조회
SELECT * FROM YOMUL_MEMBERS;

-- 이메일 중복 확인
SELECT COUNT(EMAIL) FROM YOMUL_MEMBERS WHERE LOWER(EMAIL) = LOWER('dia_changmin@naver.com');

-- 닉네임 중복 확인
SELECT COUNT(NICKNAME) FROM YOMUL_MEMBERS WHERE LOWER(NICKNAME) = LOWER('hwisaek');

-- 회원가입, 기본 비밀번호 '1234'
INSERT INTO YOMUL_MEMBERS(NO, EMAIL, PW, NICKNAME, HASHSALT, SUBSCRIBE, AUTHORITY) VALUES('M'||YOMUL_MEMBERS_NO_SEQ.NEXTVAL, 'admin@yomul.com', 'LVQl5RjTdqE2oRywog3zjhXWnZfrI4La7JlTn7orAE4=', '관리자', 'dsRPWSbFjBtmiscPw4mbph/RX9dvyI15OLs8Pq+JTKU=', 'on', 'ADMIN');
INSERT INTO YOMUL_MEMBERS(NO, EMAIL, PW, NICKNAME, HASHSALT, SUBSCRIBE) VALUES('M'||YOMUL_MEMBERS_NO_SEQ.NEXTVAL, 'yomul@yomul.com', 'LVQl5RjTdqE2oRywog3zjhXWnZfrI4La7JlTn7orAE4=', 'yomul', 'dsRPWSbFjBtmiscPw4mbph/RX9dvyI15OLs8Pq+JTKU=', 'on');
INSERT INTO YOMUL_MEMBERS(NO, EMAIL, PW, NICKNAME, HASHSALT, SUBSCRIBE) VALUES('M'||YOMUL_MEMBERS_NO_SEQ.NEXTVAL, 'hwisaek@yomul.com', 'LVQl5RjTdqE2oRywog3zjhXWnZfrI4La7JlTn7orAE4=', 'Hwisaek', 'dsRPWSbFjBtmiscPw4mbph/RX9dvyI15OLs8Pq+JTKU=', 'on');
INSERT INTO YOMUL_MEMBERS(NO, EMAIL, PW, NICKNAME, HASHSALT, SUBSCRIBE) VALUES('M'||YOMUL_MEMBERS_NO_SEQ.NEXTVAL, 'test@test.com', 'LVQl5RjTdqE2oRywog3zjhXWnZfrI4La7JlTn7orAE4=', 'TEST', 'dsRPWSbFjBtmiscPw4mbph/RX9dvyI15OLs8Pq+JTKU=', 'on');
INSERT INTO YOMUL_MEMBERS(NO, EMAIL, PW, NICKNAME, HASHSALT, SUBSCRIBE) VALUES('M'||YOMUL_MEMBERS_NO_SEQ.NEXTVAL, 'marin@yomul.com', 'LVQl5RjTdqE2oRywog3zjhXWnZfrI4La7JlTn7orAE4=', '해병', 'dsRPWSbFjBtmiscPw4mbph/RX9dvyI15OLs8Pq+JTKU=', 'on');
INSERT INTO YOMUL_MEMBERS(NO, EMAIL, PW, NICKNAME, HASHSALT, SUBSCRIBE) VALUES('M'||YOMUL_MEMBERS_NO_SEQ.NEXTVAL, 'medic@yomul.com', 'LVQl5RjTdqE2oRywog3zjhXWnZfrI4La7JlTn7orAE4=', '메딕', 'dsRPWSbFjBtmiscPw4mbph/RX9dvyI15OLs8Pq+JTKU=', 'on');
INSERT INTO YOMUL_MEMBERS(NO, EMAIL, PW, NICKNAME, HASHSALT, SUBSCRIBE) VALUES('M'||YOMUL_MEMBERS_NO_SEQ.NEXTVAL, 'ghost@yomul.com', 'LVQl5RjTdqE2oRywog3zjhXWnZfrI4La7JlTn7orAE4=', '유령', 'dsRPWSbFjBtmiscPw4mbph/RX9dvyI15OLs8Pq+JTKU=', 'on');
INSERT INTO YOMUL_MEMBERS(NO, EMAIL, PW, NICKNAME, HASHSALT, SUBSCRIBE) VALUES('M'||YOMUL_MEMBERS_NO_SEQ.NEXTVAL, 'scv@yomul.com', 'LVQl5RjTdqE2oRywog3zjhXWnZfrI4La7JlTn7orAE4=', 'SCV', 'dsRPWSbFjBtmiscPw4mbph/RX9dvyI15OLs8Pq+JTKU=', 'on');
INSERT INTO YOMUL_MEMBERS(NO, EMAIL, PW, NICKNAME, HASHSALT, SUBSCRIBE) VALUES('M'||YOMUL_MEMBERS_NO_SEQ.NEXTVAL, 'tank@yomul.com', 'LVQl5RjTdqE2oRywog3zjhXWnZfrI4La7JlTn7orAE4=', '공성전차', 'dsRPWSbFjBtmiscPw4mbph/RX9dvyI15OLs8Pq+JTKU=', 'on');
INSERT INTO YOMUL_MEMBERS(NO, EMAIL, PW, NICKNAME, HASHSALT, SUBSCRIBE) VALUES('M'||YOMUL_MEMBERS_NO_SEQ.NEXTVAL, 'drone@yomul.com', 'LVQl5RjTdqE2oRywog3zjhXWnZfrI4La7JlTn7orAE4=', '집게벌레', 'dsRPWSbFjBtmiscPw4mbph/RX9dvyI15OLs8Pq+JTKU=', 'on');
INSERT INTO YOMUL_MEMBERS(NO, EMAIL, PW, NICKNAME, HASHSALT, SUBSCRIBE) VALUES('M'||YOMUL_MEMBERS_NO_SEQ.NEXTVAL, 'zergling@yomul.com', 'LVQl5RjTdqE2oRywog3zjhXWnZfrI4La7JlTn7orAE4=', '저글링', 'dsRPWSbFjBtmiscPw4mbph/RX9dvyI15OLs8Pq+JTKU=', 'on');
INSERT INTO YOMUL_MEMBERS(NO, EMAIL, PW, NICKNAME, HASHSALT, SUBSCRIBE) VALUES('M'||YOMUL_MEMBERS_NO_SEQ.NEXTVAL, 'larva@yomul.com', 'LVQl5RjTdqE2oRywog3zjhXWnZfrI4La7JlTn7orAE4=', '라바', 'dsRPWSbFjBtmiscPw4mbph/RX9dvyI15OLs8Pq+JTKU=', 'on');
INSERT INTO YOMUL_MEMBERS(NO, EMAIL, PW, NICKNAME, HASHSALT, SUBSCRIBE) VALUES('M'||YOMUL_MEMBERS_NO_SEQ.NEXTVAL, 'hydralisk@yomul.com', 'LVQl5RjTdqE2oRywog3zjhXWnZfrI4La7JlTn7orAE4=', '척추발사기', 'dsRPWSbFjBtmiscPw4mbph/RX9dvyI15OLs8Pq+JTKU=', 'on');
INSERT INTO YOMUL_MEMBERS(NO, EMAIL, PW, NICKNAME, HASHSALT, SUBSCRIBE) VALUES('M'||YOMUL_MEMBERS_NO_SEQ.NEXTVAL, 'mutal@yomul.com', 'LVQl5RjTdqE2oRywog3zjhXWnZfrI4La7JlTn7orAE4=', '쓰리쿠션장인', 'dsRPWSbFjBtmiscPw4mbph/RX9dvyI15OLs8Pq+JTKU=', 'on');
INSERT INTO YOMUL_MEMBERS(NO, EMAIL, PW, NICKNAME, HASHSALT, SUBSCRIBE) VALUES('M'||YOMUL_MEMBERS_NO_SEQ.NEXTVAL, 'probe@yomul.com', 'LVQl5RjTdqE2oRywog3zjhXWnZfrI4La7JlTn7orAE4=', '탐사정', 'dsRPWSbFjBtmiscPw4mbph/RX9dvyI15OLs8Pq+JTKU=', 'on');
INSERT INTO YOMUL_MEMBERS(NO, EMAIL, PW, NICKNAME, HASHSALT, SUBSCRIBE) VALUES('M'||YOMUL_MEMBERS_NO_SEQ.NEXTVAL, 'zealot@yomul.com', 'LVQl5RjTdqE2oRywog3zjhXWnZfrI4La7JlTn7orAE4=', '광전사', 'dsRPWSbFjBtmiscPw4mbph/RX9dvyI15OLs8Pq+JTKU=', 'on');
INSERT INTO YOMUL_MEMBERS(NO, EMAIL, PW, NICKNAME, HASHSALT, SUBSCRIBE) VALUES('M'||YOMUL_MEMBERS_NO_SEQ.NEXTVAL, 'dragoon@yomul.com', 'LVQl5RjTdqE2oRywog3zjhXWnZfrI4La7JlTn7orAE4=', '용기병', 'dsRPWSbFjBtmiscPw4mbph/RX9dvyI15OLs8Pq+JTKU=', 'on');
INSERT INTO YOMUL_MEMBERS(NO, EMAIL, PW, NICKNAME, HASHSALT, SUBSCRIBE) VALUES('M'||YOMUL_MEMBERS_NO_SEQ.NEXTVAL, 'high_templar@yomul.com', 'LVQl5RjTdqE2oRywog3zjhXWnZfrI4La7JlTn7orAE4=', '고위기사', 'dsRPWSbFjBtmiscPw4mbph/RX9dvyI15OLs8Pq+JTKU=', 'on');
INSERT INTO YOMUL_MEMBERS(NO, EMAIL, PW, NICKNAME, HASHSALT, SUBSCRIBE) VALUES('M'||YOMUL_MEMBERS_NO_SEQ.NEXTVAL, 'dark_templar@yomul.com', 'LVQl5RjTdqE2oRywog3zjhXWnZfrI4La7JlTn7orAE4=', '암흑기사', 'dsRPWSbFjBtmiscPw4mbph/RX9dvyI15OLs8Pq+JTKU=', 'on');
INSERT INTO YOMUL_MEMBERS(NO, EMAIL, PW, NICKNAME, HASHSALT, SUBSCRIBE) VALUES('M'||YOMUL_MEMBERS_NO_SEQ.NEXTVAL, 'archon@yomul.com', 'LVQl5RjTdqE2oRywog3zjhXWnZfrI4La7JlTn7orAE4=', '집정관', 'dsRPWSbFjBtmiscPw4mbph/RX9dvyI15OLs8Pq+JTKU=', 'on');
INSERT INTO YOMUL_MEMBERS(NO, EMAIL, PW, NICKNAME, HASHSALT, SUBSCRIBE) VALUES('M'||YOMUL_MEMBERS_NO_SEQ.NEXTVAL, 'dark_archon@yomul.com', 'LVQl5RjTdqE2oRywog3zjhXWnZfrI4La7JlTn7orAE4=', '암흑집정관', 'dsRPWSbFjBtmiscPw4mbph/RX9dvyI15OLs8Pq+JTKU=', 'on');
INSERT INTO YOMUL_MEMBERS(NO, EMAIL, PW, NICKNAME, HASHSALT, SUBSCRIBE) VALUES('M'||YOMUL_MEMBERS_NO_SEQ.NEXTVAL, 'scout@yomul.com', 'LVQl5RjTdqE2oRywog3zjhXWnZfrI4La7JlTn7orAE4=', '정찰기', 'dsRPWSbFjBtmiscPw4mbph/RX9dvyI15OLs8Pq+JTKU=', 'on');
INSERT INTO YOMUL_MEMBERS(NO, EMAIL, PW, NICKNAME, HASHSALT, SUBSCRIBE) VALUES('M'||YOMUL_MEMBERS_NO_SEQ.NEXTVAL, 'corsair@yomul.com', 'LVQl5RjTdqE2oRywog3zjhXWnZfrI4La7JlTn7orAE4=', '해적선', 'dsRPWSbFjBtmiscPw4mbph/RX9dvyI15OLs8Pq+JTKU=', 'on');
INSERT INTO YOMUL_MEMBERS(NO, EMAIL, PW, NICKNAME, HASHSALT, SUBSCRIBE) VALUES('M'||YOMUL_MEMBERS_NO_SEQ.NEXTVAL, 'carrier@yomul.com', 'LVQl5RjTdqE2oRywog3zjhXWnZfrI4La7JlTn7orAE4=', '우주모함', 'dsRPWSbFjBtmiscPw4mbph/RX9dvyI15OLs8Pq+JTKU=', 'on');

-- 프로필 정보 가져오기
SELECT EMAIL, NICKNAME, PHONE, GENDER, INTRO, F.FILENAME FILENAME FROM YOMUL_MEMBERS M LEFT JOIN YOMUL_FILES F ON M.NO = F.ARTICLE_NO WHERE M.NO = 'M1';
SELECT COUNT(*) FROM YOMUL_TRADE_HISTORY WHERE SELLER = 'M1';
SELECT COUNT(*) FROM YOMUL_TRADE_HISTORY WHERE BUYER = 'M1';
SELECT COUNT(*) FROM YOMUL_FAVORITE_LISTS WHERE MEMBER_NO = 'M1';

-- FAQ 카테고리 데이터 생성
INSERT INTO YOMUL_FAQ_CATEGORIES(NO, CONTENT) VALUES(1, '운영정책');
INSERT INTO YOMUL_FAQ_CATEGORIES(NO, CONTENT) VALUES(2, '계정/인증');
INSERT INTO YOMUL_FAQ_CATEGORIES(NO, CONTENT) VALUES(3, '구매/판매');
INSERT INTO YOMUL_FAQ_CATEGORIES(NO, CONTENT) VALUES(4, '거래 품목');
INSERT INTO YOMUL_FAQ_CATEGORIES(NO, CONTENT) VALUES(5, '거래 매너');
INSERT INTO YOMUL_FAQ_CATEGORIES(NO, CONTENT) VALUES(6, '이벤트/초대');
INSERT INTO YOMUL_FAQ_CATEGORIES(NO, CONTENT) VALUES(7, '이용 제재');
INSERT INTO YOMUL_FAQ_CATEGORIES(NO, CONTENT) VALUES(8, '기타');
INSERT INTO YOMUL_FAQ_CATEGORIES(NO, CONTENT) VALUES(9, '비즈프로필');
INSERT INTO YOMUL_FAQ_CATEGORIES(NO, CONTENT) VALUES(10, '동네생활');
INSERT INTO YOMUL_FAQ_CATEGORIES(NO, CONTENT) VALUES(11, '지역 광고');
INSERT INTO YOMUL_FAQ_CATEGORIES(NO, CONTENT) VALUES(12, '채팅');

-- QNA 카테고리 데이터 생성
INSERT INTO YOMUL_QNA_CATEGORIES(NO, CONTENT) VALUES(1, '거래 환불/분쟁 및 사기 신고');
INSERT INTO YOMUL_QNA_CATEGORIES(NO, CONTENT) VALUES(2, '계정 문의');
INSERT INTO YOMUL_QNA_CATEGORIES(NO, CONTENT) VALUES(3, '판매 금지/거래 품목 문의');
INSERT INTO YOMUL_QNA_CATEGORIES(NO, CONTENT) VALUES(4, '매너평가, 매너온도, 거래후기 관련 문의');
INSERT INTO YOMUL_QNA_CATEGORIES(NO, CONTENT) VALUES(5, '게시글 노출, 미노출 문의');
INSERT INTO YOMUL_QNA_CATEGORIES(NO, CONTENT) VALUES(6, '채팅, 알림 문의');
INSERT INTO YOMUL_QNA_CATEGORIES(NO, CONTENT) VALUES(7, '앱 사용/거래 방법 문의');
INSERT INTO YOMUL_QNA_CATEGORIES(NO, CONTENT) VALUES(8, '동네 생활(커뮤니티) 문의');
INSERT INTO YOMUL_QNA_CATEGORIES(NO, CONTENT) VALUES(9, '지역 광고 문의');
INSERT INTO YOMUL_QNA_CATEGORIES(NO, CONTENT) VALUES(10, '비즈프로필(등록, 이용) 문의');
INSERT INTO YOMUL_QNA_CATEGORIES(NO, CONTENT) VALUES(11, '검색 문의');
INSERT INTO YOMUL_QNA_CATEGORIES(NO, CONTENT) VALUES(12, '기타 문의');
INSERT INTO YOMUL_QNA_CATEGORIES(NO, CONTENT) VALUES(13, '오류 제보');
INSERT INTO YOMUL_QNA_CATEGORIES(NO, CONTENT) VALUES(14, '개선/제안');
-- 데이터 입력 끝----------------------------------------------------------------------------------------------------------------------------------

COMMIT;