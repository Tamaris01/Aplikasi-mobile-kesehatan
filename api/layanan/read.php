<?php
// Sertakan file koneksi database
include "../db_connect.php";

// Periksa apakah koneksi berhasil
if ($conn->connect_error) {
    die("Koneksi gagal: " . $conn->connect_error);
}

try {
    // Persiapkan pernyataan SQL dengan placeholder
    $query = $conn->prepare("SELECT * FROM poliklinik WHERE status = ?");
    if (!$query) {
        throw new Exception("Persiapan pernyataan gagal: " . $conn->error);
    }

    // Tentukan status yang akan digunakan dalam query
    $status = 1;

    // Bind parameter ke pernyataan SQL
    $query->bind_param("i", $status);

    // Eksekusi pernyataan SQL
    $query->execute();

    // Dapatkan hasil dari eksekusi query
    $result = $query->get_result();

    // Periksa apakah ada data yang diambil
    if ($result->num_rows > 0) {
        // Ambil semua data dalam format asosiatif
        $data = $result->fetch_all(MYSQLI_ASSOC);
        // Ubah data menjadi format JSON dan tampilkan
        echo json_encode($data);
    } else {
        echo json_encode([]);
    }
} catch (Exception $e) {
    // Tangani kesalahan dengan memberikan pesan
    echo json_encode(["error" => $e->getMessage()]);
} finally {
    // Tutup pernyataan dan koneksi
    if (isset($query)) {
        $query->close();
    }
    $conn->close();
}
?>
