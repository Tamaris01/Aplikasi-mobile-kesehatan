import 'dart:convert';
import 'package:alpu_pbl/form_validator.dart';
import 'package:alpu_pbl/main.dart';
import 'package:alpu_pbl/shared_prefs.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class KelolaDokter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: KelolaDokterPage(),
    );
  }
}

class Dokter {
  final String nipDokter;
  final String idAdmin;
  final String nama;
  final String idPoliklinik;
  String namaPoliklinik;
  final String alamat;
  final String noTelepon;
  final String foto;
  final String status;

  Dokter({
    required this.nipDokter,
    required this.nama,
    required this.idPoliklinik,
    required this.namaPoliklinik,
    required this.alamat,
    required this.noTelepon,
    required this.foto,
    required this.idAdmin,
    this.status = '1',
  });

  factory Dokter.fromJson(Map<String, dynamic> json) {
    return Dokter(
      nama: json['nama_dokter'],
      idAdmin: json['id_admin'] ?? '',
      idPoliklinik: json['id_poliklinik'] ?? '',
      namaPoliklinik: json['nama_poliklinik'] ?? '',
      alamat: json['alamat'] ?? '',
      noTelepon: json['no_telepon'] ?? '',
      foto: json['foto'] ?? '',
      nipDokter: json['nip_dokter'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama_dokter': nama,
      'id_admin': idAdmin,
      'id_poliklinik': idPoliklinik,
      'nama_poliklinik': namaPoliklinik,
      'alamat': alamat,
      'no_telepon': noTelepon,
      'foto': foto,
      'nip_dokter': nipDokter,
      'status': status,
    };
  }
}

// Poliklinik
class Poliklinik {
  final String idPoliklinik; // Menggunakan String untuk ID poliklinik
  final String namaPoliklinik;

  Poliklinik({required this.idPoliklinik, required this.namaPoliklinik});

  factory Poliklinik.fromJson(Map<String, dynamic> json) {
    return Poliklinik(
      idPoliklinik: json['id_poliklinik'],
      namaPoliklinik: json['nama_poliklinik'],
    );
  }
}

class KelolaDokterPage extends StatefulWidget {
  @override
  _KelolaDokterPageState createState() => _KelolaDokterPageState();
}

class _KelolaDokterPageState extends State<KelolaDokterPage> {
  List<Dokter> dokterList = [];
  List<Dokter> filteredDokterList = [];
  TextEditingController searchController = TextEditingController();

  // List poliklinik
  List<Poliklinik> poliklinikList = [];
  Poliklinik? selectedPoliklinik;

  void _showStyledSnackBar(
      String message, IconData icon, Color iconColor, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          height: 60.0,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 30.0,
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    _showStyledDialog(message, DialogType.success, Colors.white,
        Color.fromARGB(255, 73, 176, 145));
  }

  void _showErrorSnackBar(String message) {
    _showStyledDialog(message, DialogType.error, Colors.white, Colors.red);
  }

  void _showStyledDialog(String message, DialogType dialogType, Color textColor,
      Color backgroundColor) {
    AwesomeDialog(
      context: context,
      dialogType: dialogType,
      headerAnimationLoop: false,
      animType: AnimType.scale,
      title: dialogType == DialogType.success ? 'Sukses' : 'Error',
      desc: message,
      btnOkOnPress: () {},
      btnOkText: 'OK',
      btnOkColor: backgroundColor,
    ).show();
  }

  @override
  void initState() {
    super.initState();
    fetchDataPoliklinik();
    fetchData();
  }

