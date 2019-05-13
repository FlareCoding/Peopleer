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

function login_user($connection) {
    $username = $_POST['username'];
    $password = $_POST['password'];
    $result = Array();
    
    $sql = "SELECT * FROM users WHERE username='$username'";
    $query_result = mysqli_query($connection, $sql);

    if (mysqli_num_rows($query_result) == 1) {
        $row = mysqli_fetch_array($query_result);

        if ($row['password'] == $password) {
            $result = Array("status" => "success");
        } else {
            $result = Array("status" => "error", "error" => "Incorrect password");
        }
    } else {
        $result = Array("status" => "error", "error" => "User not found");
    }

    header("Content-Type: application/json");
    echo json_encode($result);
}

function signup_user($connection) {
    $username = $_POST['username'];
    $email    = $_POST['email'];
    $password = $_POST['password'];
    
    $sql = "INSERT INTO users (username, password) VALUES ('$username', '$password')";
    $result = Array();

    if (mysqli_query($connection, $sql)) {
        $result = Array("status" => "success");
    } else {
        $err = mysqli_error($connection);
        error_log(print_r("[-] Error: " . $sql . "   " . $err, true));
        $result = Array("status" => "error", "error" => $err);
    }

    header("Content-Type: application/json");
    echo json_encode($result);
}

?>