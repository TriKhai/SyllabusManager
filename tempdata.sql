SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `books_catalog`;
DROP TABLE IF EXISTS `resources`;
DROP TABLE IF EXISTS `combined_topic_clos`;
DROP TABLE IF EXISTS `combined_topics`;
DROP TABLE IF EXISTS `practical_topic_clos`;
DROP TABLE IF EXISTS `practical_topics`;
DROP TABLE IF EXISTS `theory_topic_clos`;
DROP TABLE IF EXISTS `theory_topics`;
DROP TABLE IF EXISTS `self_study_clos`;
DROP TABLE IF EXISTS `self_study_activities`;
DROP TABLE IF EXISTS `assessment_clos`;
DROP TABLE IF EXISTS `assessments`;
DROP TABLE IF EXISTS `clos`;
DROP TABLE IF EXISTS `module_relationships`;
DROP TABLE IF EXISTS `modules`;
DROP TABLE IF EXISTS `facilities`;
DROP TABLE IF EXISTS `courses`;
DROP TABLE IF EXISTS `knowledge_blocks`;
DROP TABLE IF EXISTS `majors`;
DROP TABLE IF EXISTS `assessment_forms`;
DROP TABLE IF EXISTS `faculties_list`;
DROP TABLE IF EXISTS `departments_list`;

CREATE TABLE `assessment_forms` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `majors` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `knowledge_blocks` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `major_id` INT NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `parent_id` INT NULL,
  FOREIGN KEY (`major_id`) REFERENCES `majors`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`parent_id`) REFERENCES `knowledge_blocks`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `courses` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `major_id` INT NOT NULL,
  `block_id` INT NULL DEFAULT NULL,
  `code` VARCHAR(50) NOT NULL UNIQUE,
  `name` VARCHAR(255) NOT NULL,
  `total_hours` INT DEFAULT 0,
  `theory_hours` INT DEFAULT 0,
  `practical_hours` INT DEFAULT 0,
  `sort_order` INT DEFAULT 0,
  FOREIGN KEY (`major_id`) REFERENCES `majors`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`block_id`) REFERENCES `knowledge_blocks`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `facilities` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `modules` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `course_id` INT NULL,
  `code` VARCHAR(50) NOT NULL UNIQUE,
  `name` VARCHAR(255) NOT NULL,
  `type` ENUM('Không', 'Bắt buộc', 'Điều kiện', 'Tự chọn') NOT NULL DEFAULT 'Không',
  `credits` INT NOT NULL DEFAULT 0,
  `credits_theory` INT NOT NULL DEFAULT 0,
  `credits_practice` INT NOT NULL DEFAULT 0,
  `total_hours` INT NOT NULL DEFAULT 0,
  `theory_hours` INT NOT NULL DEFAULT 0,
  `practical_hours` INT NOT NULL DEFAULT 0,
  `self_study_hours` INT NOT NULL DEFAULT 0,
  `target_programs` TEXT NULL,
  `expected_semester` VARCHAR(50) NULL,
  `expected_year` VARCHAR(50) NULL,
  `prerequisite_modules` TEXT NULL,
  `parallel_modules` TEXT NULL,
  `previous_modules` TEXT NULL,
  `department_in_charge` VARCHAR(255) NULL,
  `coordinating_board` VARCHAR(255) NULL,
  `faculty_in_charge` VARCHAR(255) NULL,
  `description` TEXT NULL,
  `objectives` TEXT NULL,
  `grading_scale` TEXT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `faculty_id` INT NULL,
  FOREIGN KEY (`faculty_id`) REFERENCES `faculties_list`(`id`) ON DELETE SET NULL,
  FOREIGN KEY (`course_id`) REFERENCES `courses`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `module_relationships` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `module_id` INT NOT NULL,
  `related_course_id` INT NOT NULL,
  `relation_type` ENUM('Tiên quyết', 'Song hành', 'Học trước') NOT NULL,
  FOREIGN KEY (`module_id`) REFERENCES `modules`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`related_course_id`) REFERENCES `courses`(`id`) ON DELETE CASCADE,
  UNIQUE KEY `unique_relation` (`module_id`, `related_course_id`, `relation_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `module_departments` (
  `module_id` INT NOT NULL,
  `department_id` INT NOT NULL,
  PRIMARY KEY (`module_id`, `department_id`),
  FOREIGN KEY (`module_id`) REFERENCES `modules`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`department_id`) REFERENCES `departments_list`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `clos` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `module_id` INT NOT NULL,
  `code` VARCHAR(50) NOT NULL,
  `description` TEXT NOT NULL,
  `domain` VARCHAR(255) NULL,
  `bloom_level` VARCHAR(255) NULL,
  FOREIGN KEY (`module_id`) REFERENCES `modules`(`id`) ON DELETE CASCADE,
  UNIQUE KEY `unique_module_clo` (`module_id`, `code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `assessments` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `module_id` INT NOT NULL,
  `type` ENUM('Đánh giá thường xuyên', 'Đánh giá định kỳ', 'Thi cuối kỳ') NOT NULL,
  `component` VARCHAR(255) NULL,
  `form` VARCHAR(255) NOT NULL,
  `tool` VARCHAR(255) NULL,
  `weight` DECIMAL(5,2) NOT NULL DEFAULT 0.00,
  `plo_pi` VARCHAR(255) NULL,
  `assessment_form_id` INT NULL,
  FOREIGN KEY (`assessment_form_id`) REFERENCES `assessment_forms`(`id`) ON DELETE SET NULL,
  FOREIGN KEY (`module_id`) REFERENCES `modules`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `assessment_clos` (
  `assessment_id` INT NOT NULL,
  `clo_id` INT NOT NULL,
  PRIMARY KEY (`assessment_id`, `clo_id`),
  FOREIGN KEY (`assessment_id`) REFERENCES `assessments`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`clo_id`) REFERENCES `clos`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `self_study_activities` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `module_id` INT NOT NULL,
  `activity_name` TEXT NOT NULL,
  `duration_hours` INT DEFAULT 0,
  `method` TEXT NULL,
  `assessment_method` TEXT NULL,
  `evidence` TEXT NULL,
  FOREIGN KEY (`module_id`) REFERENCES `modules`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `self_study_clos` (
  `self_study_activity_id` INT NOT NULL,
  `clo_id` INT NOT NULL,
  PRIMARY KEY (`self_study_activity_id`, `clo_id`),
  FOREIGN KEY (`self_study_activity_id`) REFERENCES `self_study_activities`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`clo_id`) REFERENCES `clos`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `theory_topics` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `module_id` INT NOT NULL,
  `chapter` VARCHAR(100) NULL,
  `title` TEXT NOT NULL,
  `method` VARCHAR(255) NULL,
  `class_hours` INT DEFAULT 0,
  `self_study_hours` INT DEFAULT 0,
  `textbook_info` VARCHAR(255) NULL,
  FOREIGN KEY (`module_id`) REFERENCES `modules`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `theory_topic_clos` (
  `theory_topic_id` INT NOT NULL,
  `clo_id` INT NOT NULL,
  PRIMARY KEY (`theory_topic_id`, `clo_id`),
  FOREIGN KEY (`theory_topic_id`) REFERENCES `theory_topics`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`clo_id`) REFERENCES `clos`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `practical_topics` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `module_id` INT NOT NULL,
  `topic` VARCHAR(255) NULL,
  `content` TEXT NOT NULL,
  `method` VARCHAR(255) NULL,
  `lab_hours` INT DEFAULT 0,
  `facility_id` INT NULL,
  FOREIGN KEY (`module_id`) REFERENCES `modules`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`facility_id`) REFERENCES `facilities`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `practical_topic_clos` (
  `practical_topic_id` INT NOT NULL,
  `clo_id` INT NOT NULL,
  PRIMARY KEY (`practical_topic_id`, `clo_id`),
  FOREIGN KEY (`practical_topic_id`) REFERENCES `practical_topics`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`clo_id`) REFERENCES `clos`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `combined_topics` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `module_id` INT NOT NULL,
  `sort_order` INT DEFAULT 1,
  `content` TEXT NOT NULL,
  `method` VARCHAR(255) NULL,
  `theory_hours` INT DEFAULT 0,
  `practical_hours` INT DEFAULT 0,
  `self_study_hours` INT DEFAULT 0,
  `facility_id` INT NULL,
  FOREIGN KEY (`module_id`) REFERENCES `modules`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`facility_id`) REFERENCES `facilities`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `combined_topic_clos` (
  `combined_topic_id` INT NOT NULL,
  `clo_id` INT NOT NULL,
  PRIMARY KEY (`combined_topic_id`, `clo_id`),
  FOREIGN KEY (`combined_topic_id`) REFERENCES `combined_topics`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`clo_id`) REFERENCES `clos`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `resources` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `module_id` INT NOT NULL,
  `resource_type` ENUM('Tài liệu giảng dạy', 'Tài liệu tự học') NOT NULL,
  `sort_order` INT DEFAULT 1,
  `title` VARCHAR(255) NOT NULL,
  `editor` VARCHAR(255) NULL,
  `publisher` VARCHAR(255) NULL,
  `year` VARCHAR(50) NULL,
  `identifier` INT NULL,
  `book_id` INT NULL,
  FOREIGN KEY (`book_id`) REFERENCES `books_catalog`(`id`) ON DELETE SET NULL,
  FOREIGN KEY (`module_id`) REFERENCES `modules`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `books_catalog` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `title` VARCHAR(255) NOT NULL,
  `editor` VARCHAR(255) NULL,
  `publisher` VARCHAR(255) NULL,
  `year` VARCHAR(50) NULL,
  `identifier` INT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `faculties_list` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `departments_list` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Master data