  //poliklinik
  Future<void> fetchDataPoliklinik() async {
    try {
      final response =
          await http.get(Uri.parse("$baseUrl/api/poliklinik/read.php"));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        setState(() {
          poliklinikList = data
              .map((poliklinik) => Poliklinik.fromJson(poliklinik))
              .toList();
        });

        print(poliklinikList
            .map((poliklinik) => poliklinik.namaPoliklinik)
            .toList());
      } else {
        print('Error fetching data - status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> fetchData() async {
    try {
      final response =
          await http.get(Uri.parse("$baseUrl/api/dokter/read.php"));
      debugPrint(response.body);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          dokterList = data.map((item) => Dokter.fromJson(item)).toList();
          filteredDokterList = dokterList;
        });
      } else {
        print('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void filterDokter(String query) {
    setState(() {
      filteredDokterList = dokterList
          .where((dokter) =>
              dokter.nama.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<bool> updateDokter(Dokter dokter) async {
    final map = dokter.toJson();
    map['nip_dokter'] = dokter.nipDokter;
    map['no_telepon'] = dokter.noTelepon;
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/dokter/edit.php"),
        body: map,
      );

      if (response.statusCode == 200) {
        print('Dokter ${dokter.nama} berhasil diupdate.');
        return true;
      } else {
        print('Gagal mengupdate dokter. Status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  void showConfirmationDialog(Dokter newDokter) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.question,
      animType: AnimType.scale,
      title: 'Konfirmasi',
      desc: 'Apakah Anda yakin ingin menambahkan dokter baru?',
      btnCancelOnPress: () {},
      btnOkOnPress: () {
        tambahDokter(newDokter);
      },
    ).show();
  }

  Future<void> tambahDokter(Dokter newDokter) async {
    final apiUrl = Uri.parse("$baseUrl/api/dokter/create.php");
    final map = newDokter.toJson();
    final idAdmin = (await SharedPreferences.getInstance())
        .getString(PreferencesUtil.userId);
    map['nip_dokter'] = newDokter.nipDokter;
    map['no_telepon'] = newDokter.noTelepon;
    map['id_admin'] = idAdmin;

    try {
      final response = await http.post(apiUrl, body: map);

      if (response.statusCode == 200) {
        print('Data dokter berhasil ditambahkan');

        final poli = poliklinikList
            .where((element) => element.idPoliklinik == newDokter.idPoliklinik);
        if (poli.isNotEmpty) {
          newDokter.namaPoliklinik = poli.first.namaPoliklinik;
        }
        setState(() {
          dokterList.add(newDokter);
          filteredDokterList = dokterList;
        });
        if (mounted) Navigator.of(context).pop();
        _showDialog(
          type: DialogType.success,
          title: 'Sukses',
          description: 'Data dokter berhasil ditambahkan',
        );
      } else {
        print('Gagal menambahkan data: ${response.reasonPhrase}');
        String message = "Gagal menambahkan data dokter";
        if (response.body.startsWith('{')) {
          final json = jsonDecode(response.body);
          if ((json as Map<String, dynamic>).containsKey('message')) {
            message = json['message'];
          }
        }
        if (mounted) {
          _showDialog(
            type: DialogType.error,
            title: 'Gagal',
            description: message,
          );
        }
      }
    } catch (e) {
      print('Error: $e');
      if (mounted) {
        _showDialog(
          type: DialogType.error,
          title: 'Error',
          description: 'Terjadi kesalahan saat menambahkan data dokter',
        );
      }
    }
  }

  void _showDialog({
    required DialogType type,
    required String title,
    required String description,
  }) {
    AwesomeDialog(
      context: context,
      dialogType: type,
      animType: AnimType.scale,
      title: title,
      desc: description,
      btnOkOnPress: () {},
    ).show();
  }

  void editDokter(Dokter dokter) {
    showDialog(
      context: context,
      builder: (context) => EditDokterPage(
        poliklinikList: poliklinikList,
        dokter: dokter,
        onFormSubmit: (updatedDokter) async {
          final success = await updateDokter(updatedDokter);
          if (success) {
            setState(() {
              dokterList[dokterList.indexWhere(
                  (d) => d.nipDokter == dokter.nipDokter)] = updatedDokter;
              filteredDokterList = List.from(dokterList);
            });
            Navigator.of(context).pop();
            _showSuccessDialog();
          } else {
            print('Failed to update dokter');
            _showErrorDialog();
          }
        },
      ),
    );
  }

  void _showSuccessDialog() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.scale,
      title: 'Sukses',
      desc: 'Data dokter berhasil diubah',
      btnOkOnPress: () {},
    ).show();
  }

  void _showErrorDialog() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.scale,
      title: 'Gagal',
      desc: 'Gagal mengubah data dokter',
      btnOkOnPress: () {},
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Dokter'),
        backgroundColor: const Color.fromARGB(255, 8, 90, 132),
      ),
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: searchController,
              onChanged: filterDokter,
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
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(
                    color: Color.fromARGB(255, 8, 90, 132),
                    width: 2.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(
                    color: Color.fromARGB(255, 8, 90, 132),
                    width: 2.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            Expanded(
              child: ListView.builder(
                itemCount: filteredDokterList.length,
                itemBuilder: (context, index) {
                  Dokter dokter = filteredDokterList[index];
                  return Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      side: const BorderSide(
                        color: Color.fromARGB(255, 8, 90, 132),
                        width: 2.0,
                      ),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    color: index % 2 == 0
                        ? const Color.fromARGB(255, 184, 223, 250)
                        : const Color.fromARGB(255, 205, 247, 253),
                    child: InkWell(
                      onTap: () {
                        // Add action on card tap if needed
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                border: Border.all(
                                  color: const Color.fromARGB(255, 8, 90, 132),
                                  width: 3.0,
                                ),
                                color: Colors.white,
                              ),
                              child: Center(
                                child: dokter.foto.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        child: Image.network(
                                          '$baseUrl/api/dokter/images/${dokter.foto}',
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : const Placeholder(), // Placeholder saat tidak ada gambar
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        dokter.nama,
                                        style: const TextStyle(
                                          color:
                                              Color.fromARGB(255, 8, 90, 132),
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10.0,
                                ),
                                SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'NIP Dokter: ${dokter.nipDokter}',
                                        style: const TextStyle(
                                          fontSize: 16.0,
                                          color:
                                              Color.fromARGB(255, 8, 90, 132),
                                        ),
                                      ),
                                      Text(
                                        'Poliklinik: ${dokter.namaPoliklinik}',
                                        style: const TextStyle(
                                          fontSize: 16.0,
                                          color:
                                              Color.fromARGB(255, 8, 90, 132),
                                        ),
                                      ),
                                      Text(
                                        'No. Telepon: ${dokter.noTelepon}',
                                        style: const TextStyle(
                                          fontSize: 16.0,
                                          color:
                                              Color.fromARGB(255, 8, 90, 132),
                                        ),
                                      ),
                                      Text(
                                        'Alamat: ${dokter.alamat}',
                                        style: const TextStyle(
                                          fontSize: 16.0,
                                          color:
                                              Color.fromARGB(255, 8, 90, 132),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10.0),
                                ButtonBar(
                                  alignment: MainAxisAlignment.end,
                                  children: [
                                    //button edit
                                    ElevatedButton(
                                      onPressed: () {
                                        editDokter(dokter);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        primary: Color.fromARGB(255, 25, 131,
                                            29), // Warna latar belakang hijau
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              5), // Bentuk petak dengan sudut melengkung
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.edit_outlined,
                                            color: Colors
                                                .white, // Warna ikon putih
                                          ),
                                          const SizedBox(
                                              width:
                                                  8), // Jarak antara ikon dan teks
                                          Text(
                                            'Ubah',
                                            style: TextStyle(
                                              color: Colors
                                                  .white, // Warna teks putih
                                              fontSize: 16, // Ukuran teks
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    ElevatedButton.icon(
                                      onPressed: () {
                                        // Fungsi untuk konfirmasi sebelum aktif/nonaktif
                                        AwesomeDialog(
                                          context: context,
                                          dialogType: DialogType.question,
                                          animType: AnimType.scale,
                                          title: 'Konfirmasi',
                                          desc: dokter.status == '0'
                                              ? "Apakah Anda yakin ingin \n mengaktifkan ${dokter.nama}?"
                                              : "Apakah Anda yakin ingin \n menonaktifkan ${dokter.nama}?",
                                          btnCancelOnPress: () {},
                                          btnOkOnPress: () {
                                            aktifNonAktifDokter(dokter);
                                          },
                                          btnCancelText: 'Batal',
                                          btnOkText: 'Ya',
                                          btnCancelColor: Colors.red,
                                          btnOkColor:
                                              Color.fromARGB(255, 25, 96, 155),
                                        ).show();
                                      },
                                      icon: Icon(Icons.power_settings_new,
                                          color: Colors.white),
                                      label: Text(
                                        dokter.status == '0'
                                            ? 'AKTIFKAN'
                                            : 'NONAKTIFKAN',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        primary: dokter.status == '0'
                                            ? const Color.fromARGB(
                                                255, 8, 90, 132)
                                            : Color.fromARGB(255, 198, 9, 5),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
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
          showDialog(
            context: context,
            builder: (context) => AddDokterPage(
              poliklinikList: poliklinikList,
              onFormSubmit: (newDokter) {
                tambahDokter(newDokter);
              },
            ),
          );
        },
        child: const FaIcon(FontAwesomeIcons.plus),
        backgroundColor: const Color.fromARGB(255, 8, 90, 132),
      ),
    );
  }

  void aktifNonAktifDokter(Dokter dokter) async {
    final newStatus = dokter.status == '0' ? '1' : '0';
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/dokter/update_status.php"),
        body: {
          'nip_dokter': dokter.nipDokter,
          'status': newStatus,
        },
      );
      if (mounted) {
        if (response.statusCode == 200) {
          _showSuccessSnackBar('Status Dokter berhasil diupdate');
          fetchData();
        } else {
          _showErrorSnackBar('Gagal mengupdate status dokter');
        }
      }
    } catch (e) {
      if (mounted) _showErrorSnackBar(e.toString());
    }
  }
}

class AddDokterPage extends StatefulWidget {
  final Function(Dokter) onFormSubmit;
  final List<Poliklinik> poliklinikList;

  AddDokterPage({required this.onFormSubmit, required this.poliklinikList});

  @override
  _AddDokterPageState createState() => _AddDokterPageState();
}

class _AddDokterPageState extends State<AddDokterPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController namaController;
  late TextEditingController alamatController;
  late TextEditingController noTeleponController;
  late TextEditingController nipDokterController;

  String foto = '';
  List<Poliklinik> poliklinikList = [];
  String? selectedPoliklinikId;
  String? errorMessage;
  String? errorMessageUploadImage;

  @override
  void initState() {
    super.initState();
    poliklinikList = widget.poliklinikList;
    namaController = TextEditingController();
    alamatController = TextEditingController();
    noTeleponController = TextEditingController();
    nipDokterController = TextEditingController();
  }

  Future<void> _pickImage() async {
    errorMessageUploadImage = null;
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);
      final bytes = await imageFile.readAsBytes();
      final fileName = imageFile.uri.pathSegments.last;
      // Simpan foto di server
      final request = http.MultipartRequest(
          'POST', Uri.parse('$baseUrl/api/dokter/upload.php'));
      final multipartFile =
          http.MultipartFile.fromBytes('image', bytes, filename: fileName);
      request.files.add(multipartFile);
      final response = await request.send();
      final body = await response.stream.first;
      final responseString = utf8.decode(body);

      setState(() {
        errorMessageUploadImage = responseString;
        foto = fileName; // Mendapatkan URL foto dari response server
      });
    } else if (mounted) {
      // Tampilkan pesan kesalahan jika tidak ada foto yang dipilih
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Mohon pilih foto.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Data Dokter'),
        backgroundColor: Color.fromARGB(255, 8, 90, 132),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (errorMessage?.isNotEmpty == true)
                  Text(
                    errorMessage ?? 'Forma tidak valid',
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                const SizedBox(height: 10),
                const Text(
                  'NIP Dokter',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color.fromARGB(255, 8, 90, 132),
                  ),
                ),
                const SizedBox(height: 5.0),
                TextFormField(
                  validator: FormValidator.validateNIK,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  controller: nipDokterController,
                  decoration: InputDecoration(
                    labelText: 'Masukan NIP Dokter',
                    suffixText: '*',
                    suffixStyle: const TextStyle(color: Colors.red),
                    prefixIcon: const Icon(Icons.badge,
                        color: Color.fromARGB(255, 11, 77, 131)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 8, 90, 132)), // Warna ikon
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 8, 90, 132)), // Warna ikon
                    ),
                  ),
                  style:
                      const TextStyle(color: Color.fromARGB(255, 11, 77, 131)),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Pilih Poliklinik',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color.fromARGB(255, 8, 90, 132),
                  ),
                ),
                const SizedBox(height: 5),
                DropdownButtonFormField<String?>(
                  value: selectedPoliklinikId,
                  items: poliklinikList.map((Poliklinik poliklinik) {
                    return DropdownMenuItem<String?>(
                      value: poliklinik.idPoliklinik.toString(),
                      child: Text(poliklinik.namaPoliklinik,
                          style: const TextStyle(
                              color: Color.fromARGB(255, 11, 77, 131))),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      selectedPoliklinikId = value ?? '';
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Pilih Poliklinik',
                    suffixText: '*',
                    suffixStyle: const TextStyle(color: Colors.red),
                    prefixIcon: const Icon(Icons.local_hospital,
                        color: Color.fromARGB(255, 11, 77, 131)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 8, 90, 132)), // Warna ikon
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 8, 90, 132)), // Warna ikon
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Nama Dokter',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color.fromARGB(255, 8, 90, 132),
                  ),
                ),
                const SizedBox(height: 5.0),
                TextFormField(
                  controller: namaController,
                  decoration: InputDecoration(
                    labelText: 'Masukan Nama Dokter',
                    suffixText: '*',
                    suffixStyle: const TextStyle(color: Colors.red),
                    prefixIcon: const Icon(Icons.person,
                        color: Color.fromARGB(255, 11, 77, 131)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 8, 90, 132)), // Warna ikon
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 8, 90, 132)), // Warna ikon
                    ),
                  ),
                  validator: FormValidator.validateName,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  keyboardType: TextInputType.name,
                  style:
                      const TextStyle(color: Color.fromARGB(255, 11, 77, 131)),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Alamat',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color.fromARGB(255, 8, 90, 132),
                  ),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: alamatController,
                  decoration: InputDecoration(
                    labelText: 'Masukan Alamat',
                    suffixText: '*',
                    suffixStyle: const TextStyle(color: Colors.red),
                    prefixIcon: const Icon(Icons.location_on,
                        color: Color.fromARGB(255, 11, 77, 131)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 8, 90, 132)), // Warna ikon
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 8, 90, 132)), // Warna ikon
                    ),
                  ),
                  validator: FormValidator.validateAddress,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  keyboardType: TextInputType.streetAddress,
                  style:
                      const TextStyle(color: Color.fromARGB(255, 11, 77, 131)),
                ),
                const SizedBox(height: 10),
                const Text(
                  'No.Telepon',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color.fromARGB(255, 8, 90, 132),
                  ),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: noTeleponController,
                  decoration: InputDecoration(
                    labelText: 'Masukan No. Telepon',
                    suffixText: '*',
                    suffixStyle: const TextStyle(color: Colors.red),
                    prefixIcon: const Icon(Icons.phone,
                        color: Color.fromARGB(255, 11, 77, 131)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 8, 90, 132)), // Warna ikon
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 8, 90, 132)), // Warna ikon
                    ),
                  ),
                  validator: FormValidator.validatePhoneNumber,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  keyboardType: TextInputType.phone,
                  style:
                      const TextStyle(color: Color.fromARGB(255, 11, 77, 131)),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Tambah Foto',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color.fromARGB(255, 8, 90, 132),
                    ),
                  ),
                ),
                Text(
                  errorMessageUploadImage ?? '',
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 100.0,
                    height: 100.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      border: Border.all(
                        color: Color.fromARGB(255, 8, 90, 132),
                        width: 2.0,
                      ),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: foto.isNotEmpty
                            ? NetworkImage('$baseUrl/api/dokter/images/$foto')
                            : const AssetImage('assets/images/image.png')
                                as ImageProvider,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.camera_alt,
                        color: Color.fromARGB(255, 8, 90, 132),
                        size: 40.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Batal',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        final validate =
                            _formKey.currentState?.validate() ?? false;
                        if (!validate) {
                          return;
                        }
                        if (!isFormValid()) {
                          setState(() {
                            errorMessage = "Form tidak valid";
                          });
                          return;
                        }
                        Dokter newDokter = Dokter(
                            nama: namaController.text,
                            idPoliklinik: selectedPoliklinikId ?? '',
                            namaPoliklinik: '',
                            alamat: alamatController.text,
                            noTelepon: noTeleponController.text,
                            nipDokter: nipDokterController.text,
                            foto: foto,
                            idAdmin: '');
                        widget.onFormSubmit(newDokter);
                      },
                      child: const Text(
                        'Simpan',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: const Color.fromARGB(255, 11, 77, 131),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool isFormValid() {
    return nipDokterController.text.isNotEmpty &&
        namaController.text.isNotEmpty &&
        alamatController.text.isNotEmpty &&
        noTeleponController.text.isNotEmpty &&
        foto.isNotEmpty &&
        selectedPoliklinikId?.isNotEmpty == true;
  }
}

