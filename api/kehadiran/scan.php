<?php
include "../db_connect.php";

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

$id_pendaftaran = $_POST["id_pendaftaran"] ?? '';
$status = $_POST["status"] ?? '';
$id_admin = $_POST["id_admin"] ?? '';

$allowed_statuses = ["belum_dikonfirmasi", "hadir", "tidak_hadir"];
if (!in_array($status, $allowed_statuses)) {
    echo json_encode(['pesan' => 'gagal', 'error' => 'Nilai status tidak valid']);
    exit;
}

if (empty($id_pendaftaran) || empty($id_admin)) {
    echo json_encode(['pesan' => 'gagal', 'error' => 'ID Pendaftaran atau ID Admin tidak boleh kosong']);
    exit;
}

$stmt = $conn->prepare("UPDATE pendaftaran SET status=?, id_admin=? WHERE id_pendaftaran = ?");
$stmt->bind_param("ssi", $status, $id_admin, $id_pendaftaran);

if ($stmt->execute()) {
    echo json_encode(['pesan' => 'sukses']);
} else {
    echo json_encode(['pesan' => 'gagal', 'error' => 'Gagal mengupdate status']);
}

$stmt->close();
$conn->close();
?>