INSERT INTO `majors` (`id`, `name`) VALUES
(1, 'Y khoa'),
(2, 'Dược học'),
(3, 'Điều dưỡng');

INSERT INTO `knowledge_blocks` (`id`, `major_id`, `name`, `parent_id`) VALUES
(1, 1, 'Kiến thức giáo dục đại cương', NULL),
(2, 1, 'Kiến thức cơ sở ngành Y', NULL),
(3, 1, 'Kiến thức chuyên ngành Y khoa', NULL),
(4, 2, 'Kiến thức cơ sở ngành Dược', NULL),
(5, 2, 'Kiến thức chuyên ngành Dược', NULL),
(6, 3, 'Kiến thức cơ sở ngành Điều dưỡng', NULL),
(7, 3, 'Kiến thức chuyên ngành Điều dưỡng', NULL);

INSERT INTO `facilities` (`id`, `name`) VALUES
(1, 'Phòng thực hành Giải phẫu'),
(2, 'Phòng mô phỏng lâm sàng'),
(3, 'Phòng máy tính y học'),
(4, 'Phòng thực hành Sinh lý'),
(5, 'Phòng thực hành Dược'),
(6, 'Phòng kỹ năng Điều dưỡng');

INSERT INTO `assessment_forms` (`id`, `name`) VALUES
(1, 'Chuyên cần'),
(2, 'Kiểm tra thường xuyên'),
(3, 'Bài tập nhóm'),
(4, 'OSCE/OSPE'),
(5, 'Thi viết'),
(6, 'Thi trắc nghiệm');

