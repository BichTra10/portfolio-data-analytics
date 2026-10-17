-- Tạo database xom_sql_homework
CREATE DATABASE xom_sql_homework;
GO

-- Sử dụng database xom_sql_homework
USE xom_sql_homework;
GO

-- Tạo bảng Customers (Khách hàng)
CREATE TABLE Customers (
    CustomerID INT,
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    Email NVARCHAR(100),
    Phone NVARCHAR(15),
    Address NVARCHAR(255)
);

-- Tạo bảng Products (Sản phẩm)
CREATE TABLE Products (
    ProductID INT,
    ProductName NVARCHAR(100),
    Price DECIMAL(10, 2),
    Description NVARCHAR(255)
);

-- Tạo bảng Orders (Đơn hàng)
CREATE TABLE Orders (
    OrderID INT,
    CustomerID INT,
    OrderDate DATE,
    TotalAmount DECIMAL(10, 2)
);

-- Tạo bảng OrderDetails (Chi tiết đơn hàng)
CREATE TABLE OrderDetails (
    OrderDetailID INT,
    OrderID INT,
    ProductID INT,
    Quantity INT,
    Price DECIMAL(10, 2)
);

-- Thêm dữ liệu mẫu vào bảng Customers
INSERT INTO Customers (CustomerID, FirstName, LastName, Email, Phone, Address)
VALUES
(1, 'Nguyen', 'Van A', 'nguyenvana@gmail.com', '0912345678', N'123 Đường ABC, Quận 1, Hà Nội'),
(2, 'Tran', 'Thi B', 'tranthib@gmail.com', '0912345679', N'456 Đường XYZ, Quận 2, TP.HCM'),
(3, 'Le', 'Van C', 'levanc@gmail.com', '0912345680', N'789 Đường DEF, Quận 3, Đà Nẵng'),
(4, 'Pham', 'Thi D', 'phamthid@gmail.com', '0912345681', N'321 Đường GHI, Quận 4, Hải Phòng'),
(5, 'Hoang', 'Van E', 'hoangvane@gmail.com', '0912345682', N'654 Đường JKL, Quận 5, Cần Thơ'),
(6, 'Vu', 'Thi F', 'vuthif@gmail.com', '0912345683', N'987 Đường MNO, Quận 6, Nha Trang'),
(7, 'Do', 'Van G', 'dovang@gmail.com', '0912345684', N'147 Đường PQR, Quận 7, Vũng Tàu'),
(8, 'Bui', 'Thi H', 'buithih@gmail.com', '0912345685', N'258 Đường STU, Quận 8, Huế'),
(9, 'Dang', 'Van I', 'dangvani@gmail.com', '0912345686', N'369 Đường VWX, Quận 9, Bình Dương'),
(10, 'Ngo', 'Thi K', 'ngothik@gmail.com', '0912345687', N'159 Đường YZ, Quận 10, Đồng Nai'),
(11, 'Mai', 'Van L', 'maivanl@gmail.com', '0912345688', N'753 Đường QWE, Quận 11, Quảng Ninh');

-- Thêm dữ liệu mẫu vào bảng Products
INSERT INTO Products (ProductID, ProductName, Price, Description)
VALUES
(101, 'Laptop Dell XPS 13', 25000000, N'Laptop siêu mỏng, hiệu năng cao'),
(102, 'iPhone 14 Pro Max', 30000000, N'Điện thoại thông minh flagship của Apple'),
(103, 'Samsung Galaxy S22 Ultra', 28000000, N'Điện thoại thông minh flagship của Samsung'),
(104, 'MacBook Pro 16-inch', 45000000, N'Laptop chuyên nghiệp cho công việc sáng tạo'),
(105, 'iPad Pro 12.9-inch', 22000000, N'Máy tính bảng cao cấp của Apple'),
(106, 'Sony WH-1000XM4', 7000000, N'Tai nghe chống ồn cao cấp'),
(107, 'LG OLED C1 55-inch', 35000000, N'TV OLED cao cấp'),
(108, 'Canon EOS R5', 90000000, N'Máy ảnh mirrorless chuyên nghiệp'),
(109, 'Dyson V11 Absolute', 18000000, N'Máy hút bụi không dây cao cấp'),
(110, 'Bose QuietComfort 45', 6000000, N'Tai nghe chống ồn'),
(111, 'Apple Watch Series 8', 12000000, N'Đồng hồ thông minh của Apple');

