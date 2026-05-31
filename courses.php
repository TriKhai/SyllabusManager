<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

require 'db.php';

if (!function_exists('h')) {
    function h($text) {
        return htmlspecialchars($text ?? '', ENT_QUOTES, 'UTF-8');
    }
}

$error_msg = '';

try {
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        if (isset($_POST['add'])) {
            $stmt = $pdo->prepare(
                'INSERT INTO courses (major_id, block_id, sort_order, code, name, total_hours, theory_hours, practice_hours) ' .
                'VALUES (?, ?, ?, ?, ?, ?, ?, ?)'
            );
            $blk = !empty($_POST['block_id']) ? $_POST['block_id'] : null;
            
            $sort_order = !empty($_POST['sort_order']) ? (int)$_POST['sort_order'] : 0;
            $total_hours = !empty($_POST['total_hours']) ? (int)$_POST['total_hours'] : 0;
            $theory_hours = !empty($_POST['theory_hours']) ? (int)$_POST['theory_hours'] : 0;
            $practice_hours = !empty($_POST['practice_hours']) ? (int)$_POST['practice_hours'] : 0;

            $stmt->execute([
                $_POST['major_id'], $blk, $sort_order, $_POST['code'],
                $_POST['name'], $total_hours, $theory_hours, $practice_hours
            ]);
            header('Location: courses.php');
            exit;
        }
        if (isset($_POST['delete'])) {
            $stmt = $pdo->prepare('DELETE FROM courses WHERE id = ?');
            $stmt->execute([$_POST['delete']]);
            header('Location: courses.php');
            exit;
        }
    }

    $majors = $pdo->query('SELECT * FROM majors ORDER BY name')->fetchAll(PDO::FETCH_ASSOC);
    $blocks = $pdo->query('SELECT * FROM knowledge_blocks ORDER BY major_id')->fetchAll(PDO::FETCH_ASSOC);
    $courses = $pdo->query(
        'SELECT c.*, m.name as major_name, b.name as block_name FROM courses c ' .
        'LEFT JOIN majors m ON c.major_id = m.id ' .
        'LEFT JOIN knowledge_blocks b ON c.block_id = b.id ' .
        'ORDER BY m.name, c.sort_order, c.code'
    )->fetchAll(PDO::FETCH_ASSOC);

} catch (PDOException $e) {
    $error_msg = "Lỗi Database (Hãy chắc chắn đã chạy lệnh SQL nâng cấp bảng): " . $e->getMessage();
}
?>
<!doctype html>
<html>
<head>
    <meta charset="utf-8">
    <title>Quản lý học phần</title>
    <link rel="stylesheet" href="assets/style.css">
    <link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />
    <style>
        .table { width: 100%; border-collapse: collapse; margin-top: 15px; }
        .table th, .table td { border: 1px solid #ccc; padding: 8px; text-align: left; }
        .table th { background: #f2f2f2; }
        .row-input select, .row-input input { padding: 6px; margin-right: 5px; }
        .small { width: 70px; }
        .btn-action { padding: 4px 8px; font-size: 12px; text-decoration: none; border-radius: 4px; color: #fff; border: none; cursor: pointer; }
        .btn-edit { background: #198754; display: inline-block; margin-right: 5px; }
        .error-box { background: #f8d7da; color: #721c24; padding: 15px; border: 1px solid #f5c6cb; margin-bottom: 20px; border-radius: 4px; }
        .row-input input { width: 150px; }
        .row-input input.small { width: 70px; }
        .row-input input[type="number"] { width: 80px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Học phần</h1>
        <p>
            <a href="majors.php">Ngành</a> | 
            <a href="blocks.php">Khối kiến thức</a> | 
            <a href="index.php">Đề cương chi tiết học phần</a>
        </p>

        <?php if (!empty($error_msg)): ?>
            <div class="error-box"><strong>Thông báo:</strong> <?= h($error_msg) ?></div>
        <?php endif; ?>

        <div class="section">
            <form method="post" class="row-input">
                <select name="major_id" id="majorSelect" required onchange="filterBlocks(this.value)">
                    <option value="">Chọn ngành</option>
                    <?php foreach ($majors as $m): ?>
                        <option value="<?= h($m['id']) ?>"><?= h($m['name']) ?></option>
                    <?php endforeach; ?>
                </select>
                
                <select name="block_id" id="block_select">
                    <option value="">(Chọn khối)</option>
                </select>
                
                <input class="small" name="sort_order" placeholder="STT">
                <input name="code" placeholder="Mã" required>
                <input name="name" placeholder="Tên" required>
                <input class="small" name="total_hours" placeholder="Tổng tiết">
                <input class="small" name="theory_hours" placeholder="LT">
                <input class="small" name="practice_hours" placeholder="TH">
                <button class="button" name="add" type="submit">Thêm</button>
            </form>
        </div>

        <div class="section">
            <h3>Danh sách học phần</h3>
            <p><button class="button" onclick="window.print()">In</button></p>

            <?php if ($courses): ?>
                <table class="table">
                    <thead>
                        <tr>
                            <th>ID</th><th>Ngành</th><th>Khối</th><th>STT</th><th>Mã</th><th>Tên</th>
                            <th>Tổng</th><th>LT</th><th>TH</th><th style="width:160px; text-align:center;">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($courses as $c): ?>
                            <tr>
                                <td><?= h($c['id']) ?></td>
                                <td><?= h($c['major_name']) ?></td>
                                <td><?= h($c['block_name'] ?: '(Chưa phân khối)') ?></td>
                                <td><?= h($c['sort_order']) ?></td>
                                <td><?= h($c['code']) ?></td>
                                <td><?= h($c['name']) ?></td>
                                <td><?= h($c['total_hours']) ?></td>
                                <td><?= h($c['theory_hours']) ?></td>
                                <td><?= h($c['practice_hours']) ?></td>
                                <td style="text-align: center;">
                                    <a href="index.php?course_id=<?= h($c['id']) ?>" class="btn-action btn-edit">Biên soạn</a>
                                    <form method="post" style="display: inline; margin: 0;" onsubmit="return confirm('Xóa học phần này?');">
                                        <button class="button secondary" name="delete" value="<?= h($c['id']) ?>" type="submit">Xóa</button>
                                    </form>
                                </td>
                            </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            <?php else: ?>
                <p>Chưa có học phần.</p>
            <?php endif; ?>
        </div>
    </div>

    <script>
        const allBlocks = <?php echo json_encode($blocks); ?>;
        function filterBlocks(selectedMajorId) {
            const blockSelect = document.getElementById('block_select');
            blockSelect.innerHTML = '<option value="">(Chọn khối)</option>';
            if (!selectedMajorId) return;
            const filteredBlocks = allBlocks.filter(block => block.major_id == selectedMajorId);
            filteredBlocks.forEach(block => {
                const option = document.createElement('option');
                option.value = block.id;
                option.text = block.name;
                blockSelect.appendChild(option);
            });
            // Re-initialize Select2 for the updated select
            $('#block_select').select2({
              placeholder: '(Chọn khối)',
              allowClear: true,
              width: '100%'
            });
        }

        $(document).ready(function() {
          $('#majorSelect').select2({
            placeholder: 'Chọn ngành',
            allowClear: true,
            width: '100%'
          });
          
          $('#block_select').select2({
            placeholder: '(Chọn khối)',
            allowClear: true,
            width: '100%'
          });
        });
    </script>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>   
</body>
</html>