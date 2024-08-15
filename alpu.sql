-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Waktu pembuatan: 15 Agu 2024 pada 05.32
-- Versi server: 10.11.8-MariaDB-cll-lve
-- Versi PHP: 7.2.34

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `u494752211_aplikasi_alpu`
--

-- --------------------------------------------------------

--
-- Struktur dari tabel `admin`
--

CREATE TABLE `admin` (
  `id` varchar(18) NOT NULL,
  `nama_lengkap` varchar(50) NOT NULL,
  `foto` varchar(255) NOT NULL,
  `kata_sandi` varchar(256) NOT NULL,
  `email` varchar(50) NOT NULL,
  `nomor_telepon` varchar(12) NOT NULL,
  `alamat` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `admin`
--

INSERT INTO `admin` (`id`, `nama_lengkap`, `foto`, `kata_sandi`, `email`, `nomor_telepon`, `alamat`) VALUES
('1234567890', 'Admin RS', 'images (6).jpg', '$2y$10$tFORHtfxElySqwM2hoR20utwRCU1o.xv4D9vAfWm569.wwM87z.zO', 'admin@gmail.com', '082171475115', 'Jalan Melati No. 123');

-- --------------------------------------------------------

--
-- Struktur dari tabel `dokter`
--

CREATE TABLE `dokter` (
  `nip_dokter` varchar(20) NOT NULL,
  `id_admin` varchar(18) NOT NULL,
  `id_poliklinik` varchar(10) NOT NULL,
  `nama_dokter` varchar(50) NOT NULL,
  `alamat` text NOT NULL,
  `no_telepon` varchar(12) NOT NULL,
  `foto` varchar(255) NOT NULL,
  `status` int(11) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `dokter`
--

INSERT INTO `dokter` (`nip_dokter`, `id_admin`, `id_poliklinik`, `nama_dokter`, `alamat`, `no_telepon`, `foto`, `status`) VALUES
('19720120 200602 001', '1234567890', 'P017', 'Dr. Amelia Anderson', 'Jl. Akupuntur No. 14', '081234567890', 'Dr Amelia Anderson.png', 0),
('19720315 200603 002', '1234567890', 'P004', 'Dr. Billy Bagas', 'Jl. Bedah Digestif No. 2', '081234567891', 'Dr Billy.png', 0),
('19720418 200604 003', '1234567890', 'P019', 'Dr. Boy Sandy ', 'Jl. Bedah Mulut No. 3', '081234567895', 'Dr Boy.png', 1),
('19720522 200605 004', '1234567890', 'P020', 'Dr. Budi', 'Jl. Bedah Onkologi No. 4', '081234567893', 'Dr Budi.png', 0),
('19720630 200606 005', '1234567890', 'P007', 'Dr. Cristian', 'Jl. Bedah Syaraf No. 5', '081234567894', 'Dr Cristian.png', 1),
('19720725 200607 006', '1234567890', 'P003', 'Dr. Cristine', 'Jl. Bedah No. 6', '081234567895', 'Dr Cristine.png', 1),
('19720810 200608 007', '1234567890', 'P016', 'Dr. Evelyn Carter', 'Jl. Gigi No. 7', '081234567896', 'Dr Evelyn Carter.png', 1),
('19720914 200609 008', '1234567890', 'P008', 'Dr. Grace', 'Jl. Gizi No. 8', '081234567897', 'Dr Grace.png', 1),
('19721018 200610 009', '1234567890', 'P005', 'Dr. Isabella Nguyen', 'Jl. Jantung No. 9', '081234567898', 'Dr Isabella Nguyen.png', 1),
('19721122 200611 010', '1234567890', 'P018', 'Dr. Jhosua', 'Jl. Jiwa No. 10', '081234567899', 'Dr Jhosua.png', 1),
('19721230 200612 011', '1234567890', 'P011', 'Dr. Lily Johnson', 'Jl. Kebidanan No. 11', '081234567900', 'Dr Lily Johnson.png', 1),
('19800120 200613 012', '1234567890', 'P012', 'Dr. Maxwell', 'Jl. Kesehatan Jiwa No. 12', '081234567901', 'Dr Maxwell.png', 1),
('19800325 200614 013', '1234567890', 'P009', 'Dr. Olivia Brown', 'Jl. Medical Check Up No. 13', '081234567902', 'Dr Olivia Brown.png', 1),
('19800518 200615 014', '1234567890', 'P013', 'Dr. Richard', 'Jl. Napza dan Metadon No. 14', '081234567903', 'Dr Richard.png', 1),
('19800630 200616 015', '1234567890', 'P014', 'Dr. Sherina', 'Jl. Orthopae Di No. 15', '081234567904', 'Dr Sherina.png', 1),
('19800810 200617 016', '1234567890', 'P015', 'Dr. Tifany', 'Jl. Penyakit Dalam No. 16', '081234567905', 'Dr Tifany.png', 1),
('19801015 200618 017', '1234567890', 'P006', 'Dr. Tomi Wilson', 'Jl. THT No. 17', '081234567906', 'Dr Tomi Wilson.png', 1),
('19801120 200619 018', '1234567890', 'P010', 'Dr. Yolanda', 'Jl. Urologi No. 18', '081234567907', 'Dr Yolanda.png', 1),
('19801218 200620 019', '1234567890', 'P001', 'Dr. Zoe Clark', 'Jl. Anak No. 19', '081234567908', 'Dr Zoe Clark.png', 1),
('19810305 200621 020', '1234567890', 'P002', 'Dr. Bagas', 'Jl. Kulit No. 20', '081234567909', 'Dr Bagas.png', 1),
('19810525 200622 021', '1234567890', 'P021', 'Dr. Jhonatan', 'Jl. Mata No. 21', '081234567910', 'Dr Jhonatan.png', 1);

-- --------------------------------------------------------

--
-- Struktur dari tabel `jadwal_dokter`
--

CREATE TABLE `jadwal_dokter` (
  `id` int(11) NOT NULL,
  `id_poliklinik` varchar(10) NOT NULL,
  `jam_mulai` time NOT NULL,
  `jam_selesai` time NOT NULL,
  `hari` varchar(10) NOT NULL,
  `tanggal` date NOT NULL,
  `id_admin` varchar(18) NOT NULL,
  `nip_dokter` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `jadwal_dokter`
--

INSERT INTO `jadwal_dokter` (`id`, `id_poliklinik`, `jam_mulai`, `jam_selesai`, `hari`, `tanggal`, `id_admin`, `nip_dokter`) VALUES
(1, 'P017', '09:00:00', '16:00:00', 'Senin', '2024-08-05', '1234567890', '19720120 200602 001'),
(2, 'P004', '08:00:00', '16:00:00', 'Senin', '2024-08-05', '1234567890', '19720315 200603 002'),
(7, 'P016', '06:00:00', '16:00:00', 'Senin', '2024-08-05', '1234567890', '19720810 200608 007'),
(8, 'P008', '08:00:00', '16:00:00', 'Senin', '2024-08-05', '1234567890', '19720914 200609 008'),
(9, 'P005', '08:00:00', '16:00:00', 'Senin', '2024-08-05', '1234567890', '19721018 200610 009'),
(10, 'P018', '08:00:00', '16:00:00', 'Senin', '2024-08-05', '1234567890', '19721122 200611 010'),
(11, 'P011', '08:00:00', '16:00:00', 'Senin', '2024-08-05', '1234567890', '19721230 200612 011'),
(12, 'P012', '08:00:00', '16:00:00', 'Senin', '2024-08-05', '1234567890', '19800120 200613 012'),
(13, 'P009', '08:00:00', '16:00:00', 'Senin', '2024-08-05', '1234567890', '19800325 200614 013'),
(14, 'P013', '08:00:00', '16:00:00', 'Senin', '2024-08-05', '1234567890', '19800518 200615 014'),
(15, 'P014', '08:00:00', '16:00:00', 'Senin', '2024-08-05', '1234567890', '19800630 200616 015'),
(16, 'P015', '08:00:00', '16:00:00', 'Senin', '2024-08-05', '1234567890', '19800810 200617 016'),
(17, 'P006', '08:00:00', '16:00:00', 'Senin', '2024-08-05', '1234567890', '19801015 200618 017'),
(18, 'P010', '08:00:00', '16:00:00', 'Senin', '2024-08-05', '1234567890', '19801120 200619 018'),
(43, 'P001', '08:19:00', '16:19:00', 'Kamis', '2024-08-08', '1234567890', '19801218 200620 019');

-- --------------------------------------------------------

--
-- Struktur dari tabel `pasien`
--

CREATE TABLE `pasien` (
  `nik` varchar(16) NOT NULL,
  `id_admin` varchar(18) NOT NULL,
  `nomor_rekam_medis` int(20) NOT NULL,
  `nama_lengkap` varchar(50) NOT NULL,
  `foto` varchar(255) NOT NULL,
  `kata_sandi` varchar(255) NOT NULL,
  `email` varchar(50) NOT NULL,
  `no_telepon` varchar(15) NOT NULL,
  `alamat` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `pasien`
--

INSERT INTO `pasien` (`nik`, `id_admin`, `nomor_rekam_medis`, `nama_lengkap`, `foto`, `kata_sandi`, `email`, `no_telepon`, `alamat`) VALUES
('2171060906039004', '1234567890', 3, 'Zico Alfredo', 'FB_IMG_1722752236159.jpg', '$2y$10$R/GdX1hV.GUlE2vAiJUJ6u6BmFmDcLio.2zcz264qB2AV2YMog1U.', 'zicoalfredo05@gmail.com', '081779060190', 'Bengkong Indah'),
('2171115607019007', '1234567890', 1, 'Tamaris Roulina S', 'IMG_20231008_134641.jpg', '$2y$10$9qcspB1H31DM0yLPAFrz4Ox79vBXFIfA6MR0eD3qzYGu/Y7D5AHW.', 'tamarissilitonga@gmail.com', '082171475991', 'Batu Aji Baru Blok B 15 no 32-33'),
('2171115709020002', '1234567890', 2, 'Elsa Marina Silalahi ', 'IMG_20231008_134641.jpg', '$2y$10$jB6MeXszqyzFg1uWJPdqFOcqq2C7NeM87X700EQikMlW8pGKpcure', 'elsarn13@gmail.com', '081261628843', 'Buana impian');

-- --------------------------------------------------------

--
-- Struktur dari tabel `pendaftaran`
--

CREATE TABLE `pendaftaran` (
  `id_pendaftaran` int(11) NOT NULL,
  `nik_pasien` varchar(16) NOT NULL,
  `id_poliklinik` varchar(10) NOT NULL,
  `nip_dokter` varchar(20) DEFAULT NULL,
  `tanggal_kunjungan` date NOT NULL,
  `status` enum('belum_dikonfirmasi','hadir','tidak_hadir') NOT NULL DEFAULT 'belum_dikonfirmasi',
  `id_admin` varchar(18) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `pendaftaran`
--

INSERT INTO `pendaftaran` (`id_pendaftaran`, `nik_pasien`, `id_poliklinik`, `nip_dokter`, `tanggal_kunjungan`, `status`, `id_admin`) VALUES
(80, '2171115607019007', 'P005', '19721018 200610 009', '2024-07-30', 'hadir', '1234567890'),
(81, '2171115607019007', 'P001', '19801218 200620 019', '2024-08-01', 'hadir', '1234567890'),
(82, '2171115607019007', 'P002', '19810305 200621 020', '2024-08-01', 'hadir', '1234567890'),
(83, '2171115607019007', 'P008', '19720914 200609 008', '2024-08-01', 'tidak_hadir', '1234567890'),
(85, '2171115607019007', 'P002', '19810305 200621 020', '2024-08-02', 'hadir', '1234567890'),
(86, '2171115607019007', 'P006', '19801015 200618 017', '2024-08-02', 'hadir', '1234567890'),
(87, '2171115607019007', 'P008', '19720914 200609 008', '2024-08-02', 'hadir', '1234567890'),
(88, '2171115607019007', 'P009', '19800325 200614 013', '2024-08-02', 'hadir', '1234567890'),
(89, '2171115607019007', 'P003', '19720725 200607 006', '2024-08-02', 'hadir', '1234567890'),
(90, '2171115607019007', 'P002', '19810305 200621 020', '2024-08-03', 'hadir', '1234567890'),
(91, '2171115607019007', 'P001', '19801218 200620 019', '2024-08-03', 'hadir', '1234567890'),
(92, '2171115607019007', 'P001', '19801218 200620 019', '2024-08-03', 'hadir', '1234567890'),
(93, '2171115607019007', 'P003', '19720725 200607 006', '2024-08-03', 'hadir', '1234567890'),
(94, '2171115607019007', 'P001', '19801218 200620 019', '2024-08-04', 'hadir', '1234567890'),
(95, '2171115607019007', 'P001', '19801218 200620 019', '2024-08-05', 'tidak_hadir', '1234567890'),
(96, '2171115607019007', 'P002', '19810305 200621 020', '2024-08-05', 'belum_dikonfirmasi', NULL),
(97, '2171115607019007', 'P001', '19801218 200620 019', '2024-08-05', 'tidak_hadir', '1234567890'),
(98, '2171115607019007', 'P003', '19720725 200607 006', '2024-08-05', 'belum_dikonfirmasi', NULL),
(99, '2171115607019007', 'P005', '19721018 200610 009', '2024-08-05', 'belum_dikonfirmasi', NULL),
(100, '2171115709020002', 'P002', '19810305 200621 020', '2024-08-05', 'belum_dikonfirmasi', NULL),
(101, '2171115709020002', 'P001', '19801218 200620 019', '2024-08-06', 'belum_dikonfirmasi', NULL),
(102, '2171115709020002', 'P001', '19801218 200620 019', '2024-08-05', 'hadir', '1234567890'),
(103, '2171115709020002', 'P001', '19801218 200620 019', '2024-08-05', 'hadir', '1234567890'),
(104, '2171115607019007', 'P001', '19801218 200620 019', '2024-08-05', 'tidak_hadir', '1234567890'),
(105, '2171115709020002', 'P001', '19801218 200620 019', '2024-08-05', 'hadir', '1234567890'),
(106, '2171115709020002', 'P001', '19801218 200620 019', '2024-08-05', 'hadir', '1234567890'),
(107, '2171115709020002', 'P001', '19801218 200620 019', '2024-08-06', 'hadir', '1234567890'),
(108, '2171115607019007', 'P001', '19801218 200620 019', '2024-08-06', 'belum_dikonfirmasi', NULL),
(109, '2171115709020002', 'P001', '19801218 200620 019', '2024-08-06', 'hadir', '1234567890'),
(110, '2171060906039004', 'P001', '19801218 200620 019', '2024-08-07', 'hadir', '1234567890'),
(111, '2171115607019007', 'P001', '19801218 200620 019', '2024-08-08', 'tidak_hadir', '1234567890');

-- --------------------------------------------------------

--
-- Struktur dari tabel `poliklinik`
--

CREATE TABLE `poliklinik` (
  `id_poliklinik` varchar(10) NOT NULL,
  `nama_poliklinik` varchar(50) NOT NULL,
  `detail` text NOT NULL,
  `foto_logo` varchar(255) NOT NULL,
  `foto_rs` varchar(255) NOT NULL,
  `id_admin` varchar(18) NOT NULL,
  `status` int(11) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `poliklinik`
--

INSERT INTO `poliklinik` (`id_poliklinik`, `nama_poliklinik`, `detail`, `foto_logo`, `foto_rs`, `id_admin`, `status`) VALUES
('P001', 'Poli Anak', 'Poliklinik anak di rumah sakit ini menyediakan layanan kesehatan untuk bayi, anak, dan remaja. Dipimpin oleh dokter anak berpengalaman, poliklinik ini menawarkan perawatan pencegahan, diagnosis, dan pengobatan untuk berbagai kondisi kesehatan anak dan lain lain..', 'Logo Poli Anak.png', 'Poli Anak.jpg', '1234567890', 1),
('P002', 'Poli Kulit', 'Poliklinik kulit di rumah sakit ini menyediakan layanan untuk diagnosis dan perawatan gangguan kulit. Dipimpin oleh dokter kulit berpengalaman, poliklinik ini menawarkan konsultasi, terapi, dan prosedur dermatologi untuk meningkatkan kesehatan dan penampilan kulit.', 'Logo Poli Kulit.png', 'Poli Kulit.jpg', '1234567890', 0),
('P003', 'Poli Bedah', 'Poliklinik bedah di rumah sakit ini menawarkan berbagai layanan bedah umum untuk menangani berbagai kondisi kesehatan. Dengan tim ahli bedah yang berpengalaman, poliklinik ini memberikan perawatan yang aman dan efektif melalui prosedur bedah modern.', 'Logo Poli Bedah.png', 'Poli Bedah.jpg', '1234567890', 1),
('P004', 'Poli Bedah Digestif', 'Poliklinik bedah digestif di rumah sakit ini menangani gangguan dan penyakit yang mempengaruhi sistem pencernaan, termasuk kerongkongan, lambung, hati, dan usus. Didukung oleh tim ahli bedah dan staf medis berpengalaman, poliklinik ini menyediakan diagnosis yang tepat dan berbagai prosedur bedah untuk memulihkan kesehatan pasien.', 'Logo Poli Bedah Digestif.png', 'Poli Bedah Digestif.jpg', '1234567890', 1),
('P005', 'Poli Jantung', 'Poliklinik jantung di rumah sakit ini menyediakan layanan untuk diagnosis dan pengobatan penyakit kardiovaskular. Didukung oleh kardiologis dan staf medis terampil, poliklinik ini menawarkan pemeriksaan jantung, tes diagnostik, dan manajemen penyakit jantung secara komprehensif.', 'Logo Poli Jantung.png', 'Poli Jantung.jpg', '1234567890', 1),
('P006', 'Poli THT', 'Poliklinik THT (Telinga, Hidung, Tenggorokan) di rumah sakit ini menawarkan layanan untuk diagnosis dan pengobatan gangguan yang mempengaruhi telinga, hidung, dan tenggorokan. Dengan tim dokter THT yang terlatih, poliklinik ini menyediakan perawatan medis dan bedah untuk berbagai kondisi.', 'Logo Poli THT.png', 'Poli THT.jpg', '1234567890', 1),
('P007', 'Poli Bedah Syaraf', 'Poliklinik bedah syaraf di rumah sakit ini menyediakan perawatan untuk kondisi yang mempengaruhi sistem saraf pusat dan perifer. Dipimpin oleh ahli bedah saraf, poliklinik ini menawarkan layanan mulai dari konsultasi hingga intervensi bedah untuk berbagai kondisi neurologis.', 'Logo Poli Bedah Syaraf.png', 'Poli Bedah Syaraf.jpg', '1234567890', 1),
('P008', 'Poli Gizi', 'Poliklinik gizi di rumah sakit ini menawarkan layanan konsultasi gizi dan diet untuk membantu pasien mencapai kesehatan optimal. Dengan bimbingan dari ahli gizi berlisensi, poliklinik ini memberikan penilaian gizi dan menyusun rencana diet yang disesuaikan dengan kebutuhan individu.', 'Logo Poli Gizi.png', 'Poli Gizi.jpg', '1234567890', 1),
('P009', 'Poli Medical Check Up', 'Poliklinik medical check up di rumah sakit ini menawarkan layanan pemeriksaan kesehatan menyeluruh untuk mendeteksi dini kondisi medis. Dipimpin oleh tim dokter berpengalaman, poliklinik ini menyediakan paket pemeriksaan kesehatan yang disesuaikan dengan kebutuhan individu.', 'Logo Poli Medical Check Up.png', 'Poli Medical Check Up.jpg', '1234567890', 1),
('P010', 'Poli Urologi', 'Poliklinik urologi di rumah sakit ini menyediakan layanan untuk diagnosis dan pengobatan gangguan yang mempengaruhi sistem kemih dan reproduksi pria. Dipimpin oleh ahli urologi berpengalaman, poliklinik ini menawarkan berbagai prosedur diagnostik dan terapeutik.', 'Logo Poli Urologi.png', 'Poli Urologi.jpg', '1234567890', 1),
('P011', 'Poli Kebidanan', 'Poliklinik kebidanan di rumah sakit ini menyediakan layanan kesehatan untuk ibu dan bayi, termasuk pemeriksaan kehamilan, persalinan, dan perawatan pascapersalinan. Dipimpin oleh dokter kandungan dan bidan terlatih, poliklinik ini menawarkan pendekatan perawatan yang komprehensif dan dukungan untuk kesehatan ibu dan anak.', 'Logo Poli Kebidanan.png', 'Poli Kebidanan.jpg', '1234567890', 1),
('P012', 'Poli Kesehatan Jiwa', 'Poliklinik kesehatan jiwa di rumah sakit ini menawarkan layanan kesehatan mental dan psikologis untuk membantu individu mengatasi masalah emosional dan mental. Dengan tim terapis dan psikiater berpengalaman, poliklinik ini menyediakan terapi individu, kelompok, dan keluarga.', 'Logo Poli Kesehatan Jiwa.png', 'Poli Kesehatan Jiwa.jpg', '1234567890', 1),
('P013', 'Poli Napza dan Metadon', 'Poliklinik napza dan metadon di rumah sakit ini menyediakan layanan untuk pengobatan ketergantungan obat dan rehabilitasi. Dengan tim profesional kesehatan mental dan dokter berlisensi, poliklinik ini menawarkan program terapi dan dukungan untuk membantu pasien pulih dari kecanduan.', 'Logo Poli Napza dan Metadon.png', 'Poli Napza dan Metadon.jpg', '1234567890', 1),
('P014', 'Poli Orthopae Di', 'Poliklinik orthopae di rumah sakit ini menyediakan layanan untuk diagnosis dan perawatan gangguan muskuloskeletal. Dipimpin oleh ahli ortopedi berpengalaman, poliklinik ini menawarkan konsultasi, terapi fisik, dan intervensi bedah untuk memulihkan fungsi dan mobilitas pasien.', 'Logo Poli Orthopae Di.png', 'Poli Orthopae Di.jpg', '1234567890', 1),
('P015', 'Poli Penyakit Dalam', 'Poliklinik penyakit dalam di rumah sakit ini menyediakan layanan untuk diagnosis dan pengobatan berbagai penyakit dalam yang mempengaruhi organ internal. Dipimpin oleh dokter penyakit dalam berpengalaman, poliklinik ini menawarkan pendekatan komprehensif untuk manajemen kesehatan pasien.', 'Logo Poli Penyakit Dalam.png', 'Poli Penyakit Dalam.jpg', '1234567890', 1),
('P016', 'Poli Gigi', 'Poliklinik gigi di rumah sakit ini adalah fasilitas khusus yang menyediakan layanan perawatan gigi dan mulut. Dipimpin oleh dokter gigi dan staf medis terlatih, poliklinik ini menangani berbagai masalah mulai dari pemeriksaan gigi rutin, perawatan karies, pembersihan gigi, hingga perawatan periodontal dan prosedur restoratif seperti penambalan dan penempelan mahkota gigi. Selain itu, poliklinik gigi juga bisa menyediakan layanan konsultasi, edukasi tentang perawatan gigi, dan pencegahan masalah kesehatan gigi di masa mendatang.', 'Logo Poli Gigi.png', 'Poli Gigi.jpg', '1234567890', 1),
('P017', 'Poli Akupuntur', 'Poliklinik akupuntur di rumah sakit ini menawarkan layanan pengobatan tradisional China yang menggunakan teknik memasukkan jarum tipis ke dalam tubuh untuk meredakan nyeri dan mengatasi berbagai kondisi kesehatan. Dipimpin oleh praktisi terlatih, poliklinik ini memberikan perawatan yang dipersonalisasi dan disesuaikan dengan kebutuhan pasien.', 'Logo Poli Akupuntur.png', 'Poli Akupuntur.jpg', '1234567890', 1),
('P018', 'Poli Jiwa', 'Poliklinik jiwa di rumah sakit ini memberikan layanan kesehatan mental untuk individu dari segala usia. Dipimpin oleh psikiater dan psikolog berpengalaman, poliklinik ini menawarkan penilaian, terapi, dan dukungan untuk mengatasi berbagai kondisi kesehatan mental.', 'Logo Poli Jiwa.png', 'Poli Jiwa.jpg', '1234567890', 1),
('P019', 'Poli Bedah Mulut', 'Poliklinik bedah mulut di rumah sakit ini menyediakan layanan khusus untuk operasi mulut dan wajah. Dipimpin oleh ahli bedah mulut, poliklinik ini menawarkan perawatan untuk berbagai kondisi seperti gigi impaksi, kelainan rahang, dan tumor mulut.', 'Logo Poli Bedah Mulut.png', 'Poli Bedah Mulut.jpg', '1234567890', 1),
('P020', 'Poli Bedah Onkologi', 'Poliklinik bedah onkologi di rumah sakit ini fokus pada diagnosis dan perawatan bedah pasien kanker. Didukung oleh ahli onkologi bedah, poliklinik ini menawarkan pendekatan komprehensif untuk pengelolaan dan pengobatan kanker dengan teknologi mutakhir dan prosedur bedah canggih.', 'Logo Poli Bedah Onkologi.png', 'Poli Bedah Onkologi.jpg', '1234567890', 1),
('P021', 'Poli Mata', 'Poliklinik mata di rumah sakit ini menyediakan layanan untuk diagnosis dan pengobatan gangguan mata dan penglihatan. Dengan tim ahli mata terlatih, poliklinik ini menawarkan pemeriksaan mata rutin, perawatan kondisi mata, dan prosedur bedah mata.', 'Logo Poli Mata.png', 'Poli Mata.jpg', '1234567890', 0);

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `admin`
--
ALTER TABLE `admin`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `dokter`
--
ALTER TABLE `dokter`
  ADD PRIMARY KEY (`nip_dokter`),
  ADD KEY `id_admin` (`id_admin`),
  ADD KEY `id_poliklinik` (`id_poliklinik`);

--
-- Indeks untuk tabel `jadwal_dokter`
--
ALTER TABLE `jadwal_dokter`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_poliklinik` (`id_poliklinik`),
  ADD KEY `id_admin` (`id_admin`),
  ADD KEY `jadwal_dokter_ibfk_1` (`nip_dokter`);

--
-- Indeks untuk tabel `pasien`
--
ALTER TABLE `pasien`
  ADD PRIMARY KEY (`nik`),
  ADD KEY `id_admin` (`id_admin`);

--
-- Indeks untuk tabel `pendaftaran`
--
ALTER TABLE `pendaftaran`
  ADD PRIMARY KEY (`id_pendaftaran`),
  ADD KEY `nik_pasien` (`nik_pasien`),
  ADD KEY `id_poliklinik` (`id_poliklinik`),
  ADD KEY `nip_dokter` (`nip_dokter`),
  ADD KEY `id_admin` (`id_admin`);

--
-- Indeks untuk tabel `poliklinik`
--
ALTER TABLE `poliklinik`
  ADD PRIMARY KEY (`id_poliklinik`),
  ADD KEY `id_admin` (`id_admin`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `jadwal_dokter`
--
ALTER TABLE `jadwal_dokter`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=44;

--
-- AUTO_INCREMENT untuk tabel `pendaftaran`
--
ALTER TABLE `pendaftaran`
  MODIFY `id_pendaftaran` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=112;

--
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `dokter`
--
ALTER TABLE `dokter`
  ADD CONSTRAINT `dokter_ibfk_1` FOREIGN KEY (`id_admin`) REFERENCES `admin` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `dokter_ibfk_2` FOREIGN KEY (`id_poliklinik`) REFERENCES `poliklinik` (`id_poliklinik`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ketidakleluasaan untuk tabel `jadwal_dokter`
--
ALTER TABLE `jadwal_dokter`
  ADD CONSTRAINT `jadwal_dokter_ibfk_1` FOREIGN KEY (`nip_dokter`) REFERENCES `dokter` (`nip_dokter`),
  ADD CONSTRAINT `jadwal_dokter_ibfk_2` FOREIGN KEY (`id_poliklinik`) REFERENCES `poliklinik` (`id_poliklinik`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `jadwal_dokter_ibfk_3` FOREIGN KEY (`id_admin`) REFERENCES `admin` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ketidakleluasaan untuk tabel `pasien`
--
ALTER TABLE `pasien`
  ADD CONSTRAINT `pasien_ibfk_1` FOREIGN KEY (`id_admin`) REFERENCES `admin` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ketidakleluasaan untuk tabel `pendaftaran`
--
ALTER TABLE `pendaftaran`
  ADD CONSTRAINT `pendaftaran_ibfk_1` FOREIGN KEY (`nik_pasien`) REFERENCES `pasien` (`nik`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `pendaftaran_ibfk_2` FOREIGN KEY (`id_poliklinik`) REFERENCES `poliklinik` (`id_poliklinik`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `pendaftaran_ibfk_3` FOREIGN KEY (`nip_dokter`) REFERENCES `dokter` (`nip_dokter`),
  ADD CONSTRAINT `pendaftaran_ibfk_4` FOREIGN KEY (`id_admin`) REFERENCES `admin` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ketidakleluasaan untuk tabel `poliklinik`
--
ALTER TABLE `poliklinik`
  ADD CONSTRAINT `poliklinik_ibfk_1` FOREIGN KEY (`id_admin`) REFERENCES `admin` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