INSERT INTO `faculties_list` (`id`, `name`) VALUES
(1, 'Khoa Y'),
(2, 'Khoa Dược'),
(3, 'Khoa Điều dưỡng'),
(4, 'Khoa Khoa học cơ bản');

INSERT INTO `departments_list` (`id`, `name`) VALUES
(1, 'Bộ môn Giải phẫu'),
(2, 'Bộ môn Sinh lý'),
(3, 'Bộ môn Bệnh học'),
(4, 'Bộ môn Nội'),
(5, 'Bộ môn Hóa dược'),
(6, 'Bộ môn Dược lý'),
(7, 'Bộ môn Quản lý Dược'),
(8, 'Bộ môn Điều dưỡng cơ bản'),
(9, 'Bộ môn Điều dưỡng nội'),
(10, 'Trung tâm Công nghệ thông tin');

INSERT INTO `courses` (`id`, `major_id`, `block_id`, `code`, `name`, `total_hours`, `theory_hours`, `practical_hours`, `sort_order`) VALUES
(1, 1, 2, 'TEST001', 'Giải phẫu học đại cương', 45, 30, 15, 1),
(2, 1, 2, 'TEST002', 'Sinh lý học đại cương', 45, 30, 15, 2),
(3, 1, 3, 'TEST003', 'Bệnh học cơ sở', 45, 35, 10, 3),
(4, 1, 3, 'TEST004', 'Kỹ năng khám lâm sàng', 60, 25, 35, 4),
(5, 2, 4, 'TEST005', 'Hóa dược cơ bản', 45, 30, 15, 5),
(6, 2, 5, 'TEST006', 'Dược lý lâm sàng', 60, 45, 15, 6),
(7, 2, 5, 'TEST007', 'Quản lý cung ứng thuốc', 30, 20, 10, 7),
(8, 3, 6, 'TEST008', 'Điều dưỡng cơ bản', 60, 25, 35, 8),
(9, 3, 7, 'TEST009', 'Chăm sóc người bệnh nội khoa', 60, 30, 30, 9),
(10, 1, 1, 'TEST010', 'Tin học ứng dụng y học', 45, 20, 25, 10);

INSERT INTO `modules` (`id`, `course_id`, `code`, `name`, `type`, `credits`, `credits_theory`, `credits_practice`, `total_hours`, `theory_hours`, `practical_hours`, `self_study_hours`, `target_programs`, `expected_semester`, `expected_year`, `prerequisite_modules`, `parallel_modules`, `previous_modules`, `department_in_charge`, `coordinating_board`, `faculty_in_charge`, `description`, `objectives`, `grading_scale`) VALUES
(1, 1, 'TEST001', 'Giải phẫu học đại cương', 'Bắt buộc', 3, 2, 1, 45, 30, 15, 60, 'Sinh viên Y khoa năm 1', 'Học kỳ I', '2026-2027', '', '', '', 'Bộ môn Giải phẫu', 'Ban y học cơ sở', 'Khoa Y', 'Học phần cung cấp kiến thức nền tảng về cấu trúc cơ thể người.', 'Mô tả và xác định được các cấu trúc giải phẫu cơ bản.', 'Thang điểm 10'),
(2, 2, 'TEST002', 'Sinh lý học đại cương', 'Bắt buộc', 3, 2, 1, 45, 30, 15, 60, 'Sinh viên khối sức khỏe năm 1', 'Học kỳ II', '2026-2027', '', '', '', 'Bộ môn Sinh lý', 'Ban y học cơ sở', 'Khoa Y', 'Học phần trình bày hoạt động chức năng của cơ thể bình thường.', 'Giải thích được các cơ chế điều hòa sinh lý cơ bản.', 'Thang điểm 10'),
(3, 3, 'TEST003', 'Bệnh học cơ sở', 'Bắt buộc', 3, 2, 1, 45, 35, 10, 70, 'Sinh viên Y khoa năm 2', 'Học kỳ I', '2026-2027', '', '', '', 'Bộ môn Bệnh học', 'Ban tiền lâm sàng', 'Khoa Y', 'Học phần giới thiệu cơ chế bệnh sinh và tổn thương mô học cơ bản.', 'Phân tích được mối liên hệ giữa tổn thương và biểu hiện bệnh.', 'Thang điểm 10'),
(4, 4, 'TEST004', 'Kỹ năng khám lâm sàng', 'Bắt buộc', 4, 2, 2, 60, 25, 35, 80, 'Sinh viên Y khoa năm 3', 'Học kỳ II', '2026-2027', '', '', '', 'Bộ môn Nội', 'Ban lâm sàng', 'Khoa Y', 'Học phần rèn luyện kỹ năng hỏi bệnh và khám bệnh cơ bản.', 'Thực hiện đúng quy trình khám lâm sàng cơ bản.', 'Thang điểm 10'),
(5, 5, 'TEST005', 'Hóa dược cơ bản', 'Bắt buộc', 3, 2, 1, 45, 30, 15, 60, 'Sinh viên Dược năm 2', 'Học kỳ I', '2026-2027', '', '', '', 'Bộ môn Hóa dược', 'Ban đào tạo Dược', 'Khoa Dược', 'Học phần cung cấp kiến thức về cấu trúc và tính chất hóa học của thuốc.', 'Phân tích được liên quan cấu trúc - tác dụng của thuốc.', 'Thang điểm 10'),
(6, 6, 'TEST006', 'Dược lý lâm sàng','Bắt buộc', 4, 3, 1, 60, 45, 15, 90, 'Sinh viên Dược năm 4', 'Học kỳ II', '2026-2027', '', '', '', 'Bộ môn Dược lý', 'Ban đào tạo Dược', 'Khoa Dược', 'Học phần hướng dẫn sử dụng thuốc hợp lý, an toàn và hiệu quả.', 'Đề xuất được lựa chọn thuốc phù hợp tình huống lâm sàng.', 'Thang điểm 10'),
(7, 7, 'TEST007', 'Quản lý cung ứng thuốc', 'Tự chọn', 2, 1, 1, 30, 20, 10, 45, 'Sinh viên Dược năm 4', 'Học kỳ I', '2026-2027', '', '', '', 'Bộ môn Quản lý Dược', 'Ban đào tạo Dược', 'Khoa Dược', 'Học phần giới thiệu quy trình mua sắm, bảo quản và phân phối thuốc.', 'Lập được kế hoạch cung ứng thuốc ở đơn vị y tế.', 'Thang điểm 10'),
(8, 8, 'TEST008', 'Điều dưỡng cơ bản', 'Bắt buộc', 4, 2, 2, 60, 25, 35, 80, 'Sinh viên Điều dưỡng năm 1', 'Học kỳ II', '2026-2027', '', '', '', 'Bộ môn Điều dưỡng cơ bản', 'Ban Điều dưỡng', 'Khoa Điều dưỡng', 'Học phần rèn luyện kỹ năng chăm sóc cơ bản và kiểm soát nhiễm khuẩn.', 'Thực hiện được các quy trình chăm sóc an toàn.', 'Thang điểm 10'),
(9, 9, 'TEST009', 'Chăm sóc người bệnh nội khoa', 'Bắt buộc', 4, 2, 2, 60, 30, 30, 90, 'Sinh viên Điều dưỡng năm 3', 'Học kỳ I', '2026-2027', '', '', '', 'Bộ môn Điều dưỡng nội', 'Ban Điều dưỡng', 'Khoa Điều dưỡng', 'Học phần hướng dẫn chăm sóc người bệnh mắc bệnh nội khoa thường gặp.', 'Xây dựng được kế hoạch chăm sóc người bệnh nội khoa.', 'Thang điểm 10'),
(10, 10, 'TEST010', 'Tin học ứng dụng y học', 'Tự chọn', 3, 1, 2, 45, 20, 25, 60, 'Sinh viên khối sức khỏe', 'Học kỳ II', '2026-2027', '', '', '', 'Trung tâm Công nghệ thông tin', 'Ban liên khoa', 'Khoa Khoa học cơ bản', 'Học phần rèn luyện kỹ năng nhập liệu, xử lý dữ liệu và tra cứu y văn.', 'Sử dụng được công cụ số trong học tập và nghiên cứu y học.', 'Thang điểm 10');

