<?php
require 'db.php';
try {
    $stmt = $pdo->prepare("INSERT INTO modules (code, name, type) VALUES ('TEST_ENUM', 'Test Name', 'Bắt buộc')");
    $stmt->execute();
    echo "Insert successful.";
} catch (PDOException $e) {
    echo "Insert failed: " . $e->getMessage();
}
