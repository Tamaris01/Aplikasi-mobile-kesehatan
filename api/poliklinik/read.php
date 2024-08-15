<?php

include "../db_connect.php";

// Query untuk membaca data poliklinik
$query = "SELECT id_poliklinik, nama_poliklinik FROM poliklinik WHERE status = 1";
$result = $conn->query($query);

// Cek apakah data ditemukan
if ($result->num_rows > 0) {
    $poliklinik_arr = array();
   

    // Ambil data poliklinik dan tambahkan ke dalam array
    while ($row = $result->fetch_assoc()) {
        $poliklinik_item = array(
            "id_poliklinik" => $row['id_poliklinik'],
            "nama_poliklinik" => $row['nama_poliklinik']
        );
        $poliklinik_arr[]= $poliklinik_item;
    }

    // Kembalikan data dalam format JSON
    echo json_encode($poliklinik_arr);
} else {
    // Jika data tidak ditemukan, kirimkan respons kosong
    echo json_encode(array("message" => "Data poliklinik tidak ditemukan."));
}

// Menutup koneksi ke database
$conn->close();
?>

