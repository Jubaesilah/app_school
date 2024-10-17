<?php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE");
header("Access-Control-Allow-Headers: Content-Type");

define('DB_HOST', 'localhost');
define('DB_USER', 'praktikum_Ojan');
define('DB_PASS', 'daytt123*363#');
define('DB_NAME', 'praktikum_ti_2022_KLPK_Ojan');

$connection = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);

if ($connection->connect_error) {
    die(json_encode(["status" => "error", "pesan" => "Koneksi gagal: " . $connection->connect_error]));
}

header("Content-Type: application/json");

$method = $_SERVER['REQUEST_METHOD'];

switch ($method) {
    case 'GET':
        if (isset($_GET['kd_galery'])) {
            $kd_galery = $connection->real_escape_string($_GET['kd_galery']);
            $sql = "SELECT * FROM galery WHERE kd_galery = '$kd_galery'";
            $result = $connection->query($sql);
            $data = $result->fetch_assoc();
        } else {
            $sql = "SELECT * FROM galery";
            $result = $connection->query($sql);
            $data = $result->fetch_all(MYSQLI_ASSOC);
        }
        echo json_encode(["status" => "sukses", "data" => $data]);
        break;

    case 'POST':
        $target_dir = "uploads/";
        $target_file = $target_dir . basename($_FILES["foto_galery"]["name"]);
        $uploadOk = 1;
        $imageFileType = strtolower(pathinfo($target_file, PATHINFO_EXTENSION));

        // Cek apakah file gambar adalah gambar sebenarnya atau file palsu
        $check = getimagesize($_FILES["foto_galery"]["tmp_name"]);
        if($check === false) {
            echo json_encode(["status" => "error", "pesan" => "File bukan gambar."]);
            $uploadOk = 0;
        }

        // Cek ukuran file
        if ($_FILES["foto_galery"]["size"] > 500000) {
            echo json_encode(["status" => "error", "pesan" => "File terlalu besar."]);
            $uploadOk = 0;
        }

        // Izinkan hanya format tertentu
        if(!in_array($imageFileType, ['jpg', 'png', 'jpeg', 'gif'])) {
            echo json_encode(["status" => "error", "pesan" => "Hanya file JPG, JPEG, PNG & GIF yang diizinkan."]);
            $uploadOk = 0;
        }

        // Cek apakah $uploadOk diatur ke 0 oleh kesalahan
        if ($uploadOk == 0) {
            echo json_encode(["status" => "error", "pesan" => "File tidak diupload."]);
        } else {
            if (move_uploaded_file($_FILES["foto_galery"]["tmp_name"], $target_file)) {
                $judul_galery = $connection->real_escape_string($_POST['judul_galery']);
                $foto_galery = $connection->real_escape_string(basename($_FILES["foto_galery"]["name"]));
                $isi_galery = $connection->real_escape_string($_POST['isi_galery']);
                $tgl_post_galery = $connection->real_escape_string($_POST['tgl_post_galery']);
                $status_galery = $connection->real_escape_string($_POST['status_galery']);
                $kd_petugas = $connection->real_escape_string($_POST['kd_petugas']);

                $sql = "INSERT INTO galery (judul_galery, foto_galery, isi_galery, tgl_post_galery, status_galery, kd_petugas) 
                        VALUES ('$judul_galery', '$foto_galery', '$isi_galery', '$tgl_post_galery', '$status_galery', '$kd_petugas')";
                
                if ($connection->query($sql)) {
                    echo json_encode(["status" => "sukses", "pesan" => "Data galery berhasil ditambahkan"]);
                } else {
                    echo json_encode(["status" => "error", "pesan" => "Gagal menambahkan data galery: " . $connection->error]);
                }
            } else {
                echo json_encode(["status" => "error", "pesan" => "Gagal mengupload file."]);
            }
        }
        break;

    case 'PUT':
        if (!isset($_GET['kd_galery'])) {
            echo json_encode(["status" => "error", "pesan" => "ID Gallery diperlukan"]);
            break;
        }

        $kd_galery = $connection->real_escape_string($_GET['kd_galery']);
        
        // Periksa apakah gallery ada
        $check_sql = "SELECT * FROM galery WHERE kd_galery = '$kd_galery'";
        $check_result = $connection->query($check_sql);
        if ($check_result->num_rows == 0) {
            echo json_encode(["status" => "error", "pesan" => "Gallery tidak ditemukan"]);
            break;
        }
        $existing_gallery = $check_result->fetch_assoc();

        // Ambil raw input
        $input = json_decode(file_get_contents('php://input'), true);
        if (json_last_error() !== JSON_ERROR_NONE) {
            echo json_encode(["status" => "error", "pesan" => "Invalid JSON data"]);
            break;
        }

        // Validasi input
        $required_fields = ['judul_galery', 'isi_galery', 'tgl_post_galery', 'status_galery', 'kd_petugas'];
        $missing_fields = array_diff($required_fields, array_keys($input));
        if (!empty($missing_fields)) {
            echo json_encode(["status" => "error", "pesan" => "Ada field yang belum diisi", "missing_fields" => $missing_fields]);
            break;
        }

        // Validasi status_galery
        if (!in_array($input['status_galery'], ['0', '1', 0, 1], true)) {
            echo json_encode(["status" => "error", "pesan" => "Status galery harus 0 atau 1"]);
            break;
        }

        // Periksa perubahan data
        $is_data_changed = false;
        foreach ($required_fields as $field) {
            if ($field !== 'foto_galery' && $existing_gallery[$field] != $input[$field]) {
                $is_data_changed = true;
                break;
            }
        }

        // Proses foto jika ada
        $foto_galery = $existing_gallery['foto_galery'];
        if (isset($input['foto_galery']) && !empty($input['foto_galery'])) {
            $is_data_changed = true;
            $base64_image = $input['foto_galery'];
            $image_data = base64_decode(preg_replace('#^data:image/\w+;base64,#i', '', $base64_image));
            
            $file_info = finfo_open();
            $mime_type = finfo_buffer($file_info, $image_data, FILEINFO_MIME_TYPE);
            finfo_close($file_info);

            $allowed_types = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif'];
            if (!in_array($mime_type, $allowed_types)) {
                echo json_encode(["status" => "error", "pesan" => "File tidak valid", "file_error" => "File harus berupa gambar (jpg, png, gif)"]);
                break;
            }

            if (strlen($image_data) > 2 * 1024 * 1024) {
                echo json_encode(["status" => "error", "pesan" => "File tidak valid", "file_error" => "Ukuran file tidak boleh lebih dari 2MB"]);
                break;
            }

            $file_extension = explode('/', $mime_type)[1];
            $foto_galery = bin2hex(random_bytes(16)) . '.' . $file_extension;
            $file_path = "uploads/" . $foto_galery;
            
            if (!file_put_contents($file_path, $image_data)) {
                echo json_encode(["status" => "error", "pesan" => "Gagal mengunggah gambar"]);
                break;
            }

            // Hapus file lama jika bukan placeholder
            if ($existing_gallery['foto_galery'] !== 'placeholder_image.png' && file_exists("uploads/" . $existing_gallery['foto_galery'])) {
                unlink("uploads/" . $existing_gallery['foto_galery']);
            }
        }

        if (!$is_data_changed) {
            echo json_encode(["status" => "sukses", "pesan" => "Tidak ada perubahan pada gallery", "data" => $existing_gallery]);
            break;
        }

        $judul_galery = $connection->real_escape_string($input['judul_galery']);
        $isi_galery = $connection->real_escape_string($input['isi_galery']);
        $tgl_post_galery = $connection->real_escape_string($input['tgl_post_galery']);
        $status_galery = (int)$input['status_galery'];
        $kd_petugas = $connection->real_escape_string($input['kd_petugas']);

        $sql = "UPDATE galery SET 
                    judul_galery = '$judul_galery', 
                    foto_galery = '$foto_galery', 
                    isi_galery = '$isi_galery', 
                    tgl_post_galery = '$tgl_post_galery', 
                    status_galery = $status_galery, 
                    kd_petugas = '$kd_petugas' 
                WHERE kd_galery = '$kd_galery'";
        
        if ($connection->query($sql)) {
            $updated_gallery = [
                "kd_galery" => $kd_galery,
                "judul_galery" => $judul_galery,
                "foto_galery" => $foto_galery,
                "isi_galery" => $isi_galery,
                "tgl_post_galery" => $tgl_post_galery,
                "status_galery" => $status_galery,
                "kd_petugas" => $kd_petugas
            ];
            echo json_encode(["status" => "sukses", "pesan" => "Gallery berhasil diperbarui", "data" => $updated_gallery]);
        } else {
            echo json_encode(["status" => "error", "pesan" => "Gagal memperbarui gallery: " . $connection->error]);
        }
        break;

    case 'DELETE':
        if (isset($_GET['kd_galery'])) {
            $kd_galery = $connection->real_escape_string($_GET['kd_galery']);
            $sql = "DELETE FROM galery WHERE kd_galery = '$kd_galery'";

            if ($connection->query($sql)) {
                echo json_encode(["status" => "sukses", "pesan" => "Data galery berhasil dihapus"]);
            } else {
                echo json_encode(["status" => "error", "pesan" => "Gagal menghapus data galery: " . $connection->error]);
            }
        } else {
            echo json_encode(["status" => "error", "pesan" => "kd_galery tidak ditemukan"]);
        }
        break;

    default:
        echo json_encode(["status" => "error", "pesan" => "Metode tidak valid"]);
        break;
}

$connection->close();
?>