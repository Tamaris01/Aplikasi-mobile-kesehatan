import 'dart:convert';
import 'package:alpu_pbl/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

class JadwalPage extends StatefulWidget {
  @override
  _JadwalPageState createState() => _JadwalPageState();
}

class JadwalDokter {
  final String id;
  final String nipDokter;
  final String idPoliklinik;
  final TimeOfDay jamMulai;
  final TimeOfDay jamSelesai;
  final String hari;
  final String tanggal;
  String namaDokter;

  JadwalDokter({
    required this.id,
    required this.nipDokter,
    required this.idPoliklinik,
    required this.jamMulai,
    required this.jamSelesai,
    required this.hari,
    required this.tanggal,
    this.namaDokter = "",
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

class _JadwalPageState extends State<JadwalPage> {
  List<JadwalDokter> jadwalDokterList = [];
  List<JadwalDokter> filteredJadwalDokterList = [];
  TextEditingController searchController = TextEditingController();

  List<Poliklinik> poliklinikList = [];
  List<Dokter> dokterList = [];
  bool isLoading = true;

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
            .toSet()
            .toList(); // Menghapus duplikat dengan menggunakan Set
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
                  namaDokter: item['nama_dokter'] ?? '',
                ),
              )
              .toList();
          filteredJadwalDokterList = jadwalDokterList;
          isLoading = false;
        });
      } else {
        print("Unexpected response structure: $responseData");
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      isLoading = true; // Menandakan bahwa data sedang dimuat
    });
    await fetchData(); // Memanggil metode untuk memuat ulang data
  }

  void filterJadwalDokter(String query) {
    setState(() {
      filteredJadwalDokterList = jadwalDokterList
          .where((jadwal) =>
              jadwal.nipDokter.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  TimeOfDay _parseTimeOfDay(String timeString) {
    final timeParts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );
  }

  Widget buildShimmer() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.blueGrey[200]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            margin: EdgeInsets.symmetric(vertical: 16.0, horizontal: 2.0),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(8.0), // Mengubah radius border
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(24.0), // Menambah padding
              leading: CircleAvatar(
                radius: 10.0, // Memperbesar radius
                backgroundColor: Color.fromARGB(255, 255, 255, 255),
              ),
              title: Container(
                color: Colors.grey,
                height: 6.0, // Memperbesar tinggi
                width: double.infinity,
              ),
              subtitle: Container(
                color: Colors.grey,
                height: 100.0, // Memperbesar tinggi
                width: 200.0, // Memperbesar lebar
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final paddingSize = screenWidth > 600 ? 16.0 : 8.0;

    return Scaffold(
        appBar: AppBar(
          title: Text('Jadwal Dokter'),
          backgroundColor: Color.fromARGB(255, 8, 90, 132),
        ),
        backgroundColor: Colors.white,
        body: RefreshIndicator(
          onRefresh: _refreshData, // Menambahkan fungsi refresh
          child: Padding(
            padding: EdgeInsets.all(paddingSize),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.0),
                TextField(
                  controller: searchController,
                  onChanged: filterJadwalDokter,
                  decoration: InputDecoration(
                    hintText: 'Cari jadwal dokter...',
                    suffixIcon: Icon(
                      Icons.search,
                      color: Color.fromARGB(255, 8, 90, 132),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 8, 90, 132),
                        width: 2.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 8, 90, 132),
                        width: 2.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 8, 90, 132),
                        width: 2.0,
                      ),
                    ),
                    labelText: 'Cari jadwal dokter...',
                    labelStyle: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 16.0,
                    ),
                  ),
                  style: TextStyle(
                    color: Color.fromARGB(255, 8, 90, 132),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 10.0),
                Expanded(
                  child: isLoading
                      ? buildShimmer()
                      : ListView.builder(
                          itemCount: filteredJadwalDokterList.length,
                          itemBuilder: (context, index) {
                            JadwalDokter jadwal =
                                filteredJadwalDokterList[index];
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
                            Poliklinik? poliklinik = poliklinikList.firstWhere(
                              (poliklinik) =>
                                  poliklinik.idPoliklinik ==
                                  jadwal.idPoliklinik,
                              orElse: () {
                                print(
                                    'ID poliklinik ${jadwal.idPoliklinik} tidak ditemukan dalam poliklinikList');
                                return Poliklinik(
                                  idPoliklinik: jadwal.idPoliklinik,
                                  namaPoliklinik: '',
                                );
                              },
                            );

                            final cardColor = index % 2 == 0
                                ? const Color.fromARGB(255, 184, 223, 250)
                                : const Color.fromARGB(255, 214, 241, 245);

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
                                color: cardColor,
                                margin: EdgeInsets.symmetric(vertical: 8.0),
                                child: Padding(
                                  padding: const EdgeInsets.all(18.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(
                                                right: paddingSize),
                                            child: Icon(
                                              Icons.schedule,
                                              size: screenWidth * 0.10,
                                              color: Color.fromARGB(
                                                  255, 6, 69, 101),
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${dokter.namaDokter}',
                                                  style: TextStyle(
                                                    fontSize: 18.0,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color.fromARGB(
                                                        255, 6, 69, 101),
                                                  ),
                                                ),
                                                SizedBox(height: paddingSize),
                                                Text(
                                                  'Poliklinik: ${poliklinik.namaPoliklinik}',
                                                  style: TextStyle(
                                                    fontSize: 16.0,
                                                    color: Color.fromARGB(
                                                        255, 6, 69, 101),
                                                  ),
                                                ),
                                                SizedBox(
                                                    height: paddingSize / 2),
                                                Text(
                                                  'Jam Mulai: ${jadwal.jamMulai.format(context)}',
                                                  style: TextStyle(
                                                    fontSize: 16.0,
                                                    color: Color.fromARGB(
                                                        255, 6, 69, 101),
                                                  ),
                                                ),
                                                SizedBox(
                                                    height: paddingSize / 2),
                                                Text(
                                                  'Jam Selesai: ${jadwal.jamSelesai.format(context)}',
                                                  style: TextStyle(
                                                    fontSize: 16.0,
                                                    color: Color.fromARGB(
                                                        255, 6, 69, 101),
                                                  ),
                                                ),
                                                SizedBox(
                                                    height: paddingSize / 2),
                                                Text(
                                                  'Hari: ${jadwal.hari}',
                                                  style: TextStyle(
                                                    fontSize: 16.0,
                                                    color: Color.fromARGB(
                                                        255, 6, 69, 101),
                                                  ),
                                                ),
                                                SizedBox(
                                                    height: paddingSize / 2),
                                                Text(
                                                  'Tanggal: ${jadwal.tanggal}',
                                                  style: TextStyle(
                                                    fontSize: 16.0,
                                                    color: Color.fromARGB(
                                                        255, 6, 69, 101),
                                                  ),
                                                ),
                                              ],
                                            ),
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
        ));
  }
}
