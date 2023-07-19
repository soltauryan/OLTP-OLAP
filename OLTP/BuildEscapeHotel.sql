-- EscapeHotel database
-- Originally Written: July 2023
-----------------------------------------------------------
-- Replace <data_path> with the full path to this file 
-- Ensure it ends with a backslash 
-- E.g., C:\MyDatabases\ See line 17
-----------------------------------------------------------
IF NOT EXISTS(SELECT * FROM sys.databases
	WHERE NAME = N'EscapeHotel')
	CREATE DATABASE EscapeHotel
GO
USE EscapeHotel
--
-- Alter the path so the script can find the CSV files 
--
DECLARE @data_path NVARCHAR(256);
SELECT @data_path = 'C:\Users\Ryan Soltau\Documents\soltauryan OneDrive\OneDrive\Ryan & Chloe\Professional\Ryan DU MS BA\4. INFO 4240 - Data Warehousing\Group Project\New Data\';
--
-- Delete existing tables
--
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE NAME = N'ReservationDetail'
       )
	DROP TABLE ReservationDetail;
--
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE NAME = N'Payment_Table'
       )
	DROP TABLE Payment_Table;
--
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE NAME = N'ReservationHeader'
       )
	DROP TABLE ReservationHeader;
--
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE NAME = N'Room_Data'
       )
	DROP TABLE Room_Data;
--
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE NAME = N'Room_Type'
       )
	DROP TABLE Room_Type;
--
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE NAME = N'Payment_Type'
       )
	DROP TABLE Payment_Type;
--
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE NAME = N'Customer_Table'
       )
	DROP TABLE Customer_Table;
--
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE NAME = N'Employee_Table'
       )
	DROP TABLE Employee_Table;
--
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE NAME = N'Hotel_Data'
       )
	DROP TABLE Hotel_Data;
--
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE NAME = N'Positions'
       )
	DROP TABLE Positions;
--
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE NAME = N'States'
       )
	DROP TABLE States;


-- Create tables
--
CREATE TABLE States
	(StateID			NVARCHAR(2) CONSTRAINT pk_state_id PRIMARY KEY,
	StateName			NVARCHAR(50) CONSTRAINT nn_state_name NOT NULL
	);
--
CREATE TABLE Positions
	(PositionID			INT IDENTITY(1,1) CONSTRAINT pk_position_id PRIMARY KEY,
	PositionName		NVARCHAR(50) CONSTRAINT nn_position_name NOT NULL
	);
--
CREATE TABLE Room_Type
	(RoomTypeID			INT IDENTITY(1,1) CONSTRAINT pk_room_type_id PRIMARY KEY,
	RoomTypeName		NVARCHAR(50) CONSTRAINT nn_room_type_name NOT NULL
	);
--
CREATE TABLE Payment_Type
	(PaymentTypeID		INT IDENTITY(1,1) CONSTRAINT pk_payment_type_id PRIMARY KEY,
	PaymentTypeName		NVARCHAR(50) CONSTRAINT nn_payment_type_name NOT NULL
	);
--
CREATE TABLE Customer_Table
	(CustomerID			INT IDENTITY(1000,1) CONSTRAINT pk_customer_id PRIMARY KEY,
	first_name			NVARCHAR(50) CONSTRAINT nn_customer_first_name NOT NULL,
	middle_name			NVARCHAR(50),
	last_name			NVARCHAR(50) CONSTRAINT nn_customer_last_name NOT NULL,
	Birth_Date			DATE CONSTRAINT nn_customer_birth_date NOT NULL,
	gender				NVARCHAR(15),
	Address				NVARCHAR(50) CONSTRAINT nn_customer_address NOT NULL,
	City				NVARCHAR(50) CONSTRAINT nn_customer_city NOT NULL,
	stateid				NVARCHAR(2) CONSTRAINT fk_customer_table_state_id FOREIGN KEY
						REFERENCES States(StateID),
	ZipCode				NVARCHAR(6) CONSTRAINT nn_zip_code NOT NULL,
	phone_number		NVARCHAR(12) CONSTRAINT nn_phone_number NOT NULL,
	email				NVARCHAR(50)
	);