INSERT INTO `module_relationships` (`module_id`, `related_course_id`, `relation_type`) VALUES
(2, 1, 'Học trước'), (3, 2, 'Học trước'), (4, 3, 'Song hành'), (6, 5, 'Học trước'), (9, 8, 'Học trước');

INSERT INTO `clos` (`module_id`, `code`, `description`, `domain`, `bloom_level`) VALUES
(1, 'CLO1', 'Trình bày được kiến thức cốt lõi của học phần.', 'Kiến thức', '2. Understand'), (1, 'CLO2', 'Thực hiện được kỹ năng cơ bản liên quan học phần.', 'Kỹ năng', '3. Precision'), (1, 'CLO3', 'Thể hiện thái độ học tập nghiêm túc và an toàn.', 'Thái độ', '3. Valuing'),
(2, 'CLO1', 'Trình bày được kiến thức cốt lõi của học phần.', 'Kiến thức', '2. Understand'), (2, 'CLO2', 'Thực hiện được kỹ năng cơ bản liên quan học phần.', 'Kỹ năng', '3. Precision'), (2, 'CLO3', 'Thể hiện thái độ học tập nghiêm túc và an toàn.', 'Thái độ', '3. Valuing'),
(3, 'CLO1', 'Trình bày được kiến thức cốt lõi của học phần.', 'Kiến thức', '2. Understand'), (3, 'CLO2', 'Thực hiện được kỹ năng cơ bản liên quan học phần.', 'Kỹ năng', '3. Precision'), (3, 'CLO3', 'Thể hiện thái độ học tập nghiêm túc và an toàn.', 'Thái độ', '3. Valuing'),
(4, 'CLO1', 'Trình bày được kiến thức cốt lõi của học phần.', 'Kiến thức', '2. Understand'), (4, 'CLO2', 'Thực hiện được kỹ năng cơ bản liên quan học phần.', 'Kỹ năng', '3. Precision'), (4, 'CLO3', 'Thể hiện thái độ học tập nghiêm túc và an toàn.', 'Thái độ', '3. Valuing'),
(5, 'CLO1', 'Trình bày được kiến thức cốt lõi của học phần.', 'Kiến thức', '2. Understand'), (5, 'CLO2', 'Thực hiện được kỹ năng cơ bản liên quan học phần.', 'Kỹ năng', '3. Precision'), (5, 'CLO3', 'Thể hiện thái độ học tập nghiêm túc và an toàn.', 'Thái độ', '3. Valuing'),
(6, 'CLO1', 'Trình bày được kiến thức cốt lõi của học phần.', 'Kiến thức', '2. Understand'), (6, 'CLO2', 'Thực hiện được kỹ năng cơ bản liên quan học phần.', 'Kỹ năng', '3. Precision'), (6, 'CLO3', 'Thể hiện thái độ học tập nghiêm túc và an toàn.', 'Thái độ', '3. Valuing'),
(7, 'CLO1', 'Trình bày được kiến thức cốt lõi của học phần.', 'Kiến thức', '2. Understand'), (7, 'CLO2', 'Thực hiện được kỹ năng cơ bản liên quan học phần.', 'Kỹ năng', '3. Precision'), (7, 'CLO3', 'Thể hiện thái độ học tập nghiêm túc và an toàn.', 'Thái độ', '3. Valuing'),
(8, 'CLO1', 'Trình bày được kiến thức cốt lõi của học phần.', 'Kiến thức', '2. Understand'), (8, 'CLO2', 'Thực hiện được kỹ năng cơ bản liên quan học phần.', 'Kỹ năng', '3. Precision'), (8, 'CLO3', 'Thể hiện thái độ học tập nghiêm túc và an toàn.', 'Thái độ', '3. Valuing'),
(9, 'CLO1', 'Trình bày được kiến thức cốt lõi của học phần.', 'Kiến thức', '2. Understand'), (9, 'CLO2', 'Thực hiện được kỹ năng cơ bản liên quan học phần.', 'Kỹ năng', '3. Precision'), (9, 'CLO3', 'Thể hiện thái độ học tập nghiêm túc và an toàn.', 'Thái độ', '3. Valuing'),
(10, 'CLO1', 'Trình bày được kiến thức cốt lõi của học phần.', 'Kiến thức', '2. Understand'), (10, 'CLO2', 'Thực hiện được kỹ năng cơ bản liên quan học phần.', 'Kỹ năng', '3. Precision'), (10, 'CLO3', 'Thể hiện thái độ học tập nghiêm túc và an toàn.', 'Thái độ', '3. Valuing');

