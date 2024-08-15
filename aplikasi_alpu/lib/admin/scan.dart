import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Tambahkan ini
import 'package:alpu_pbl/main.dart';
import 'package:alpu_pbl/shared_prefs.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class ScanPage extends StatefulWidget {
  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  String _scanBarcode = '';
  String _status = '';
  bool _showConfirmButton = false;

  @override
  void initState() {
    super.initState();
    _startBarcodeScan();
  }

  Future<void> _startBarcodeScan() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#FF0000', // Warna garis pemindaian
        '', // Teks tombol batal
        true, // Tampilkan ikon flash
        ScanMode.BARCODE, // Mode pemindaian
      );
      if (barcodeScanRes != '-1') {
        setState(() {
          _scanBarcode = barcodeScanRes;
          _showConfirmButton =
              true; // Tampilkan tombol konfirmasi jika pemindaian berhasil
        });
        await _checkStatusAndUpdateUI(_scanBarcode);
      } else {
        setState(() {
          _scanBarcode = '';
          _status = '';
          _showConfirmButton =
              false; // Sembunyikan tombol konfirmasi jika pemindaian dibatalkan
        });
      }
    } catch (e) {
      print('Error scanning barcode: $e');
    }
  }

  Future<String> _getAdminId() async {
    PreferencesUtil? prefs = await PreferencesUtil.getInstance();
    return prefs?.getString(PreferencesUtil.userId) ?? '';
  }

  Future<void> _checkStatusAndUpdateUI(String barcode) async {
    if (barcode.isNotEmpty) {
      try {
        final uri = Uri.parse(
            '$baseUrl/api/kehadiran/check_status.php'); // URL PHP untuk memeriksa status
        final response = await http.post(
          uri,
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: {'id_pendaftaran': barcode},
        );

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          setState(() {
            _status = responseData['status'] ?? 'Tidak ada status';
            _showConfirmButton = _status == 'belum_dikonfirmasi';
          });
        } else {
          final snackBar = SnackBar(
            content: Text('HTTP Error: ${response.statusCode}'),
            backgroundColor: Colors.red,
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      } catch (e) {
        final snackBar = SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  Future<void> _confirmKehadiran() async {
    if (_scanBarcode.isNotEmpty) {
      try {
        String idAdmin = await _getAdminId();
        if (idAdmin.isEmpty) {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            headerAnimationLoop: false,
            animType: AnimType.scale,
            title: 'Error',
            desc: 'ID Admin tidak ditemukan. Harap login terlebih dahulu.',
            btnOkOnPress: () {},
            btnOkColor: Colors.red,
          )..show();
          return;
        }

        final uri = Uri.parse(
            '$baseUrl/api/kehadiran/update_status.php'); // URL PHP untuk memperbarui status
        final response = await http.post(
          uri,
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: {
            'id_pendaftaran': _scanBarcode,
            'status': 'hadir',
            'id_admin': idAdmin,
          },
        );

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          if (responseData['pesan'] == 'sukses') {
            AwesomeDialog(
              context: context,
              dialogType: DialogType.success,
              headerAnimationLoop: false,
              animType: AnimType.scale,
              title: 'Berhasil',
              desc: 'Kehadiran berhasil dikonfirmasi',
              btnOkOnPress: () {},
              btnOkColor: Colors.green,
            )..show();
            setState(() {
              _showConfirmButton = false;
            });
          } else {
            AwesomeDialog(
              context: context,
              dialogType: DialogType.error,
              headerAnimationLoop: false,
              animType: AnimType.scale,
              title: 'Error',
              desc: responseData['error'] ?? 'Gagal mengkonfirmasi kehadiran',
              btnOkOnPress: () {},
              btnOkColor: Colors.red,
            )..show();
          }
        } else {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            headerAnimationLoop: false,
            animType: AnimType.scale,
            title: 'Error',
            desc: 'HTTP Error: ${response.statusCode}',
            btnOkOnPress: () {},
            btnOkColor: Colors.red,
          )..show();
        }
      } catch (e) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          headerAnimationLoop: false,
          animType: AnimType.scale,
          title: 'Error',
          desc: 'Terjadi kesalahan: $e',
          btnOkOnPress: () {},
          btnOkColor: Colors.red,
        )..show();
      }
    } else {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        headerAnimationLoop: false,
        animType: AnimType.scale,
        title: 'Error',
        desc: 'Data tidak valid',
        btnOkOnPress: () {},
        btnOkColor: Colors.red,
      )..show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan QR Code'),
        backgroundColor: Color.fromARGB(255, 8, 90, 132),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 255, 255, 255),
              Color.fromARGB(255, 249, 252, 255),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 16),
                Container(
                  width: MediaQuery.of(context).size.width *
                      0.9, // Responsif terhadap ukuran layar
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 6),
                      ),
                    ],
                    border: Border.all(
                      width: 3,
                      color: Color.fromARGB(255, 8, 90, 132),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hasil Pemindaian',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 8, 90, 132),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _scanBarcode,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Status:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 8, 90, 132),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _status.isEmpty ? 'Tidak ada status' : _status,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 30),
                      if (_showConfirmButton)
                        Align(
                          alignment:
                              Alignment.center, // Menempatkan tombol di tengah
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width *
                                0.9, // Lebar tombol
                            height: 50, // Tinggi tombol
                            child: ElevatedButton(
                              onPressed: _confirmKehadiran,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .center, // Menyebar ikon dan teks di tengah
                                children: [
                                  FaIcon(FontAwesomeIcons.check,
                                      size: 22,
                                      color: Colors.white), // Ikon konfirmasi
                                  SizedBox(width: 8),
                                  Text('Konfirmasi Hadir',
                                      style: TextStyle(color: Colors.white)),
                                ],
                              ),
                              style: ElevatedButton.styleFrom(
                                primary: Color.fromARGB(
                                    255, 7, 171, 7), // Warna biru tombol
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 5,
                              ),
                            ),
                          ),
                        ),
                      SizedBox(height: 16),
                      Align(
                        alignment:
                            Alignment.center, // Menempatkan tombol di tengah
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width *
                              0.9, // Lebar tombol
                          height: 50, // Tinggi tombol
                          child: ElevatedButton(
                            onPressed: _startBarcodeScan,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment
                                  .center, // Menyebar ikon dan teks di tengah
                              children: [
                                FaIcon(FontAwesomeIcons.camera,
                                    size: 22,
                                    color: Colors
                                        .white), // Ikon pemindaian dari Font Awesome
                                SizedBox(width: 8),
                                Text('Scan Ulang',
                                    style: TextStyle(color: Colors.white)),
                              ],
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: Color.fromARGB(255, 10, 107, 155),
                              // Warna biru tombol
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
