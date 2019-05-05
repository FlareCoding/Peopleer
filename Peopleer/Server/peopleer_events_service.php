<?php
require 'peopleer_events_dbops.php';

$service_request = $_POST['servreq'];

$connection = connect_to_db();

if ($service_request == "get_all_events") {
    retrieve_all_events($connection);
} else if ($service_request == "insert_event") {
    insert_event($connection);
} else if ($service_request == "get_specific_event") {
    get_specific_event($connection);
}

close_db_connection($connection);

?>