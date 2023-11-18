<?php
session_start();
$_SESSION["tab"] = "New Donation";

if($_SESSION["login"] != 1) {
    echo '<h2 txtcolor="red">Authentication Error!!!</h2>';
} else {
    include_once('header.php'); 
    $pid = $_POST['pid'];  
    $units = $_POST['units'];

    // Check if the person is allowed to donate
    $check_ban_sql = "SELECT donation_ban FROM person WHERE p_id = '$pid'";
    $result = $con->query($check_ban_sql);

    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();
        $donation_ban_date = $row['donation_ban'];

        // Get the current date and time
        $current_date = date('Y-m-d');
        $current_time = date('H:i:s');

        // Combine the current date and time to compare with the donation ban date and time
        $current_datetime = $current_date . ' ' . $current_time;

        // Check if the current datetime is less than or equal to the donation ban datetime
        if ($current_datetime <= $donation_ban_date) {
            echo 'You are not allowed to donate blood until ' . $donation_ban_date;
            include_once('footer.php');
            exit; // Exit the script
        }
    }

    date_default_timezone_set("Asia/Calcutta"); 
    $date = date('Y-m-d'); // Use 'Y' for 4-digit year, not 'y'
    $time = date('H:i:s'); // Use 'H' for 24-hour format, not 'h'

    $sql_1 = "INSERT INTO donation (p_id, d_date, d_time, d_quantity) VALUES ('$pid', '$date', '$time', '$units')";  
    $sql_2 = "UPDATE stock SET s_quantity = s_quantity + '$units' WHERE s_blood_group = (SELECT p_blood_group FROM person WHERE p_id = '$pid')";

    if ($con->query($sql_1) === TRUE && $con->query($sql_2) === TRUE) {
        // Success message
        echo 'Your donation is successful';
    } else {
        // Error message
        echo "Error: " . $sql . "<br>" . $con->error;
    }
    include_once('footer.php');
}
?>
