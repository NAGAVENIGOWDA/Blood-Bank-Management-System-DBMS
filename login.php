<?php      
session_start();//keeps track of user info
include('connection.php'); 

// checks whether the submit is set or not
if(isset($_POST['submit'])){

    // prevents little sql injection possibilities(not prevented fully)
    //a security vulnerability that can occur when user input is directly inserted into SQL queries
    $username = stripcslashes($_POST['user']);  //to remove backslashes from the user input. Backslashes are often used in SQL injection attempts to escape characters and manipulate SQL queries.
    $username = mysqli_real_escape_string($con, $username);  //to escape special characters in the "user" input.
    $password = stripcslashes($_POST['pass']);  
    $password = mysqli_real_escape_string($con, $password);  

    // checks whether the the username or password is empty or not 
    // if so a login error is set and returned to the homepage
    if($username === '' or $password === ''){
        $_SESSION["login_error"] = 'username or password cannot be empty';
        header('Location: index.php');
    }

    else{
        // query processed to check whether the user is present or not
        $sql = "select * from user where username = '$username' and password = '$password'";  
        $result = $con->query($sql);

        // user is present
        if($result->num_rows > 0){  
            $row = $result->fetch_assoc();// method to fetch data from a MySQL database
            $_SESSION["login"] = 1;
            $_SESSION["username"] = $row["username"];
            header('Location: Home.php');
        }  

        // user is not present
        else{
            $_SESSION["login"] = 0;
            $_SESSION["login_error"] = 'invalid login credentials';
            header('Location: index.php');
        }
    }
} 

// submit is not set.directed to homepage
else
    header('Location: index.php');
?>