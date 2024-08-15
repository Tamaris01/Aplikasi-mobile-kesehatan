<?php
include "../db_connect.php";

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

$id_pendaftaran = $_POST['id_pendaftaran'] ?? '';

if (empty($id_pendaftaran)) {
    echo json_encode(['status' => 'error', 'message' => 'ID pendaftaran tidak diberikan']);
    exit();
}

$query = "SELECT status FROM pendaftaran WHERE id_pendaftaran = ?";
$stmt = $conn->prepare($query);
$stmt->bind_param('s', $id_pendaftaran);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $row = $result->fetch_assoc();
    $status = $row['status'];
    echo json_encode(['status' => $status]);
} else {
    echo json_encode(['status' => 'error', 'message' => 'ID pendaftaran tidak ditemukan']);
}

$stmt->close();
$conn->close();
?>
