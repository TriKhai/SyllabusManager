-- =====================================================================
-- HỆ THỐNG QUẢN LÝ ĐỀ CƯƠNG CHI TIẾT HỌC PHẦN (TEMPCTDT)
-- TOÀN BỘ CẤU TRÚC BẢNG (SCHEMA) & 5 BỘ DỮ LIỆU KIỂM THỬ ĐỒNG BỘ
-- =====================================================================

SET NAMES utf8mb4;
-- Tạm thời tắt kiểm tra khóa ngoại để dọn dẹp hệ thống bảng cũ một cách an toàn
SET FOREIGN_KEY_CHECKS = 0;

-- ---------------------------------------------------------------------
-- BƯỚC 1: XÓA CÁC BẢNG CŨ NẾU ĐÃ TỒN TẠI (ĐẢM BẢO KHÔNG BỊ XUNG ĐỘT)
-- ---------------------------------------------------------------------
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

-- ---------------------------------------------------------------------
-- BƯỚC 2: KHỞI TẠO CẤU TRÚC BẢNG (SCHEMA) ĐÃ SỬA ĐỔI RÀNG BUỘC TỐI ƯU
-- ---------------------------------------------------------------------

-- 1. Các bảng danh mục nền tảng (Master Data)
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
  FOREIGN KEY (`major_id`) REFERENCES `majors`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `courses` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `major_id` INT NOT NULL,
  `block_id` INT NULL DEFAULT NULL,
  `code` VARCHAR(50) NOT NULL UNIQUE,
  `name` VARCHAR(255) NOT NULL,
  `total_hours` INT DEFAULT 0,
  `theory_hours` INT DEFAULT 0,
  `practice_hours` INT DEFAULT 0,
  `sort_order` INT DEFAULT 0,
  FOREIGN KEY (`major_id`) REFERENCES `majors`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`block_id`) REFERENCES `knowledge_blocks`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `facilities` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- 2. Bảng thông tin đề cương chi tiết (Modules)
CREATE TABLE `modules` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `course_id` INT NULL,
  `code` VARCHAR(50) NOT NULL UNIQUE,
  `name_vn` VARCHAR(255) NOT NULL,
  `name_en` VARCHAR(255) NULL,
  `type` ENUM('Bắt buộc', 'Điều kiện', 'Tự chọn') NOT NULL DEFAULT 'Bắt buộc',
  `credits` INT NOT NULL DEFAULT 0,
  `theory_hours` INT NOT NULL DEFAULT 0,
  `practical_hours` INT NOT NULL DEFAULT 0,
  `self_study_hours` INT NOT NULL DEFAULT 0,
  `target_programs` TEXT NULL COMMENT 'Đối tượng người học dự kiến',
  `expected_semester` VARCHAR(50) NULL COMMENT 'Học kỳ dự kiến học',
  `expected_year` VARCHAR(50) NULL COMMENT 'Năm học dự kiến',
  `department_in_charge` VARCHAR(255) NULL COMMENT 'Bộ môn tham gia giảng dạy',
  `coordinating_board` VARCHAR(255) NULL COMMENT 'Ban điều phối học phần',
  `faculty_in_charge` VARCHAR(255) NULL COMMENT 'Khoa phụ trách',
  `description` TEXT NULL COMMENT 'Mô tả học phần',
  `objectives` TEXT NULL COMMENT 'Mục tiêu học phần',
  `grading_scale` VARCHAR(50) NULL DEFAULT '10' COMMENT 'Thang điểm lượng giá',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`course_id`) REFERENCES `courses`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- 3. Mối quan hệ giữa các học phần