class EditDokterPage extends StatefulWidget {
  final Dokter dokter;
  final Function(Dokter) onFormSubmit;
  final List<Poliklinik> poliklinikList;

  EditDokterPage({
    required this.dokter,
    required this.onFormSubmit,
    required this.poliklinikList,
  });

  @override
  _EditDokterPageState createState() => _EditDokterPageState();
}

class _EditDokterPageState extends State<EditDokterPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nipDokterController;
  late TextEditingController namaController;
  late TextEditingController alamatController;
  late TextEditingController noTeleponController;

  String fotoFileName = '';
  String? selectedPoliklinikId;
  List<Poliklinik> poliklinikList = [];

  String? errorMessage;
  String? errorMessageUploadImage;

  @override
  void initState() {
    super.initState();
    poliklinikList = widget.poliklinikList;
    nipDokterController = TextEditingController(text: widget.dokter.nipDokter);
    namaController = TextEditingController(text: widget.dokter.nama);
    alamatController = TextEditingController(text: widget.dokter.alamat);
    noTeleponController = TextEditingController(text: widget.dokter.noTelepon);
    fotoFileName = widget.dokter.foto;
    selectedPoliklinikId = widget.dokter.idPoliklinik;
  }

  Future<void> _pickImage() async {
    errorMessageUploadImage = null;
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);
      final bytes = await imageFile.readAsBytes();
      final fileName = imageFile.uri.pathSegments.last;
      final request = http.MultipartRequest(
          'POST', Uri.parse('$baseUrl/api/dokter/upload.php'));
      final multipartFile =
          http.MultipartFile.fromBytes('image', bytes, filename: fileName);
      request.files.add(multipartFile);
      final response = await request.send();
      final body = await response.stream.first;
      final responseString = utf8.decode(body);

      setState(() {
        errorMessageUploadImage = responseString;
        fotoFileName = fileName;
      });
    } else if (mounted) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Mohon pilih foto.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Data Dokter'),
        backgroundColor: const Color.fromARGB(255, 8, 90, 132),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (errorMessage?.isNotEmpty == true)
                  Text(
                    errorMessage ?? 'Form tidak valid',
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                const SizedBox(height: 10),
                const Text(
                  'NIP Dokter',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color.fromARGB(255, 8, 90, 132),
                  ),
                ),
                const SizedBox(height: 5.0),
                TextField(
                  enabled: false,
                  controller: nipDokterController,
                  decoration: InputDecoration(
                    labelText: '',
                    suffixText: '*',
                    suffixStyle: const TextStyle(color: Colors.red),
                    labelStyle: const TextStyle(
                      color:
                          Color.fromARGB(255, 8, 90, 132), // Warna teks label
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(
                            255, 8, 90, 132), // Warna border saat tidak fokus
                      ),
                    ),
                  ),
                  style: const TextStyle(
                    color: Color.fromARGB(
                        255, 11, 77, 131), // Warna teks di dalam field
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Poliklinik',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color.fromARGB(255, 8, 90, 132),
                  ),
                ),
                const SizedBox(height: 5.0),
                DropdownButtonFormField<String?>(
                  value: selectedPoliklinikId,
                  items: widget.poliklinikList.map((Poliklinik poliklinik) {
                    return DropdownMenuItem<String?>(
                      value: poliklinik.idPoliklinik.toString(),
                      child: Text(poliklinik.namaPoliklinik,
                          style: const TextStyle(
                              color: Color.fromARGB(255, 11, 77, 131))),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      selectedPoliklinikId = value ?? '';
                    });
                  },
                  decoration: InputDecoration(
                    labelText: '',
                    suffixText: '*',
                    suffixStyle: const TextStyle(color: Colors.red),
                    prefixIcon: const Icon(Icons.local_hospital,
                        color: Color.fromARGB(255, 11, 77, 131)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 8, 90, 132)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 8, 90, 132)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Nama Dokter',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color.fromARGB(255, 8, 90, 132),
                  ),
                ),
                const SizedBox(height: 5.0),
                TextFormField(
                  controller: namaController,
                  decoration: InputDecoration(
                    labelText: '',
                    suffixText: '*',
                    suffixStyle: const TextStyle(color: Colors.red),
                    prefixIcon: const Icon(Icons.person,
                        color: Color.fromARGB(255, 11, 77, 131)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 8, 90, 132)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 8, 90, 132)),
                    ),
                  ),
                  validator: FormValidator.validateName,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  keyboardType: TextInputType.name,
                  style:
                      const TextStyle(color: Color.fromARGB(255, 11, 77, 131)),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Alamat',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color.fromARGB(255, 8, 90, 132),
                  ),
                ),
                const SizedBox(height: 5.0),
                TextFormField(
                  controller: alamatController,
                  decoration: InputDecoration(
                    labelText: '',
                    suffixText: '*',
                    suffixStyle: const TextStyle(color: Colors.red),
                    prefixIcon: const Icon(Icons.location_on,
                        color: Color.fromARGB(255, 11, 77, 131)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 8, 90, 132)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 8, 90, 132)),
                    ),
                  ),
                  validator: FormValidator.validateAddress,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  keyboardType: TextInputType.streetAddress,
                  style:
                      const TextStyle(color: Color.fromARGB(255, 11, 77, 131)),
                ),
                const SizedBox(height: 10),
                const Text(
                  'No.Telepon',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color.fromARGB(255, 8, 90, 132),
                  ),
                ),
                const SizedBox(height: 5.0),
                TextFormField(
                  controller: noTeleponController,
                  decoration: InputDecoration(
                    labelText: '',
                    suffixText: '*',
                    suffixStyle: const TextStyle(color: Colors.red),
                    prefixIcon: const Icon(Icons.phone,
                        color: Color.fromARGB(255, 11, 77, 131)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 8, 90, 132)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 8, 90, 132)),
                    ),
                  ),
                  validator: FormValidator.validatePhoneNumber,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  keyboardType: TextInputType.phone,
                  style:
                      const TextStyle(color: Color.fromARGB(255, 11, 77, 131)),
                ),
                const SizedBox(height: 10),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Ubah Foto',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color.fromARGB(255, 8, 90, 132),
                    ),
                  ),
                ),
                Text(
                  errorMessageUploadImage ?? '',
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 100.0,
                    height: 100.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      border: Border.all(
                        color: Color.fromARGB(255, 8, 90, 132),
                        width: 2.0,
                      ),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: fotoFileName.isNotEmpty
                            ? NetworkImage(
                                '$baseUrl/api/dokter/images/$fotoFileName')
                            : const AssetImage('assets/images/image.png')
                                as ImageProvider,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.camera_alt,
                        color: Color.fromARGB(255, 8, 90, 132),
                        size: 40.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() != true) {
                          return;
                        }
                        if (!isFormValid()) {
                          setState(() {
                            errorMessage = 'Form tidak valid';
                          });
                          return;
                        } else {
                          errorMessage = null;
                        }
                        Dokter updatedDokter = Dokter(
                          nama: namaController.text,
                          namaPoliklinik: '',
                          idPoliklinik: selectedPoliklinikId ?? '',
                          alamat: alamatController.text,
                          noTelepon: noTeleponController.text,
                          nipDokter: nipDokterController.text,
                          foto: fotoFileName,
                          idAdmin: '',
                        );
                        widget.onFormSubmit(updatedDokter);
                      },
                      child: const Text(
                        'Simpan',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: const Color.fromARGB(255, 11, 77, 131),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool isFormValid() {
    return nipDokterController.text.isNotEmpty &&
        namaController.text.isNotEmpty &&
        selectedPoliklinikId != null &&
        alamatController.text.isNotEmpty &&
        noTeleponController.text.isNotEmpty &&
        fotoFileName.isNotEmpty;
  }
}
