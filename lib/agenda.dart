import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AgendaScreen extends StatefulWidget {
  @override
  _AgendaScreenState createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  final String apiUrl = 'https://praktikum-cpanel-unbin.com/kelompok_ojan/tugas_mpper4/agenda.php';

  TextEditingController judulController = TextEditingController();
  TextEditingController isiController = TextEditingController();
  TextEditingController tglAgendaController = TextEditingController();
  TextEditingController tglPostAgendaController = TextEditingController();
  TextEditingController statusAgendaController = TextEditingController();
  TextEditingController kdPetugasController = TextEditingController();

  Future<List<dynamic>> fetchAgendaData() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == 'success') {
        List<dynamic> data = jsonResponse['data'];
        // Menghapus agenda yang tidak valid
        data.removeWhere((agenda) =>
            agenda['judul_agenda'].isEmpty ||
            agenda['isi_agenda'].isEmpty ||
            agenda['tgl_agenda'] == '0000-00-00');
        return data; // Mengembalikan semua data yang valid
      } else {
        throw Exception('Gagal memuat data agenda: ${jsonResponse['status']}');
      }
    } else {
      throw Exception('Gagal memuat data agenda: ${response.statusCode}');
    }
  }

  String formatDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    return '${dateTime.day}-${dateTime.month}-${dateTime.year}';
  }

  Future<void> createAgenda() async {
    if (!validateInputs()) return;

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'judul_agenda': judulController.text,
        'isi_agenda': isiController.text,
        'tgl_agenda': tglAgendaController.text,
        'tgl_post_agenda': tglPostAgendaController.text,
        'status_agenda': statusAgendaController.text,
        'kd_petugas': kdPetugasController.text,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      setState(() {
        // Memanggil kembali data agenda setelah menambahkan
        fetchAgendaData();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Agenda berhasil ditambahkan')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan agenda: ${response.body}')),
      );
    }
  }

  Future<void> updateAgenda(String id) async {
    if (!validateInputs()) return;

    final response = await http.put(
      Uri.parse('$apiUrl?kd_agenda=$id'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'judul_agenda': judulController.text,
        'isi_agenda': isiController.text,
        'tgl_agenda': tglAgendaController.text,
        'tgl_post_agenda': tglPostAgendaController.text,
        'status_agenda': statusAgendaController.text,
        'kd_petugas': kdPetugasController.text,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Agenda berhasil diperbarui')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui agenda')),
      );
    }
  }

  Future<void> deleteAgenda(String id) async {
    final response = await http.delete(
      Uri.parse('$apiUrl?kd_agenda=$id'),
    );

    if (response.statusCode == 200) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data berhasil dihapus')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus data: ${response.body}')),
      );
    }
  }

  void showAgendaDialog({String? id, bool isEdit = false}) async {
    if (isEdit && id != null) { // Pastikan id tidak null
      final response = await http.get(Uri.parse('$apiUrl?kd_agenda=$id'));
      
      // Tambahkan log untuk memeriksa respons
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'success' && jsonResponse['data'] != null) {
          final data = jsonResponse['data']; // Ambil data langsung tanpa array
          // Pastikan data tidak null sebelum mengakses
          if (data != null) {
            judulController.text = data['judul_agenda'] ?? '';
            isiController.text = data['isi_agenda'] ?? '';
            tglAgendaController.text = data['tgl_agenda'] ?? '';
            tglPostAgendaController.text = data['tgl_post_agenda'] ?? '';
            statusAgendaController.text = data['status_agenda'] ?? '';
            kdPetugasController.text = data['kd_petugas'] ?? '';
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Data agenda tidak ditemukan.')),
            );
            return;
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memuat data agenda atau data tidak ditemukan.')),
          );
          return;
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data agenda: ${response.statusCode}')),
        );
        return;
      }
    } else {
      judulController.clear();
      isiController.clear();
      tglAgendaController.clear();
      tglPostAgendaController.clear();
      statusAgendaController.clear();
      kdPetugasController.clear();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isEdit ? 'Perbarui Agenda' : 'Tambah Agenda Baru'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: judulController,
                  decoration: InputDecoration(labelText: 'Judul Agenda'),
                ),
                TextField(
                  controller: isiController,
                  decoration: InputDecoration(labelText: 'Isi Agenda'),
                ),
                TextField(
                  controller: tglAgendaController,
                  decoration: InputDecoration(labelText: 'Tanggal Agenda (YYYY-MM-DD)'),
                ),
                TextField(
                  controller: tglPostAgendaController,
                  decoration: InputDecoration(labelText: 'Tanggal Post Agenda (YYYY-MM-DD)'),
                ),
                TextField(
                  controller: statusAgendaController,
                  decoration: InputDecoration(labelText: 'Status Agenda'),
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
                  await updateAgenda(id!);
                } else {
                  await createAgenda();
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
        tglAgendaController.text.isEmpty ||
        statusAgendaController.text.isEmpty ||
        kdPetugasController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Harap isi semua kolom.')),
      );
      return false;
    }

    try {
      DateTime.parse(tglAgendaController.text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Format tanggal tidak valid. Gunakan YYYY-MM-DD.')),
      );
      return false;
    }

    return true;
  }

  Future<void> _refreshAgendaData() async {
    await fetchAgendaData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              showAgendaDialog();
            },
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchAgendaData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak Ada Agenda Tersedia'));
          } else {
            return RefreshIndicator(
              onRefresh: _refreshAgendaData,
              child: ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  var agenda = snapshot.data![index];

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
                            agenda['judul_agenda'] ?? 'Judul tidak tersedia',
                            style: const TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            agenda['isi_agenda'] ?? 'Isi tidak tersedia',
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
                                'Diposting: ${formatDate(agenda['tgl_post_agenda'] ?? '2000-01-01')}',
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
                                  showAgendaDialog(id: agenda['kd_agenda'], isEdit: true);
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
                                        content: Text('Apakah Anda yakin ingin menghapus agenda ini?'),
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
                                              await deleteAgenda(agenda['kd_agenda']);
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
