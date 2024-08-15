<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

// Koneksi ke database
$servername = "localhost";
$username = "u494752211_tamarisroulina";
$password = "Verynise_16";
$dbname = "u494752211_aplikasi_alpu";


$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Koneksi ke database gagal: " . $conn->connect_error);
}
 