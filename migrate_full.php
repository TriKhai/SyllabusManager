<?php
require 'db.php';
$sql = file_get_contents('tempdata.sql');
try {
    $pdo->exec($sql);
    echo "Full DB migration successful.";
} catch (PDOException $e) {
    echo "Migration failed: " . $e->getMessage();
}
