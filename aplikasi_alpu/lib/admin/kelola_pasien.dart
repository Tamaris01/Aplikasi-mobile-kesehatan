import 'dart:convert';
import 'package:alpu_pbl/form_validator.dart';
import 'package:alpu_pbl/main.dart';
import 'package:alpu_pbl/shared_prefs.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
// import 'home_admin.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class KelolaPasien extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: KelolaPasienPage(),
    );
  }
}

class Pasien {
  final String nik;
  final String idAdmin;
  final String nomorRekamMedis;
  final String namaLengkap;
  final String foto;
  final String kataSandi;
  final String email;
  final String noTelepon;
  final String alamat;

  Pasien({
    required this.nik,
    required this.idAdmin,
    required this.nomorRekamMedis,
    required this.namaLengkap,
    required this.foto,
    required this.kataSandi,
    required this.email,
    required this.noTelepon,
    required this.alamat,
  });

  factory Pasien.fromJson(Map<String, dynamic> json) {
    return Pasien(
      nik: json['nik'],
      idAdmin: json['id_admin'] ?? '',
      nomorRekamMedis: json['nomor_rekam_medis'] ?? '',
      namaLengkap: json['nama_lengkap'] ?? '',
      foto: json['foto'] ?? '',
      kataSandi: json['kata_sandi'] ?? '',
      email: json['email'] ?? '',
      noTelepon: json['no_telepon'] ?? '',
      alamat: json['alamat'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nik': nik,
      'id_admin': idAdmin,
      'nomor_rekam_medis': nomorRekamMedis,
      'nama_lengkap': namaLengkap,
      'foto': foto,
      'kata_sandi': kataSandi,
      'email': email,
      'no_telepon': noTelepon,
      'alamat': alamat,
    };
  }
}

class KelolaPasienPage extends StatefulWidget {
  @override
  _KelolaPasienPageState createState() => _KelolaPasienPageState();
}

class _KelolaPasienPageState extends State<KelolaPasienPage> {
  List<Pasien> PasienList = [];
  List<Pasien> filteredPasienList = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response =
          await http.get(Uri.parse("$baseUrl/api/pasien/read.php"));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          PasienList = data.map((item) => Pasien.fromJson(item)).toList();
          filteredPasienList = PasienList;
        });
      } else {
        print('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void filterPasien(String query) {
    setState(() {
      filteredPasienList = PasienList.where((Pasien) =>
              Pasien.namaLengkap.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<bool> updatePasien(Pasien pasien) async {
    final map = pasien.toJson();
    map['nik'] = pasien.nik;
    map['no_telepon'] = pasien.noTelepon;
    final pref = await PreferencesUtil.getInstance();
    final idAdmin = pref?.getString(PreferencesUtil.userId) ?? "";
    map['id_admin'] = idAdmin;

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/pasien/edit.php"),
        body: map,
      );
      debugPrint("Response body: ${response.body}");

      if (response.statusCode == 200) {
        print('Pasien ${pasien.namaLengkap} berhasil diupdate.');
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.scale,
          title: 'Sukses',
          desc: 'Data Pasien berhasil diupdate.',
          btnOkOnPress: () {
            Navigator.of(context).pop(); // Kembali ke halaman sebelumnya
          },
        ).show();
        return true;
      } else {
        print('Gagal mengupdate Pasien. Status code: ${response.statusCode}');
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.scale,
          title: 'Gagal',
          desc: 'Gagal mengupdate data Pasien.',
          btnOkOnPress: () {},
        ).show();
        return false;
      }
    } catch (e) {
      print('Error: $e');
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.scale,
        title: 'Error',
        desc: 'Terjadi kesalahan saat mengupdate data Pasien.',
        btnOkOnPress: () {},
      ).show();
      return false;
    }
  }

  Future<void> showSuccessDialog(BuildContext context, String message) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Berhasil'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> showErrorDialog(BuildContext context, String message) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Gagal'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void hapusPasien(Pasien pasien) async {
    bool konfirmasi = await konfirmasiHapus(pasien);

    if (konfirmasi) {
      try {
        final response = await http.delete(
          Uri.parse("$baseUrl/api/pasien/delete.php"),
          body: json.encode({"nik": pasien.nik}),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          setState(() {
            PasienList.remove(pasien);
            filteredPasienList = List.from(PasienList);
          });
          _showResultDialog("Sukses", "Data pasien berhasil dihapus");
        } else {
          _showResultDialog("Gagal", "Gagal menghapus data pasien");
        }
      } catch (e) {
        _showResultDialog(
            "Error", "Terjadi kesalahan saat menghapus data pasien");
      }
    }
  }

  Future<bool> konfirmasiHapus(Pasien pasien) async {
    bool result = false;

    await AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      headerAnimationLoop: false,
      animType: AnimType.scale,
      title: 'Konfirmasi Hapus',
      desc: 'Anda yakin ingin menghapus ${pasien.namaLengkap}?',
      btnCancelOnPress: () {},
      btnOkOnPress: () {
        result = true;
      },
      btnOkText: 'Hapus',
      btnCancelText: 'Batal',
      btnOkColor: Color.fromARGB(255, 8, 90, 132),
      btnCancelColor: Color.fromARGB(255, 219, 53, 42),
    ).show();

    return result;
  }

  void _showResultDialog(String title, String message) {
    AwesomeDialog(
      context: context,
      dialogType: title == "Sukses" ? DialogType.success : DialogType.error,
      headerAnimationLoop: false,
      animType: AnimType.scale,
      title: title,
      desc: message,
      btnOkOnPress: () {},
      btnOkText: 'OK',
      btnOkColor: Color.fromARGB(255, 8, 90, 132),
    ).show();
  }

  void tambahPasien(Pasien newPasien) async {
    final apiUrl = Uri.parse("$baseUrl/api/pasien/create.php");
    final map = newPasien.toJson();
    final idAdmin = (await SharedPreferences.getInstance())
        .getString(PreferencesUtil.userId);
    map['nik'] = newPasien.nik;
    map['no_telepon'] = newPasien.noTelepon;
    map['id_admin'] = idAdmin;

    try {
      final response = await http.post(apiUrl, body: map);
      debugPrint("sql: ${response.body}");

      if (response.statusCode == 200) {
        print('Data Pasien berhasil ditambahkan');

        setState(() {
          PasienList.add(newPasien);
          filteredPasienList = PasienList;
        });

        if (mounted) {
          Navigator.of(context).pop();
          _showSuccessDialog("Data Pasien berhasil ditambahkan");
        }
      } else {
        print('Gagal menambahkan data: ${response.reasonPhrase}');
        String message = "Gagal menambahkan data Pasien";

        if (response.body.startsWith('{')) {
          final json = jsonDecode(response.body) as Map<String, dynamic>;
          if (json.containsKey('message')) {
            message = json['message'];
          }
        }

        if (mounted) {
          _showErrorDialog(message);
        }
      }
    } catch (e) {
      print('Error: $e');
      if (mounted) {
        _showErrorDialog("Terjadi kesalahan saat menambahkan data Pasien");
      }
    }
  }

  void _showSuccessDialog(String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.scale,
      title: 'Sukses',
      desc: message,
      btnOkOnPress: () {},
    ).show();
  }

  void _showErrorDialog(String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.scale,
      title: 'Gagal',
      desc: message,
      btnOkOnPress: () {
        Navigator.of(context).pop();
      },
    ).show();
  }

  void editPasien(Pasien pasien) {
    showDialog(
      context: context,
      builder: (context) => EditPasienPage(
        pasien: pasien,
        onFormSubmit: (updatedPasien) async {
          final success = await updatePasien(updatedPasien);
          if (success) {
            setState(() {
              PasienList[PasienList.indexWhere((d) => d.nik == pasien.nik)] =
                  updatedPasien;
              filteredPasienList = List.from(PasienList);
            });
            Navigator.of(context).pop();
            AwesomeDialog(
              context: context,
              dialogType: DialogType.success,
              animType: AnimType.scale,
              title: 'Sukses',
              desc: 'Data Pasien berhasil diubah',
              btnOkOnPress: () {
                Navigator.of(context).pop(); // Kembali ke halaman sebelumnya
              },
            ).show();
          } else {
            print('Failed to update Pasien');
            AwesomeDialog(
              context: context,
              dialogType: DialogType.error,
              animType: AnimType.scale,
              title: 'Gagal',
              desc: 'Gagal mengubah data Pasien',
              btnOkOnPress: () {},
            ).show();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Kelola Pasien",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 8, 90, 132),
        leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_outlined,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            }),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: searchController,
              onChanged: filterPasien,
              decoration: InputDecoration(
                hintText: 'Cari Data Pasien...',
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
                itemCount: filteredPasienList.length,
                itemBuilder: (context, index) {
                  Pasien pasien = filteredPasienList[index];
                  return Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      side: const BorderSide(
                        color: Color.fromARGB(255, 8, 90, 132),
                        width: 2.0,
                      ),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 10.0),
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
                                child: pasien.foto.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        child: Image.network(
                                          '$baseUrl/api/pasien/images/${pasien.foto}',
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : const Placeholder(), // Placeholder saat tidak ada gambar
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
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
                                        pasien.namaLengkap,
                                        style: const TextStyle(
                                          color:
                                              Color.fromARGB(255, 8, 90, 132),
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'NIK: ${pasien.nik}',
                                        style: const TextStyle(
                                          fontSize: 16.0,
                                          color:
                                              Color.fromARGB(255, 8, 90, 132),
                                        ),
                                      ),
                                      Text(
                                        'No.Rekam Medis: ${pasien.nomorRekamMedis}',
                                        style: const TextStyle(
                                          fontSize: 16.0,
                                          color:
                                              Color.fromARGB(255, 8, 90, 132),
                                        ),
                                      ),
                                      Text(
                                        'No. Telepon: ${pasien.noTelepon}',
                                        style: const TextStyle(
                                          fontSize: 16.0,
                                          color:
                                              Color.fromARGB(255, 8, 90, 132),
                                        ),
                                      ),
                                      Text(
                                        'Email : ${pasien.email}',
                                        style: const TextStyle(
                                          fontSize: 16.0,
                                          color:
                                              Color.fromARGB(255, 8, 90, 132),
                                        ),
                                      ),
                                      Text(
                                        'Alamat: ${pasien.alamat}',
                                        style: const TextStyle(
                                          fontSize: 16.0,
                                          color:
                                              Color.fromARGB(255, 8, 90, 132),
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              editPasien(pasien);
                                            },
                                            style: TextButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 8),
                                              backgroundColor:
                                                  const Color.fromARGB(
                                                      255, 42, 127, 45),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.edit_outlined,
                                                  color: Colors.white,
                                                  size: 14,
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  'Ubah',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          TextButton(
                                            onPressed: () {
                                              hapusPasien(pasien);
                                            },
                                            style: TextButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                              backgroundColor:
                                                  const Color.fromARGB(
                                                      255, 209, 48, 36),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.delete,
                                                  color: Colors.white,
                                                  size: 14,
                                                ),
                                                SizedBox(
                                                  width: 2,
                                                ),
                                                Text(
                                                  'Hapus',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
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
            builder: (context) => AddPasienPage(
              onFormSubmit: (newPasien) {
                tambahPasien(newPasien);
              },
            ),
          );
        },
        child: const FaIcon(FontAwesomeIcons.plus),
        backgroundColor: const Color.fromARGB(255, 8, 90, 132),
      ),
    );
  }
}