-- Thêm dữ liệu mẫu vào bảng Orders
INSERT INTO Orders (OrderID, CustomerID, OrderDate, TotalAmount)
VALUES
(1, 1, '2023-09-01', 25000000),
(2, 2, '2023-09-02', 30000000),
(3, 3, '2023-09-03', 28000000),
(4, 4, '2023-09-04', 45000000),
(5, 5, '2023-09-05', 22000000),
(6, 6, '2023-09-06', 7000000),
(7, 7, '2023-09-07', 35000000),
(8, 8, '2023-09-08', 90000000),
(9, 9, '2023-09-09', 18000000),
(10, 10, '2023-09-10', 6000000),
(11, 11, '2023-09-11', 12000000);

-- Thêm dữ liệu mẫu vào bảng OrderDetails
INSERT INTO OrderDetails (OrderDetailID, OrderID, ProductID, Quantity, Price)
VALUES
(1, 1, 101, 1, 25000000),
(2, 2, 102, 1, 30000000),
(3, 3, 103, 1, 28000000),
(4, 4, 104, 1, 45000000),
(5, 5, 105, 1, 22000000),
(6, 6, 106, 1, 7000000),
(7, 7, 107, 1, 35000000),
(8, 8, 108, 1, 90000000),
(9, 9, 109, 1, 18000000),
(10, 10, 110, 1, 6000000),
(11, 11, 111, 1, 12000000);

-------------------------------------------------------------------------------
-- ĐỀ BÀI THỰC HÀNH
-- Lưu ý: Đề bài có thể chứa câu hỏi vượt kiến thức chưa được học trên lớp
-- nhằm đề cao tính tự giác và nâng cao khả năng tự đọc, tự học, tự tìm hiểu!
-------------------------------------------------------------------------------

-- Bài tập 1: Truy vấn cơ bản
-- 1. Truy vấn tất cả khách hàng trong bảng `Customers`.
SELECT 
	*
FROM Customers;

-- 2. Truy vấn tất cả sản phẩm trong bảng `Products`.
SELECT 
	*
FROM Products;

-- 3. Truy vấn tất cả đơn hàng trong bảng `Orders`.
SELECT 
	*
FROM Orders;

-- 4. Truy vấn tất cả chi tiết đơn hàng trong bảng `OrderDetails`.
SELECT 
	*
FROM OrderDetails;


-- Bài tập 2: Sử dụng các hàm và toán tử
-- 1. Truy vấn tên và email của các khách hàng có địa chỉ ở Quận 1. 
SELECT 
	FirstName,
	LastName,
	Email
FROM Customers 
WHERE Address like N'%Quận 1%';

-- 2. Truy vấn các sản phẩm có giá lớn hơn 20,000,000.
SELECT 
	ProductName,
	Price
FROM Products 
WHERE price > 20000000;

-- 3. Truy vấn các đơn hàng có tổng số tiền lớn hơn 30,000,000.
SELECT 
	OrderID,
	TotalAmount
FROM Orders 
WHERE TotalAmount > 30000000;


-- Bài tập 3: Sử dụng hàm TOP và DISTINCT
-- 1. Truy vấn 5 khách hàng đầu tiên trong bảng `Customers`.
SELECT TOP 5 *
FROM Customers;

-- 2. Truy vấn các ngày đặt hàng duy nhất từ bảng `Orders`.
SELECT DISTINCT OrderDate
FROM Orders;

-- 3. Truy vấn 3 sản phẩm có giá cao nhất.
SELECT TOP 3 Price
FROM Products
ORDER BY Price DESC;

-- Bài tập 4: Truy vấn phức tạp hơn
-- 1. Truy vấn tất cả đơn hàng của khách hàng có tên 'Nguyen Van A'. 
SELECT 
	o.OrderID,
	o.OrderDate,
	o.TotalAmount
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID 
WHERE c.FirstName = N'Nguyen' AND c.LastName = N'Van A';

-- 2. Truy vấn số lượng đơn hàng của mỗi khách hàng.
SELECT 
	c.FirstName,
	c.LastName,
	COUNT(o.OrderID) as NumberOfOrders
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID 
GROUP BY c.FirstName, c.LastName;

-- 3. Truy vấn tổng số tiền mà mỗi khách hàng đã chi tiêu.
SELECT
	c.FirstName,
	c.LastName,
	SUM(o.TotalAmount) as Totalspent
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID 
GROUP BY c.FirstName, c.LastName;
