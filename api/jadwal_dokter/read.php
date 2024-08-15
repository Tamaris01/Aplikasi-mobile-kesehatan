<?php
include "../db_connect.php";

// Fungsi untuk mengubah hari ke bahasa Indonesia
function hariToIndo($hari)
{
    $hariIndo = array(
        "Sunday" => "Minggu",
        "Monday" => "Senin",
        "Tuesday" => "Selasa",
        "Wednesday" => "Rabu",
        "Thursday" => "Kamis",
        "Friday" => "Jumat",
        "Saturday" => "Sabtu"
    );
    return isset($hariIndo[$hari]) ? $hariIndo[$hari] : $hari;
}

$query = "SELECT b.nama_dokter, a.* FROM jadwal_dokter a";
$query .= " LEFT JOIN dokter b ON a.nip_dokter = b.nip_dokter";
$query .= " WHERE b.status = 1"; // Menambahkan kondisi untuk dokter aktif
$result = $conn->query($query);

if ($result->num_rows > 0) {
    $jadwal_dokter_array = array();

    while ($row = $result->fetch_assoc()) {
        // Konversi hari dari format internasional ke bahasa Indonesia
        $hariIndo = hariToIndo($row["hari"]);

        $jadwal_dokter_item = array(
            "id" => $row["id"],
            "nip_dokter" => $row["nip_dokter"],
            "id_poliklinik" => $row["id_poliklinik"],
            "jam_mulai" => $row["jam_mulai"],
            "jam_selesai" => $row["jam_selesai"],
            "hari" => $hariIndo,
            "tanggal" => $row["tanggal"],
            "nama_dokter" => $row["nama_dokter"],
        );

        array_push($jadwal_dokter_array, $jadwal_dokter_item);
    }

    echo json_encode($jadwal_dokter_array);
} else {
    $response = array("status" => "error", "message" => "No data found");
    echo json_encode($response);
}

$conn->close();
?>
