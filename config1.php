<?php
header("Access-Control-Allow-Origin:*");
return array(
    'host' => 'localhost',     // ชื่อโฮสต์ของ MySQL Server
    'username' => 'root',      // ชื่อผู้ใช้ MySQL
    'password' => '',      // รหัสผ่าน MySQL (เว้นว่างไว้ถ้าไม่มีรหัสผ่าน)
    'database' => 'test',      // ชื่อฐานข้อมูลที่ต้องการใช้
);

?>  