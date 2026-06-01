<?php
require 'db.php';
$stmt = $pdo->query("SHOW COLUMNS FROM assessments LIKE 'type'");
$col = $stmt->fetch(PDO::FETCH_ASSOC);
preg_match("/^enum\((.*)\)$/", $col['Type'], $matches);
$values = str_getcsv($matches[1], ',', "'");
echo "Type column: " . $col['Type'] . "\n";
echo "Parsed first value: " . ($values[0] ?? 'EMPTY') . "\n";
