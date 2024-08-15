import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:alpu_pbl/main.dart'; // Sesuaikan dengan path file main.dart

class Attendance {
  final String patientName;
  final String clinicName;
  final DateTime visitDate;

  Attendance({
    required this.patientName,
    required this.clinicName,
    required this.visitDate,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      patientName: json['Nama_Pasien'],
      clinicName: json['Nama_Poliklinik'],
      visitDate: DateTime.parse(json['tanggal_kunjungan']),
    );
  }
}

class DaftarHadirPage extends StatefulWidget {
  @override
  _DaftarHadirPageState createState() => _DaftarHadirPageState();
}

class _DaftarHadirPageState extends State<DaftarHadirPage> {
  late Future<List<Attendance>> futureAttendance;
  String? selectedClinic;
  List<Map<String, dynamic>> clinics = [];
  bool isLoadingClinics = true;

  @override
  void initState() {
    super.initState();
    fetchClinics();
    futureAttendance = Future.value([]);
  }

  Future<void> fetchClinics() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/poliklinik/get_poliklinik.php'));
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        setState(() {
          clinics = jsonResponse
              .map<Map<String, dynamic>>(
                  (clinic) => clinic as Map<String, dynamic>)
              .toList();
          isLoadingClinics = false;
        });
      } else {
        throw Exception('Failed to load clinics');
      }
    } catch (e) {
      print('Error fetching clinics: $e');
      setState(() {
        isLoadingClinics = false;
      });
    }
  }

  Future<List<Attendance>> fetchAttendance(String? idPoliklinik) async {
    final url = idPoliklinik == null || idPoliklinik.isEmpty
        ? '$baseUrl/api/kehadiran/daftarhadir.php'
        : '$baseUrl/api/kehadiran/daftarhadir.php?id_poliklinik=$idPoliklinik';

    print('Fetching attendance from URL: $url'); // Debugging line

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      print('Fetched attendance data: ${jsonResponse}'); // Debugging line

      // Filter data to include only those with the matching clinic ID
      return jsonResponse
          .where((attendance) =>
              attendance['Nama_Poliklinik'] ==
              getClinicNameFromId(idPoliklinik))
          .map((attendance) => Attendance.fromJson(attendance))
          .toList();
    } else {
      throw Exception('Failed to load attendance');
    }
  }

  String getClinicNameFromId(String? idPoliklinik) {
    final clinic = clinics.firstWhere(
        (c) => c['id_poliklinik'].toString() == idPoliklinik,
        orElse: () => {});
    return clinic.isEmpty ? '' : clinic['nama_poliklinik'];
  }

  void _filterAttendance() {
    if (selectedClinic != null && selectedClinic!.isNotEmpty) {
      print('Selected Clinic ID: $selectedClinic'); // Debugging line
      setState(() {
        futureAttendance = fetchAttendance(selectedClinic);
      });
    } else {
      setState(() {
        futureAttendance = Future.value([]);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Hadir Pasien'),
        backgroundColor: Color.fromARGB(255, 8, 90, 132),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isLoadingClinics
                ? Center(child: CircularProgressIndicator())
                : Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: DropdownButtonFormField<String>(
                        value: selectedClinic,
                        hint: Text('Pilih Poliklinik'),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 15),
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedClinic = newValue;
                            _filterAttendance(); // Fetch attendance data when clinic changes
                          });
                        },
                        items: clinics.map((clinic) {
                          return DropdownMenuItem<String>(
                            value: clinic['id_poliklinik'].toString(),
                            child: Text(clinic['nama_poliklinik']),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
            SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Attendance>>(
                future: futureAttendance,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (snapshot.hasData) {
                    if (snapshot.data!.isEmpty) {
                      return Center(
                          child: Text(
                              'Tidak ada data untuk poliklinik yang dipilih.'));
                    }
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 16,
                        columns: [
                          DataColumn(label: Text('Nama Pasien')),
                          DataColumn(label: Text('Poliklinik')),
                          DataColumn(label: Text('Tanggal Kunjungan')),
                        ],
                        rows: snapshot.data!.map((attendance) {
                          return DataRow(
                            cells: [
                              DataCell(Text(attendance.patientName)),
                              DataCell(Text(attendance.clinicName)),
                              DataCell(Text(DateFormat('dd MMM yyyy')
                                  .format(attendance.visitDate))),
                            ],
                          );
                        }).toList(),
                      ),
                    );
                  } else {
                    return Center(
                        child: Text(
                            'Tidak ada data untuk poliklinik yang dipilih.'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
