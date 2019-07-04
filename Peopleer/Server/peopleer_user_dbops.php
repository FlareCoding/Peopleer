<?php

function connect_to_db() {
    // Create connection
    $conn = mysqli_connect("127.0.0.1","AlbertSlepakAdmin","Al455drank2002","peopleerdatabase");
    
    // Check connection
    if (mysqli_connect_errno())
    {
        error_log(print_r("Failed to connect to MySQL: " . mysqli_connect_error(), true));
    }

    return $conn;
}

function close_db_connection($connection) {
    mysqli_close($connection);
}

function perform_query($connection, $query) {
    $result = Array();

    if (mysqli_query($connection, $query)) {
        $result = Array("status" => "success");
    } else {
        $err = mysqli_error($connection);
        error_log(print_r("[-] Error: " . $query . "   " . $err, true));
        $result = Array("status" => "error", "error" => $err);
    }

    return $result;
}

function get_single_db_row($connection, $query) {
    $result = Array();

    $query_result = mysqli_query($connection, $query);
    if (mysqli_num_rows($query_result) == 1) {
        $result = mysqli_fetch_array($query_result);
    }

    return $result;
}

function get_listof_db_rows($connection, $query) {
    $resultArray = array();

    if ($result = mysqli_query($connection, $sql)) {
        // Loop through each row in the result set
        while($row = $result->fetch_object()) {
            array_push($resultArray, $row);
        }
    }

    return $resultArray;
}

function get_user_info($connection) {
    $username = $_POST['username'];

    $sql = "SELECT * FROM users WHERE username = '$username'";
    $query_result = mysqli_query($connection, $sql);

    $result = array();

    if (mysqli_num_rows($query_result) == 1) {
        array_push($result, $query_result->fetch_object());
    }

    header("Content-Type: application/json");
    echo json_encode($result);
}

?>