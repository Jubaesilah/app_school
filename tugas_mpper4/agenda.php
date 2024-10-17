<?php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE");
header("Access-Control-Allow-Headers: Content-Type");

// Konfigurasi Database
define('DB_HOST', 'localhost');               // Host server database
define('DB_USER', 'praktikum_Ojan');           // Username database
define('DB_PASS', 'daytt123*363#');           // Password database
define('DB_NAME', 'praktikum_ti_2022_KLPK_Ojan'); // Nama database
$connection = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);

if ($connection->connect_error) {
    die(json_encode(["error" => "Koneksi gagal: " . $connection->connect_error]));
}

header("Content-Type: application/json");

$method = $_SERVER['REQUEST_METHOD'];

switch ($method) {
    case 'GET':
        if (isset($_GET['kd_agenda'])) {
            $kd_agenda = $connection->real_escape_string($_GET['kd_agenda']);
            $sql = "SELECT * FROM agenda WHERE kd_agenda = '$kd_agenda'";
            $result = $connection->query($sql);
            $data = $result->fetch_assoc();
        } else {
            $sql = "SELECT * FROM agenda";
            $result = $connection->query($sql);
            $data = $result->fetch_all(MYSQLI_ASSOC);
        }
        echo json_encode(["status" => "success", "data" => $data]);
        break;

    case 'POST':
        $input = json_decode(file_get_contents('php://input'), true);
        $judul_agenda = $connection->real_escape_string($input['judul_agenda']);
        $isi_agenda = $connection->real_escape_string($input['isi_agenda']);
        $tgl_agenda = $connection->real_escape_string($input['tgl_agenda']);
        $kd_petugas = $connection->real_escape_string($input['kd_petugas']);

        $sql = "INSERT INTO agenda (judul_agenda, isi_agenda, tgl_agenda, kd_petugas) 
                VALUES ('$judul_agenda', '$isi_agenda', '$tgl_agenda', '$kd_petugas')";
        
        if ($connection->query($sql)) {
            echo json_encode(["status" => "success", "message" => "Data agenda berhasil ditambahkan"]);
        } else {
            echo json_encode(["status" => "error", "message" => "Gagal menambahkan data agenda"]);
        }
        break;

     case 'PUT':
        if (isset($_GET['kd_agenda'])) {
            $input = json_decode(file_get_contents('php://input'), true);
            $kd_agenda = $connection->real_escape_string($_GET['kd_agenda']); // Menggunakan kd_agenda dari URL
            $judul_agenda = $connection->real_escape_string($input['judul_agenda']);
            $isi_agenda = $connection->real_escape_string($input['isi_agenda']);
            $tgl_agenda = $connection->real_escape_string($input['tgl_agenda']);
            $kd_petugas = $connection->real_escape_string($input['kd_petugas']);

            $sql = "UPDATE agenda SET 
                        judul_agenda = '$judul_agenda', 
                        isi_agenda = '$isi_agenda', 
                        tgl_agenda = '$tgl_agenda', 
                        kd_petugas = '$kd_petugas' 
                    WHERE kd_agenda = '$kd_agenda'";
            
            if ($connection->query($sql)) {
                echo json_encode(["status" => "success", "message" => "Data agenda berhasil diperbarui"]);
            } else {
                echo json_encode(["status" => "error", "message" => "Gagal memperbarui data agenda"]);
            }   
        } else {
            echo json_encode(["status" => "error", "message" => "kd_agenda tidak ditemukan"]);
        }
        
        break;

    case 'DELETE':
        if (isset($_GET['kd_agenda'])) {
            $kd_agenda = $connection->real_escape_string($_GET['kd_agenda']);
            $sql = "DELETE FROM agenda WHERE kd_agenda = '$kd_agenda'";

            if ($connection->query($sql)) {
                echo json_encode(["status" => "success", "message" => "Data agenda berhasil dihapus"]);
            } else {
                echo json_encode(["status" => "error", "message" => "Gagal menghapus data agenda"]);
            }
        } else {
            echo json_encode(["status" => "error", "message" => "kd_agenda tidak ditemukan"]);
        }
        break;

    default:
        echo json_encode(["status" => "error", "message" => "Metode tidak valid"]);
        break;
}

$connection->close();
?>