// -------TambahDataPasien--------- //
class AddPasienPage extends StatefulWidget {
  final Function(Pasien) onFormSubmit;

  AddPasienPage({required this.onFormSubmit});

  @override
  _AddPasienPageState createState() => _AddPasienPageState();
}

class _AddPasienPageState extends State<AddPasienPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nikController;
  late TextEditingController nomorRekamMedisController;
  late TextEditingController kataSandiController;
  late TextEditingController namaLengkapController;
  late TextEditingController alamatController;
  late TextEditingController noTeleponController;
  late TextEditingController emailController;

  String foto = '';
  String? errorMessage;
  String? errorMessageUploadImage;
  bool isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    nikController = TextEditingController();
    nomorRekamMedisController = TextEditingController();
    kataSandiController = TextEditingController();
    namaLengkapController = TextEditingController();
    alamatController = TextEditingController();
    noTeleponController = TextEditingController();
    emailController = TextEditingController();
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
          'POST', Uri.parse('$baseUrl/api/pasien/upload.php'));
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
        title: const Text('Tambah Data Pasien'),
        backgroundColor: Color.fromARGB(255, 8, 90, 132),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
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
                'NIK Pasien',
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
                controller: nikController,
                decoration: InputDecoration(
                  labelText: 'Masukan NIK Pasien',
                  suffixText: '*',
                  suffixStyle: const TextStyle(color: Colors.red),
                  labelStyle: const TextStyle(
                    color: Color.fromARGB(255, 8, 90, 132),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 8, 90, 132),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 8, 90, 132),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 8, 90, 132),
                    ),
                  ),
                  prefixIcon: const Icon(Icons.credit_card,
                      color: Color.fromARGB(255, 8, 90, 132)),
                ),
                style: const TextStyle(
                  color: Color.fromARGB(255, 11, 77, 131),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Nama Pasien',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color.fromARGB(255, 8, 90, 132),
                ),
              ),
              const SizedBox(height: 5.0),
              TextFormField(
                validator: FormValidator.validateName,
                keyboardType: TextInputType.name,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                controller: namaLengkapController,
                decoration: InputDecoration(
                  labelText: 'Masukan Nama Pasien',
                  suffixText: '*',
                  suffixStyle: const TextStyle(color: Colors.red),
                  labelStyle: const TextStyle(
                    color: Color.fromARGB(255, 8, 90, 132),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 8, 90, 132),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 8, 90, 132),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 8, 90, 132),
                    ),
                  ),
                  prefixIcon: const Icon(Icons.person,
                      color: Color.fromARGB(255, 8, 90, 132)),
                ),
                style: const TextStyle(
                  color: Color.fromARGB(255, 11, 77, 131),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 10),
              const Text(
                'Kata Sandi',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color.fromARGB(255, 8, 90, 132),
                ),
              ),
              const SizedBox(height: 5.0),
              TextFormField(
                controller: kataSandiController,
                obscureText: !isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Masukan Kata Sandi',
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Color.fromARGB(
                          255, 8, 90, 132), // Warna biru tua untuk ikon
                    ),
                  ),
                  suffixStyle: TextStyle(
                    color: _isPasswordValid(kataSandiController.text)
                        ? Colors.green // Warna hijau jika kata sandi kuat
                        : Colors.red, // Warna merah jika kata sandi lemah
                  ),
                  helperText: _isPasswordValid(kataSandiController.text)
                      ? 'Kata Sandi Kuat'
                      : '',
                  helperStyle: TextStyle(
                    color: _isPasswordValid(kataSandiController.text)
                        ? Colors
                            .green // Warna hijau untuk teks "Kata Sandi Kuat"
                        : Colors
                            .black, // Warna hitam jika tidak ada pesan "Kata Sandi Kuat"
                  ),
                  errorText: kataSandiController.text.isNotEmpty &&
                          !_isPasswordValid(kataSandiController.text)
                      ? 'Kata Sandi lemah'
                      : null,
                  errorStyle: TextStyle(
                    color: Colors.red, // Warna merah untuk pesan error
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                      color: Color.fromARGB(
                          255, 8, 90, 132), // Warna biru tua border
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                      color: Color.fromARGB(
                          255, 8, 90, 132), // Warna biru tua border
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                      color: Color.fromARGB(
                          255, 8, 90, 132), // Warna biru tua border
                    ),
                  ),
                  prefixIcon: Icon(
                    Icons.lock,
                    color: Color.fromARGB(
                        255, 8, 90, 132), // Warna biru tua untuk ikon
                  ),
                ),
                style: TextStyle(
                  color: Color.fromARGB(
                      255, 8, 90, 132), // Warna biru tua untuk teks input
                ),
                onChanged: (_) => setState(() {}),
              ),
              const Text(
                'No. Telepon',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color.fromARGB(255, 8, 90, 132),
                ),
              ),
              const SizedBox(height: 5.0),
              TextFormField(
                validator: FormValidator.validatePhoneNumber,
                keyboardType: TextInputType.phone,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                controller: noTeleponController,
                decoration: InputDecoration(
                  labelText: 'Masukan Nomor Telepon',
                  suffixText: '*',
                  suffixStyle: const TextStyle(color: Colors.red),
                  labelStyle: const TextStyle(
                    color: Color.fromARGB(255, 8, 90, 132),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 8, 90, 132),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 8, 90, 132),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 8, 90, 132),
                    ),
                  ),
                  prefixIcon: const Icon(Icons.phone,
                      color: Color.fromARGB(255, 8, 90, 132)),
                ),
                style: const TextStyle(
                  color: Color.fromARGB(255, 11, 77, 131),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 10),
              const Text(
                'Email',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color.fromARGB(255, 8, 90, 132),
                ),
              ),
              const SizedBox(height: 5.0),
              TextFormField(
                validator: FormValidator.validateEmail,
                keyboardType: TextInputType.emailAddress,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Masukan Email',
                  suffixText: '*',
                  suffixStyle: const TextStyle(color: Colors.red),
                  labelStyle: const TextStyle(
                    color: Color.fromARGB(255, 8, 90, 132),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 8, 90, 132),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 8, 90, 132),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 8, 90, 132),
                    ),
                  ),
                  prefixIcon: const Icon(Icons.email,
                      color: Color.fromARGB(255, 8, 90, 132)),
                ),
                style: const TextStyle(
                  color: Color.fromARGB(255, 11, 77, 131),
                ),
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
                validator: FormValidator.validateAddress,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                controller: alamatController,
                decoration: InputDecoration(
                  labelText: 'Alamat',
                  suffixText: '*',
                  suffixStyle: const TextStyle(color: Colors.red),
                  labelStyle: const TextStyle(
                    color: Color.fromARGB(255, 8, 90, 132),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 8, 90, 132),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 8, 90, 132),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 8, 90, 132),
                    ),
                  ),
                  prefixIcon: const Icon(Icons.home,
                      color: Color.fromARGB(255, 8, 90, 132)),
                ),
                style: const TextStyle(
                  color: Color.fromARGB(255, 11, 77, 131),
                ),
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
                          ? NetworkImage('$baseUrl/api/pasien/images/$foto')
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
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
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
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState?.validate() != true) {
                  return;
                }
                if (!isFormValid()) {
                  setState(() {
                    errorMessage = "Form tidak valid";
                  });
                  return;
                }
                if (!_isPasswordValid(kataSandiController.text)) {
                  setState(() {
                    errorMessage = "Kata Sandi yang anda inputkan lemah!";
                  });
                  return;
                }
                Pasien newPasien = Pasien(
                    nik: nikController.text,
                    nomorRekamMedis: nomorRekamMedisController.text,
                    namaLengkap: namaLengkapController.text,
                    foto: foto,
                    email: emailController.text,
                    kataSandi: kataSandiController.text,
                    alamat: alamatController.text,
                    noTelepon: noTeleponController.text,
                    idAdmin: '');
                widget.onFormSubmit(newPasien);
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
      ),
    );
  }

  bool isFormValid() {
    return nikController.text.isNotEmpty &&
        // nomorRekamMedisController.text.isNotEmpty &&
        namaLengkapController.text.isNotEmpty &&
        foto.isNotEmpty &&
        // kataSandiController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        noTeleponController.text.isNotEmpty &&
        alamatController.text.isNotEmpty;
  }

  bool _isPasswordValid(String password) {
    if (password.length < 8) {
      return false; // Kata sandi terlalu pendek
    }

    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasDigit = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialCharacters =
        password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    return hasUppercase && hasLowercase && hasDigit && hasSpecialCharacters;
  }
}

