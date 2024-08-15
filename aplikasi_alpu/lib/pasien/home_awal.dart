import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../pasien/info.dart';
import '../pasien/jadwal.dart';
import '/login.dart';
import '/lokasi.dart';
import '../pasien/pencarian_dokter.dart';
import 'dart:async';
// import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeAwal extends StatefulWidget {
  @override
  _HomeAwalState createState() => _HomeAwalState();
}

class _HomeAwalState extends State<HomeAwal> {
  int _selectedIndex = 0;
  final List<String> hospitalImages = [
    // "assets/images/Banner 1.png",
    "assets/images/home.png",
    "assets/images/Banner 2.png",
    "assets/images/Banner 3.png",
    "assets/images/Banner 4.png",
    "assets/images/Banner 5.png",
    // "assets/images/poli.jpeg",
    // "assets/images/rs_embung.jpg",
  ];
  late PageController _pageController;
  int _currentPage = 0;

  final List<FeatureItem> featureItems = [
    FeatureItem("Pendaftaran Online", "assets/images/formulir.png", (context) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ),
      );
    }),
    FeatureItem("Informasi Layanan", "assets/images/info.png", (context) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InfoPage(),
        ),
      );
    }),
    FeatureItem("Jadwal Dokter", "assets/images/jadwal.png", (context) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => JadwalPage(),
        ),
      );
    }),
    FeatureItem("Pencarian Dokter", "assets/images/doctor.png", (context) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PencarianDokterPage(),
        ),
      );
    }),
  ];

  List<FeatureItem> filteredFeatureItems = [];

  @override
  void initState() {
    super.initState();
    filteredFeatureItems = featureItems;

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
                  Color(0xFF0288D1)
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
          actions: <Widget>[],
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
                    Row(
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
                            "Hallo, Selamat datang di ALPU!",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors
                                  .white, // Warna ini tidak penting karena akan tertutup oleh ShaderMask
                            ),
                          ),
                        ),
                        SizedBox(width: 8), // Jarak antara teks dan ikon
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              Color.fromARGB(255, 8, 100, 146),
                              Colors.lightBlueAccent
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: FaIcon(
                            FontAwesomeIcons.handshake,
                            color: Colors
                                .white, // Warna ini tidak penting karena akan tertutup oleh ShaderMask
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.15,
                  child: PageView.builder(
                    controller: _pageController,
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
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Layanan Pasien Umum",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 8, 100, 146),
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
                    suffixIcon: Icon(
                      Icons.search,
                      color: Color.fromARGB(255, 8, 100, 146),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 8, 100, 146),
                        width: 3.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 8, 100, 146),
                        width: 2.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 8, 100, 146),
                        width: 2.0,
                      ),
                    ),
                  ),
                  style: TextStyle(
                    color: Color.fromARGB(255, 8, 100, 146),
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
                physics: NeverScrollableScrollPhysics(),
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
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Color.fromARGB(255, 8, 100, 146), width: 2.5),
        ),
        margin: EdgeInsets.all(15.10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              featureItem.icon,
              width: 45,
              height: 45,
            ),
            SizedBox(height: 8),
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
            Color(0xFF0288D1) // Biru lebih cerah
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
            icon: ImageIcon(
              AssetImage('assets/images/whatsapp.png'),
              size: 20,
            ),
            label: 'WhatsApp admin',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Lokasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_3_outlined),
            label: 'Masuk',
          ),
        ],
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent, // Set to transparent for gradient
        elevation: 1,
        selectedItemColor: Colors.white, // Warna ikon yang dipilih
        unselectedItemColor: Colors.grey[300], // Warna ikon yang tidak dipilih
        currentIndex: _selectedIndex,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
            if (index == 1) {
              openWhatsApp();
            } else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LokasiPage(),
                ),
              );
            } else if (index == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPage(),
                ),
              );
            }
          });
        },
      ),
    );
  }

  openWhatsApp() async {
    String phoneNumber = "6282171475991";
    String message = "Hallo Admin Saya Perlu Bantuan!";

    String whatsappUrl =
        "https://wa.me/$phoneNumber?text=${Uri.encodeFull(message)}";

    if (await canLaunch(whatsappUrl)) {
      await launch(whatsappUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("WhatsApp anda tidak terinstall")),
      );
    }
  }
}

class FeatureItem {
  final String title;
  final String icon;
  final Function(BuildContext) onTap;

  FeatureItem(this.title, this.icon, this.onTap);
}
