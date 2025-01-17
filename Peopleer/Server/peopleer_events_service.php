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
} else if ($service_request == "delete_event") {
    delete_event($connection);
} else if ($service_request == "modify_event") {
    modify_event($connection);
} else if ($service_request == "join_event") {
    join_event($connection);
} else if ($service_request == "leave_event") {
    leave_event($connection);
} else if ($service_request == "is_user_in_event") {
    is_user_in_event($connection);
} else if ($service_request == "get_events_based_on_owner") {
    get_events_based_on_owner($connection);
} else if ($service_request == "get_events_based_on_title") {
    get_events_based_on_title($connection);
} else if ($service_request == "get_events_based_on_participant_name") {
    get_events_based_on_participant_name($connection);
}

close_db_connection($connection);

?>