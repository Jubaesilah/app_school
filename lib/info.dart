import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class InfoScreen extends StatefulWidget {
  @override
  _InfoScreenState createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  final String apiUrl = 'https://praktikum-cpanel-unbin.com/kelompok_ojan/tugas_mpper4/info.php';

  TextEditingController judulController = TextEditingController();
  TextEditingController isiController = TextEditingController();
  TextEditingController tglPostInfoController = TextEditingController();
  TextEditingController statusInfoController = TextEditingController();
  TextEditingController kdPetugasController = TextEditingController();

  Future<List<dynamic>> fetchInfoData() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'sukses') {
          List<dynamic> data = jsonResponse['data'];
          // Menghapus info yang tidak valid
          data.removeWhere((info) =>
              info['judul_info'].isEmpty ||
              info['isi_info'].isEmpty ||
              info['tgl_post_info'] == '0000-00-00');
          return data; // Mengembalikan semua data yang valid
        } else {
          throw Exception('Gagal memuat data info: ${jsonResponse['status']}');
        }
      } else {
        throw Exception('Gagal memuat data info: ${response.statusCode}');
      }
    } catch (e) {
      print('Error saat memuat data info: $e');
      return []; // Mengembalikan list kosong jika terjadi error
    }
  }

  String formatDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    return '${dateTime.day}-${dateTime.month}-${dateTime.year}';
  }

  Future<void> createInfo() async {
    if (!validateInputs()) return;

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'judul_info': judulController.text,
          'isi_info': isiController.text,
          'tgl_post_info': tglPostInfoController.text,
          'status_info': statusInfoController.text,
          'kd_petugas': kdPetugasController.text,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          // Memanggil kembali data info setelah menambahkan
          fetchInfoData();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Info berhasil ditambahkan')),
        );
      } else {
        throw Exception('Gagal menambahkan info: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  Future<void> updateInfo(String id) async {
    if (!validateInputs()) return;

    try {
      final response = await http.put(
        Uri.parse('$apiUrl?kd_info=$id'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'judul_info': judulController.text,
          'isi_info': isiController.text,
          'tgl_post_info': tglPostInfoController.text,
          'status_info': statusInfoController.text,
          'kd_petugas': kdPetugasController.text,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Info berhasil diperbarui')),
        );
      } else {
        throw Exception('Gagal memperbarui info: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  Future<void> deleteInfo(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiUrl?kd_info=$id'),
      );

      if (response.statusCode == 200) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data berhasil dihapus')),
        );
      } else {
        throw Exception('Gagal menghapus data: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  void showInfoDialog({String? id, bool isEdit = false}) async {
    if (isEdit && id != null) {
      try {
        final response = await http.get(Uri.parse('$apiUrl?kd_info=$id'));
        
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          final jsonResponse = json.decode(response.body);
          if (jsonResponse['status'] == 'sukses' && jsonResponse['data'] != null) {
            final data = jsonResponse['data'];
            if (data != null) {
              judulController.text = data['judul_info'] ?? '';
              isiController.text = data['isi_info'] ?? '';
              tglPostInfoController.text = data['tgl_post_info'] ?? '';
              statusInfoController.text = data['status_info'] ?? '';
              kdPetugasController.text = data['kd_petugas'] ?? '';
            } else {
              throw Exception('Data info tidak ditemukan.');
            }
          } else {
            throw Exception('Gagal memuat data info atau data tidak ditemukan.');
          }
        } else {
          throw Exception('Gagal memuat data info: ${response.statusCode}');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
        return;
      }
    } else {
      // Menghapus isi controller hanya jika tidak dalam mode edit
      judulController.clear();
      isiController.clear();
      tglPostInfoController.clear();
      statusInfoController.clear();
      kdPetugasController.clear();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isEdit ? 'Perbarui Info' : 'Tambah Info Baru'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: judulController,
                  decoration: InputDecoration(labelText: 'Judul Info'),
                ),
                TextField(
                  controller: isiController,
                  decoration: InputDecoration(labelText: 'Isi Info'),
                ),
                TextField(
                  controller: tglPostInfoController,
                  decoration: InputDecoration(labelText: 'Tanggal Post Info (YYYY-MM-DD)'),
                ),
                TextField(
                  controller: statusInfoController,
                  decoration: InputDecoration(labelText: 'Status Info'),
                ),
                TextField(
                  controller: kdPetugasController,
                  decoration: InputDecoration(labelText: 'Kode Petugas'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(isEdit ? 'Perbarui' : 'Tambah'),
              onPressed: () async {
                if (isEdit) {
                  await updateInfo(id!);
                } else {
                  await createInfo();
                }
                Navigator.of(context).pop();
                setState(() {});
              },
            ),
          ],
        );
      },
    );
  }

  bool validateInputs() {
    if (judulController.text.isEmpty ||
        isiController.text.isEmpty ||
        tglPostInfoController.text.isEmpty ||
        statusInfoController.text.isEmpty ||
        kdPetugasController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Harap isi semua kolom.')),
      );
      return false;
    }

    try {
      DateTime.parse(tglPostInfoController.text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Format tanggal tidak valid. Gunakan YYYY-MM-DD.')),
      );
      return false;
    }

    return true;
  }

  Future<void> _refreshInfoData() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Info'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              showInfoDialog();
            },
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchInfoData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak Ada Info Tersedia'));
          } else {
            return RefreshIndicator(
              onRefresh: _refreshInfoData,
              child: ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  var info = snapshot.data![index];

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    elevation: 8,
                    margin: const EdgeInsets.symmetric(
                        vertical: 7.0, horizontal: 13.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            info['judul_info'] ?? 'Judul tidak tersedia',
                            style: const TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            info['isi_info'] ?? 'Isi tidak tersedia',
                            style: const TextStyle(
                              fontSize: 16.0,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Icon(
                                Icons.post_add,
                                size: 16.0,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 8.0),
                              Text(
                                'Diposting: ${formatDate(info['tgl_post_info'] ?? '2000-01-01')}',
                                style: const TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  showInfoDialog(id: info['kd_info'], isEdit: true);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Konfirmasi'),
                                        content: Text('Apakah Anda yakin ingin menghapus info ini?'),
                                        actions: [
                                          TextButton(
                                            child: Text('Batal'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                            child: Text('Hapus'),
                                            onPressed: () async {
                                              Navigator.of(context).pop();
                                              await deleteInfo(info['kd_info']);
                                              setState(() {});
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
