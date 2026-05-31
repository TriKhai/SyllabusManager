<?php
require 'db.php';

// Output CSV of all courses
header('Content-Type: text/csv; charset=utf-8');
header('Content-Disposition: attachment; filename=courses_export.csv');

$fp = fopen('php://output', 'w');

// Header row
fputcsv($fp, ['ID', 'Ngành', 'Khối', 'STT', 'Mã', 'Tên', 'Tổng tiết', 'LT', 'TH']);

// Fetch courses
$stmt = $pdo->query(
    'SELECT c.*, m.name as major_name, b.name as block_name ' .
    'FROM courses c ' .
    'LEFT JOIN majors m ON c.major_id = m.id ' .
    'LEFT JOIN knowledge_blocks b ON c.block_id = b.id ' .
    'ORDER BY m.name, c.sort_order'
);

// Output rows
while ($c = $stmt->fetch(PDO::FETCH_ASSOC)) {
    fputcsv($fp, [
        $c['id'],
        $c['major_name'],
        $c['block_name'],
        $c['sort_order'],
        $c['code'],
        $c['name'],
        $c['total_hours'],
        $c['theory_hours'],
        $c['practice_hours']
    ]);
}

fclose($fp);
exit;
?>