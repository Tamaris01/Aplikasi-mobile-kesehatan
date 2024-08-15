<?php
include "../db_connect.php";

$nik = $_POST['nik'];
$idAdmin = $_POST['id_admin'];
$namaLengkap = $_POST['nama_lengkap'];
$foto = $_POST['foto'];
$email = $_POST['email'];
$noTelepon = $_POST['no_telepon'];
$alamat = $_POST['alamat'];
$newPassword = $_POST['new_password'];

if (!empty($newPassword)) {
    // Hash password baru sebelum menyimpannya ke database
    $hashedPassword = password_hash($newPassword, PASSWORD_BCRYPT);
    
    $stmt = $conn->prepare("UPDATE pasien 
                            SET id_admin = ?, nama_lengkap = ?, 
                                foto = ?, email = ?, no_telepon = ?, alamat = ?, kata_sandi = ?
                            WHERE nik = ?");
    $stmt->bind_param("ssssssss", $idAdmin, $namaLengkap, $foto, $email, $noTelepon, $alamat, $hashedPassword, $nik);
} else {
    $stmt = $conn->prepare("UPDATE pasien 
                            SET id_admin = ?, nama_lengkap = ?, 
                                foto = ?, email = ?, no_telepon = ?, alamat = ?
                            WHERE nik = ?");
    $stmt->bind_param("sssssss", $idAdmin, $namaLengkap, $foto, $email, $noTelepon, $alamat, $nik);
}

if ($stmt->execute()) {
    echo json_encode(['message' => 'Data pasien berhasil diperbarui']);
} else {
    http_response_code(403);
    echo json_encode(['message' => 'Gagal memperbarui data pasien', 'error' => $conn->error]);
}

$stmt->close();
$conn->close();
?>