--
CREATE TABLE Employee_Table
	(Employeeid			INT IDENTITY(10000,1) CONSTRAINT pk_employee_id PRIMARY KEY,
	first_name			NVARCHAR(50) CONSTRAINT nn_employee_first_name NOT NULL,
	middle_name			NVARCHAR(50),
	last_name			NVARCHAR(50) CONSTRAINT nn_employee_last_name NOT NULL,
	Birtdate			DATE CONSTRAINT nn_employee_birth_date NOT NULL,
	gender				NVARCHAR(15),
	Address				NVARCHAR(50) CONSTRAINT nn_employee_address NOT NULL,
	City				NVARCHAR(50) CONSTRAINT nn_employee_city NOT NULL,
	stateid				NVARCHAR(2) CONSTRAINT fk_employee_table_state_id FOREIGN KEY
						REFERENCES States(StateID),
	PhoneNumber			NVARCHAR(12) CONSTRAINT nn_phone_number NOT NULL,
	email				NVARCHAR(50),
	Hired_Date			DATE CONSTRAINT nn_employee_hired_date NOT NULL,
	PositionID			INT CONSTRAINT fk_position_id FOREIGN KEY
						REFERENCES Positions(PositionID)
	);
--
CREATE TABLE Hotel_Data
	(HotelID			INT IDENTITY(100,1) CONSTRAINT pk_hotel_id PRIMARY KEY,
	Hotel_Name			NVARCHAR(50) CONSTRAINT nn_hotel_name NOT NULL,
	Hotel_Address		NVARCHAR(50) CONSTRAINT nn_hotel_address NOT NULL,
	City				NVARCHAR(50) CONSTRAINT nn_hotel_city NOT NULL,
	State				NVARCHAR(2) CONSTRAINT fk_hotel_table_state_id FOREIGN KEY
						REFERENCES States(StateID),
	ZipCode				NVARCHAR(6),
	PhoneNumber			NVARCHAR(12),
	NumRooms			INT
	);
--
CREATE TABLE Room_Data
	(HotelID			INT CONSTRAINT nn_room_data_hotel_id NOT NULL,
	RoomNum				INT CONSTRAINT nn_room_data_room_num_id NOT NULL,
	RoomTypeID			INT CONSTRAINT fk_room_data_room_type FOREIGN KEY
						REFERENCES Room_Type(RoomTypeID),
	Floor				INT CONSTRAINT nn_room_data_floor NOT NULL,
	Occupancy			INT CONSTRAINT nn_room_data_occupancy NOT NULL,
						PRIMARY KEY (HotelID,RoomNum)
	);

ALTER TABLE Room_Data ADD CONSTRAINT FK_Room_Hotel FOREIGN KEY (HotelID)
REFERENCES Hotel_Data(HotelID);
--
CREATE TABLE ReservationHeader
	(ReservationID		INT IDENTITY(100000000,1) CONSTRAINT pk_Reservation_id PRIMARY KEY,
	CustomerID			INT CONSTRAINT fk_reservation_header_customer_id FOREIGN KEY
						REFERENCES Customer_Table(CustomerID),
	ReservationDate		DATE CONSTRAINT nn_reservation_header_reservation_date NOT NULL,
	EmployeeID			INT CONSTRAINT fk_reservation_header_employee_id FOREIGN KEY
						REFERENCES Employee_Table(EmployeeID),
	HotelID				INT CONSTRAINT fk_reservation_header_hotel_id FOREIGN KEY
						REFERENCES Hotel_Data(HotelID),
	CheckIn				DATE CONSTRAINT nn_reservation_header_check_in NOT NULL,
	CheckOut			DATE CONSTRAINT nn_reservation_header_check_out NOT NULL,
	NumGuests			INT,
	IsBusinessTripFlag	INT
	);
--
CREATE TABLE ReservationDetail
	(ReservationDetailID	INT IDENTITY(100000000,1) CONSTRAINT nn_reservation_detail_id NOT NULL,
	ReservationID		INT CONSTRAINT fk_reservation_detail_reservation_id FOREIGN KEY
						REFERENCES ReservationHeader(ReservationID),
	RoomTypeID			INT CONSTRAINT fk_reservation_detail_room_type_id FOREIGN KEY
						REFERENCES Room_Type(RoomTypeID),
	Record_Rate			MONEY CONSTRAINT nn_reservation_detail_record_rate NOT NULL,
	OrderQty			INT CONSTRAINT nn_reservation_detail_order_quantity NOT NULL,
						PRIMARY KEY (ReservationDetailID,ReservationID)
	);
