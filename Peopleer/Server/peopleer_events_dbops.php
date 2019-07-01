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

function verify_user($connection, $username, $password) {
    $sql = "SELECT * FROM users WHERE username='$username'";
    $query_result = mysqli_query($connection, $sql);

    if (mysqli_num_rows($query_result) == 1) {
        $row = mysqli_fetch_array($query_result);
        if ($row['password'] == $password) {
            return true;
        }
    }
    return false;
}

function insert_event($connection) {
    $event_title = $_POST['event_title'];
    $latitude    = $_POST['lat'];
    $longitude   = $_POST['long'];
    $username    = $_POST['username'];
    $address     = $_POST['address'];
    $description = $_POST['description'];
    $start_time  = $_POST['start_time'];
    $end_time    = $_POST['end_time'];
    $max_participants = $_POST['max_participants'];

    $sql = "INSERT INTO events (title, latitude, longitude, owner, address, description, start_time, end_time, max_participants, current_participants) VALUES ('$event_title', '$latitude', '$longitude', '$username', '$address', '$description', '$start_time', '$end_time', '$max_participants', '0')";
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

    if ($result['status'] != 'error') {
        $sql = "DELETE FROM event_participants WHERE latitude='$latitude' AND longitude='$longitude'";
        perform_query($connection, $sql);
    }

    header("Content-Type: application/json");
    echo json_encode($result);
}

function modify_event($connection) {
    $latitude    = $_POST['lat'];
    $longitude   = $_POST['long'];
    $event_title = $_POST['event_title'];
    $username    = $_POST['username'];
    $address     = $_POST['address'];
    $description = $_POST['description'];
    $start_time  = $_POST['start_time'];
    $end_time    = $_POST['end_time'];
    $max_participants = $_POST['max_participants'];

    $sql = "UPDATE events SET title='$event_title', address='$address', description='$description', start_time='$start_time', end_time='$end_time', max_participants='$max_participants' WHERE (latitude, longitude) = ($latitude, $longitude) AND owner = '$username'";
    $result = perform_query($connection, $sql);

    header("Content-Type: application/json");
    echo json_encode($result);
}

function join_event($connection) {
    $latitude    = $_POST['lat'];
    $longitude   = $_POST['long'];
    $username    = $_POST['user'];
    
    $sql = "SELECT * FROM events WHERE (latitude, longitude) = ($latitude, $longitude)";
    $event_db_obj = get_single_db_row($connection, $sql);

    $current_participants = $event_db_obj['current_participants'];
    $max_participants = $event_db_obj['max_participants'];

    if ($current_participants < $max_participants) {
        $sql = "INSERT INTO event_participants (latitude, longitude, user) VALUES ('$latitude', '$longitude', '$username')";
        $result = perform_query($connection, $sql);
        
        if ($result['status'] != 'error') {
            // If user successfully joined the event, increment event's participant count by 1
            $sql = "UPDATE events SET current_participants = current_participants + 1 WHERE (latitude, longitude) = ($latitude, $longitude)";
            $result = perform_query($connection, $sql);
        }
    } else {
        $result = Array("status" => "error", "error" => "Participant limit exceeded");
    }

    header("Content-Type: application/json");
    echo json_encode($result);
}

function is_user_in_event($connection) {
    $latitude    = $_POST['lat'];
    $longitude   = $_POST['long'];
    $username    = $_POST['user'];

    $result = Array("result" => "false");

    $sql = "SELECT * FROM event_participants WHERE (latitude, longitude, user) = ('$latitude', '$longitude', '$username')";
    $query_result = mysqli_query($connection, $sql);

    if (mysqli_num_rows($query_result) == 1) {
        $result = Array("result" => "true");
    }

    header("Content-Type: application/json");
    echo json_encode($result);
}

function get_events_based_on_owner($connection) {
    $username = $_POST['username'];

    $sql = "SELECT * FROM events WHERE owner = '$username'";
    $query_result = mysqli_query($connection, $sql);

    $json_result = array();

    if ($result = mysqli_query($connection, $sql))
    {
        $json_result = array();
    
        while($row = $result->fetch_object())
        {
            array_push($json_result, $row);
        }
    }

    header("Content-Type: application/json");
    echo json_encode($json_result);
}

?>
