<html>
<head>
<title>Demo</title>
</head>
<body>
<h1>Demo</h1>

<?php
// Variables
$db_host='192.168.56.73';
$db_user='demo';
$db_name='demo';
$db_password='demo';
$db_table='demo';

// Connecting, selecting database
$link = mysql_connect($db_host, $db_user, $db_password)
  or die("<p>Could not connect to database server: $db_host</p><p>" . mysql_error() . "</p>\n");
mysql_select_db($db_name)
  or die("<p>Could not select database: $db_name</p><p>" . mysql_error() . "</p>\n");

// Performing SQL query
$query = "SELECT * FROM $db_table";
$result = mysql_query($query)
  or die('<p>Query failed:</p><p>' . mysql_error() . "</p>\n");

// Printing results in HTML
echo "<table>\n";
while ($line = mysql_fetch_array($result, MYSQL_ASSOC)) {
    echo "\t<tr>\n";
    foreach ($line as $col_value) {
        echo "\t\t<td>$col_value</td>\n";
    }
    echo "\t</tr>\n";
}
echo "</table>\n";

// Free resultset
mysql_free_result($result);

// Closing connection
mysql_close($link);
?>
</body>
