<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE");
header("Access-Control-Allow-Headers: Content-Type");

// // Konfigurasi Database
define('DB_HOST', 'localhost');
define('DB_USER', 'praktikum_Ojan');
define('DB_PASS', 'daytt123*363#');
define('DB_NAME', 'praktikum_ti_2022_KLPK_Ojan');

$koneksi = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);

if ($koneksi->connect_error) {
    die(json_encode(["status" => "error", "pesan" => "Koneksi gagal: " . $koneksi->connect_error]));
}

header("Content-Type: application/json");

$metode = $_SERVER['REQUEST_METHOD'];

switch ($metode) {
    case 'GET':
        if (isset($_GET['kd_info'])) {
            $kd_info = $koneksi->real_escape_string($_GET['kd_info']);
            $query = "SELECT * FROM info WHERE kd_info = '$kd_info'";
            $hasil = $koneksi->query($query);
            $data = $hasil->fetch_assoc();
        } else {
            $query = "SELECT * FROM info ORDER BY tgl_post_info DESC";
            $hasil = $koneksi->query($query);
            $data = $hasil->fetch_all(MYSQLI_ASSOC);
        }
        
        if ($data) {
            echo json_encode(["status" => "sukses", "data" => $data]);
        } else {
            echo json_encode(["status" => "error", "pesan" => "Data tidak ditemukan"]);
        }
        break;

    case 'POST':
        $input = json_decode(file_get_contents('php://input'), true);
        $judul_info = $koneksi->real_escape_string($input['judul_info']);
        $isi_info = $koneksi->real_escape_string($input['isi_info']);
        $tgl_post_info = $koneksi->real_escape_string($input['tgl_post_info']);
        $status_info = $koneksi->real_escape_string($input['status_info']);
        $kd_petugas = $koneksi->real_escape_string($input['kd_petugas']);

        $query = "INSERT INTO info (judul_info, isi_info, tgl_post_info, status_info, kd_petugas) 
                VALUES ('$judul_info', '$isi_info', '$tgl_post_info', '$status_info', '$kd_petugas')";
        
        if ($koneksi->query($query)) {
            echo json_encode(["status" => "sukses", "pesan" => "Data berhasil ditambahkan"]);
        } else {
            echo json_encode(["status" => "error", "pesan" => "Gagal menambahkan data: " . $koneksi->error]);
        }
        break;

   
case 'PUT':
    if (isset($_GET['kd_info'])) {
        $kd_info = $koneksi->real_escape_string($_GET['kd_info']); // Ambil kd_info dari URL
        $input = json_decode(file_get_contents('php://input'), true);
        
        // Pastikan input yang diperlukan ada
        if (isset($input['judul_info'], $input['isi_info'], $input['tgl_post_info'], $input['status_info'], $input['kd_petugas'])) {
            $judul_info = $koneksi->real_escape_string($input['judul_info']);
            $isi_info = $koneksi->real_escape_string($input['isi_info']);
            $tgl_post_info = $koneksi->real_escape_string($input['tgl_post_info']);
            $status_info = $koneksi->real_escape_string($input['status_info']);
            $kd_petugas = $koneksi->real_escape_string($input['kd_petugas']);

            $query = "UPDATE info SET 
                        judul_info = '$judul_info', 
                        isi_info = '$isi_info', 
                        tgl_post_info = '$tgl_post_info', 
                        status_info = '$status_info', 
                        kd_petugas = '$kd_petugas' 
                    WHERE kd_info = '$kd_info'";
            
            if ($koneksi->query($query)) {
                echo json_encode(["status" => "sukses", "pesan" => "Data berhasil diperbarui"]);
            } else {
                echo json_encode(["status" => "error", "pesan" => "Gagal memperbarui data: " . $koneksi->error]);
            }
        } else {
            echo json_encode(["status" => "error", "message" => "Input tidak lengkap"]);
        }
    } else {
        echo json_encode(["status" => "error", "message" => "kd_info tidak ditemukan"]);
    }
    break;


    case 'DELETE':
        if (isset($_GET['kd_info'])) {
            $kd_info = $koneksi->real_escape_string($_GET['kd_info']);
            $query = "DELETE FROM info WHERE kd_info = '$kd_info'";

            if ($koneksi->query($query)) {
                echo json_encode(["status" => "sukses", "pesan" => "Data berhasil dihapus"]);
            } else {
                echo json_encode(["status" => "error", "pesan" => "Gagal menghapus data: " . $koneksi->error]);
            }
        } else {
            echo json_encode(["status" => "error", "pesan" => "kd_info tidak ditemukan"]);
        }
        break;

    default:
        echo json_encode(["status" => "error", "pesan" => "Metode tidak valid"]);
        break;
}

$koneksi->close();
?>