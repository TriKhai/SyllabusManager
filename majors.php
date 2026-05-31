<?php
require 'db.php';

// Handle POST requests
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_POST['add'])) {
        $stmt = $pdo->prepare('INSERT INTO majors (name) VALUES (?)');
        $stmt->execute([$_POST['name']]);
        header('Location: majors.php');
        exit;
    }
    if (isset($_POST['delete'])) {
        $stmt = $pdo->prepare('DELETE FROM majors WHERE id = ?');
        $stmt->execute([$_POST['delete']]);
        header('Location: majors.php');
        exit;
    }
}

// Fetch majors
$majors = $pdo->query('SELECT * FROM majors ORDER BY name')->fetchAll(PDO::FETCH_ASSOC);
?>
<!doctype html>
<html>
<head>
    <meta charset="utf-8">
    <title>Quản lý ngành đào tạo</title>
    <link rel="stylesheet" href="assets/style.css">
</head>
<body>
    <div class="container">
        <h1>Ngành đào tạo</h1>
        <p><a href="index.php">Về form module</a></p>

        <div class="section">
            <form method="post" class="row-input">
                <input name="name" placeholder="Tên ngành" required>
                <button class="button" name="add">Thêm</button>
            </form>
        </div>

        <div class="section">
            <h3>Danh sách ngành</h3>
            <?php if ($majors): ?>
                <table class="table">
                    <tr>
                        <th>ID</th>
                        <th>Tên</th>
                        <th></th>
                    </tr>
                    <?php foreach ($majors as $m): ?>
                        <tr>
                            <td><?= h($m['id']) ?></td>
                            <td><?= h($m['name']) ?></td>
                            <td>
                                <form method="post" style="margin: 0;">
                                    <button class="button secondary" name="delete" value="<?= h($m['id']) ?>">
                                        Xóa
                                    </button>
                                </form>
                            </td>
                        </tr>
                    <?php endforeach; ?>
                </table>
            <?php else: ?>
                <p>Chưa có ngành nào.</p>
            <?php endif; ?>
        </div>
    </div>
</body>
</html>