INSERT INTO `assessments` (`module_id`, `type`, `component`, `form`, `tool`, `weight`, `plo_pi`) VALUES
(1,'Đánh giá thường xuyên','Chuyên cần','Điểm danh, hỏi đáp','Danh sách lớp',10,'PLO1'),(1,'Đánh giá định kỳ','Kiểm tra giữa kỳ','Bài tập tình huống','Rubric',30,'PLO2'),(1,'Thi cuối kỳ','Thi kết thúc','Trắc nghiệm','Ngân hàng câu hỏi',60,'PLO1, PLO2'),
(2,'Đánh giá thường xuyên','Chuyên cần','Điểm danh, hỏi đáp','Danh sách lớp',10,'PLO1'),(2,'Đánh giá định kỳ','Kiểm tra giữa kỳ','Bài tập tình huống','Rubric',30,'PLO2'),(2,'Thi cuối kỳ','Thi kết thúc','Trắc nghiệm','Ngân hàng câu hỏi',60,'PLO1, PLO2'),
(3,'Đánh giá thường xuyên','Chuyên cần','Điểm danh, hỏi đáp','Danh sách lớp',10,'PLO1'),(3,'Đánh giá định kỳ','Kiểm tra giữa kỳ','Bài tập tình huống','Rubric',30,'PLO2'),(3,'Thi cuối kỳ','Thi kết thúc','Trắc nghiệm','Ngân hàng câu hỏi',60,'PLO1, PLO2'),
(4,'Đánh giá thường xuyên','Chuyên cần','Điểm danh, hỏi đáp','Danh sách lớp',10,'PLO1'),(4,'Đánh giá định kỳ','Kiểm tra giữa kỳ','Bài tập tình huống','Rubric',30,'PLO2'),(4,'Thi cuối kỳ','Thi kết thúc','Trắc nghiệm','Ngân hàng câu hỏi',60,'PLO1, PLO2'),
(5,'Đánh giá thường xuyên','Chuyên cần','Điểm danh, hỏi đáp','Danh sách lớp',10,'PLO1'),(5,'Đánh giá định kỳ','Kiểm tra giữa kỳ','Bài tập tình huống','Rubric',30,'PLO2'),(5,'Thi cuối kỳ','Thi kết thúc','Trắc nghiệm','Ngân hàng câu hỏi',60,'PLO1, PLO2'),
(6,'Đánh giá thường xuyên','Chuyên cần','Điểm danh, hỏi đáp','Danh sách lớp',10,'PLO1'),(6,'Đánh giá định kỳ','Kiểm tra giữa kỳ','Bài tập tình huống','Rubric',30,'PLO2'),(6,'Thi cuối kỳ','Thi kết thúc','Trắc nghiệm','Ngân hàng câu hỏi',60,'PLO1, PLO2'),
(7,'Đánh giá thường xuyên','Chuyên cần','Điểm danh, hỏi đáp','Danh sách lớp',10,'PLO1'),(7,'Đánh giá định kỳ','Kiểm tra giữa kỳ','Bài tập tình huống','Rubric',30,'PLO2'),(7,'Thi cuối kỳ','Thi kết thúc','Trắc nghiệm','Ngân hàng câu hỏi',60,'PLO1, PLO2'),
(8,'Đánh giá thường xuyên','Chuyên cần','Điểm danh, hỏi đáp','Danh sách lớp',10,'PLO1'),(8,'Đánh giá định kỳ','Kiểm tra giữa kỳ','Bài tập tình huống','Rubric',30,'PLO2'),(8,'Thi cuối kỳ','Thi kết thúc','Trắc nghiệm','Ngân hàng câu hỏi',60,'PLO1, PLO2'),
(9,'Đánh giá thường xuyên','Chuyên cần','Điểm danh, hỏi đáp','Danh sách lớp',10,'PLO1'),(9,'Đánh giá định kỳ','Kiểm tra giữa kỳ','Bài tập tình huống','Rubric',30,'PLO2'),(9,'Thi cuối kỳ','Thi kết thúc','Trắc nghiệm','Ngân hàng câu hỏi',60,'PLO1, PLO2'),
(10,'Đánh giá thường xuyên','Chuyên cần','Điểm danh, hỏi đáp','Danh sách lớp',10,'PLO1'),(10,'Đánh giá định kỳ','Kiểm tra giữa kỳ','Bài tập tình huống','Rubric',30,'PLO2'),(10,'Thi cuối kỳ','Thi kết thúc','Trắc nghiệm','Ngân hàng câu hỏi',60,'PLO1, PLO2');

