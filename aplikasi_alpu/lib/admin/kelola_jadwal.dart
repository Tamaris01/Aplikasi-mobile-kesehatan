import 'dart:convert';
import 'package:alpu_pbl/admin/add_jadwal_page.dart';
import 'package:alpu_pbl/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class JadwalDokter {
  final String id;
  final String nipDokter;
  final String idPoliklinik;
  final TimeOfDay jamMulai;
  final TimeOfDay jamSelesai;
  final String hari;
  final String tanggal;
  String namaDokter = "";

  JadwalDokter({
    required this.id,
    required this.nipDokter,
    required this.idPoliklinik,
    required this.jamMulai,
    required this.jamSelesai,
    required this.hari,
    required this.tanggal,
  });
}

class Poliklinik {
  final String idPoliklinik;
  final String namaPoliklinik;

  Poliklinik({
    required this.idPoliklinik,
    required this.namaPoliklinik,
  });
}

class Dokter {
  final String nipDokter;
  final String namaDokter;

  Dokter({
    required this.nipDokter,
    required this.namaDokter,
  });
}

class KelolaJadwalDokterPage extends StatefulWidget {
  @override
  _KelolaJadwalDokterPageState createState() => _KelolaJadwalDokterPageState();
}

class _KelolaJadwalDokterPageState extends State<KelolaJadwalDokterPage> {
  List<JadwalDokter> jadwalDokterList = [];
  List<JadwalDokter> filteredJadwalDokterList = [];
  TextEditingController searchController = TextEditingController();

  List<Poliklinik> poliklinikList = [];
  List<Dokter> dokterList = [];

  @override
  void initState() {
    super.initState();
    fetchPoliklinik();
    fetchData();
  }

