<?php
include "../db_connect.php";


$id_poli = $_POST["id_poliklinik"];
$nama_poli = $_POST["nama_poliklinik"];
$detail = $_POST["detail"];
$idAdmin = $_POST['id_admin'];

// Check if a new image for RS is provided
if (!empty($_FILES['foto_rs']['name'])) {
    $image_rs = $_FILES['foto_rs']['name'];
    $imagePath_rs = "images/" . $image_rs;
    move_uploaded_file($_FILES['foto_rs']['tmp_name'], $imagePath_rs);
    $updateImageRS = ", foto_rs='$image_rs'";
} else {
    $updateImageRS = "";
}

// Check if a new image for Logo is provided
if (!empty($_FILES['foto_logo']['name'])) {
    $image_logo = $_FILES['foto_logo']['name'];
    $imagePath_logo = "images/" . $image_logo;
    move_uploaded_file($_FILES['foto_logo']['tmp_name'], $imagePath_logo);
    $updateImageLogo = ", foto_logo='$image_logo'";
} else {
    $updateImageLogo = "";
}

$data = mysqli_query($conn, "UPDATE poliklinik SET id_admin = '$idAdmin', id_poliklinik='$id_poli', nama_poliklinik='$nama_poli', detail='$detail' $updateImageRS $updateImageLogo WHERE id_poliklinik = '$id_poli'");

if ($data) {
    echo json_encode(['pesan' => 'sukses']);
} else {
    echo json_encode(['pesan' => 'gagal', 'error' => mysqli_error($conn)]);
}

$conn->close();
?>