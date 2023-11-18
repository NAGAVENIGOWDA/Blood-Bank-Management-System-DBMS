

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `blood_bank`
--
CREATE DATABASE IF NOT EXISTS `blood_bank` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `blood_bank`;

-- --------------------------------------------------------

--
-- Table structure for table `donation`
--

CREATE TABLE `donation` (
  `p_id` int(10) NOT NULL,
  `d_date` date NOT NULL,
  `d_time` time NOT NULL,
  `d_quantity` int(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;



DELIMITER //
CREATE TRIGGER DonationBanTrigger
AFTER INSERT ON donation
FOR EACH ROW
BEGIN
    DECLARE donation_date DATE;
    SET donation_date = NEW.d_date;

    UPDATE person
    SET donation_ban = DATE_ADD(donation_date, INTERVAL 15 DAY)
    WHERE p_id = NEW.p_id;
END;
//
DELIMITER ;


-- --------------------------------------------------------

--
-- Table structure for table `person`
--

CREATE TABLE `person` (
  `p_id` int(10) NOT NULL,
  `p_name` varchar(25) NOT NULL,
  `p_phone` char(10) NOT NULL,
  `p_dob` date NOT NULL,
  `p_address` varchar(100) DEFAULT NULL,
  `p_gender` char(1) NOT NULL,
  `p_blood_group` varchar(3) NOT NULL,
  `p_med_issues` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


ALTER TABLE person
ADD COLUMN donation_ban DATE;

-- --------------------------------------------------------

--
-- Table structure for table `receive`
--

CREATE TABLE `receive` (
  `p_id` int(10) NOT NULL,
  `r_date` date NOT NULL,
  `r_time` time NOT NULL,
  `r_quantity` int(1) NOT NULL,
  `r_hospital` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `stock`
--

CREATE TABLE `stock` (
  `s_blood_group` varchar(3) NOT NULL,
  `s_quantity` int(5) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `stock`
--

INSERT INTO `stock` (`s_blood_group`, `s_quantity`) VALUES
('A+', 0),
('A-', 0),
('AB+', 0),
('AB-', 0),
('B+', 0),
('B-', 0),
('O+', 0),
('O-', 0);

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

CREATE TABLE `user` (
  `username` varchar(10) NOT NULL,
  `password` varchar(16) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `user`
--

INSERT INTO `user` (`username`, `password`) VALUES
('SuperAdmin', 'superadmin'),
('test_user', 'testuser');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `donation`
--
ALTER TABLE `donation`
  ADD PRIMARY KEY (`p_id`,`d_date`,`d_time`);

--
-- Indexes for table `person`
--
ALTER TABLE `person`
  ADD PRIMARY KEY (`p_id`);

--
-- Indexes for table `receive`
--
ALTER TABLE `receive`
  ADD PRIMARY KEY (`p_id`,`r_date`,`r_time`);

--
-- Indexes for table `stock`
--
ALTER TABLE `stock`
  ADD PRIMARY KEY (`s_blood_group`);

--
-- Indexes for table `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`username`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `person`
--
ALTER TABLE `person`
  MODIFY `p_id` int(10) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `donation`
--
ALTER TABLE `donation`
  ADD CONSTRAINT `Donation_ibfk_1` FOREIGN KEY (`p_id`) REFERENCES `person` (`p_id`);

--
-- Constraints for table `receive`
--
ALTER TABLE `receive`
  ADD CONSTRAINT `Receive_ibfk_1` FOREIGN KEY (`p_id`) REFERENCES `person` (`p_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

------------------------------------------------------------------------------------------------

DELIMITER //
CREATE PROCEDURE AddPersonProcedure(
    IN p_name VARCHAR(25),
    IN p_phone CHAR(10),
    IN p_gender CHAR(1),
    IN p_dob DATE,
    IN p_blood_group VARCHAR(3),
    IN p_address VARCHAR(100),
    IN p_med_issues VARCHAR(100)
)
BEGIN
    -- Insert a new record
    INSERT INTO Person (p_name, p_phone, p_gender, p_dob, p_blood_group, p_address, p_med_issues)
    VALUES (p_name, p_phone, p_gender, p_dob, p_blood_group, p_address, p_med_issues);

    -- Retrieve the newly inserted p_id
    SELECT LAST_INSERT_ID() AS p_id;
END;
//
DELIMITER ;





------------------------------------------------------------------------------------------------


DELIMITER //
CREATE PROCEDURE AddUserProcedure(
    IN p_super_pwd VARCHAR(16),
    IN p_usr_name VARCHAR(10),
    IN p_usr_pwd VARCHAR(16)
)
BEGIN
    DECLARE super_pwd_valid INT;
    DECLARE username_available INT;

    -- Check if the Super Admin password is valid
    SELECT COUNT(*) INTO super_pwd_valid FROM User WHERE username = 'SuperAdmin' AND password = p_super_pwd;

    IF super_pwd_valid = 1 THEN
        -- Check if the username is available
        SELECT COUNT(*) INTO username_available FROM User WHERE username = p_usr_name;

        IF username_available = 0 THEN
            -- Insert the new user record
            INSERT INTO User (username, password) VALUES (p_usr_name, p_usr_pwd);
        ELSE
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Username is not available.';
        END IF;
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid Super Admin Password.';
    END IF;
END;
//
DELIMITER ;

--------------------------------------------------------------------------------------------

DELIMITER //
CREATE FUNCTION GetDonationHistory(p_sdate DATE, p_edate DATE)
RETURNS TABLE (
    p_id INT,
    p_name VARCHAR(255),
    p_phone CHAR(10),
    p_blood_group VARCHAR(3),
    d_date DATE,
    d_time TIME,
    d_quantity INT
)
READS SQL DATA
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE cur CURSOR FOR
        SELECT
            p.p_id,
            p.p_name,
            p.p_phone,
            p.p_blood_group,
            d.d_date,
            d.d_time,
            d.d_quantity
        FROM Person p
        JOIN Donation d ON p.p_id = d.p_id
        WHERE d.d_date >= p_sdate AND d.d_date <= p_edate;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    
    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO p_id, p_name, p_phone, p_blood_group, d_date, d_time, d_quantity;
        IF done = 1 THEN
            LEAVE read_loop;
        END IF;
        INSERT INTO result_table VALUES (p_id, p_name, p_phone, p_blood_group, d_date, d_time, d_quantity);
    END LOOP;

    CLOSE cur;
END;
//
DELIMITER ;


-------------------------------------------------------------------------------------------
DELIMITER //

CREATE PROCEDURE GetReceiveHistory(IN p_sdate DATE, IN p_edate DATE)
BEGIN
    SELECT
        p.p_id,
        p.p_name,
        p.p_phone,
        p.p_blood_group,
        r.r_date,
        r.r_time,
        r.r_quantity
    FROM Person p
    JOIN Receive r ON p.p_id = r.p_id
    WHERE r.r_date >= p_sdate AND r.r_date <= p_edate;
END;
//

DELIMITER ;

