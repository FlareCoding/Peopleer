<?php
require 'peopleer_login_dbops.php';

$connection = connect_to_db();

login_user($connection);

close_db_connection($connection);
?>