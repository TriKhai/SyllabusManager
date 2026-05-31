<?php
require 'db.php';
?>
<!doctype html>
<html>
<head>
    <meta charset="utf-8">
    <title>Danh sách học phần</title>
    <link rel="stylesheet" href="assets/style.css">
    <style>
        .btn-link { text-decoration: none; color: #0066cc; cursor: pointer; }
        .btn-link:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Danh sách học phần</h1>
        <p><a href="index.php">Tạo học phần mới</a></p>

        <?php
        $stmt = $pdo->query(
            'SELECT id, code, credits, created_at, name_vn FROM modules ORDER BY created_at DESC'
        );
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if (!$rows) {
            echo '<p>Chưa có học phần nào.</p>';
        } else {
            echo '<table class="table">';
            echo '<tr>';
            echo '<th>STT</th>';
            echo '<th style="width: 20%;">Mã học phần</th>';
            echo '<th style="width: 50%;">Tên học phần</th>';
            echo '<th style="width: 10%;">Tín chỉ</th>';
            echo '<th style="width: 15%;">Ngày tạo</th>';
            echo '<th style="width: 5%;">Thao tác</th>';
            echo '</tr>';

            $stt = 0;
            foreach ($rows as $r) {
                $stt++;
                echo '<tr>';
                echo '<td>' . $stt . '</td>';
                echo '<td>' . h($r['code']) . '</td>';
                echo '<td>' . h($r['name_vn']) . '</td>';
                echo '<td>' . h($r['credits']) . '</td>';
                echo '<td>' . h($r['created_at']) . '</td>';
                echo '<td><a href="view.php?id=' . h($r['id']) . '&edit=1" class="btn-link">Chi tiết</a></td>';
                echo '</tr>';
            }
            echo '</table>';
        }
        ?>
    </div>
</body>
</html>