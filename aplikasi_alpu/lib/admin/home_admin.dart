import 'package:alpu_pbl/user_profile.dart';
import 'package:alpu_pbl/main.dart';
import 'package:alpu_pbl/shared_prefs.dart';
import 'package:flutter/material.dart';
import '../admin/kelola_dokter.dart';
import '../admin/kelola_pasien.dart';
import '../admin/kelola_jadwal.dart';
import '../admin/konfirmasi.dart';
import '../admin/daftar_hadir.dart';
import '../admin/scan.dart';
import '../admin/kelola_poliklinik.dart';
import '../splash.dart';
import 'dart:async';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_dialog/awesome_dialog.dart';

class HomeAdminPage extends StatefulWidget {
  @override
  _HomeAdminPageState createState() => _HomeAdminPageState();
}

class _HomeAdminPageState extends State<HomeAdminPage> {
  String name = '';
  final List<String> hospitalImages = [
    "assets/images/home.png",
    "assets/images/Banner Admin 2.png",
    "assets/images/Banner Admin 3.png",
    "assets/images/Banner Admin 4.png",
    "assets/images/Banner Admin 5.png",
    // "assets/images/poli.jpeg",
    // "assets/images/rs_embung.jpg",
  ];
  late PageController _pageController;
  int _currentPage = 0;

