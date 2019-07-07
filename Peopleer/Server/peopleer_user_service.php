<?php
require 'peopleer_user_dbops.php';

$service_request = $_POST['servreq'];

$connection = connect_to_db();

if ($service_request == "get_user_info") {
    get_user_info($connection);
} else if ($service_request == "get_event_participants") {
    get_event_participants($connection);
}

close_db_connection($connection);

?>