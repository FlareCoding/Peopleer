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

?>