<?php
require 'db.php';
$stmt = $pdo->query("SHOW COLUMNS FROM modules LIKE 'type'");
$col = $stmt->fetch(PDO::FETCH_ASSOC);
print_r($col);
