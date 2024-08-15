<?php
include "../db_connect.php";

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

$id_pendaftaran = $_POST['id_pendaftaran'] ?? '';
$status = $_POST['status'] ?? '';
$id_admin = $_POST['id_admin'] ?? '';

if (empty($id_pendaftaran) || empty($status) || empty($id_admin)) {
    echo json_encode(['pesan' => 'error', 'error' => 'Data tidak lengkap']);
    exit();
}

$query = "UPDATE pendaftaran SET status = ?, id_admin = ? WHERE id_pendaftaran = ? AND status = 'belum_dikonfirmasi'";
$stmt = $conn->prepare($query);
$stmt->bind_param('sis', $status, $id_admin, $id_pendaftaran);

if ($stmt->execute()) {
    if ($stmt->affected_rows > 0) {
        echo json_encode(['pesan' => 'sukses']);
    } else {
        echo json_encode(['pesan' => 'error', 'error' => 'Status sudah diperbarui atau tidak ditemukan']);
    }
} else {
    echo json_encode(['pesan' => 'error', 'error' => 'Gagal memperbarui status']);
}

$stmt->close();
$conn->close();
?>
