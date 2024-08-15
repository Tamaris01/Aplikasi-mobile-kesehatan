<?php
header("Content-Type: application/json");

// Sertakan file koneksi database
include "../db_connect.php"; // Pastikan path ke file ini benar

// Mendapatkan parameter id_poliklinik dari query string
$id_poliklinik = isset($_GET['id_poliklinik']) ? $_GET['id_poliklinik'] : '';

// Debug: Cetak parameter id_poliklinik untuk memverifikasi
error_log("ID Poliklinik: $id_poliklinik");

// Query untuk mendapatkan data kehadiran
$sql = "
    SELECT 
        pa.nama_lengkap AS Nama_Pasien,
        pk.nama_poliklinik AS Nama_Poliklinik,
        p.tanggal_kunjungan
    FROM 
        pendaftaran p
    JOIN 
        pasien pa ON p.nik_pasien = pa.nik
    JOIN 
        poliklinik pk ON p.id_poliklinik = pk.id_poliklinik
    WHERE 
        p.status = 'hadir'
";

// Tambahkan kondisi filter jika id_poliklinik disediakan
if (!empty($id_poliklinik)) {
    $sql .= " AND p.id_poliklinik = ?";
}

$stmt = $conn->prepare($sql);

if (!empty($id_poliklinik)) {
    $stmt->bind_param("i", $id_poliklinik);
}

$stmt->execute();
$result = $stmt->get_result();

// Menyimpan data dalam array
$data = array();
while ($row = $result->fetch_assoc()) {
    $data[] = $row;
}

// Mengembalikan data dalam format JSON
echo json_encode($data);

// Menutup koneksi
$conn->close();
?>
