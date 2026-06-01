<?php
require 'db.php';
try {
    $pdo->exec("
        ALTER TABLE modules
        ADD COLUMN credits_theory INT NOT NULL DEFAULT 0 AFTER credits,
        ADD COLUMN credits_practice INT NOT NULL DEFAULT 0 AFTER credits_theory,
        ADD COLUMN total_hours INT NOT NULL DEFAULT 0 AFTER credits_practice,
        ADD COLUMN prerequisite_modules TEXT NULL AFTER expected_year,
        ADD COLUMN parallel_modules TEXT NULL AFTER prerequisite_modules,
        ADD COLUMN previous_modules TEXT NULL AFTER parallel_modules;
    ");
    echo "Table altered successfully.";
} catch (PDOException $e) {
    if (strpos($e->getMessage(), 'Duplicate column name') !== false) {
        echo "Columns already exist.";
    } else {
        echo "Alter failed: " . $e->getMessage();
    }
}