  final List<FeatureItem> featureItems = [
    FeatureItem("Konfirmasi", "assets/images/confirm.png",
        (BuildContext context) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => KehadiranPage(),
        ),
      );
    }),
    FeatureItem("Kelola Poliklinik", "assets/images/info.png",
        (BuildContext context) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const KelolaPoliklinikPage(),
        ),
      );
    }),
    FeatureItem("Kelola Jadwal", "assets/images/jadwal.png",
        (BuildContext context) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => KelolaJadwalDokterPage(),
        ),
      );
    }),
    FeatureItem("Kelola Dokter", "assets/images/doctor.png",
        (BuildContext context) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => KelolaDokterPage(),
        ),
      );
    }),
    FeatureItem("Kelola Pasien", "assets/images/kelola_pasien.png",
        (BuildContext context) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => KelolaPasienPage(),
        ),
      );
    }),
  ];

  List<FeatureItem> filteredFeatureItems = [];
  @override
  void initState() {
    super.initState();
    final cek =
        featureItems.where((element) => element.title == 'Profil').toList();
    if (cek.isEmpty) {
      final item = FeatureItem("Profile", "assets/images/profile.png",
          (BuildContext context) async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileUser(),
          ),
        );
        _loadAdmin();
      });
      featureItems.add(item);
    }

    filteredFeatureItems = featureItems;
    _loadAdmin();

    _pageController = PageController(initialPage: _currentPage);

    Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (_currentPage < hospitalImages.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 600),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 8, 100, 146),
                  Color(0xFF0288D1),
                ], // Gradasi biru tua
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: Text(
            "ALPU",
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
            ),
          ),
          elevation: 4,
          actions: <Widget>[
            IconButton(
              icon: const Icon(
                Icons.exit_to_app,
                color: Colors.white,
                size: 26.0, // Warna putih
              ),
              onPressed: () {
                AwesomeDialog(
                  context: context,
                  dialogType: DialogType.info,
                  headerAnimationLoop: false,
                  animType: AnimType.scale,
                  title: 'Konfirmasi Keluar',
                  desc: 'Apakah Anda yakin ingin keluar?',
                  btnCancelOnPress: () {},
                  btnOkOnPress: () {
                    _handleLogout(); // Panggil void logout saat tombol "Iya" diklik
                  },
                  btnOkText: 'Iya',
                  btnCancelText: 'Tidak',
                  btnOkColor: Color.fromARGB(255, 8, 90, 132),
                  btnCancelColor: Colors.red,
                )..show();
              },
            ),
          ],
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          Color.fromARGB(255, 8, 100, 146),
                          Colors.lightBlueAccent
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: Text(
                        "Hallo, Selamat Datang $name !",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors
                              .white, // Warna ini tidak penting karena akan tertutup oleh ShaderMask
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.15,
                  child: PageView.builder(
                    controller:
                        _pageController, // Tambahkan _pageController di sini
                    itemCount: hospitalImages.length,
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Image.asset(
                          hospitalImages[index],
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                  ),
                ),
              ),
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Menu Admin",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 8, 90, 132),
                      letterSpacing: 1.0,
                      shadows: [
                        Shadow(
                          blurRadius: 2,
                          color: Color(0xFFCCEBFF),
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Cari layanan",
                    suffixIcon: const Icon(
                      Icons.search,
                      color: Color.fromARGB(255, 8, 94, 137),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 8, 94, 137),
                        width: 3.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 8, 94, 137),
                        width: 2.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 8, 94, 137),
                        width: 2.5,
                      ),
                    ),
                  ),
                  style: const TextStyle(
                    color: Color.fromARGB(255, 8, 94, 137),
                    fontStyle: FontStyle.italic,
                  ),
                  onChanged: (text) {
                    setState(() {
                      filteredFeatureItems = featureItems
                          .where((item) => item.title
                              .toLowerCase()
                              .contains(text.toLowerCase()))
                          .toList();
                    });
                  },
                ),
              ),
              GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                      MediaQuery.of(context).size.width > 400 ? 3 : 2,
                ),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredFeatureItems.length,
                itemBuilder: (context, index) {
                  return _buildFeatureCard(
                      filteredFeatureItems[index], context);
                },
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(context),
      ),
    );
  }

  Widget _buildFeatureCard(FeatureItem featureItem, BuildContext context) {
    return GestureDetector(
      onTap: () => featureItem.onTap(context),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(
              color: Color.fromARGB(255, 8, 94, 137), width: 3.0),
        ),
        margin: const EdgeInsets.all(15.10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              featureItem.icon,
              width: 45,
              height: 45,
            ),
            const SizedBox(height: 8),
            Text(
              featureItem.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color.fromARGB(255, 8, 100, 146),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 8, 100, 146),
            Color(0xFF0288D1), // Biru lebih cerah
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(
                FontAwesomeIcons.qrcode), // Ikon QR Code dari Font Awesome
            label: 'Scan QR',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(
                FontAwesomeIcons.listAlt), // Ikon Daftar dari Font Awesome
            label: 'Daftar Hadir',
          ),
        ],
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent, // Set to transparent for gradient
        elevation: 1,
        selectedItemColor: Colors.white, // Warna ikon yang dipilih
        unselectedItemColor: Colors.grey[300], // Warna ikon yang tidak dipilih
        onTap: (int index) {
          switch (index) {
            case 0:
              // Tambahkan logika untuk beranda di sini
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ScanPage(),
                ),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DaftarHadirPage(),
                ),
              );
              break;
          }
        },
      ),
    );
  }

  void _handleLogout() async {
    try {
      final pref = await PreferencesUtil.getInstance();
      await pref?.clearAll();

      final response = await http.post(
        Uri.parse('$baseUrl/api/logout.php'),
      );
      debugPrint(response.body);
      if (response.statusCode == 200) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => SplashPage(),
          ),
          (r) => false,
        );

        _showSnackBar('Berhasil Keluar',
            backgroundColor: Color.fromARGB(255, 64, 190, 131));
      } else {
        throw Exception('Logout gagal');
      }
    } catch (e) {
      print('Error during logout: $e');
      _showSnackBar('Terjadi kesalahan saat logout',
          backgroundColor: Colors.red);
    }
  }

  void _showSnackBar(String message, {Color backgroundColor = Colors.green}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
        backgroundColor: backgroundColor,
      ),
    );
  }

  void _loadAdmin() async {
    final pref = await PreferencesUtil.getInstance();
    name = pref?.getString(PreferencesUtil.name) ?? '';
    if (mounted) {
      setState(() {});
    }
  }
}

class FeatureItem {
  final String title;
  final String icon;
  final Function(BuildContext) onTap;

  FeatureItem(this.title, this.icon, this.onTap);
}