INSERT INTO `assessment_clos` (`assessment_id`, `clo_id`)
SELECT a.id, c.id FROM assessments a JOIN clos c ON c.module_id = a.module_id;

INSERT INTO `self_study_activities` (`module_id`, `activity_name`, `duration_hours`, `method`, `assessment_method`, `evidence`) VALUES
(1,'Đọc tài liệu trước buổi học',8,'Đọc giáo trình và ghi chú','Quiz đầu giờ','Phiếu trả lời'),(1,'Làm bài tập tự học',10,'Làm bài tập trên LMS','Chấm bài nộp','File bài tập'),
(2,'Đọc tài liệu trước buổi học',8,'Đọc giáo trình và ghi chú','Quiz đầu giờ','Phiếu trả lời'),(2,'Làm bài tập tự học',10,'Làm bài tập trên LMS','Chấm bài nộp','File bài tập'),
(3,'Đọc tài liệu trước buổi học',8,'Đọc giáo trình và ghi chú','Quiz đầu giờ','Phiếu trả lời'),(3,'Làm bài tập tự học',10,'Làm bài tập trên LMS','Chấm bài nộp','File bài tập'),
(4,'Đọc tài liệu trước buổi học',8,'Đọc giáo trình và ghi chú','Quiz đầu giờ','Phiếu trả lời'),(4,'Làm bài tập tự học',10,'Làm bài tập trên LMS','Chấm bài nộp','File bài tập'),
(5,'Đọc tài liệu trước buổi học',8,'Đọc giáo trình và ghi chú','Quiz đầu giờ','Phiếu trả lời'),(5,'Làm bài tập tự học',10,'Làm bài tập trên LMS','Chấm bài nộp','File bài tập'),
(6,'Đọc tài liệu trước buổi học',8,'Đọc giáo trình và ghi chú','Quiz đầu giờ','Phiếu trả lời'),(6,'Làm bài tập tự học',10,'Làm bài tập trên LMS','Chấm bài nộp','File bài tập'),
(7,'Đọc tài liệu trước buổi học',8,'Đọc giáo trình và ghi chú','Quiz đầu giờ','Phiếu trả lời'),(7,'Làm bài tập tự học',10,'Làm bài tập trên LMS','Chấm bài nộp','File bài tập'),
(8,'Đọc tài liệu trước buổi học',8,'Đọc giáo trình và ghi chú','Quiz đầu giờ','Phiếu trả lời'),(8,'Làm bài tập tự học',10,'Làm bài tập trên LMS','Chấm bài nộp','File bài tập'),
(9,'Đọc tài liệu trước buổi học',8,'Đọc giáo trình và ghi chú','Quiz đầu giờ','Phiếu trả lời'),(9,'Làm bài tập tự học',10,'Làm bài tập trên LMS','Chấm bài nộp','File bài tập'),
(10,'Đọc tài liệu trước buổi học',8,'Đọc giáo trình và ghi chú','Quiz đầu giờ','Phiếu trả lời'),(10,'Làm bài tập tự học',10,'Làm bài tập trên LMS','Chấm bài nộp','File bài tập');

INSERT INTO `self_study_clos` (`self_study_activity_id`, `clo_id`)
SELECT s.id, c.id FROM self_study_activities s JOIN clos c ON c.module_id = s.module_id AND c.code IN ('CLO1', 'CLO2');

INSERT INTO `theory_topics` (`module_id`, `chapter`, `title`, `method`, `class_hours`, `self_study_hours`, `textbook_info`) VALUES
(1,'Chương 1','Tổng quan học phần','Thuyết trình ngắn',4,8,'Giáo trình chính - chương 1'),(1,'Bài 1','Nội dung cốt lõi 1','Thảo luận nhóm',6,10,'Giáo trình chính - chương 2'),
(2,'Chương 1','Tổng quan học phần','Thuyết trình ngắn',4,8,'Giáo trình chính - chương 1'),(2,'Bài 1','Nội dung cốt lõi 1','Thảo luận nhóm',6,10,'Giáo trình chính - chương 2'),
(3,'Chương 1','Tổng quan học phần','Thuyết trình ngắn',4,8,'Giáo trình chính - chương 1'),(3,'Bài 1','Nội dung cốt lõi 1','Thảo luận nhóm',6,10,'Giáo trình chính - chương 2'),
(4,'Chương 1','Tổng quan học phần','Thuyết trình ngắn',4,8,'Giáo trình chính - chương 1'),(4,'Bài 1','Nội dung cốt lõi 1','Thảo luận nhóm',6,10,'Giáo trình chính - chương 2'),
(5,'Chương 1','Tổng quan học phần','Thuyết trình ngắn',4,8,'Giáo trình chính - chương 1'),(5,'Bài 1','Nội dung cốt lõi 1','Thảo luận nhóm',6,10,'Giáo trình chính - chương 2'),
(6,'Chương 1','Tổng quan học phần','Thuyết trình ngắn',4,8,'Giáo trình chính - chương 1'),(6,'Bài 1','Nội dung cốt lõi 1','Thảo luận nhóm',6,10,'Giáo trình chính - chương 2'),
(7,'Chương 1','Tổng quan học phần','Thuyết trình ngắn',4,8,'Giáo trình chính - chương 1'),(7,'Bài 1','Nội dung cốt lõi 1','Thảo luận nhóm',6,10,'Giáo trình chính - chương 2'),
(8,'Chương 1','Tổng quan học phần','Thuyết trình ngắn',4,8,'Giáo trình chính - chương 1'),(8,'Bài 1','Nội dung cốt lõi 1','Thảo luận nhóm',6,10,'Giáo trình chính - chương 2'),
(9,'Chương 1','Tổng quan học phần','Thuyết trình ngắn',4,8,'Giáo trình chính - chương 1'),(9,'Bài 1','Nội dung cốt lõi 1','Thảo luận nhóm',6,10,'Giáo trình chính - chương 2'),
(10,'Chương 1','Tổng quan học phần','Thuyết trình ngắn',4,8,'Giáo trình chính - chương 1'),(10,'Bài 1','Nội dung cốt lõi 1','Thảo luận nhóm',6,10,'Giáo trình chính - chương 2');

