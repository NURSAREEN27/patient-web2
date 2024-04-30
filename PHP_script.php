<?php
// กำหนดสิทธิ์การเข้าถึงทรัพยากรสำหรับแอพพลิเคชันอื่น ๆ
header("Access-Control-Allow-Origin: *");

// เรียกใช้ไฟล์คอนฟิกเพื่อรับค่าการเชื่อมต่อฐานข้อมูล
$config = include_once("config1.php");

// เชื่อมต่อฐานข้อมูล MySQL
$mysqli = new mysqli($config['host'], $config['username'], $config['password'], $config['database']);

// ตรวจสอบการเชื่อมต่อฐานข้อมูล
if ($mysqli->connect_error) {
    die("การเชื่อมต่อล้มเหลว: " . $mysqli->connect_error);
}

// เพิ่มข้อมูล
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // ตรวจสอบว่ามีข้อมูลที่จำเป็นครบหรือไม่
    if (isset($_POST['name']) && isset($_POST['lastName']) && isset($_POST['position'])) {
        $name = $_POST['name'];
        $lastname = $_POST['lastName'];
        $position = $_POST['position'];

        // ใช้คำสั่ง prepared statement เพื่อป้องกันการโจมตี SQL Injection
        $sql = "INSERT INTO datahh (Name, Lastname, Position) VALUES (?, ?, ?)";
        $stmt = $mysqli->prepare($sql);
        $stmt->bind_param("sss", $name, $lastname, $position);

        if ($stmt->execute()) {
            echo "บันทึกข้อมูลใหม่เรียบร้อยแล้ว";
        } else {
            echo "เกิดข้อผิดพลาด: " . $sql . "<br>" . $mysqli->error;
        }
    } else {
        echo "เกิดข้อผิดพลาด: ข้อมูลไม่ครบถ้วน";
    }
}

// ลบข้อมูล
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    parse_str(file_get_contents("php://input"), $data);
    if (isset($data['_method']) && $data['_method'] == 'DELETE' && isset($data['id'])) {
        $id = $data['id']; 

        
        $sql = "DELETE FROM datahh WHERE ID = ?";
        $stmt = $mysqli->prepare($sql);
        $stmt->bind_param("i", $id);

        if ($stmt->execute()) {
            echo "ลบรายการเรียบร้อยแล้ว";
        } else {
            echo "เกิดข้อผิดพลาด: " . $sql . "<br>" . $mysqli->error;
        }
    }
}

// เรียกข้อมูล
if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    $result = $mysqli->query("SELECT * FROM datahh");
    $rows = array();
    while ($row = $result->fetch_assoc()) {
        $rows[] = $row;
    }
    echo json_encode($rows);
}



// อัปเดตข้อมูล
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    parse_str(file_get_contents("php://input"), $data);
    if (isset($data['_method']) && $data['_method'] == 'UPDATE' && isset($data['id'])) {
        $id = $data['id']; 
        $name = $data['name']; // เพิ่มการรับค่า name
        $lastname = $data['lastname']; // เพิ่มการรับค่า lastname
        $position = $data['position']; // เพิ่มการรับค่า position

        // ทำการอัปเดตข้อมูลในฐานข้อมูล
        $sql = "UPDATE datahh SET Name = ?, Lastname = ?, Position = ? WHERE ID = ?";
        $stmt = $mysqli->prepare($sql);
        
        // ตรวจสอบว่า prepared statement สามารถเตรียมได้สำเร็จหรือไม่
        if ($stmt) {
            // ทำการ bind parameters
            $stmt->bind_param("sssi", $name, $lastname, $position, $id);
            
            if ($stmt->execute()) {
                echo "อัปเดตข้อมูลเรียบร้อยแล้ว";
            } else {
                echo "เกิดข้อผิดพลาดในการอัปเดตข้อมูล: " . $stmt->error;
            }
        } else {
            echo "เกิดข้อผิดพลาดในการเตรียมคำสั่ง: " . $mysqli->error;
        }
    }
}




?>