class EditPasienPage extends StatefulWidget {
  final Pasien pasien;
  final Function(Pasien) onFormSubmit;

  EditPasienPage({required this.pasien, required this.onFormSubmit});

  @override
  _EditPasienPageState createState() => _EditPasienPageState();
}

class _EditPasienPageState extends State<EditPasienPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nikController;
  late TextEditingController nomorRekamMedisController;
  late TextEditingController namaLengkapController;
  late TextEditingController emailController;
  late TextEditingController noTeleponController;
  late TextEditingController alamatController;
  late TextEditingController newPasswordController;

  String fotoFileName = '';
  String? errorMessage;
  String? errorMessageUploadImage;

  @override
  void initState() {
    super.initState();

    nikController = TextEditingController(text: widget.pasien.nik);
    nomorRekamMedisController =
        TextEditingController(text: widget.pasien.nomorRekamMedis);
    namaLengkapController =
        TextEditingController(text: widget.pasien.namaLengkap);
    emailController = TextEditingController(text: widget.pasien.email);
    alamatController = TextEditingController(text: widget.pasien.alamat);
    noTeleponController = TextEditingController(text: widget.pasien.noTelepon);
    newPasswordController = TextEditingController();
    fotoFileName = widget.pasien.foto;
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
          'POST', Uri.parse('$baseUrl/api/pasien/upload.php'));
      final multipartFile =
          http.MultipartFile.fromBytes('image', bytes, filename: fileName);
      request.files.add(multipartFile);
      final response = await request.send();
      final body = await response.stream.first;
      final responseString = utf8.decode(body);

      setState(() {
        errorMessageUploadImage = responseString;
        fotoFileName = fileName; // Mendapatkan URL foto dari response server
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
        title: const Text('Ubah Data Pasien'),
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
                    errorMessage ?? 'Form tidak valid',
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                const SizedBox(height: 10),
                const Text(
                  'NIK Pasien',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color.fromARGB(255, 8, 90, 132),
                  ),
                ),
                const SizedBox(height: 5.0),
                TextField(
                  enabled: false,
                  controller: nikController,
                  decoration: InputDecoration(
                    labelText: '',
                    suffixText: '*',
                    suffixStyle: const TextStyle(color: Colors.red),
                    labelStyle: const TextStyle(
                      color: Color.fromARGB(255, 8, 90, 132),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 8, 90, 132),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 8, 90, 132),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 8, 90, 132),
                      ),
                    ),
                    prefixIcon: const Icon(
                      Icons.credit_card,
                      color: Color.fromARGB(255, 8, 90, 132),
                    ),
                  ),
                  style: const TextStyle(
                    color: Color.fromARGB(255, 11, 77, 131),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Nama Pasien',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color.fromARGB(255, 8, 90, 132),
                  ),
                ),
                const SizedBox(height: 5.0),
                TextFormField(
                  controller: namaLengkapController,
                  decoration: InputDecoration(
                    labelText: '',
                    suffixText: '*',
                    suffixStyle: const TextStyle(color: Colors.red),
                    labelStyle: const TextStyle(
                      color: Color.fromARGB(255, 8, 90, 132),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 8, 90, 132),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 8, 90, 132),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 8, 90, 132),
                      ),
                    ),
                    prefixIcon: const Icon(
                      Icons.person,
                      color: Color.fromARGB(255, 8, 90, 132),
                    ),
                  ),
                  validator: FormValidator.validateName,
                  keyboardType: TextInputType.name,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 11, 77, 131),
                  ),
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
                  validator: FormValidator.validatePhoneNumber,
                  keyboardType: TextInputType.phone,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  controller: noTeleponController,
                  decoration: InputDecoration(
                    labelText: '',
                    suffixText: '*',
                    suffixStyle: const TextStyle(color: Colors.red),
                    labelStyle: const TextStyle(
                      color: Color.fromARGB(255, 8, 90, 132),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 8, 90, 132),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 8, 90, 132),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 8, 90, 132),
                      ),
                    ),
                    prefixIcon: const Icon(
                      Icons.phone,
                      color: Color.fromARGB(255, 8, 90, 132),
                    ),
                  ),
                  style: const TextStyle(
                    color: Color.fromARGB(255, 11, 77, 131),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Email',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color.fromARGB(255, 8, 90, 132),
                  ),
                ),
                const SizedBox(height: 5.0),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: '',
                    suffixText: '*',
                    suffixStyle: const TextStyle(color: Colors.red),
                    labelStyle: const TextStyle(
                      color: Color.fromARGB(255, 8, 90, 132),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 8, 90, 132),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 8, 90, 132),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 8, 90, 132),
                      ),
                    ),
                    prefixIcon: const Icon(
                      Icons.email,
                      color: Color.fromARGB(255, 8, 90, 132),
                    ),
                  ),
                  validator: FormValidator.validateEmail,
                  keyboardType: TextInputType.emailAddress,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 11, 77, 131),
                  ),
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
                    labelStyle: const TextStyle(
                      color: Color.fromARGB(255, 8, 90, 132),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 8, 90, 132),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 8, 90, 132),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 8, 90, 132),
                      ),
                    ),
                    prefixIcon: const Icon(
                      Icons.location_on,
                      color: Color.fromARGB(255, 8, 90, 132),
                    ),
                  ),
                  validator: FormValidator.validateAddress,
                  keyboardType: TextInputType.streetAddress,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 11, 77, 131),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Kata Sandi',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color.fromARGB(255, 8, 90, 132),
                  ),
                ),
                const SizedBox(height: 5.0),
                TextFormField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: ' Masukan Kata Sandi Baru',
                    suffixText: '*',
                    suffixStyle: const TextStyle(color: Colors.red),
                    labelStyle: const TextStyle(
                      color: Color.fromARGB(255, 8, 90, 132),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 8, 90, 132),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 8, 90, 132),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 8, 90, 132),
                      ),
                    ),
                    prefixIcon: const Icon(
                      Icons.lock,
                      color: Color.fromARGB(255, 8, 90, 132),
                    ),
                  ),
                  style: const TextStyle(
                    color: Color.fromARGB(255, 11, 77, 131),
                  ),
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
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
                                '$baseUrl/api/pasien/images/$fotoFileName')
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
                        Pasien updatedPasien = Pasien(
                          nik: nikController.text,
                          namaLengkap: namaLengkapController.text,
                          nomorRekamMedis: nomorRekamMedisController.text,
                          email: emailController.text,
                          alamat: alamatController.text,
                          noTelepon: noTeleponController.text,
                          foto: fotoFileName,
                          idAdmin: '',
                          kataSandi: newPasswordController.text.isNotEmpty
                              ? newPasswordController.text
                              : widget.pasien
                                  .kataSandi, // Mengganti kata sandi jika diisi
                        );
                        widget.onFormSubmit(updatedPasien);
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
    final valid = nikController.text.isNotEmpty &&
        namaLengkapController.text.isNotEmpty &&
        fotoFileName.isNotEmpty &&
        emailController.text.isNotEmpty &&
        noTeleponController.text.isNotEmpty &&
        alamatController.text.isNotEmpty;
    return valid;
  }
}
