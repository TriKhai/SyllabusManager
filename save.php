<?php
require 'db.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    header('Location: index.php');
    exit;
}

try {
    $pdo->beginTransaction();

    // 2. Thu thập dữ liệu cơ bản của Đề cương (Đã đồng bộ hóa 100% với thuộc tính name trong file index.php)
    $course_id = !empty($_POST['course_id']) ? (int)$_POST['course_id'] : null;
    $code = $_POST['code'] ?? '';
    $name_vn = $_POST['name_vn'] ?? '';
    $name_en = $_POST['name_en'] ?? ''; // Nếu index.php không truyền thì mặc định rỗng
    $type = $_POST['module_type'] ?? 'Bắt buộc'; // Đồng bộ trường <select name="module_type"> từ index.php
    $credits = !empty($_POST['credits']) ? (int)$_POST['credits'] : 0;
    $theory_hours = !empty($_POST['theory_hours']) ? (int)$_POST['theory_hours'] : 0;
    $practical_hours = !empty($_POST['practical_hours']) ? (int)$_POST['practical_hours'] : 0;
    $self_study_hours = !empty($_POST['self_study_hours']) ? (int)$_POST['self_study_hours'] : 0;
    
    $target_programs = $_POST['target_programs'] ?? '';
    $expected_semester = $_POST['expected_semester'] ?? '';
    $expected_year = $_POST['expected_year'] ?? '';
    $department_in_charge = $_POST['department_in_charge'] ?? ''; // Đồng bộ trường name="department_in_charge" từ index.php
    $coordinating_board = $_POST['coordinating_board'] ?? '';
    $faculty_in_charge = $_POST['faculty_in_charge'] ?? '';
    
    $description = $_POST['description'] ?? '';
    $objectives = $_POST['objectives'] ?? '';
    $grading_scale = $_POST['grading_scale'] ?? ''; // Đồng bộ trường name="grading_scale" từ index.php

    // Chèn dữ liệu vào bảng modules
    $stmtModule = $pdo->prepare('
        INSERT INTO modules (
            course_id, code, name_vn, name_en, type, credits, 
            theory_hours, practical_hours, self_study_hours,
            target_programs, expected_semester, expected_year, 
            department_in_charge, coordinating_board, faculty_in_charge,
            description, objectives, grading_scale
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ');
    
    $stmtModule->execute([
        $course_id, $code, $name_vn, $name_en, $type, $credits,
        $theory_hours, $practical_hours, $self_study_hours,
        $target_programs, $expected_semester, $expected_year,
        $department_in_charge, $coordinating_board, $faculty_in_charge,
        $description, $objectives, $grading_scale
    ]);
    
    $module_id = $pdo->lastInsertId();

    // 3. Giải mã dữ liệu các chuỗi JSON từ cấu trúc <input type="hidden"> của frontend index.php
    $clos_arr = json_decode($_POST['clos_json'] ?? '[]', true);
    $assess_arr = json_decode($_POST['assess_json'] ?? '[]', true);
    $activity_arr = json_decode($_POST['self_study_json'] ?? '[]', true); // Đồng bộ name="self_study_json"
    $theory_arr = json_decode($_POST['theory_json'] ?? '[]', true);
    $practical_arr = json_decode($_POST['practical_json'] ?? '[]', true);
    $combined_arr = json_decode($_POST['combined_json'] ?? '[]', true);
    $res_teach_arr = json_decode($_POST['res_teach_json'] ?? '[]', true); // Đồng bộ name="res_teach_json"
    $res_self_arr = json_decode($_POST['res_self_json'] ?? '[]', true);   // Đồng bộ name="res_self_json"

    // --- ĐOẠN CODE ĐÃ CẬP NHẬT TRONG SAVE.PHP ---

$clo_id_map = [];

// 1. LƯU CHUẨN ĐẦU RA (bảng clos) - Chuẩn hóa xóa bỏ khoảng trắng
if (is_array($clos_arr)) {
    $stmtClo = $pdo->prepare('
        INSERT INTO clos (module_id, code, description, domain, bloom_level) 
        VALUES (?, ?, ?, ?, ?)
    ');
    foreach ($clos_arr as $c) {
        // Loại bỏ khoảng trắng và chuyển thành chữ in hoa (Ví dụ: "clo1 " -> "CLO1")
        $cloCode = strtoupper(trim($c['code'] ?? ''));
        if ($cloCode === '') continue;

        $stmtClo->execute([
            $module_id,
            $cloCode,
            $c['description'] ?? '',
            $c['domain'] ?? '',
            $c['bloom'] ?? ''
        ]);
        // Lưu lại ID vừa sinh của CLO này vào mảng map với khóa là 'CLO1', 'CLO2'
        $clo_id_map[$cloCode] = $pdo->lastInsertId();
    }
}

// 2. Hàm tiện ích bóc tách chuỗi liên kết (Ví dụ người dùng nhập "CLO1, CLO2" hoặc "CLO1 CLO3")
$linkClosToEntity = function($pdo, $tableName, $foreignKeyName, $entityId, $cloCodesString) use ($clo_id_map) {
    if (empty(trim($cloCodesString))) return;
    
    // Tách chuỗi bằng dấu phẩy, khoảng trắng hoặc dấu chấm phẩy
    $codes = preg_split('/[\s,;]+/', $cloCodesString);
    
    $stmtLink = $pdo->prepare("INSERT IGNORE INTO {$tableName} ({$foreignKeyName}, clo_id) VALUES (?, ?)");
    foreach ($codes as $code) {
        $code = strtoupper(trim($code)); // Chuẩn hóa về chữ in hoa không khoảng trắng
        if ($code === '') continue;
        
        // Kiểm tra nếu mã CLO này tồn tại trong mảng map thì thực hiện lưu mối quan hệ n-n
        if (isset($clo_id_map[$code])) {
            $stmtLink->execute([$entityId, $clo_id_map[$code]]);
        }
    }
};

    // 5. LƯU PHƯƠNG PHÁP ĐÁNH GIÁ (assessments)
    if (is_array($assess_arr)) {
        $stmtAssess = $pdo->prepare('
            INSERT INTO assessments (module_id, type, component, form, tool, weight, plo_pi) 
            VALUES (?, ?, ?, ?, ?, ?, ?)
        ');
        foreach ($assess_arr as $a) {
            $typeInput = $a['type'] ?? '';
            $dbType = 'Đánh giá thường xuyên';
            if (strpos($typeInput, 'định kỳ') !== false || strpos($typeInput, 'Giữa kỳ') !== false) {
                $dbType = 'Đánh giá định kỳ';
            } elseif (strpos($typeInput, 'cuối kỳ') !== false || strpos($typeInput, 'Cuối kỳ') !== false) {
                $dbType = 'Thi cuối kỳ';
            }

            $weight = !empty($a['weight']) ? (float)$a['weight'] : 0.0;
            $stmtAssess->execute([
                $module_id, $dbType, $a['component'] ?? '', $a['form'] ?? '', $a['tool'] ?? '', $weight, $a['plo_pi'] ?? ''
            ]);
            
            $assess_id = $pdo->lastInsertId();
            $linkClosToEntity($pdo, 'assessment_clos', 'assessment_id', $assess_id, $a['clos'] ?? '');
        }
    }

    // 6. LƯU HOẠT ĐỘNG TỰ HỌC (self_study_activities)
    if (is_array($activity_arr)) {
        $stmtAct = $pdo->prepare('
            INSERT INTO self_study_activities (module_id, activity_name, duration_hours, method, assessment_method, evidence) 
            VALUES (?, ?, ?, ?, ?, ?)
        ');
        foreach ($activity_arr as $act) {
            $hours = !empty($act['hours']) ? (int)$act['hours'] : 0;
            $stmtAct->execute([
                $module_id, $act['name'] ?? '', $hours, $act['method'] ?? '', $act['assess'] ?? '', $act['evidence'] ?? ''
            ]);
            $act_id = $pdo->lastInsertId();
            $linkClosToEntity($pdo, 'self_study_clos', 'self_study_activity_id', $act_id, $act['clos'] ?? '');
        }
    }

    // 7. LƯU TIẾN ĐỘ LÝ THUYẾT (theory_topics)
    if (is_array($theory_arr)) {
        $stmtTheory = $pdo->prepare('
            INSERT INTO theory_topics (module_id, chapter, title, method, class_hours, self_study_hours, textbook_info) 
            VALUES (?, ?, ?, ?, ?, ?, ?)
        ');
        foreach ($theory_arr as $t) {
            $c_hours = !empty($t['hours_class']) ? (int)$t['hours_class'] : 0;
            $s_hours = !empty($t['hours_self']) ? (int)$t['hours_self'] : 0;
            $stmtTheory->execute([
                $module_id, $t['chapter'] ?? '', $t['title'] ?? '', $t['method'] ?? '', $c_hours, $s_hours, $t['book'] ?? ''
            ]);
            $theory_id = $pdo->lastInsertId();
            $linkClosToEntity($pdo, 'theory_topic_clos', 'theory_topic_id', $theory_id, $t['clos'] ?? '');
        }
    }

    // 8. LƯU TIẾN ĐỘ THỰC HÀNH (practical_topics)
    if (is_array($practical_arr)) {
        $stmtPractical = $pdo->prepare('
            INSERT INTO practical_topics (module_id, topic, content, method, lab_hours, facility) 
            VALUES (?, ?, ?, ?, ?, ?)
        ');
        foreach ($practical_arr as $p) {
            $l_hours = !empty($p['hours_lab']) ? (int)$p['hours_lab'] : 0;
            $stmtPractical->execute([
                $module_id, $p['topic'] ?? '', $p['content'] ?? '', $p['method'] ?? $l_hours, $p['facility'] ?? ''
            ]);
            $practical_id = $pdo->lastInsertId();
            $linkClosToEntity($pdo, 'practical_topic_clos', 'practical_topic_id', $practical_id, $p['clos'] ?? '');
        }
    }

    // 9. LƯU TIẾN ĐỘ TÍCH HỢP CHUNG (combined_topics)
    if (is_array($combined_arr)) {
        $stmtCombined = $pdo->prepare('
            INSERT INTO combined_topics (module_id, content, method, theory_hours, practical_hours, selfstudy_hours, facility) 
            VALUES (?, ?, ?, ?, ?, ?, ?)
        ');
        foreach ($combined_arr as $cb) {
            $lt_h = !empty($cb['hours_theory']) ? (int)$cb['hours_theory'] : 0;
            $th_h = !empty($cb['hours_practice']) ? (int)$cb['hours_practice'] : 0;
            $sh_h = !empty($cb['hours_self']) ? (int)$cb['hours_self'] : 0;
            $stmtCombined->execute([
                $module_id, $cb['content'] ?? '', $cb['method'] ?? '', $lt_h, $th_h, $sh_h, $cb['facility'] ?? ''
            ]);
            $combined_id = $pdo->lastInsertId();
            $linkClosToEntity($pdo, 'combined_topic_clos', 'combined_topic_id', $combined_id, $cb['clos'] ?? '');
        }
    }

    // 10. LƯU TÀI LIỆU THAM KHẢO (resources)
    $stmtRes = $pdo->prepare('
        INSERT INTO resources (module_id, resource_type, sort_order, title, editor, publisher, year, identifier) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    ');

    if (is_array($res_teach_arr)) {
        foreach ($res_teach_arr as $idx => $r) {
            $stmtRes->execute([
                $module_id, 'Tài liệu giảng dạy', ($idx + 1),
                $r['title'] ?? '', $r['editor'] ?? '', $r['publisher'] ?? '', $r['year'] ?? '', $r['isbn'] ?? ''
            ]);
        }
    }

    if (is_array($res_self_arr)) {
        foreach ($res_self_arr as $idx => $r) {
            $stmtRes->execute([
                $module_id, 'Tài liệu tự học', ($idx + 1),
                $r['title'] ?? '', $r['editor'] ?? '', $r['publisher'] ?? '', $r['year'] ?? '', $r['isbn'] ?? ''
            ]);
        }
    }

    $pdo->commit();
    
    // Lưu thành công chuyển hướng thẳng tới view.php vừa làm để hiển thị kết quả trực quan
    header("Location: view.php?id=" . $module_id);
    exit;

} catch (Exception $e) {
    $pdo->rollBack();
    die("Lỗi hệ thống trong quá trình lưu trữ đề cương: " . $e->getMessage());
}