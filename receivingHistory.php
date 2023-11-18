<?php
session_start();
$_SESSION["tab"] = "Receiving History";

if ($_SESSION["login"] != 1) {
    echo '<h2>Authentication Error!!!</h2>';
} else {
    include_once('header.php');
    $sdate = $_POST['sdate'];
    $edate = $_POST['edate'];

    // Call the stored function to retrieve receive history records
    $sql = "CALL GetReceiveHistory('$sdate', '$edate')";
    $result = $con->query($sql);

    echo "<h2>Receiving History</h2><br>";

    if ($result->num_rows > 0) {
        echo "<table>
        <tr>
        <th>Personal ID</th>
        <th>Name</th>
        <th>Phone</th>
        <th>Blood Group</th>
        <th>Date</th>
        <th>Time</th>
        <th>Units of Blood</th>
        </tr>";
        while($row = $result->fetch_assoc()) {
            echo "
            <tr>
            <td>" . $row["p_id"]. "</td>
            <td>" . $row["p_name"]."</td>
            <td>" .$row["p_phone"] ."</td>
            <td>" . $row["p_blood_group"]. "</td>
            <td>" . $row["r_date"]. "</td>
            <td>" . $row["r_time"]. "</td>
            <td>" . $row["r_quantity"]. "</td>
            
            </tr>";
        }
        
        echo "</table> <br><br>";
    } else {
        echo "No record found in the specified interval";
    }

    include_once('footer.php');
}
?>