  Future<void> fetchPoliklinik() async {
    final response = await http.get(
      Uri.parse("$baseUrl/api/poliklinik/get_poliklinik.php"),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        poliklinikList = data
            .map((item) => Poliklinik(
                  idPoliklinik: item['id_poliklinik'],
                  namaPoliklinik: item['nama_poliklinik'],
                ))
            .toList();

        // Hilangkan duplikat
        poliklinikList = poliklinikList.toSet().toList();
      });
    } else {
      throw Exception('Failed to load poliklinik data');
    }
  }

  Future<void> fetchData() async {
    final response = await http.get(
      Uri.parse("$baseUrl/api/jadwal_dokter/read.php"),
    );

    if (response.statusCode == 200) {
      final dynamic responseData = json.decode(response.body);

      if (responseData is List) {
        setState(() {
          jadwalDokterList = responseData
              .map(
                (item) => JadwalDokter(
                  id: item['id'],
                  nipDokter: item['nip_dokter'],
                  idPoliklinik: item['id_poliklinik'],
                  jamMulai: _parseTimeOfDay(item['jam_mulai']),
                  jamSelesai: _parseTimeOfDay(item['jam_selesai']),
                  hari: item['hari'],
                  tanggal: item['tanggal'],
                )..namaDokter = item['nama_dokter'] ?? '',
              )
              .toList();
          filteredJadwalDokterList = jadwalDokterList;
        });
      } else {
        print("Unexpected response structure: $responseData");
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  void filterJadwalDokter(String query) {
    setState(() {
      final lowerCaseQuery = query.toLowerCase();

      filteredJadwalDokterList = jadwalDokterList.where((jadwal) {
        // Get the name of the poliklinik based on the ID
        Poliklinik? poliklinik = poliklinikList.firstWhere(
          (poliklinik) => poliklinik.idPoliklinik == jadwal.idPoliklinik,
          orElse: () => Poliklinik(
            idPoliklinik: '',
            namaPoliklinik: 'Poliklinik Tidak Ditemukan',
          ),
        );

        return jadwal.namaDokter.toLowerCase().contains(lowerCaseQuery) ||
            poliklinik.namaPoliklinik.toLowerCase().contains(lowerCaseQuery) ||
            _timeOfDayToString(jadwal.jamMulai)
                .toLowerCase()
                .contains(lowerCaseQuery) ||
            _timeOfDayToString(jadwal.jamSelesai)
                .toLowerCase()
                .contains(lowerCaseQuery) ||
            jadwal.hari.toLowerCase().contains(lowerCaseQuery) ||
            jadwal.tanggal.toLowerCase().contains(lowerCaseQuery);
      }).toList();
    });
  }

  String _timeOfDayToString(TimeOfDay time) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  TimeOfDay _parseTimeOfDay(String timeString) {
    final timeParts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );
  }

  Future<void> _showAddPage() async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const AddJadwalPage();
      },
    ));
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final paddingSize = screenWidth > 600 ? 16.0 : 8.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Kelola Jadwal",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 8, 90, 132),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10.0),
            TextField(
              controller: searchController,
              onChanged: filterJadwalDokter,
              decoration: InputDecoration(
                hintText: 'Cari jadwal dokter...',
                suffixIcon: const Icon(
                  Icons.search,
                  color: Color.fromARGB(255, 8, 90, 132),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(
                    color: Color.fromARGB(255, 8, 90, 132),
                    width: 2.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(
                    color: Color.fromARGB(255, 8, 90, 132),
                    width: 2.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(
                    color: Color.fromARGB(255, 8, 90, 132),
                    width: 2.0,
                  ),
                ),
                labelText: 'Cari Jadwal Dokter...',
                labelStyle: const TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 14.0,
                ),
              ),
              style: const TextStyle(
                color: Color.fromARGB(255, 8, 90, 132),
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 10.0),
            Expanded(
              child: ListView.builder(
                itemCount: filteredJadwalDokterList.length,
                itemBuilder: (context, index) {
                  JadwalDokter jadwal = filteredJadwalDokterList[index];
                  // Dapatkan nama dokter berdasarkan ID dokter
                  Dokter? dokter = dokterList.firstWhere(
                    (dokter) => dokter.nipDokter == jadwal.nipDokter,
                    orElse: () {
                      print(
                          'ID dokter ${jadwal.nipDokter} tidak ditemukan dalam dokterList');
                      return Dokter(
                        nipDokter: jadwal.nipDokter,
                        namaDokter: jadwal.namaDokter,
                      );
                    },
                  );
                  // Dapatkan nama poliklinik berdasarkan ID poliklinik
                  Poliklinik? poliklinik = poliklinikList.firstWhere(
                    (poliklinik) =>
                        poliklinik.idPoliklinik == jadwal.idPoliklinik,
                    orElse: () => Poliklinik(
                        idPoliklinik: '',
                        namaPoliklinik: 'Poliklinik Tidak Ditemukan'),
                  );
                  return SizedBox(
                    width: screenWidth > 600 ? 600 : null,
                    child: Card(
                      elevation: 1.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: const BorderSide(
                          color: Color.fromARGB(255, 8, 90, 132),
                          width: 2.0,
                        ),
                      ),
                      color: index % 2 == 0
                          ? const Color.fromARGB(255, 184, 223, 250)
                          : const Color.fromARGB(255, 214, 241, 245),
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  alignment: Alignment.topLeft,
                                  child: Icon(
                                    Icons.schedule,
                                    size: screenWidth * 0.10,
                                    color:
                                        const Color.fromARGB(255, 6, 69, 101),
                                  ),
                                ),
                                SizedBox(width: paddingSize),
                                Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${dokter.namaDokter}',
                                          style: const TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Color.fromARGB(255, 6, 69, 101),
                                          ),
                                        ),
                                        SizedBox(height: paddingSize),
                                        Text(
                                          'Poliklinik: ${poliklinik.namaPoliklinik}',
                                          style: const TextStyle(
                                            fontSize: 16.0,
                                            color:
                                                Color.fromARGB(255, 6, 69, 101),
                                          ),
                                        ),
                                        Text(
                                          'Jam Mulai: ${jadwal.jamMulai.format(context)}',
                                          style: const TextStyle(
                                            fontSize: 16.0,
                                            color:
                                                Color.fromARGB(255, 6, 69, 101),
                                          ),
                                        ),
                                        Text(
                                          'Jam Selesai: ${jadwal.jamSelesai.format(context)}',
                                          style: const TextStyle(
                                            fontSize: 16.0,
                                            color:
                                                Color.fromARGB(255, 6, 69, 101),
                                          ),
                                        ),
                                        Text(
                                          'Hari: ${jadwal.hari}',
                                          style: const TextStyle(
                                            fontSize: 16.0,
                                            color:
                                                Color.fromARGB(255, 6, 69, 101),
                                          ),
                                        ),
                                        Text(
                                          'Tanggal: ${jadwal.tanggal}',
                                          style: const TextStyle(
                                            fontSize: 16.0,
                                            color:
                                                Color.fromARGB(255, 6, 69, 101),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            TextButton(
                                              onPressed: () async {
                                                await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) {
                                                    return AddJadwalPage(
                                                        jadwal: jadwal);
                                                  }),
                                                );
                                                fetchData();
                                              },
                                              style: TextButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 15,
                                                        vertical: 4),
                                                backgroundColor:
                                                    const Color.fromARGB(
                                                        255, 19, 122, 24),
                                              ),
                                              child: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.edit,
                                                    color: Colors.white,
                                                    size: 14, // Ukuran ikon
                                                  ),
                                                  SizedBox(
                                                    width: 3,
                                                  ),
                                                  Text(
                                                    'Ubah',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize:
                                                          11, // Ukuran teks
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            TextButton(
                                              onPressed: () {
                                                _deleteJadwal(jadwal.id);
                                              },
                                              style: TextButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 4),
                                                backgroundColor:
                                                    const Color.fromARGB(
                                                        255, 176, 2, 2),
                                              ),
                                              child: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.delete,
                                                    color: Colors.white,
                                                    size: 14, // Ukuran ikon
                                                  ),
                                                  SizedBox(
                                                    width: 2,
                                                  ),
                                                  Text(
                                                    'Hapus',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize:
                                                          11, // Ukuran teks
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ]),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddPage();
        },
        backgroundColor: const Color.fromARGB(255, 8, 90, 132),
        child: const FaIcon(FontAwesomeIcons.plus),
      ),
    );
  }

  void _deleteJadwal(String id) async {
    bool konfirm = false;

    await AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      headerAnimationLoop: false,
      animType: AnimType.scale,
      title: 'Konfirmasi',
      desc: 'Apakah anda yakin ingin menghapus \n data jadwal ini?',
      btnCancelOnPress: () {},
      btnOkOnPress: () {
        konfirm = true;
      },
      btnOkText: 'Ya',
      btnCancelText: 'Tidak',
      btnOkColor: Color.fromARGB(202, 6, 52, 120),
      btnCancelColor: Color.fromARGB(255, 223, 44, 31),
    ).show();

    if (!konfirm) {
      return;
    }

    const url = "$baseUrl/api/jadwal_dokter/delete.php";
    final response = await http.post(
      Uri.parse(url),
      body: json.encode({'id': id}),
      headers: {"Content-Type": "application/json"},
    );

    final map = jsonDecode(response.body);
    if (map == null || map['status'] == 'error') {
      if (mounted) {
        showTopSnackBar(
          Overlay.of(context),
          Material(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(map?['message'] ?? 'Tidak berhasil'),
            ),
          ),
        );
      }
      return;
    }

    fetchData();
    if (mounted) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        headerAnimationLoop: false,
        animType: AnimType.scale,
        title: 'Sukses',
        desc: 'Data berhasil dihapus',
        btnOkOnPress: () {},
        btnOkText: 'OK',
      ).show();
    }
  }
}