--
CREATE TABLE Payment_Table
	(ReservationID		INT IDENTITY(100000000,1) CONSTRAINT nn_payment_table_id NOT NULL,
	PaymentTypeID		INT CONSTRAINT fk_payment_table_payment_type_id FOREIGN KEY
						REFERENCES Payment_Type(PaymentTypeID),
	PaymentDate			DATE CONSTRAINT nn_payment_table_payment_date NOT NULL,
	PaymentAmount		MONEY CONSTRAINT nn_payment_table_payment_amount NOT NULL
	);

ALTER TABLE Payment_Table ADD CONSTRAINT FK_payment_table_reservation_id FOREIGN KEY (ReservationID)
REFERENCES ReservationHeader(ReservationID);
--
-- Load table
EXECUTE (N'BULK INSERT States FROM ''' + @data_path + N'States.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	FIRSTROW = 2,
	KEEPIDENTITY,
	TABLOCK
	);
');
--
EXECUTE (N'BULK INSERT Positions FROM ''' + @data_path + N'Positions.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	FIRSTROW = 2,
	KEEPIDENTITY,
	TABLOCK
	);
');
--
EXECUTE (N'BULK INSERT Room_Type FROM ''' + @data_path + N'Room_Type.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	FIRSTROW = 2,
	KEEPIDENTITY,
	TABLOCK
	);
');
--
EXECUTE (N'BULK INSERT Payment_Type FROM ''' + @data_path + N'Payment_Type.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	FIRSTROW = 2,
	KEEPIDENTITY,
	TABLOCK
	);
');
--
EXECUTE (N'BULK INSERT Customer_Table FROM ''' + @data_path + N'Customer_Table.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	FIRSTROW = 2,
	KEEPIDENTITY,
	TABLOCK
	);
');
--
EXECUTE (N'BULK INSERT Employee_Table FROM ''' + @data_path + N'Employee_Table.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	FIRSTROW = 2,
	KEEPIDENTITY,
	TABLOCK
	);
');
--
EXECUTE (N'BULK INSERT Hotel_Data FROM ''' + @data_path + N'Hotel_Data.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	FIRSTROW = 2,
	KEEPIDENTITY,
	TABLOCK
	);
');
--
EXECUTE (N'BULK INSERT Room_Data FROM ''' + @data_path + N'Room_Data.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	FIRSTROW = 2,
	KEEPIDENTITY,
	TABLOCK
	);
');
--
EXECUTE (N'BULK INSERT ReservationHeader FROM ''' + @data_path + N'ReservationHeader.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	FIRSTROW = 2,
	KEEPIDENTITY,
	TABLOCK
	);
');
--
EXECUTE (N'BULK INSERT ReservationDetail FROM ''' + @data_path + N'ReservationDetail.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	FIRSTROW = 2,
	KEEPIDENTITY,
	TABLOCK
	);
');
--
EXECUTE (N'BULK INSERT Payment_Table FROM ''' + @data_path + N'Payment_Table.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	FIRSTROW = 2,
	KEEPIDENTITY,
	TABLOCK
	);
');
--
-- List table names and row counts for confirmation
--
GO
SET NOCOUNT ON
SELECT 'Room_Type' AS "Table",		COUNT(*) AS "Rows"	FROM Room_Type			UNION
SELECT 'Positions',					COUNT(*)			FROM Positions			UNION
SELECT 'States',					COUNT(*)			FROM States				UNION
SELECT 'Payment_Type',				COUNT(*)			FROM Payment_Type		UNION
SELECT 'Customer_Table',			COUNT(*)			FROM Customer_Table		UNION
SELECT 'Employee_Table',			COUNT(*)			FROM Employee_Table		UNION
SELECT 'Hotel_Data',				COUNT(*)			FROM Hotel_Data			UNION
SELECT 'Room_Data',					COUNT(*)			FROM Room_Data			UNION
SELECT 'ReservationHeader',			COUNT(*)			FROM ReservationHeader	UNION
SELECT 'ReservationDetail',			COUNT(*)			FROM ReservationDetail	UNION
SELECT 'Payment_Table',				COUNT(*)			FROM Payment_Table
ORDER BY 1;
SET NOCOUNT OFF
GO