INSERT INTO `theory_topic_clos` (`theory_topic_id`, `clo_id`)
SELECT t.id, c.id FROM theory_topics t JOIN clos c ON c.module_id = t.module_id AND c.code IN ('CLO1', 'CLO2');

INSERT INTO `practical_topics` (`module_id`, `topic`, `content`, `method`, `lab_hours`, `facility_id`) VALUES
(1,'Thực hành 1','Nhận diện cấu trúc/mô hình chính','Thực hành nhóm',4,1),(1,'Thực hành 2','Hoàn thành bảng kiểm kỹ năng','Trạm kỹ năng',5,2),
(2,'Thực hành 1','Đo và phân tích thông số sinh lý','Thực hành nhóm',4,4),(2,'Thực hành 2','Hoàn thành bảng kiểm kỹ năng','Trạm kỹ năng',5,2),
(3,'Thực hành 1','Quan sát tiêu bản và mô tả tổn thương','Thực hành nhóm',4,1),(3,'Thực hành 2','Hoàn thành bảng kiểm kỹ năng','Trạm kỹ năng',5,2),
(4,'Thực hành 1','Khám hệ cơ quan theo quy trình','Thực hành nhóm',4,2),(4,'Thực hành 2','Hoàn thành bảng kiểm kỹ năng','Trạm kỹ năng',5,2),
(5,'Thực hành 1','Phân tích cấu trúc hóa học mẫu','Thực hành nhóm',4,5),(5,'Thực hành 2','Hoàn thành bảng kiểm kỹ năng','Trạm kỹ năng',5,5),
(6,'Thực hành 1','Phân tích đơn thuốc và tương tác thuốc','Thực hành nhóm',4,5),(6,'Thực hành 2','Hoàn thành bảng kiểm kỹ năng','Trạm kỹ năng',5,5),
(7,'Thực hành 1','Lập kế hoạch cung ứng thuốc','Thực hành nhóm',4,5),(7,'Thực hành 2','Hoàn thành bảng kiểm kỹ năng','Trạm kỹ năng',5,5),
(8,'Thực hành 1','Thực hiện kỹ thuật chăm sóc cơ bản','Thực hành nhóm',4,6),(8,'Thực hành 2','Hoàn thành bảng kiểm kỹ năng','Trạm kỹ năng',5,6),
(9,'Thực hành 1','Lập kế hoạch chăm sóc người bệnh','Thực hành nhóm',4,6),(9,'Thực hành 2','Hoàn thành bảng kiểm kỹ năng','Trạm kỹ năng',5,6),
(10,'Thực hành 1','Nhập và xử lý bộ dữ liệu mẫu','Thực hành nhóm',4,3),(10,'Thực hành 2','Hoàn thành báo cáo dữ liệu','Thực hành máy tính',5,3);

INSERT INTO `practical_topic_clos` (`practical_topic_id`, `clo_id`)
SELECT p.id, c.id FROM practical_topics p JOIN clos c ON c.module_id = p.module_id AND c.code IN ('CLO2', 'CLO3');

INSERT INTO `combined_topics` (`module_id`, `sort_order`, `content`, `method`, `theory_hours`, `practical_hours`, `self_study_hours`, `facility_id`) VALUES
(1,1,'Tích hợp lý thuyết và thực hành tình huống 1','Case-based learning',2,3,5,1),(1,2,'Tổng kết học phần và phản hồi','Seminar',1,2,4,2),
(2,1,'Tích hợp lý thuyết và thực hành tình huống 1','Case-based learning',2,3,5,4),(2,2,'Tổng kết học phần và phản hồi','Seminar',1,2,4,2),
(3,1,'Tích hợp lý thuyết và thực hành tình huống 1','Case-based learning',2,3,5,1),(3,2,'Tổng kết học phần và phản hồi','Seminar',1,2,4,2),
(4,1,'Tích hợp lý thuyết và thực hành tình huống 1','Case-based learning',2,3,5,2),(4,2,'Tổng kết học phần và phản hồi','Seminar',1,2,4,2),
(5,1,'Tích hợp lý thuyết và thực hành tình huống 1','Case-based learning',2,3,5,5),(5,2,'Tổng kết học phần và phản hồi','Seminar',1,2,4,5),
(6,1,'Tích hợp lý thuyết và thực hành tình huống 1','Case-based learning',2,3,5,5),(6,2,'Tổng kết học phần và phản hồi','Seminar',1,2,4,5),
(7,1,'Tích hợp lý thuyết và thực hành tình huống 1','Case-based learning',2,3,5,5),(7,2,'Tổng kết học phần và phản hồi','Seminar',1,2,4,5),
(8,1,'Tích hợp lý thuyết và thực hành tình huống 1','Case-based learning',2,3,5,6),(8,2,'Tổng kết học phần và phản hồi','Seminar',1,2,4,6),
(9,1,'Tích hợp lý thuyết và thực hành tình huống 1','Case-based learning',2,3,5,6),(9,2,'Tổng kết học phần và phản hồi','Seminar',1,2,4,6),
(10,1,'Tích hợp lý thuyết và thực hành tình huống 1','Case-based learning',2,3,5,3),(10,2,'Tổng kết học phần và phản hồi','Seminar',1,2,4,3);

