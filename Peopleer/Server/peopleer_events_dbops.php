<?php

function connect_to_db() {
    // Create connection
    $conn = mysqli_connect("localhost","AlbertSlepakAdmin","Al455drank2002","peopleerdatabase");
    
    // Check connection
    if (mysqli_connect_errno())
    {
        error_log(print_r("Failed to connect to MySQL: " . mysqli_connect_error(), true));
    }

    return $conn;
}

function close_db_connection($conn) {
    mysqli_close($conn);
}

function insert_event($connection) {
    $event_title = $_POST['event_title'];
    $latitude    = $_POST['lat'];
    $longitude   = $_POST['long'];

    $sql = "INSERT INTO events (title, latitude, longitude) VALUES ('$event_title', '$latitude', '$longitude')";
    $result = Array();

    if (mysqli_query($connection, $sql)) {
        error_log(print_r("[+] New event successfully added to the database [+]", true));
        $result = Array("status" => "success");
    } else {
        $err = mysqli_error($connection);
        error_log(print_r("[-] Error: " . $sql . "   " . $err, true));
        $result = Array("status" => "error", "error" => $err);
    }

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
    $event_title = $_POST['event_title'];
    
    $sql = "SELECT * FROM events WHERE title='$event_title'";
    $query_result = mysqli_query($connection, $sql);

    $json_result = array();

    if (mysqli_num_rows($query_result) == 1) {
        array_push($json_result, $query_result->fetch_object());
    }

    header("Content-Type: application/json");
    echo json_encode($json_result);
}

?>