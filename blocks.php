<?php
require 'db.php';

// Handle POST requests
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_POST['add'])) {
        $stmt = $pdo->prepare('INSERT INTO knowledge_blocks (major_id, name, parent_id) VALUES (?, ?, ?)');
        $pid = $_POST['parent_id'] ?: null;
        $stmt->execute([$_POST['major_id'], $_POST['name'], $pid]);
        header('Location: blocks.php');
        exit;
    }
    if (isset($_POST['delete'])) {
        $stmt = $pdo->prepare('DELETE FROM knowledge_blocks WHERE id = ?');
        $stmt->execute([$_POST['delete']]);
        header('Location: blocks.php');
        exit;
    }
}

// Fetch data
$majors = $pdo->query('SELECT * FROM majors ORDER BY name')->fetchAll(PDO::FETCH_ASSOC);
$blocks = $pdo->query(
    'SELECT b.*, m.name as major_name FROM knowledge_blocks b ' .
    'JOIN majors m ON b.major_id = m.id ' .
    'ORDER BY m.name, b.parent_id, b.name'
)->fetchAll(PDO::FETCH_ASSOC);
?>
<!doctype html>
<html>
<head>
    <meta charset="utf-8">
    <title>Quản lý khối kiến thức</title>
    <link rel="stylesheet" href="assets/style.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />

    <style>
        body { background-color: #f4f6f9; padding-top: 30px; padding-bottom: 50px; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        .syllabus-container { background: #ffffff; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1); padding: 40px; }
        .main-title { font-weight: 700; color: #1a446c; text-transform: uppercase; margin-bottom: 30px; border-bottom: 3px solid #1a446c; padding-bottom: 10px; }
        .section-title { background: #1a446c; color: #ffffff; padding: 10px 15px; font-weight: 600; text-transform: uppercase; margin-top: 35px; margin-bottom: 20px; border-radius: 4px; }
        .sub-section-header { display: flex; justify-content: space-between; align-items: center; margin-top: 25px; margin-bottom: 15px; border-left: 4px solid #3498db; padding-left: 10px; }
        .sub-section-title { font-weight: 600; color: #2c3e50; margin: 0; }
        .table th { background-color: #f8f9fa; color: #333; font-weight: 600; text-align: center; vertical-align: middle; font-size: 14px; }
        .form-helper { font-size: 12px; color: #6c757d; display: block; margin-top: 4px; }
    </style>
</head>
<body>
    <div class="container">
        <p>
            <a href="majors.php">Quản lý ngành</a> |
            <a href="index.php">Về form module</a>
        </p>
        <h2 class="text-center main-title">Khối kiến thức</h2>
        

        <div class="section">
            <form method="psost" class="row-input">
                <select name="major_id" required>
                    <option value="">Chọn ngành</option>
                    <?php foreach ($majors as $m): ?>
                        <option value="<?= h($m['id']) ?>"><?= h($m['name']) ?></option>
                    <?php endforeach; ?>
                </select>
                <input name="name" placeholder="Tên khối" required>
                <select name="parent_id">
                    <option value="">(Không có cha)</option>
                    <?php foreach ($blocks as $b): ?>
                        <?php if (!$b['parent_id']): ?>
                            <option value="<?= h($b['id']) ?>">
                                <?= h($b['major_name']) ?> - <?= h($b['name']) ?>
                            </option>
                        <?php endif; ?>
                    <?php endforeach; ?>
                </select>
                <button class="button" name="add">Thêm</button>
            </form>
        </div>

        <div class="section">
            <div class="section-title">Danh sách khối</div>
            <?php if ($blocks): ?>
                <table class="table">
                    <tr>
                        <th>ID</th>
                        <th>Ngành</th>
                        <th>Tên</th>
                        <th>Thuộc khối</th>
                        <th></th>
                    </tr>
                    <?php foreach ($blocks as $b): ?>
                        <tr>
                            <td><?= h($b['id']) ?></td>
                            <td><?= h($b['major_name']) ?></td>
                            <td><?= h($b['name']) ?></td>
                            <td><?= h($b['parent_id'] ?: '') ?></td>
                            <td>
                                <form method="post" style="margin: 0;">
                                    <button class="button secondary" name="delete" value="<?= h($b['id']) ?>">
                                        Xóa
                                    </button>
                                </form>
                            </td>
                        </tr>
                    <?php endforeach; ?>
                </table>
            <?php else: ?>
                <p>Chưa có khối kiến thức.</p>
            <?php endif; ?>
        </div>
    </div>
</body>
</html>