<?php
require 'peopleer_login_dbops.php';

$service_request = $_POST['servreq'];

$connection = connect_to_db();

if ($service_request == "login") {
    login_user($connection);
} else if ($service_request == "signup") {
    signup_user($connection);
}

close_db_connection($connection);
?>