/*
 Navicat Premium Data Transfer

 Source Server         : qldt
 Source Server Type    : MySQL
 Source Server Version : 50544 (5.5.44-0ubuntu0.14.04.1)
 Source Host           : 10.1.64.12:3306
 Source Schema         : dccthp

 Target Server Type    : MySQL
 Target Server Version : 50544 (5.5.44-0ubuntu0.14.04.1)
 File Encoding         : 65001

 Date: 04/05/2026 14:00:11
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for activities
-- ----------------------------
DROP TABLE IF EXISTS `activities`;
CREATE TABLE `activities`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `module_id` int(11) NOT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `clos_codes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  `duration_hours` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `method` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  `assessment` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  `evidence` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `module_id`(`module_id`) USING BTREE,
  CONSTRAINT `activities_ibfk_1` FOREIGN KEY (`module_id`) REFERENCES `modules` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Compact;

-- ----------------------------
-- Records of activities
-- ----------------------------
INSERT INTO `activities` VALUES (1, 11, 'Đọc tài liệu, giáo trình trước buổi học', 'CLO1, CLO2', '6', 'Đọc tài liệu, ghi chú', 'Kiểm tra nhanh/quiz đầu giờ', 'Bài quiz, phiếu ghi chú');
INSERT INTO `activities` VALUES (2, 11, 'Làm bài tập tình huống, thảo luận online', 'CLO2, CLO3', '8', 'Nghiên cứu case study, trả lời câu hỏi', 'Bài tập nhóm, báo cáo ngắn', 'Bản word/pdf nộp LMS');
INSERT INTO `activities` VALUES (3, 12, 'Câu hỏi ngắn, trắc nghiệm, vẽ hình', 'CLO1, CLO2', '10', 'GV nêu mục tiêu, người học tìm, đọc và trả lời các nội dung tự học, nộp; GV giao hình ảnh, người học vẽ và nộp', 'Đánh giá thang điểm 10 bài tập nhóm, hình vẽ', 'Phiếu trả lời, Hình vẽ');
INSERT INTO `activities` VALUES (4, 12, 'Học e-learning', 'CLO2, CLO3', '10', 'Tham khảo bài giảng trên hệ thống e-learning, chuẩn bị nội dung trả lời cho bài mới.', 'MCQ, câu hỏi ngắn', 'Phiếu trả lời trực tuyến');

-- ----------------------------
-- Table structure for assessments
-- ----------------------------
DROP TABLE IF EXISTS `assessments`;
CREATE TABLE `assessments`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `module_id` int(11) NOT NULL,
  `clos_codes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  `plo_pi` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  `form` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `tool` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `weight` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `module_id`(`module_id`) USING BTREE,
  CONSTRAINT `assessments_ibfk_1` FOREIGN KEY (`module_id`) REFERENCES `modules` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Compact;

-- ----------------------------
-- Records of assessments
-- ----------------------------
INSERT INTO `assessments` VALUES (1, 11, 'CLO1:Trình bày quá trình hình thành và phát triển của triết học Mác-Lênin và vai trò của triết học trong đời sống.', 'PLO1, PI1.1', 'Chuyên cần + Thi viết', 'Điểm danh, câu hỏi ngắn, đáp án', '15%');
INSERT INTO `assessments` VALUES (2, 11, 'CLO2: Giải thích những nội dung cơ bản của chủ nghĩa duy vật biện chứng và phương pháp luận biện chứng duy vật.', 'PLO2, PI2.1', 'Kiểm tra thường xuyên', 'Bài tập tình huống, rubric', '20%');
INSERT INTO `assessments` VALUES (3, 12, 'CLO1', 'PLO1, PI1.1', 'Chuyên cần', 'Kiểm tra đầu giờ/cuối giờ bằng MCQ', '0-5%');
INSERT INTO `assessments` VALUES (4, 12, 'CLO2', 'PLO2, PI2.1', 'Kiểm tra thường xuyên', 'Trả lời ngắn trong giờ LT, TH', '0-5%');
INSERT INTO `assessments` VALUES (5, 12, 'CLO3', 'PLO2, PI2.1', 'Kiểm tra thường xuyên', 'Điểm chuyên đề nhóm ', '0-5%');
INSERT INTO `assessments` VALUES (6, 12, 'CLO4', 'PLO2, PI2.1', 'Kiểm tra thường xuyên', 'Kiểm tra thực hành', '45-35%');
INSERT INTO `assessments` VALUES (7, 12, 'CLO5', 'PLO3, PI3.1', 'Thi kết thúc', 'Trắc nghiệm', '55%');

-- ----------------------------
-- Table structure for clos
-- ----------------------------
DROP TABLE IF EXISTS `clos`;
CREATE TABLE `clos`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `module_id` int(11) NOT NULL,
  `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  `domain` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `bloom_level` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `module_id`(`module_id`) USING BTREE,
  CONSTRAINT `clos_ibfk_1` FOREIGN KEY (`module_id`) REFERENCES `modules` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 13 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Compact;

-- ----------------------------
-- Records of clos
-- ----------------------------
INSERT INTO `clos` VALUES (1, 11, 'CLO1', 'Trình bày quá trình hình thành và phát triển của triết học Mác-Lênin và vai trò của triết học trong đời sống.', 'Kiến thức', '2');
INSERT INTO `clos` VALUES (2, 11, 'CLO2', 'Giải thích những nội dung cơ bản của chủ nghĩa duy vật biện chứng và phương pháp luận biện chứng duy vật.', 'Kiến thức', '3');
INSERT INTO `clos` VALUES (3, 11, 'CLO3', 'Giải quyết các nội dung cơ bản của chủ nghĩa duy vật lịch sử.', 'Kiến thức', '3');
INSERT INTO `clos` VALUES (4, 11, 'CLO4', 'Vận dụng các nguyên lý cơ bản của triết học Mác – Lênin vào quá trình nhận thức và hoạt động thực tiễn.', 'Kỹ năng', '3');
INSERT INTO `clos` VALUES (5, 11, 'CLO5', 'Ý thức được vai trò, trách nhiệm của bản thân đối với sự phát triển của xã hội; xây dựng và củng cố niềm tin, lý tưởng cách mạng cho bản thân.', 'Thái độ', '3');
INSERT INTO `clos` VALUES (6, 12, 'CLO1', 'Có thái độ tôn trọng ngành học, môn học, xác ướp và tiêu bản học tập.', 'Thái độ', '3');
INSERT INTO `clos` VALUES (7, 12, 'CLO2', 'Kể tên theo vị trí, lớp các thành phần cấu thành chi trên, chi dưới, đầu mặt cổ. ', 'Kiến thức,\r\nKỹ năng', '2,2');
INSERT INTO `clos` VALUES (8, 12, 'CLO3', 'Mô tả hình thể và liên quan theo vùng của chi trên, chi dưới, đầu mặt cổ. ', 'Kiến thức,\r\nKỹ năng', '3,3');
INSERT INTO `clos` VALUES (9, 12, 'CLO4', 'Hệ thống được kiến thức về nguyên ủy, đường đi, phân nhánh, vùng cấp máu, chi phối của mạch máu, thần kinh vùng chi trên, chi dưới, đầu mặt cổ. ', 'Kiến thức,\r\nKỹ năng', '3,3');
INSERT INTO `clos` VALUES (10, 12, 'CLO5', 'Mô tả hình thể, cấu tạo, liên quan, cấp máu, và chi phối của các cơ quan đầu mặt cổ.', 'Kiến thức,\r\nKỹ năng', '3,3');
INSERT INTO `clos` VALUES (11, 12, 'CLO6', 'So sánh đặc điểm giải phẫu của chi trên, chi dưới. ', 'Kiến thức,\r\nKỹ năng', '4,3');
INSERT INTO `clos` VALUES (12, 12, 'CLO7', 'Vận dụng đặc điểm giải phẫu để giải thích các biểu hiện lâm sàng và cơ chế một số chấn thương thường gặp trên lâm sàng vùng chi trên, chi dưới, đầu mặt cổ. ', 'Kiến thức,\r\nKỹ năng', '5,4');

-- ----------------------------
-- Table structure for combined_topics
-- ----------------------------
DROP TABLE IF EXISTS `combined_topics`;
CREATE TABLE `combined_topics`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `module_id` int(11) NOT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  `method` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `theory_hours` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `practical_hours` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `selfstudy_hours` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `clos_codes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `module_id`(`module_id`) USING BTREE,
  CONSTRAINT `combined_topics_ibfk_1` FOREIGN KEY (`module_id`) REFERENCES `modules` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Compact;

-- ----------------------------
-- Records of combined_topics
-- ----------------------------
INSERT INTO `combined_topics` VALUES (1, 11, 'Nội dung 1', 'Hình thức ', '30', '10', '10', 'CLO3');
INSERT INTO `combined_topics` VALUES (3, 12, 'Bài 3: Xương khớp chi trên', 'Thuyết trình ngắn, Bài tập nhóm', '2', '3', '4', 'CLO2');
INSERT INTO `combined_topics` VALUES (4, 12, 'Bài 4: Nách và đám rối thần kinh cánh tay', 'Thuyết trình ngắn, Bài tập nhóm', '2', '2', '4', 'CLO2');
INSERT INTO `combined_topics` VALUES (5, 12, 'Bài 5: Cánh tay và khuỷu', 'Thuyết trình ngắn, Bài tập nhóm', '2', '2', '4', 'CLO3');
INSERT INTO `combined_topics` VALUES (6, 12, 'Bài 6: Cẳng tay – Bàn tay', 'Thuyết trình ngắn, Bài tập nhóm', '2', '2', '4', 'CLO3');
INSERT INTO `combined_topics` VALUES (7, 12, 'Bài 7: Xương khớp chi dưới', 'Thuyết trình ngắn, Bài tập nhóm', '2', '3', '4', 'CLO3');

-- ----------------------------
-- Table structure for courses
-- ----------------------------
DROP TABLE IF EXISTS `courses`;
CREATE TABLE `courses`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `major_id` int(11) NOT NULL,
  `block_id` int(11) NULL DEFAULT NULL,
  `sort_order` int(11) NULL DEFAULT 0,
  `code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `total_hours` int(11) NULL DEFAULT 0,
  `theory_hours` int(11) NULL DEFAULT 0,
  `practice_hours` int(11) NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `major_id`(`major_id`) USING BTREE,
  INDEX `block_id`(`block_id`) USING BTREE,
  CONSTRAINT `courses_ibfk_1` FOREIGN KEY (`major_id`) REFERENCES `majors` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `courses_ibfk_2` FOREIGN KEY (`block_id`) REFERENCES `knowledge_blocks` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Compact;

-- ----------------------------
-- Records of courses
-- ----------------------------
INSERT INTO `courses` VALUES (1, 2, 2, 1, 'CT1', 'Chính trị', 11, 11, 0);
INSERT INTO `courses` VALUES (2, 2, 2, 2, 'XHH', 'Xã hội học y tế', 3, 3, 0);
INSERT INTO `courses` VALUES (3, 2, 2, 3, 'GDQP', 'Giáo dục quốc phòng-an ninh', 8, 6, 2);
INSERT INTO `courses` VALUES (4, 2, 2, 4, 'GDTC', 'Giáo dục thể chất', 3, 1, 2);
INSERT INTO `courses` VALUES (5, 2, 2, 5, 'TTK', 'Toán xác suất thống kê và thống kê y tế', 3, 2, 1);
INSERT INTO `courses` VALUES (6, 2, 2, 6, 'CNYT', 'Công nghệ y tế', 3, 2, 1);
INSERT INTO `courses` VALUES (7, 2, 2, 7, 'NN', 'Ngoại ngữ', 6, 6, 0);
INSERT INTO `courses` VALUES (8, 2, 2, 8, 'PPNK', 'Phương pháp nghiên cứu khoa học sức khoẻ/dự án học thuật', 2, 1, 1);
INSERT INTO `courses` VALUES (9, 2, 3, 9, 'NY', 'Nghề Y và tính chuyên nghiệp', 3, 2, 1);
INSERT INTO `courses` VALUES (10, 2, 3, 10, 'TCQLYT', 'Tổ chức và quản lý y tế (tên mới)', 3, 2, 1);

-- ----------------------------
-- Table structure for knowledge_blocks
-- ----------------------------
DROP TABLE IF EXISTS `knowledge_blocks`;
CREATE TABLE `knowledge_blocks`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `major_id` int(11) NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `parent_id` int(11) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `major_id`(`major_id`) USING BTREE,
  INDEX `parent_id`(`parent_id`) USING BTREE,
  CONSTRAINT `knowledge_blocks_ibfk_1` FOREIGN KEY (`major_id`) REFERENCES `majors` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `knowledge_blocks_ibfk_2` FOREIGN KEY (`parent_id`) REFERENCES `knowledge_blocks` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 13 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Compact;

-- ----------------------------
-- Records of knowledge_blocks
-- ----------------------------
INSERT INTO `knowledge_blocks` VALUES (1, 2, 'Kiến thức giáo dục đại cương', NULL);
INSERT INTO `knowledge_blocks` VALUES (2, 2, 'Những vấn đề chung', 1);
INSERT INTO `knowledge_blocks` VALUES (3, 2, 'Giáo dục nghề nghiệp', 1);
INSERT INTO `knowledge_blocks` VALUES (4, 2, 'Kiến thức giáo dục chuyên nghiệp', NULL);
INSERT INTO `knowledge_blocks` VALUES (5, 2, 'Tác động bên ngoài', 4);
INSERT INTO `knowledge_blocks` VALUES (6, 2, 'Cơ thể sống', 4);
INSERT INTO `knowledge_blocks` VALUES (7, 2, 'Chuyên ngành', 4);
INSERT INTO `knowledge_blocks` VALUES (8, 2, 'Module tự chọn', 4);
INSERT INTO `knowledge_blocks` VALUES (9, 2, 'Tự chọn I (chọn 2 trong 4 Module)', 4);
INSERT INTO `knowledge_blocks` VALUES (10, 2, 'Tự chọn II (chọn 2 trong 5 Module)', 4);
INSERT INTO `knowledge_blocks` VALUES (11, 2, 'Lĩnh vực 3: Trao đổi học thuật', 4);
INSERT INTO `knowledge_blocks` VALUES (12, 2, 'Thực tế chuyên ngành (Chọn 1 trong 4 HP)', 4);

-- ----------------------------
-- Table structure for majors
-- ----------------------------
DROP TABLE IF EXISTS `majors`;
CREATE TABLE `majors`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 14 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Compact;

-- ----------------------------
-- Records of majors
-- ----------------------------
INSERT INTO `majors` VALUES (2, 'Y Khoa');
INSERT INTO `majors` VALUES (3, 'Dược học');
INSERT INTO `majors` VALUES (4, 'Răng Hàm Mặt');
INSERT INTO `majors` VALUES (5, 'Kỹ Thuật Xét Nghiệm Y Học');
INSERT INTO `majors` VALUES (6, 'Điều Dưỡng');
INSERT INTO `majors` VALUES (7, 'Y Tế Công Cộng');
INSERT INTO `majors` VALUES (8, 'Y học cổ truyền');
INSERT INTO `majors` VALUES (9, 'Hộ sinh');
INSERT INTO `majors` VALUES (10, 'Dinh dưỡng');
INSERT INTO `majors` VALUES (11, 'Kỹ thuật Hình ảnh y học');
INSERT INTO `majors` VALUES (12, 'Kỹ thuật Phục hồi chức năng');
INSERT INTO `majors` VALUES (13, 'Kỹ thuật Y sinh');

-- ----------------------------
-- Table structure for modules
-- ----------------------------
DROP TABLE IF EXISTS `modules`;
CREATE TABLE `modules`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `credits` int(11) NULL DEFAULT NULL,
  `total_hours` int(11) NULL DEFAULT NULL,
  `self_study_hours` int(11) NULL DEFAULT NULL,
  `target_programs` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  `prerequisite_codes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  `prior_codes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  `departments` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  `description_en` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  `objectives` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  `grading_scale` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `name_vn` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `name_en` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 13 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Compact;

-- ----------------------------
-- Records of modules
-- ----------------------------
INSERT INTO `modules` VALUES (11, 'CB0310', 3, 45, 90, 'Y khoa', '', '', 'Bộ môn Khoa học Mác – Lênin và tư tưởng Hồ Chí Minh', 'Học phần Triết học Mác - Lênin cung cấp hệ thống kiến thức cơ bản về triết học, triết học Mác – Lênin và vai trò của triết học Mác – Lênin trong đời sống xã hội. Học phần được học bằng hình thức trực tiếp trên giảng đường, kết hợp với elearning với các phương pháp dạy học chủ yếu là: thuyết trình ngắn gián đoạn, nêu vấn đề, bài tập nhóm, tự học. Học phần là cơ sở lý luận quan trọng trong việc hình thành thế giới quan và phương pháp luận cho hoạt động nhận thức và hoạt động thực tiễn của sinh viên. Thông qua học phần, sinh viên hình thành tư duy khoa học ứng dụng trong học tập và cuộc sống.', NULL, 'Học phần này trang bị cho người học:\r\n3.1. Trình bày những kiến thức có tính nền tảng và hệ thống về triết học và triết học Mác-Lênin.\r\n3.2. Xây dựng thế giới quan duy vật và phương pháp luận biện chứng duy vật làm nền tảng lý luận cho việc nhận thức các vấn đề, nội dung các môn học khác.\r\n3.3. Nhận thức thực chất giá trị, bản chất khoa học, cách mạng của Triết học Mác-Lênin đối với việc hình thành hệ tư tưởng của Đảng.\r\n3.4. Vận dụng tri thức triết học Mác - Lênin, thế giới quan duy vật và phương pháp luận biện chứng duy vật để rèn luyện tư duy khoa học trong học tập và cuộc sống.\r\n', 'Học phần được đánh giá theo thang điểm 10. \r\nPhòng Đào tạo đại học sẽ quy đổi điểm học phần từ thang điểm 10 về thang điểm 4 và điểm chữ tương ứng theo quy định đào tạo tín chỉ.\r\n', '2026-01-13 10:05:16', 'TRIẾT HỌC MÁC - LÊNIN', 'MARXIST AND LENINIST PHILOSOPHY');
INSERT INTO `modules` VALUES (12, 'YY0101', 3, 60, 60, 'Y khoa', '', '', 'Bộ môn Giải phẫu', 'Giải phẫu I là học phần mở đầu trong các học phần giải phẫu nhằm giới thiệu cho sinh viên nắm được vị trí và tầm quan trọng của giải phẫu học trong khối ngành khoa học sức khỏe nói chung và y học nói riêng, định nghĩa, phạm vi và cách gọi tên trong giải phẫu học, các phương tiện và phương pháp học giải phẫu. Sinh viên được học lý thuyết về cấu tạo tứ chi, đầu mặt cổ của cơ thể bình thường và thực hành trên mô hình, xác ướp để mô tả vị trí, hình thể ngoài, hình thể trong và mối liên quan của xương, cơ, mạch máu và thần kinh của tứ chi, đầu mặt cổ. Phương pháp lượng giá là kiểm tra đầu và cuối giờ, trả lời ngắn, đánh giá tự học, kiểm tra thực tập và thi trắc nghiệm', NULL, 'Học phần này nhằm trang bị cho người học:\r\n3.1. Kiến thức về hình thái, cấu tạo, mối liên quan giữa các chi tiết, cơ quan ở vùng chi trên, chi dưới và đầu mặt cổ.\r\n3.2. Kỹ năng xác định các mốc giải phẫu trên cơ thể, từ đó ứng dụng vào thăm khám, chẩn đoán lâm sàng ở vùng chi trên, chi dưới, đầu mặt cổ.\r\n3.3. Kỹ năng xác định các vị trí trọng yếu và liên quan giải phẫu ở chi trên, chi dưới, đầu mặt cổ; từ đó thực hiện các thủ thuật, phẫu thuật trên lâm sàng, hạn chế tai biến.\r\n', 'Học phần được đánh giá theo thang điểm 10. \r\nPhòng Đào tạo đại học sẽ quy đổi điểm học phần từ thang điểm 10 về thang điểm 4 và điểm chữ tương ứng theo quy định đào tạo tín chỉ.\r\n', '2026-01-13 10:18:45', 'GIẢI PHẪU I\r\nGiải phẫu chi trên, chi dưới, đầu mặt cổ\r\n', 'ANATOMY I\r\nUpper limb, Lower limb, Head & Neck\r\n');

-- ----------------------------
-- Table structure for practical_topics
-- ----------------------------
DROP TABLE IF EXISTS `practical_topics`;
CREATE TABLE `practical_topics`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `module_id` int(11) NOT NULL,
  `topic` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  `method` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `lab_hours` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `clos_codes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  `facility` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `module_id`(`module_id`) USING BTREE,
  CONSTRAINT `practical_topics_ibfk_1` FOREIGN KEY (`module_id`) REFERENCES `modules` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Compact;

-- ----------------------------
-- Records of practical_topics
-- ----------------------------
INSERT INTO `practical_topics` VALUES (2, 12, 'Chủ đề thực hành', 'Nội dung thực hành', 'Hình thức', '10', 'CLO1', 'Bệnh viện Nhi đồng');

-- ----------------------------
-- Table structure for resources
-- ----------------------------
DROP TABLE IF EXISTS `resources`;
CREATE TABLE `resources`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `module_id` int(11) NOT NULL,
  `type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `title` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  `editor` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `publisher` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `year` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `identifier` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `module_id`(`module_id`) USING BTREE,
  CONSTRAINT `resources_ibfk_1` FOREIGN KEY (`module_id`) REFERENCES `modules` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Compact;

-- ----------------------------
-- Records of resources
-- ----------------------------
INSERT INTO `resources` VALUES (1, 11, 'Tài liệu giảng dạy', '1. Giáo trình Triết học Mác-Lênin ', 'Bộ Giáo dục và Đào tạo ', 'Nhà xuất bản Chính trị quốc gia Sự thật, Hà Nội', '2021', 'YCT.034735');
INSERT INTO `resources` VALUES (2, 11, 'Tài liệu tự học', '1. Văn kiện đại hội đại biểu toàn quốc lần thứ XIII, tập I, II', 'Đảng Cộng sản Việt Nam ', 'Nhà xuất bản Chính trị quốc gia Sự thật, Hà Nội', '2021', 'YCT.034799\r\nYCT.034806');
INSERT INTO `resources` VALUES (3, 11, 'Tài liệu tự học', '2.Tài liệu học tập Tư tưởng Hồ Chí Minh', 'Trần Thị Hồng Lê, Lương Thị Hoài Thanh ', 'Trường Đại học Y Dược Cần Thơ, Cần Thơ', '2021', 'GT.002139');
INSERT INTO `resources` VALUES (4, 12, 'Tài liệu giảng dạy', '1.Giải Phẫu học, tập 1', 'Nguyễn Văn Lâm ', 'NXB Y học TP.HCM.', '2021', 'YCT.032356');
INSERT INTO `resources` VALUES (5, 12, 'Tài liệu tự học', '1.Atlas Giải Phẫu Người (bản dịch tiếng Việt)', 'Nguyễn Quang Quyền và Phạm Đăng Diệu ', 'NXB Y học TP HCM', '2019', 'YCT.023756');
INSERT INTO `resources` VALUES (6, 12, 'Tài liệu tự học', '2.Bài giảng Giải Phẫu Học, tập 1', 'Lê Văn Cường ', 'NXB Y học TP HCM.', '2019', 'YCT.018269');
INSERT INTO `resources` VALUES (7, 12, 'Tài liệu tự học', '3. Giải Phẫu Chi trên Chi dưới và G+iải Phẫu Đầu mặt cổ', 'Phạm Đăng Diệu ', 'NXB Y học TP HCM.', '2018', 'YCT.017567');
INSERT INTO `resources` VALUES (8, 12, 'Tài liệu tự học', '4. Gray’s anatomy for students, Philadelphia', 'Drake, Richard R ', 'PA: ChurchilS Livingstone', '2020', 'YCT.001800');
INSERT INTO `resources` VALUES (9, 12, 'Tài liệu tự học', '5. Atlas of Human Anatomy, 7th', 'Frank M. Netter ', 'Elservier, Philadelphia', '2018', 'YCTS.03054');

-- ----------------------------
-- Table structure for theory_topics
-- ----------------------------
DROP TABLE IF EXISTS `theory_topics`;
CREATE TABLE `theory_topics`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `module_id` int(11) NOT NULL,
  `chapter` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `title` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  `method` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `class_hours` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `selfstudy_hours` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `clos_codes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `module_id`(`module_id`) USING BTREE,
  CONSTRAINT `theory_topics_ibfk_1` FOREIGN KEY (`module_id`) REFERENCES `modules` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Compact;

-- ----------------------------
-- Records of theory_topics
-- ----------------------------
INSERT INTO `theory_topics` VALUES (1, 11, 'Chương 1', 'Khái luận về triết học và triết học Mác - Lênin', 'Thuyết trình ngắn gián đoạn', '10', '20', 'CLO1');
INSERT INTO `theory_topics` VALUES (2, 12, 'Bài 1', 'Nhập môn Giải Phẫu Học ', 'Thuyết trình ngắn', '1', '2', 'CLO1');
INSERT INTO `theory_topics` VALUES (3, 12, 'Chương 1', 'Chi trên – Chi dưới', NULL, NULL, NULL, NULL);
INSERT INTO `theory_topics` VALUES (4, 12, 'Bài 2', 'Đại cương hệ vận động', 'Thuyết trình ngắn', '1', '2', 'CLO1');
INSERT INTO `theory_topics` VALUES (5, 11, 'Bài 1', 'Giới thiệu về học phần\r\nKhái luận về triết học và vấn đề cơ bản của triết học\r\n', 'Thuyết trình ngắn gián đoạn', '4', '8', 'CLO1');
INSERT INTO `theory_topics` VALUES (6, 11, 'Bài 2', 'Triết học Mác – Lênin và vai trò của triết học Mác – Lênin trong đời sống xã hội', 'Thuyết trình ngắn gián đoạn', '6', '12', 'CLO1');
INSERT INTO `theory_topics` VALUES (7, 11, 'Chương 2', 'Chủ nghĩa duy vật biện chứng', 'Thuyết trình ngắn gián đoạn', '18', '36', 'CLO2');
INSERT INTO `theory_topics` VALUES (8, 11, 'Bài 3', 'Vật chất và ý thức', 'Thuyết trình ngắn gián đoạn', '6', '12', 'CLO2');
INSERT INTO `theory_topics` VALUES (9, 11, 'Bài 4', 'Phép biện chứng duy vật', 'Thuyết trình ngắn gián đoạn', '7', '14', 'CLO2');
INSERT INTO `theory_topics` VALUES (10, 11, 'Bài 4', 'Lý luận nhận thức', 'Thuyết trình ngắn gián đoạn', '5', '10', 'CLO2');

SET FOREIGN_KEY_CHECKS = 1;s
