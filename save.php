<?php
require 'db.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    header('Location: index.php');
    exit;
}

try {
    $pdo->beginTransaction();

    $getFirstId = function(string $sql, array $params = []) use ($pdo) {
        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);
        $value = $stmt->fetchColumn();
        return $value !== false ? (int)$value : null;
    };

    $getFirstEnumValue = function(string $table, string $column) use ($pdo) {
        $stmt = $pdo->query("SHOW COLUMNS FROM {$table} LIKE " . $pdo->quote($column));
        $col = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$col || !preg_match("/^enum\((.*)\)$/", $col['Type'], $matches)) {
            return '';
        }
        $values = str_getcsv($matches[1], ',', "'");
        return $values[0] ?? '';
    };

    $getFacilityId = function($name) use ($pdo) {
        $name = trim((string)$name);
        if ($name === '') {
            return null;
        }

        $stmt = $pdo->prepare('SELECT id FROM facilities WHERE name = ? LIMIT 1');
        $stmt->execute([$name]);
        $id = $stmt->fetchColumn();
        if ($id) {
            return (int)$id;
        }

        $stmt = $pdo->prepare('INSERT INTO facilities (name) VALUES (?)');
        $stmt->execute([$name]);
        return (int)$pdo->lastInsertId();
        
    };
     // Hàm tìm ID nhanh từ bảng danh mục (thêm vào đầu file save.php)
    $lookupId = function($pdo, $table, $name) {
        if (empty($name)) return null;
        $stmt = $pdo->prepare("SELECT id FROM {$table} WHERE name = ? LIMIT 1");
        $stmt->execute([$name]);
        $id = $stmt->fetchColumn();
        return $id ? (int)$id : null;
    };

    // 1. Thu thập dữ liệu cơ bản từ Form
    $course_id = !empty($_POST['course_id']) ? (int)$_POST['course_id'] : null;
    $code = strtoupper(trim($_POST['code'] ?? ''));
    $name = trim($_POST['name'] ?? 'Chưa có tên');

    $typeInput = trim($_POST['module_type'] ?? $_POST['type'] ?? '');

    if (empty($typeInput)) {
        $type = 'Không';
    } elseif (mb_strpos($typeInput, 'Bắt buộc') !== false) {
        $type = 'Bắt buộc';
    } elseif (mb_strpos($typeInput, 'Điều kiện') !== false) {
        $type = 'Điều kiện';
    } elseif (mb_strpos($typeInput, 'Tự chọn') !== false) {
        $type = 'Tự chọn';
    } else {
        $type = 'Không'; 
    }

    $credits = !empty($_POST['credits']) ? (int)$_POST['credits'] : 0;
    $credits_theory = !empty($_POST['credits_theory']) ? (int)$_POST['credits_theory'] : 0;
    $credits_practice = !empty($_POST['credits_practice']) ? (int)$_POST['credits_practice'] : 0;
    $theory_hours = !empty($_POST['theory_hours']) ? (int)$_POST['theory_hours'] : 0;
    $practical_hours = !empty($_POST['practical_hours']) ? (int)$_POST['practical_hours'] : 0;
    $total_hours = !empty($_POST['total_hours']) ? (int)$_POST['total_hours'] : ($theory_hours + $practical_hours);
    $self_study_hours = !empty($_POST['self_study_hours']) ? (int)$_POST['self_study_hours'] : 0;

    $target_programs = $_POST['target_programs'] ?? '';
    $expected_semester = $_POST['expected_semester'] ?? '';
    $expected_year = $_POST['expected_year'] ?? '';
    $prerequisite_modules = $_POST['prerequisite_modules'] ?? '';
    $parallel_modules = $_POST['parallel_modules'] ?? '';
    $previous_modules = $_POST['previous_modules'] ?? '';
    $department_in_charge = $_POST['department_in_charge'] ?? '';
    $coordinating_board = $_POST['coordinating_board'] ?? '';
    $faculty_name = $_POST['faculty_in_charge'] ?? '';
    $faculty_id = $lookupId($pdo, 'faculties_list', $faculty_name);

    $description = $_POST['description'] ?? '';
    $objectives = $_POST['objectives'] ?? '';
    $grading_scale = $_POST['grading_scale'] ?? '';

    if (empty($code) || empty($name)) {
        throw new Exception("Mã học phần và Tên học phần tiếng Việt không được để trống.");
    }


    // [XỬ LÝ ĐỒNG BỘ SANG BẢNG COURSES]
    // Nếu chưa có course_id, kiểm tra xem mã học phần này đã có trong danh mục chưa
    if (empty($course_id)) {
        $stmtCheckCourse = $pdo->prepare("SELECT id FROM courses WHERE code = ?");
        $stmtCheckCourse->execute([$code]);
        $existCourseId = $stmtCheckCourse->fetchColumn();

        if ($existCourseId) {
            $course_id = $existCourseId;
        } else {
            // Nếu hoàn toàn chưa có, tự động chèn mới vào bảng courses để hiển thị bên trang courses.php
            $majorId = $getFirstId('SELECT id FROM majors ORDER BY id ASC LIMIT 1');
            if (!$majorId) {
                throw new Exception("Chua co nganh hoc nao trong he thong nen khong the tao hoc phan nen moi.");
            }
            $blockId = $getFirstId('SELECT id FROM knowledge_blocks WHERE major_id = ? ORDER BY id ASC LIMIT 1', [$majorId]);
            $sortOrder = $getFirstId('SELECT COALESCE(MAX(sort_order), 0) + 1 FROM courses WHERE major_id = ?', [$majorId]) ?? 1;

            $stmtInsCourse = $pdo->prepare("
                INSERT INTO courses (major_id, block_id, sort_order, code, name, total_hours, theory_hours, practical_hours)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            ");
            $stmtInsCourse->execute([$majorId, $blockId, $sortOrder, $code, $name, $total_hours, $theory_hours, $practical_hours]);
            $course_id = $pdo->lastInsertId();
        }
    } else {
        // Nếu đã chọn học phần nền có sẵn, cập nhật lại số giờ và tên theo đề cương cho đồng bộ
        $stmtUpCourse = $pdo->prepare("
            UPDATE courses
            SET code = ?, name = ?, total_hours = ?, theory_hours = ?, practical_hours = ?
            WHERE id = ?
        ");
        $stmtUpCourse->execute([$code, $name, $total_hours, $theory_hours, $practical_hours, $course_id]);
    }

    
   
    $stmtModule = $pdo->prepare('INSERT INTO modules (
        course_id, code, name, type,
        credits, credits_theory, credits_practice,
        total_hours, theory_hours, practical_hours, self_study_hours,
        target_programs, expected_semester, expected_year,
        prerequisite_modules, parallel_modules, previous_modules,
        description, objectives, grading_scale,
        department_in_charge, coordinating_board, faculty_in_charge
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)');

    $stmtModule->execute([
        $course_id,
        $code,
        $name,
        $type,
        $credits,
        $credits_theory,
        $credits_practice,
        $total_hours,
        $theory_hours,
        $practical_hours,
        $self_study_hours,
        $target_programs,
        $expected_semester,
        $expected_year,
        $prerequisite_modules,
        $parallel_modules,
        $previous_modules,
        $description,
        $objectives,
        $grading_scale,
        $department_in_charge,
        $coordinating_board,
        $faculty_in_charge
    ]);

    // Lấy ID vừa sinh ra để tiếp tục chạy cho các luồng xử lý JSON phía sau
    $module_id = $pdo->lastInsertId();
    

    $module_id = $pdo->lastInsertId();

    // 3. Giải mã dữ liệu chuỗi JSON từ Frontend chuyển lên
    $clos_arr = json_decode($_POST['clos_json'] ?? '[]', true);
    $assessments_arr = json_decode($_POST['assessments_json'] ?? '[]', true);
    $activity_arr = json_decode($_POST['self_study_json'] ?? '[]', true);
    $theory_arr = json_decode($_POST['theory_json'] ?? '[]', true);
    $practical_arr = json_decode($_POST['practical_json'] ?? '[]', true);
    $combined_arr = json_decode($_POST['combined_json'] ?? '[]', true);
    $res_teach_arr = json_decode($_POST['res_teach_json'] ?? '[]', true);
    $res_self_arr = json_decode($_POST['res_self_json'] ?? '[]', true);

    $bookTitleFromPost = function($value) use ($pdo) {
        $value = trim((string)$value);
        if ($value === '') {
            return '';
        }

        if (ctype_digit($value)) {
            $stmt = $pdo->prepare('SELECT title FROM books_catalog WHERE id = ?');
            $stmt->execute([(int)$value]);
            $title = $stmt->fetchColumn();
            return $title ?: '';
        }

        return $value;
    };

    if (empty($assessments_arr) && !empty($_POST['assessment_row_ids'])) {
        $assessments_arr = [];
        foreach ($_POST['assessment_row_ids'] as $idx => $rowId) {
            $forms = $_POST['assessment_form_' . $rowId] ?? [];
            $assessments_arr[] = [
                'clos' => $_POST['assessment_clos'][$idx] ?? '',
                'plo_pi' => $_POST['assessment_plo_pi'][$idx] ?? '',
                'form' => is_array($forms) ? implode(', ', $forms) : (string)$forms,
                'tool' => $_POST['assessment_tool'][$idx] ?? '',
                'weight' => $_POST['assessment_weight'][$idx] ?? 0,
            ];
        }
    }

    if (empty($activity_arr) && !empty($_POST['self_study_name'])) {
        $activity_arr = [];
        foreach ($_POST['self_study_name'] as $idx => $name) {
            $activity_arr[] = [
                'name' => $name,
                'clos' => $_POST['self_study_clos'][$idx] ?? '',
                'hours' => $_POST['self_study_duration'][$idx] ?? 0,
                'method' => $_POST['self_study_method'][$idx] ?? '',
                'assess' => $_POST['self_study_assess'][$idx] ?? '',
                'evidence' => $_POST['self_study_evidence'][$idx] ?? '',
            ];
        }
    }

    if (empty($theory_arr) && !empty($_POST['theory_chapter'])) {
        $theory_arr = [];
        foreach ($_POST['theory_chapter'] as $idx => $chapter) {
            $theory_arr[] = [
                'chapter' => $chapter,
                'title' => $_POST['theory_title'][$idx] ?? '',
                'method' => $_POST['theory_method'][$idx] ?? '',
                'hours_class' => $_POST['theory_class_hours'][$idx] ?? 0,
                'hours_self' => $_POST['theory_self_hours'][$idx] ?? 0,
                'clos' => $_POST['theory_clos'][$idx] ?? '',
                'book' => $_POST['theory_book'][$idx] ?? '',
            ];
        }
    }

    if (empty($practical_arr) && !empty($_POST['practical_topic'])) {
        $practical_arr = [];
        foreach ($_POST['practical_topic'] as $idx => $topic) {
            $practical_arr[] = [
                'topic' => $topic,
                'content' => $_POST['practical_content'][$idx] ?? '',
                'method' => $_POST['practical_method'][$idx] ?? '',
                'hours_lab' => $_POST['practical_hours'][$idx] ?? 0,
                'clos' => $_POST['practical_clos'][$idx] ?? '',
                'facility' => $_POST['practical_facility'][$idx] ?? '',
            ];
        }
    }

    if (empty($combined_arr) && !empty($_POST['combined_content'])) {
        $combined_arr = [];
        foreach ($_POST['combined_content'] as $idx => $content) {
            $combined_arr[] = [
                'stt' => $idx + 1,
                'content' => $content,
                'method' => $_POST['combined_method'][$idx] ?? '',
                'hours_theory' => $_POST['combined_theory_hours'][$idx] ?? 0,
                'hours_practice' => $_POST['combined_practical_hours'][$idx] ?? 0,
                'hours_self' => $_POST['combined_self_hours'][$idx] ?? 0,
                'clos' => $_POST['combined_clos'][$idx] ?? '',
                'facility' => $_POST['combined_facility'][$idx] ?? '',
            ];
        }
    }

    $buildResourcesFromPost = function(string $prefix) use ($bookTitleFromPost) {
        $resources = [];
        foreach ($_POST[$prefix . '_book_id'] ?? [] as $idx => $bookValue) {
            $resources[] = [
                'title' => $bookTitleFromPost($bookValue),
                'editor' => $_POST[$prefix . '_editor'][$idx] ?? '',
                'publisher' => $_POST[$prefix . '_publisher'][$idx] ?? '',
                'year' => $_POST[$prefix . '_year'][$idx] ?? '',
                'isbn' => $_POST[$prefix . '_isbn'][$idx] ?? '',
            ];
        }
        return $resources;
    };

    if (empty($res_teach_arr) && !empty($_POST['res_teach_book_id'])) {
        $res_teach_arr = $buildResourcesFromPost('res_teach');
    }

    if (empty($res_self_arr) && !empty($_POST['res_self_book_id'])) {
        $res_self_arr = $buildResourcesFromPost('res_self');
    }

    $clo_id_map = [];

    // 4. LƯU CHUẨN ĐẦU RA (clos)
    if (is_array($clos_arr)) {
        $stmtClo = $pdo->prepare('
            INSERT INTO clos (module_id, code, description, domain, bloom_level)
            VALUES (?, ?, ?, ?, ?)
        ');
        foreach ($clos_arr as $c) {
            $cloCode = strtoupper(trim($c['code'] ?? ''));
            if ($cloCode === '') continue;

            $stmtClo->execute([
                $module_id,
                $cloCode,
                $c['description'] ?? '',
                $c['domain'] ?? '',
                $c['bloom'] ?? ''
            ]);
            $clo_id_map[$cloCode] = $pdo->lastInsertId();
        }
    }

    // Hàm tiện ích phân tách chuỗi map liên kết CLOs n-n
    $linkClosToEntity = function($pdo, $tableName, $foreignKeyName, $entityId, $cloCodesString) use ($clo_id_map) {
        if (empty(trim($cloCodesString))) return;
        $codes = preg_split('/[\s,;]+/', $cloCodesString);
        $stmtLink = $pdo->prepare("INSERT IGNORE INTO {$tableName} ({$foreignKeyName}, clo_id) VALUES (?, ?)");
        foreach ($codes as $code) {
            $code = strtoupper(trim($code));
            if ($code === '') continue;
            if (isset($clo_id_map[$code])) {
                $stmtLink->execute([$entityId, $clo_id_map[$code]]);
            }
        }
    };

    // 5. LƯU PHƯƠNG PHÁP ĐÁNH GIÁ (assessments)
    if (is_array($assessments_arr)) {
        $assessmentType = $getFirstEnumValue('assessments', 'type');
        foreach ($assessments_arr as $a) {
            if (
                trim(($a['clos'] ?? '') . ($a['plo_pi'] ?? '') . ($a['form'] ?? '') . ($a['tool'] ?? '')) === ''
                && empty($a['weight'])
            ) {
                continue;
            }

            $stmtInsertAssess = $pdo->prepare("
                INSERT INTO assessments (module_id, type, component, plo_pi, form, tool, weight)
                VALUES (?, ?, ?, ?, ?, ?, ?)
            ");
            $stmtInsertAssess->execute([
                $module_id,
                $assessmentType,
                $a['component'] ?? '',
                $a['plo_pi'] ?? '',
                $a['form'] ?? '',
                $a['tool'] ?? '',
                !empty($a['weight']) ? (int)$a['weight'] : 0
            ]);
            $assessment_id = $pdo->lastInsertId();
            if (!empty($a['clos'])) {
                $linkClosToEntity($pdo, 'assessment_clos', 'assessment_id', $assessment_id, $a['clos']);
            }
        }
    }

    // 6. LƯU HOẠT ĐỘNG TỰ HỌC (self_study_activities)
    if (is_array($activity_arr)) {
        $stmtAct = $pdo->prepare('
            INSERT INTO self_study_activities (module_id, activity_name, duration_hours, method, assessment_method, evidence)
            VALUES (?, ?, ?, ?, ?, ?)
        ');
        foreach ($activity_arr as $act) {
            if (trim(($act['name'] ?? '') . ($act['clos'] ?? '') . ($act['method'] ?? '') . ($act['assess'] ?? '') . ($act['evidence'] ?? '')) === '' && empty($act['hours'])) {
                continue;
            }

            $hours = !empty($act['hours']) ? (int)$act['hours'] : 0;
            $stmtAct->execute([
                $module_id,
                $act['name'] ?? '',
                $hours,
                $act['method'] ?? '',
                $act['assess'] ?? '',
                $act['evidence'] ?? ''
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
            if (trim(($t['title'] ?? '') . ($t['clos'] ?? '') . ($t['book'] ?? '')) === '' && empty($t['hours_class']) && empty($t['hours_self'])) {
                continue;
            }

            $c_hours = !empty($t['hours_class']) ? (int)$t['hours_class'] : 0;
            $s_hours = !empty($t['hours_self']) ? (int)$t['hours_self'] : 0;
            $stmtTheory->execute([
                $module_id, $t['chapter'] ?? '', $t['title'] ?? '', $t['method'] ?? '', $c_hours, $s_hours, $t['book'] ?? ''
            ]);
            $theory_id = $pdo->lastInsertId();
            $linkClosToEntity($pdo, 'theory_topic_clos', 'theory_topic_id', $theory_id, $t['clos'] ?? '');
        }
    }

    // 8. LƯU TIẾN ĐỘ THỰC HÀNH (practical_topics) - ĐÃ ĐƯỢC FIX LỖI 6 THAM SỐ
    if (is_array($practical_arr)) {
        $stmtPractical = $pdo->prepare('
            INSERT INTO practical_topics (module_id, topic, content, method, lab_hours, facility_id)
            VALUES (?, ?, ?, ?, ?, ?)
        ');
        foreach ($practical_arr as $p) {
            if (trim(($p['topic'] ?? '') . ($p['content'] ?? '') . ($p['method'] ?? '') . ($p['clos'] ?? '') . ($p['facility'] ?? '')) === '' && empty($p['hours_lab'])) {
                continue;
            }

            $l_hours = !empty($p['hours_lab']) ? (int)$p['hours_lab'] : 0;
            $facilityId = $getFacilityId($p['facility'] ?? '');
            $stmtPractical->execute([
                $module_id,
                $p['topic'] ?? '',
                $p['content'] ?? '',
                $p['method'] ?? '',
                $l_hours,
                $facilityId
            ]);
            $practical_id = $pdo->lastInsertId();
            $linkClosToEntity($pdo, 'practical_topic_clos', 'practical_topic_id', $practical_id, $p['clos'] ?? '');
        }
    }

    // 9. LƯU TIẾN ĐỘ TÍCH HỢP CHUNG (combined_topics)
    if (is_array($combined_arr)) {
        $stmtCombined = $pdo->prepare('
            INSERT INTO combined_topics (module_id, sort_order, content, method, theory_hours, practical_hours, self_study_hours, facility_id)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ');
        foreach ($combined_arr as $idx => $cb) {
            if (
                trim(($cb['content'] ?? '') . ($cb['method'] ?? '') . ($cb['clos'] ?? '') . ($cb['facility'] ?? '')) === ''
                && empty($cb['hours_theory'])
                && empty($cb['hours_practice'])
                && empty($cb['hours_self'])
            ) {
                continue;
            }

            $lt_h = !empty($cb['hours_theory']) ? (int)$cb['hours_theory'] : 0;
            $th_h = !empty($cb['hours_practice']) ? (int)$cb['hours_practice'] : 0;
            $sh_h = !empty($cb['hours_self']) ? (int)$cb['hours_self'] : 0;
            $facilityId = $getFacilityId($cb['facility'] ?? '');
            $stmtCombined->execute([
                $module_id, $cb['stt'] ?? ($idx + 1), $cb['content'] ?? '', $cb['method'] ?? '', $lt_h, $th_h, $sh_h, $facilityId
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
            $title = trim($r['title'] ?? '');
            if ($title === '' || str_starts_with($title, '-- Chọn')) continue;
            
            $stmtBook = $pdo->prepare("SELECT id FROM books_catalog WHERE title = ? LIMIT 1");
            $stmtBook->execute([$title]);
            $book_id = $stmtBook->fetchColumn() ?: null;

            $stmtRes->execute([
                $module_id, 'Tài liệu giảng dạy', ($idx + 1),
                $title, $r['editor'] ?? '', $r['publisher'] ?? '', $r['year'] ?? '', $book_id // Lưu ID vào identifier
            ]);
        }
    }

    if (is_array($res_self_arr)) {
        foreach ($res_self_arr as $idx => $r) {
            $title = trim($r['title'] ?? '');
            if ($title === '' || str_starts_with($title, '-- Chọn')) continue;

            // Phải tra cứu ID cho sách tự học
            $stmtBook = $pdo->prepare("SELECT id FROM books_catalog WHERE title = ? LIMIT 1");
            $stmtBook->execute([$title]);
            $book_id = $stmtBook->fetchColumn() ?: null;

            $stmtRes->execute([
                $module_id, 'Tài liệu tự học', ($idx + 1),
                $title, $r['editor'] ?? '', $r['publisher'] ?? '', $r['year'] ?? '', $book_id
            ]);
        }
    }

    $pdo->commit();
    header("Location: view.php?id=" . $module_id);
    exit;

} catch (Exception $e) {
    $pdo->rollBack();
    die("Lỗi hệ thống trong quá trình lưu dữ liệu: " . $e->getMessage());
}
