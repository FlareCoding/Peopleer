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

function insert_event($connection) {
    $event_title = $_POST['event_title'];
    $latitude    = $_POST['lat'];
    $longitude   = $_POST['long'];
    $username    = $_POST['username'];

    $sql = "INSERT INTO events (title, latitude, longitude, owner) VALUES ('$event_title', '$latitude', '$longitude', '$username')";
    $result = perform_query($connection, $sql);

    header("Content-Type: application/json");
    echo json_encode($result);
}

function retrieve_all_events($connection) {
    // This SQL statement selects ALL from the table 'Locations'
    $sql = "SELECT * FROM events";
    
    // Check if there are results
    if ($result = mysqli_query($connection, $sql))
    {
        // If so, then create a results array and a temporary one
        // to hold the data
        $resultArray = array();
    
        // Loop through each row in the result set
        while($row = $result->fetch_object())
        {
            // Add each row into our results array
            array_push($resultArray, $row);
        }
    
        // Finally, encode the array to JSON and output the results
        echo json_encode($resultArray);
    }
}

function get_specific_event($connection) {
    $latitude   = $_POST['lat'];
    $longitude  = $_POST['long'];
    $username   = $_POST['username'];
    
    $sql = "SELECT * FROM events WHERE (latitude, longitude) = ($latitude, $longitude)";
    $query_result = mysqli_query($connection, $sql);

    $json_result = array();

    if (mysqli_num_rows($query_result) == 1) {
        array_push($json_result, $query_result->fetch_object());
    }

    header("Content-Type: application/json");
    echo json_encode($json_result);
}

function delete_event($connection) {
    $latitude = $_POST['lat'];
    $longitude = $_POST['long'];

    $sql = "DELETE FROM events WHERE (latitude, longitude) = ($latitude, $longitude)";
    $result = perform_query($connection, $sql);

    header("Content-Type: application/json");
    echo json_encode($result);
}

function modify_event($connection) {
    $latitude    = $_POST['lat'];
    $longitude   = $_POST['long'];
    $event_title = $_POST['event_title'];

    $sql = "UPDATE events SET title='$event_title' WHERE (latitude, longitude) = ($latitude, $longitude)";
    $result = perform_query($connection, $sql);

    header("Content-Type: application/json");
    echo json_encode($result);
}

?>
