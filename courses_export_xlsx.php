<?php
require 'db.php';

// Check if PhpSpreadsheet is installed
if (!file_exists(__DIR__ . '/vendor/autoload.php')) {
    die('Run "composer install" to install dependencies.');
}

require __DIR__ . '/vendor/autoload.php';

use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Writer\Xlsx;

// Create spreadsheet
$spreadsheet = new Spreadsheet();
$sheet = $spreadsheet->getActiveSheet();

// Add headers
$headers = ['ID', 'Ngành', 'Khối', 'STT', 'Mã', 'Tên', 'Tổng tiết', 'LT', 'TH'];
$sheet->fromArray($headers, NULL, 'A1');

// Fetch courses
$stmt = $pdo->query(
    'SELECT c.*, m.name as major_name, b.name as block_name ' .
    'FROM courses c ' .
    'LEFT JOIN majors m ON c.major_id = m.id ' .
    'LEFT JOIN knowledge_blocks b ON c.block_id = b.id ' .
    'ORDER BY m.name, c.sort_order'
);

// Add data rows
$row = 2;
while ($c = $stmt->fetch(PDO::FETCH_ASSOC)) {
    $sheet->fromArray([
        $c['id'],
        $c['major_name'],
        $c['block_name'],
        $c['sort_order'],
        $c['code'],
        $c['name'],
        $c['total_hours'],
        $c['theory_hours'],
        $c['practice_hours']
    ], NULL, 'A' . $row);
    $row++;
}

// Output file
header('Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
header('Content-Disposition: attachment; filename="courses_export.xlsx"');
$writer = new Xlsx($spreadsheet);
$writer->save('php://output');
exit;