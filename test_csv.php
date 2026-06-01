<?php
$input = "'Đánh giá thường xuyên','Đánh giá định kỳ','Thi cuối kỳ'";
var_dump($input);
$values = str_getcsv($input, ',', "'");
var_dump($values);
