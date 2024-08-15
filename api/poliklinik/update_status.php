<?php
include "../db_connect.php";

// Periksa ketersediaan variabel POST
$id = $_POST['id_poliklinik'];
$status = $_POST['status'];

$data = mysqli_query($conn, "UPDATE poliklinik 
    SET  
    status = '$status'
    WHERE id_poliklinik = '".$id."'");

if ($data) {
    echo json_encode(['message' => 'Data poli berhasil diubah']);
} else {
    echo json_encode(['message' => 'Gagal mengubah data poli', 'error' => mysqli_error($conn)]);
}

$conn->close();
?>