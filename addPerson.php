<?php
session_start();
$_SESSION["tab"] = "Add Person";

if ($_SESSION["login"] != 1)
    echo '<h2 txtcolor="red">Authentication Error!!!</h2>';
else {
    include_once('header.php');
    $name = $_POST['name'];
    $phone = $_POST['phone'];
    $gender = $_POST['gender'];
    $dob = $_POST['dob'];
    $blood_group = $_POST['blood_group'];
    $address = $_POST['address'];
    $med_issues = $_POST['med_issues'];

    $sql = "CALL AddPersonProcedure('$name', '$phone', '$gender', '$dob', '$blood_group', '$address', '$med_issues')";
    $result = mysqli_query($con, $sql);

    if ($result) {
        $row = mysqli_fetch_assoc($result);
        $pid = $row['p_id'];

        echo '<h2>' . $name . '</h2><br><br>';
        echo 'Your registration is successful..<br><br>';
        echo 'Personal Id: ' . $pid . '<br><br>';
        echo 'Name: ' . $name . '<br><br>';
        echo 'Phone Number: ' . $phone . '<br><br>';
        echo 'DOB: ' . $dob . '<br><br>';
        echo 'Blood Group: ' . $blood_group . '<br><br>';
        echo 'Gender: ';
        if ($gender === 'm')
            echo 'Male<br><br>';
        if ($gender === 'f')
            echo 'Female<br><br>';
        if ($gender === 'o')
            echo 'Others<br><br>';
        echo 'Address: ' . $address . '<br><br>';

        echo 'Medical Issues: ';
        if ($med_issues === "")
            echo 'None<br><br>';
        else{
            echo  $med_issues.'<br><br>' ;
        }
        echo '<div style ="color:red;">NB: Please keep your Personal Id for future reference!!!';
    } else {
        echo "Error: " . $sql . "<br>" . $con->error;
    }

    include_once('footer.php');
}
?>
