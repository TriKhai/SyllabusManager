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
</head>
<body>
    <div class="container">
        <h1>Khối kiến thức</h1>
        <p>
            <a href="majors.php">Quản lý ngành</a> | 
            <a href="index.php">Về form module</a>
        </p>

        <div class="section">
            <form method="post" class="row-input">
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
            <h3>Danh sách khối</h3>
            <?php if ($blocks): ?>
                <table class="table">
                    <tr>
                        <th>ID</th>
                        <th>Ngành</th>
                        <th>Tên</th>
                        <th>Cha</th>
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