CREATE TABLE `module_relationships` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `module_id` INT NOT NULL,
  `related_module_id` INT NOT NULL,
  `relation_type` ENUM('Tiên quyết', 'Song hành', 'Học trước') NOT NULL,
  FOREIGN KEY (`module_id`) REFERENCES `modules`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`related_module_id`) REFERENCES `modules`(`id`) ON DELETE CASCADE,
  UNIQUE KEY `unique_relation` (`module_id`, `related_module_id`, `relation_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- 4. Chuẩn đầu ra học phần (CLOs)
CREATE TABLE `clos` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `module_id` INT NOT NULL,
  `code` VARCHAR(50) NOT NULL COMMENT 'Ví dụ: CLO1, CLO2',
  `description` TEXT NOT NULL,
  `domain` VARCHAR(255) NULL COMMENT 'Lĩnh vực (Kiến thức/Kỹ năng/Năng lực tự chủ)',
  `bloom_level` VARCHAR(255) NULL COMMENT 'Mức độ Bloom',
  FOREIGN KEY (`module_id`) REFERENCES `modules`(`id`) ON DELETE CASCADE,
  UNIQUE KEY `unique_module_clo` (`module_id`, `code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- 5. Phương pháp kiểm tra, lượng giá học phần
CREATE TABLE `assessments` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `module_id` INT NOT NULL,
  `type` ENUM('Đánh giá thường xuyên', 'Đánh giá định kỳ', 'Thi cuối kỳ') NOT NULL,
  `component` VARCHAR(255) NULL COMMENT 'Thành phần đánh giá',
  `form` VARCHAR(255) NOT NULL COMMENT 'Hình thức đánh giá',
  `tool` VARCHAR(255) NULL COMMENT 'Công cụ đánh giá',
  `weight` DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT 'Trọng số (%)',
  `plo_pi` VARCHAR(255) NULL COMMENT 'PLO/PI liên quan',
  FOREIGN KEY (`module_id`) REFERENCES `modules`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `assessment_clos` (
  `assessment_id` INT NOT NULL,
  `clo_id` INT NOT NULL,
  PRIMARY KEY (`assessment_id`, `clo_id`),
  FOREIGN KEY (`assessment_id`) REFERENCES `assessments`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`clo_id`) REFERENCES `clos`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- 6. Lượng giá hoạt động tự học
CREATE TABLE `self_study_activities` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `module_id` INT NOT NULL,
  `activity_name` TEXT NOT NULL COMMENT 'Hoạt động tự học',
  `duration_hours` INT DEFAULT 0 COMMENT 'Thời lượng (giờ)',
  `method` TEXT NULL COMMENT 'Phương pháp tự học',
  `assessment_method` TEXT NULL COMMENT 'Cách thức đánh giá',
  `evidence` TEXT NULL COMMENT 'Minh chứng',
  FOREIGN KEY (`module_id`) REFERENCES `modules`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `self_study_clos` (
  `self_study_activity_id` INT NOT NULL,
  `clo_id` INT NOT NULL,
  PRIMARY KEY (`self_study_activity_id`, `clo_id`),
  FOREIGN KEY (`self_study_activity_id`) REFERENCES `self_study_activities`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`clo_id`) REFERENCES `clos`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- 7. Tiến độ giảng dạy và nội dung chi tiết
CREATE TABLE `theory_topics` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `module_id` INT NOT NULL,
  `chapter` VARCHAR(100) NULL COMMENT 'Chương/Bài',
  `title` TEXT NOT NULL COMMENT 'Bài giảng/Nội dung lý thuyết',
  `method` VARCHAR(255) NULL COMMENT 'Hình thức dạy học',
  `class_hours` INT DEFAULT 0 COMMENT 'Số tiết trên lớp',
  `self_study_hours` INT DEFAULT 0 COMMENT 'Số tiết tự học',
  `textbook_info` VARCHAR(255) NULL COMMENT 'Tên sách/giáo trình, chương sử dụng',
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
  `topic` VARCHAR(255) NULL COMMENT 'Chủ đề',
  `content` TEXT NOT NULL COMMENT 'Nội dung thực hành/kỹ năng',
  `method` VARCHAR(255) NULL COMMENT 'Hình thức dạy học',
  `lab_hours` INT DEFAULT 0 COMMENT 'Số tiết thực hành',
  `facility_id` INT NULL COMMENT 'Cơ sở thực hành (FK từ bảng facilities)',
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
  `sort_order` INT DEFAULT 1 COMMENT 'STT',
  `content` TEXT NOT NULL COMMENT 'Nội dung chính',
  `method` VARCHAR(255) NULL COMMENT 'Hình thức dạy học',
  `theory_hours` INT DEFAULT 0 COMMENT 'Số tiết LT',
  `practical_hours` INT DEFAULT 0 COMMENT 'Số tiết TH',
  `self_study_hours` INT DEFAULT 0 COMMENT 'Số tiết tự học',
  `facility_id` INT NULL COMMENT 'Cơ sở thực hành',
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


-- 8. Tài liệu dạy học (Resources)
CREATE TABLE `resources` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `module_id` INT NOT NULL,
  `resource_type` ENUM('Tài liệu giảng dạy', 'Tài liệu tự học') NOT NULL,
  `sort_order` INT DEFAULT 1 COMMENT 'STT',
  `title` VARCHAR(255) NOT NULL COMMENT 'Tên giáo trình/tài liệu',
  `editor` VARCHAR(255) NULL COMMENT 'Chủ biên',
  `publisher` VARCHAR(255) NULL COMMENT 'Nhà xuất bản',
  `year` VARCHAR(50) NULL COMMENT 'Năm xuất bản',
  `identifier` VARCHAR(100) NULL COMMENT 'Số định danh cá biệt tại thư viện / ISBN',
  FOREIGN KEY (`module_id`) REFERENCES `modules`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `books_catalog` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `title` VARCHAR(255) NOT NULL COMMENT 'Tên giáo trình/tài liệu',
  `editor` VARCHAR(255) NULL COMMENT 'Chủ biên',
  `publisher` VARCHAR(255) NULL COMMENT 'Nhà xuất bản',
  `year` VARCHAR(50) NULL COMMENT 'Năm xuất bản',
  `identifier` VARCHAR(100) NULL COMMENT 'Số định danh cá biệt / ISBN'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ---------------------------------------------------------------------
-- BƯỚC 3: CHÈN DỮ LIỆU KIỂM THỬ ĐỒNG BỘ (5 MẪU ĐỀ CƯƠNG CHI TIẾT)
-- ---------------------------------------------------------------------

-- Danh mục Ngành
INSERT INTO `majors` (`id`, `name`) VALUES 
(1, 'Y khoa'), 
(2, 'Dược học'), 
(3, 'Điều dưỡng');

-- Danh mục Khối kiến thức
INSERT INTO `knowledge_blocks` (`id`, `major_id`, `name`, `parent_id`) VALUES 
(1, 1, 'Khối kiến thức cơ sở ngành (Y khoa)', NULL),
(2, 2, 'Khối kiến thức chuyên ngành (Dược)', NULL),
(3, 3, 'Khối kiến thức cơ sở ngành (Điều dưỡng)', NULL),
(4, 1, 'Khối kiến thức đại cương', NULL);

-- Khung chương trình (Courses)
INSERT INTO `courses` (`id`, `major_id`, `block_id`, `code`, `name`, `total_hours`, `theory_hours`, `practice_hours`, `sort_order`) VALUES 
(1, 1, 1, 'HP001', 'Giải phẫu học 1', 45, 30, 15, 1),
(2, 2, 2, 'HP002', 'Dược lý học lâm sàng', 60, 45, 15, 2),
(3, 3, 3, 'HP003', 'Điều dưỡng cơ bản 1', 45, 20, 25, 3),
(4, 1, 1, 'HP004', 'Sinh lý học đại cương', 45, 35, 10, 4),
(5, 1, 4, 'HP005', 'Tin học ứng dụng trong Y Dược', 30, 15, 15, 5);

-- Danh mục Cơ sở vật chất
INSERT INTO `facilities` (`id`, `name`) VALUES 
(1, 'Phòng thực hành Giải phẫu - Nhà A'),
(2, 'Trung tâm Mô phỏng Lâm sàng (Pre-clinic)'),
(3, 'Phòng Máy tính - Trung tâm CNTT'),
(4, 'Phòng thực hành Sinh lý - Sinh lý bệnh');

-- Danh mục Hình thức đánh giá tổng thể
INSERT INTO `assessment_forms` (`id`, `name`) VALUES 
(1, 'Trắc nghiệm khách quan trên máy tính'),
(2, 'Chạy trạm OSCE/OSPE thực hành'),
(3, 'Bảng kiểm kỹ năng (Skill checklist)'),
(4, 'Thi viết tự luận'),
(5, 'Báo cáo bài tập lớn (Tiểu luận)');

CREATE TABLE IF NOT EXISTS `faculties_list` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
-- Chèn dữ liệu mẫu cho các khoa
INSERT INTO `faculties_list` (`name`) VALUES 
('Khoa Y'),
('Khoa Dược'),
('Khoa Điều dưỡng');
-- ---------------------------------------------------------------------
-- PHẦN THÔNG TIN CHUNG ĐỀ CƯƠNG CHI TIẾT (modules)
-- ---------------------------------------------------------------------

-- Đề cương số 1: Giải phẫu học 1
INSERT INTO `modules` (`id`, `course_id`, `code`, `name_vn`, `name_en`, `type`, `credits`, `theory_hours`, `practical_hours`, `self_study_hours`, `target_programs`, `expected_semester`, `expected_year`, `department_in_charge`, `coordinating_board`, `faculty_in_charge`, `description`, `objectives`, `grading_scale`) 
VALUES (1, 1, 'GP001', 'Giải phẫu học 1', 'Anatomy 1', 'Bắt buộc', 3, 30, 15, 90, 'Sinh viên hệ chính quy ngành Y khoa - Năm 1', 'Học kỳ I', '2026-2027', 'Bộ môn Giải phẫu học', 'Ban điều phối y học cơ sở', 'Khoa Y', 'Học phần cung cấp các kiến thức cốt lõi về hình thái học, cấu trúc giải phẫu đại thể của các hệ cơ quan trong cơ thể người bao gồm hệ xương, hệ cơ, hệ tuần hoàn và hệ hô hấp.', 'Mục tiêu giúp người học mô tả được vị trí, hình thể cấu trúc và liên quan giải phẫu các hệ cơ quan.', 'Thang điểm 10');

-- Đề cương số 2: Dược lý học lâm sàng
INSERT INTO `modules` (`id`, `course_id`, `code`, `name_vn`, `name_en`, `type`, `credits`, `theory_hours`, `practical_hours`, `self_study_hours`, `target_programs`, `expected_semester`, `expected_year`, `department_in_charge`, `coordinating_board`, `faculty_in_charge`, `description`, `objectives`, `grading_scale`) 
VALUES (2, 2, 'DL002', 'Dược lý học lâm sàng', 'Clinical Pharmacology', 'Bắt buộc', 4, 45, 15, 120, 'Sinh viên hệ chính quy ngành Dược học - Năm 4', 'Học kỳ II', '2026-2027', 'Bộ môn Dược lý - Dược lâm sàng', 'Ban đào tạo Khoa Dược', 'Khoa Dược', 'Môn học trang bị cơ chế tác dụng, dược động học, tác dụng phụ và chỉ định lâm sàng của các nhóm thuốc điều trị chính, hướng dẫn cách phối hợp thuốc an toàn, hợp lý.', 'Mục tiêu giúp sinh viên phân tích được tương tác thuốc, thiết lập kế hoạch chăm sóc dược tối ưu.', 'Thang điểm 10');

-- Đề cương số 3: Điều dưỡng cơ bản 1
INSERT INTO `modules` (`id`, `course_id`, `code`, `name_vn`, `name_en`, `type`, `credits`, `theory_hours`, `practical_hours`, `self_study_hours`, `target_programs`, `expected_semester`, `expected_year`, `department_in_charge`, `coordinating_board`, `faculty_in_charge`, `description`, `objectives`, `grading_scale`) 
VALUES (3, 3, 'DD001', 'Điều dưỡng cơ bản 1', 'Fundamentals of Nursing 1', 'Bắt buộc', 3, 20, 25, 90, 'Sinh viên ngành Điều dưỡng - Năm 2', 'Học kỳ I', '2026-2027', 'Bộ môn Điều dưỡng cơ bản', NULL, 'Khoa Điều dưỡng', 'Học phần giới thiệu về quy trình điều dưỡng toàn diện và huấn luyện các kỹ năng chăm sóc cốt lõi cơ bản như đo dấu hiệu sinh tồn, kiểm soát nhiễm khuẩn và kỹ thuật tiêm.', 'Mục tiêu giúp sinh viên thực hiện thành thạo, chính xác và an toàn các quy trình kỹ thuật chăm sóc cơ bản.', 'Thang điểm 10');

-- Đề cương số 4: Sinh lý học đại cương
INSERT INTO `modules` (`id`, `course_id`, `code`, `name_vn`, `name_en`, `type`, `credits`, `theory_hours`, `practical_hours`, `self_study_hours`, `target_programs`, `expected_semester`, `expected_year`, `department_in_charge`, `coordinating_board`, `faculty_in_charge`, `description`, `objectives`, `grading_scale`) 
VALUES (4, 4, 'SL001', 'Sinh lý học đại cương', 'Human Physiology', 'Bắt buộc', 3, 35, 10, 90, 'Sinh viên Khối ngành Sức khỏe', 'Học kỳ II', '2026-2027', 'Bộ môn Sinh lý học', 'Ban điều phối liên khoa', 'Khoa Y', 'Nghiên cứu về hoạt động chức năng lý hóa bình thường của các cơ quan, hệ thống cơ quan và cơ chế điều hòa hằng định nội môi của cơ thể người.', 'Giúp người học phân tích được các cơ chế phản xạ thần kinh, nội tiết và hằng định nội môi.', 'Thang điểm 10');

-- Đề cương số 5: Tin học ứng dụng trong Y Dược
INSERT INTO `modules` (`id`, `course_id`, `code`, `name_vn`, `name_en`, `type`, `credits`, `theory_hours`, `practical_hours`, `self_study_hours`, `target_programs`, `expected_semester`, `expected_year`, `department_in_charge`, `coordinating_board`, `faculty_in_charge`, `description`, `objectives`, `grading_scale`) 
VALUES (5, 5, 'TH003', 'Tin học ứng dụng trong Y Dược', 'Applied Informatics', 'Tự chọn', 2, 15, 15, 60, 'Sinh viên đại học các ngành thuộc khối Sức khỏe', 'Học kỳ I', '2026-2027', 'Trung tâm Công nghệ thông tin', NULL, 'Khoa Khoa học cơ bản', 'Trang bị kiến thức ứng dụng CNTT vào quản lý hồ sơ bệnh án, kỹ năng phân tích số liệu y học cơ bản bằng phần mềm chuyên dụng và cách tìm kiếm dữ liệu y văn.', 'Mục tiêu giúp sinh viên thành thạo thao tác nhập liệu, thống kê số liệu y học và tra cứu PubMed.', 'Thang điểm 10');


-- ---------------------------------------------------------------------
-- PHẦN MỐI QUAN HỆ GIỮA CÁC HỌC PHẦN (module_relationships)
-- ---------------------------------------------------------------------
INSERT INTO `module_relationships` (`module_id`, `related_module_id`, `relation_type`) VALUES 
(2, 4, 'Học trước'),
(3, 1, 'Song hành');


-- ---------------------------------------------------------------------
-- PHẦN CHUẨN ĐẦU RA HỌC PHẦN (clos)
-- ---------------------------------------------------------------------

-- CLOs cho Giải phẫu học 1 (Module 1)
INSERT INTO `clos` (`id`, `module_id`, `code`, `domain`, `bloom_level`, `description`) VALUES
(11, 1, 'CLO1', 'Kiến thức', '1. Remember', 'Nhận biết và gọi tên cấu trúc giải phẫu của các xương, khớp, cơ lớn trên mô hình.'),
(12, 1, 'CLO2', 'Kiến thức', '2. Understand', 'Trình bày được đường đi, liên quan của các mạch máu và thần kinh cơ bản.'),
(13, 1, 'CLO3', 'Kỹ năng', '2. Manipulation', 'Xác định chính xác các mốc giải phẫu bề mặt trên cơ thể người sống.');

-- CLOs cho Dược lý lâm sàng (Module 2)
INSERT INTO `clos` (`id`, `module_id`, `code`, `domain`, `bloom_level`, `description`) VALUES
(21, 2, 'CLO1', 'Kiến thức', '4. Analyze', 'Phân tích được cơ chế tác dụng và chỉ định phù hợp của các nhóm thuốc điều trị.'),
(22, 2, 'Kỹ năng', '3. Precision', 'Tính toán chính xác liều lượng thuốc hiệu chỉnh trên bệnh nhân suy gan, suy thận.'),
(23, 2, 'Năng lực tự chủ', '3. Valuing', 'Thể hiện sự cẩn trọng, nghiêm túc khi duyệt đơn thuốc nhằm hạn chế tương tác có hại.');

-- CLOs cho Điều dưỡng cơ bản 1 (Module 3)
INSERT INTO `clos` (`id`, `module_id`, `code`, `domain`, `bloom_level`, `description`) VALUES
(31, 3, 'CLO1', 'Kỹ năng', '3. Precision', 'Thực hiện kỹ thuật tiêm dưới da, tiêm tĩnh mạch đúng quy trình kỹ thuật vô khuẩn.'),
(32, 3, 'Kỹ năng', '2. Manipulation', 'Đo và ghi nhận chính xác 4 dấu hiệu sinh tồn của người bệnh vào bảng theo dõi.'),
(33, 3, 'Năng lực tự chủ', '5. Characterizing', 'Thể hiện sự đồng cảm, giao tiếp lịch sự, tôn trọng quyền riêng tư của bệnh nhân.');

-- CLOs cho Sinh lý học đại cương (Module 4)
INSERT INTO `clos` (`id`, `module_id`, `code`, `domain`, `bloom_level`, `description`) VALUES
(41, 4, 'CLO1', 'Kiến thức', '2. Understand', 'Giải thích được cơ chế điều hòa huyết áp và hằng định nội môi của cơ thể.'),
(42, 4, 'Kiến thức', '3. Apply', 'Biện luận được sự thay đổi của các chỉ số sinh lý trong trạng thái lao động đặc biệt.'),
(43, 4, 'Kỹ năng', '1. Imitation', 'Thực hiện đúng kỹ thuật ghi điện tâm đồ cơ bản trên người tình nguyện.');

-- CLOs cho Tin học ứng dụng (Module 5)
INSERT INTO `clos` (`id`, `module_id`, `code`, `domain`, `bloom_level`, `description`) VALUES
(51, 5, 'CLO1', 'Kỹ năng', '2. Manipulation', 'Sử dụng thành thạo phần mềm chuyên dụng để thống kê mô tả tập mẫu dữ liệu lâm sàng.'),
(52, 5, 'Kỹ năng', '4. Articulation', 'Xây dựng được câu lệnh tìm kiếm nâng cao nâng cao để truy xuất tài liệu trên PubMed.'),
(53, 5, 'Kiến thức', '2. Understand', 'Trình bày được các quy định cốt lõi về bảo mật thông tin dữ liệu bệnh án điện tử.');


-- ---------------------------------------------------------------------
-- PHẦN PHƯƠNG PHÁP KIỂM TRA LƯỢNG GIÁ (assessments & assessment_clos)
-- ---------------------------------------------------------------------
INSERT INTO `assessments` (`id`, `module_id`, `type`, `component`, `form`, `tool`, `weight`, `plo_pi`) VALUES 
(1, 1, 'Đánh giá thường xuyên', 'Chuyên cần', 'Điểm danh lớp học', 'Sổ theo dõi lên lớp', 10.00, 'PLO1'),
(2, 1, 'Đánh giá định kỳ', 'Thi giữa kỳ thực hành', 'Chạy trạm OSPE', 'Mô hình giải phẫu', 30.00, 'PLO2'),
(3, 1, 'Thi cuối kỳ', 'Thi kết thúc môn', 'Trắc nghiệm trên máy tính', 'Ngân hàng câu hỏi MCQ', 60.00, 'PLO1'),
(4, 2, 'Thi cuối kỳ', 'Thi cuối kỳ tổng hợp', 'Trắc nghiệm khách quan', 'Phần mềm thi máy tính', 100.00, 'PLO3');

INSERT INTO `assessment_clos` (`assessment_id`, `clo_id`) VALUES 
(1, 13), (2, 11), (3, 11), (3, 12), (4, 21), (4, 22);


-- ---------------------------------------------------------------------
-- PHẦN HOẠT ĐỘNG TỰ HỌC (self_study_activities & self_study_clos)
-- ---------------------------------------------------------------------
INSERT INTO `self_study_activities` (`id`, `module_id`, `activity_name`, `duration_hours`, `method`, `assessment_method`, `evidence`) VALUES 
(1, 1, 'Nghiên cứu Hệ xương và Hệ cơ qua mô hình ảo', 30, 'Đọc giáo trình kết hợp tập atlas giải phẫu', 'Kiểm tra vấn đáp đầu giờ', 'Sổ ghi chép cá nhân'),
(2, 5, 'Thực hành phân tích tệp dữ liệu y tế mẫu', 20, 'Thao tác lại bài tập Excel/SPSS tại nhà', 'Chấm điểm sản phẩm trên LMS', 'File kết quả phân tích');

INSERT INTO `self_study_clos` (`self_study_activity_id`, `clo_id`) VALUES 
(1, 11), (2, 51);


-- ---------------------------------------------------------------------
-- PHẦN TIẾN ĐỘ GIẢNG DẠY LÝ THUYẾT (theory_topics & theory_topic_clos)
-- ---------------------------------------------------------------------
INSERT INTO `theory_topics` (`id`, `module_id`, `chapter`, `title`, `method`, `class_hours`, `self_study_hours`, `textbook_info`) VALUES 
(1, 1, 'Chương I', 'Đại cương Giải phẫu người và Hệ xương', 'Thuyết trình trực quan', 4, 12, 'Giáo trình Giải phẫu người - Chương 1'),
(2, 1, 'Chương II', 'Giải phẫu Hệ tuần hoàn và Tim', 'Thuyết trình kết hợp video 3D', 4, 12, 'Giáo trình Giải phẫu người - Chương 4'),
(3, 4, 'Chương I', 'Sinh lý học tế bào và nội môi', 'Diễn giảng và thảo luận', 5, 10, 'Sinh lý học đại cương - Chương I');

INSERT INTO `theory_topic_clos` (`theory_topic_id`, `clo_id`) VALUES 
(1, 11), (2, 12), (3, 41);


-- ---------------------------------------------------------------------
-- PHẦN TIẾN ĐỘ GIẢNG DẠY THỰC HÀNH (practical_topics & practical_topic_clos)
-- ---------------------------------------------------------------------
INSERT INTO `practical_topics` (`id`, `module_id`, `topic`, `content`, `method`, `lab_hours`, `facility_id`) VALUES 
(1, 1, 'Bài thực hành 1', 'Định danh hệ thống xương đầu mặt và xương thân mình', 'Quan sát và thực hành nhóm', 5, 1),
(2, 3, 'Bài thực hành Tiêm', 'Quy trình kỹ thuật tiêm dưới da và tiêm tĩnh mạch', 'Hướng dẫn mẫu và thao tác giả lập', 10, 2);

INSERT INTO `practical_topic_clos` (`practical_topic_id`, `clo_id`) VALUES 
(1, 11), (2, 31);


-- ---------------------------------------------------------------------
-- PHẦN TIẾN ĐỘ GIẢNG DẠY TÍCH HỢP (combined_topics & combined_topic_clos)
-- ---------------------------------------------------------------------
INSERT INTO `combined_topics` (`id`, `module_id`, `sort_order`, `content`, `method`, `theory_hours`, `practical_hours`, `self_study_hours`, `facility_id`) VALUES 
(1, 5, 1, 'Khai thác tài liệu y học nâng cao trên PubMed', 'Học kết hợp lý thuyết và thực hành máy', 3, 3, 10, 3),
(2, 5, 2, 'Nhập dữ liệu và xử lý thống kê mô tả với phần mềm', 'Học kết hợp lý thuyết và thực hành máy', 4, 4, 15, 3);

INSERT INTO `combined_topic_clos` (`combined_topic_id`, `clo_id`) VALUES 
(1, 52), (2, 51);


-- ---------------------------------------------------------------------
-- PHẦN TÀI LIỆU DẠY HỌC & CATALOGUE (resources & books_catalog)
-- ---------------------------------------------------------------------
INSERT INTO `resources` (`id`, `module_id`, `resource_type`, `sort_order`, `title`, `editor`, `publisher`, `year`, `identifier`) VALUES 
(1, 1, 'Tài liệu giảng dạy', 1, 'Giáo trình Giải phẫu học Tập 1', 'PGS.TS. Nguyễn Văn A', 'NXB Y học', '2023', 'Mã số GP2023'),
(2, 1, 'Tài liệu tự học', 2, 'Atlas Giải phẫu người (Frank H. Netter)', 'Khoa dịch thuật', 'NXB Y học', '2021', 'ISBN: 978-604-66-5012-1'),
(3, 2, 'Tài liệu giảng dạy', 1, 'Dược lý học lâm sàng đại cương', 'GS.TS. Trần Thị B', 'NXB Giáo dục', '2024', 'ISBN: 978-604-01-3445-2');

INSERT INTO `books_catalog` (`id`, `title`, `editor`, `publisher`, `year`, `identifier`) VALUES 
(1, 'Giáo trình Giải phẫu học Tập 1', 'PGS.TS. Nguyễn Văn A', 'NXB Y học', '2023', 'GP2023'),
(2, 'Atlas Giải phẫu người (Frank H. Netter)', 'Khoa dịch thuật', 'NXB Y học', '2021', '978-604-66-5012-1'),
(3, 'Dược lý học lâm sàng đại cương', 'GS.TS. Trần Thị B', 'NXB Giáo dục', '2024', '978-604-01-3445-2');

-- Bật lại kiểm tra khóa ngoại để bảo vệ tính toàn vẹn dữ liệu hệ thống
SET FOREIGN_KEY_CHECKS = 1;