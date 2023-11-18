<?php      
$host = "localhost";  
$user = "root";  
$password = "12345678";  
$db_name = "blood_bank";  

$con = mysqli_connect($host, $user, $password, $db_name);  
if(mysqli_connect_errno()) {  
	die("Failed to connect with MySQL: ". mysqli_connect_error());  //to stop the execution of a script and display a specified message to the user before terminating the script. 
}  
?>  