INSERT INTO `combined_topic_clos` (`combined_topic_id`, `clo_id`)
SELECT cb.id, c.id FROM combined_topics cb JOIN clos c ON c.module_id = cb.module_id;

INSERT INTO `resources` (`module_id`, `resource_type`, `sort_order`, `title`, `editor`, `publisher`, `year`, `identifier`) VALUES
(1,'Tài liệu giảng dạy',1,'Giáo trình Giải phẫu học đại cương','Nguyễn Văn A','NXB Y học','2025', 1),
(1,'Tài liệu tự học',1,'Atlas thực hành giải phẫu','Trần Thị B','NXB Y học','2024', NULL),
(2,'Tài liệu giảng dạy',1,'Giáo trình Sinh lý học đại cương','Nguyễn Văn A','NXB Y học','2025', 2),
(2,'Tài liệu tự học',1,'Bài tập sinh lý học','Trần Thị B','NXB Y học','2024', NULL),
(3,'Tài liệu giảng dạy',1,'Giáo trình Bệnh học cơ sở','Nguyễn Văn A','NXB Y học','2025', 3),
(3,'Tài liệu tự học',1,'Tập tình huống bệnh học','Trần Thị B','NXB Y học','2024', NULL),
(4,'Tài liệu giảng dạy',1,'Giáo trình Kỹ năng khám lâm sàng','Nguyễn Văn A','NXB Y học','2025', 4),
(4,'Tài liệu tự học',1,'Bảng kiểm khám lâm sàng','Trần Thị B','NXB Y học','2024', NULL),
(5,'Tài liệu giảng dạy',1,'Giáo trình Hóa dược cơ bản','Nguyễn Văn A','NXB Y học','2025', 5),
(5,'Tài liệu tự học',1,'Bài tập hóa dược','Trần Thị B','NXB Y học','2024', NULL),
(6,'Tài liệu giảng dạy',1,'Giáo trình Dược lý lâm sàng','Nguyễn Văn A','NXB Y học','2025', 6),
(6,'Tài liệu tự học',1,'Case study dược lý','Trần Thị B','NXB Y học','2024', NULL),
(7,'Tài liệu giảng dạy',1,'Giáo trình Quản lý cung ứng thuốc','Nguyễn Văn A','NXB Y học','2025', 7),
(7,'Tài liệu tự học',1,'Bài tập quản lý tồn kho thuốc','Trần Thị B','NXB Y học','2024', NULL),
(8,'Tài liệu giảng dạy',1,'Giáo trình Điều dưỡng cơ bản','Nguyễn Văn A','NXB Y học','2025', 8),
(8,'Tài liệu tự học',1,'Bảng kiểm kỹ thuật điều dưỡng','Trần Thị B','NXB Y học','2024', NULL),
(9,'Tài liệu giảng dạy',1,'Giáo trình Chăm sóc nội khoa','Nguyễn Văn A','NXB Y học','2025', 9),
(9,'Tài liệu tự học',1,'Kế hoạch chăm sóc mẫu','Trần Thị B','NXB Y học','2024', NULL),
(10,'Tài liệu giảng dạy',1,'Giáo trình Tin học ứng dụng y học','Nguyễn Văn A','NXB Y học','2025', 10),
(10,'Tài liệu tự học',1,'Bài tập xử lý dữ liệu y học','Trần Thị B','NXB Y học','2024', NULL);

INSERT INTO `books_catalog` (`id`, `title`, `editor`, `publisher`, `year`, `identifier`) VALUES
(1,'Giáo trình Giải phẫu học đại cương','Nguyễn Văn A','NXB Y học','2025', 1),
(2,'Giáo trình Sinh lý học đại cương','Nguyễn Văn A','NXB Y học','2025', 2),
(3,'Giáo trình Bệnh học cơ sở','Nguyễn Văn A','NXB Y học','2025', 3),
(4,'Giáo trình Kỹ năng khám lâm sàng','Nguyễn Văn A','NXB Y học','2025', 4),
(5,'Giáo trình Hóa dược cơ bản','Nguyễn Văn A','NXB Y học','2025', 5),
(6,'Giáo trình Dược lý lâm sàng','Nguyễn Văn A','NXB Y học','2025', 6),
(7,'Giáo trình Quản lý cung ứng thuốc','Nguyễn Văn A','NXB Y học','2025', 7),
(8,'Giáo trình Điều dưỡng cơ bản','Nguyễn Văn A','NXB Y học','2025', 8),
(9,'Giáo trình Chăm sóc nội khoa','Nguyễn Văn A','NXB Y học','2025', 9),
(10,'Giáo trình Tin học ứng dụng y học','Nguyễn Văn A','NXB Y học','2025', 10);

SET FOREIGN_KEY_CHECKS = 1;
