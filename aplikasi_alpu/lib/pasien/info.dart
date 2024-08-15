import 'package:alpu_pbl/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

void main() {
  runApp(const layanan());
}

class layanan extends StatelessWidget {
  const layanan({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: InfoPage(),
    );
  }
}

class InfoPage extends StatefulWidget {
  InfoPage({Key? key}) : super(key: key);

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  List<Map<String, dynamic>> _listData = [];
  bool _isLoading = false;
  String _searchQuery = '';

  Future _getData() async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/api/layanan/read.php'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<Map<String, dynamic>> dataList =
            List<Map<String, dynamic>>.from(data);

        setState(() {
          _listData = dataList;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  List<dynamic> get _filteredData {
    return _listData.where((data) {
      final nama_poliklinik = data['nama_poliklinik'].toString().toLowerCase();
      return nama_poliklinik.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  void initState() {
    _getData();
    super.initState();
  }

  String splitPoliName(String poliName) {
    List<String> words = poliName.split(' ');

    if (words.length > 3) {
      return words.sublist(0, 2).join(' ') + '\n' + words.sublist(2).join(' ');
    } else {
      return poliName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 8, 100, 146),
                Color.fromARGB(255, 8, 100, 146)
              ], // Warna gradasi
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          "Informasi Layanan",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_outlined,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Cari Poliklinik...',
                suffixIcon: Icon(
                  Icons.search,
                  color: Color.fromARGB(255, 8, 90, 132),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: BorderSide(
                    color: Color.fromARGB(255, 8, 90, 132),
                    width: 2.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: Color.fromARGB(255, 8, 90, 132),
                    width: 2.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: Color.fromARGB(230, 8, 100, 146),
                    width: 2.0,
                  ),
                ),
                labelText: 'Cari Poliklinik...',
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
          ),
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : _filteredData.isEmpty
                    ? Center(
                        child: Text('Data tidak ditemukan.'),
                      )
                    : GridView.builder(
                        padding: EdgeInsets.all(10.0),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // Dua kartu per baris
                          childAspectRatio:
                              0.9, // Rasio 1:1.1 untuk kartu lebih kompak
                          mainAxisSpacing: 8.0,
                          crossAxisSpacing: 8.0,
                        ),
                        itemCount: _filteredData.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailDataPage(
                                    ListData: {
                                      "id_poliklinik": _filteredData[index]
                                          ['id_poliklinik'],
                                      "nama_poliklinik": _filteredData[index]
                                          ['nama_poliklinik'],
                                      "detail": _filteredData[index]['detail'],
                                      "foto_rs": _filteredData[index]
                                          ['foto_rs'],
                                      "foto_logo": _filteredData[index]
                                          ['foto_logo'],
                                    },
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              margin: EdgeInsets.zero,
                              color: Colors.white,
                              elevation: 4, // Menambah efek cahaya
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                side: BorderSide(
                                  color: Color.fromARGB(255, 8, 100, 146),
                                  width: 2.5, // Menambah ketebalan border
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Ukuran logo 2x2
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.25, // Ukuran logo lebih kecil
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.25,
                                      child: _filteredData[index]
                                                  ['foto_logo'] !=
                                              null
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              child: Image.network(
                                                '$baseUrl/api/layanan/images/${_filteredData[index]['foto_logo']}',
                                                fit: BoxFit.contain,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  print(
                                                      'Error loading image: $error');
                                                  return Icon(Icons.error);
                                                },
                                              ),
                                            )
                                          : Icon(Icons.image_not_supported),
                                    ),
                                    SizedBox(height: 10.0),
                                    // Nama poliklinik di bawah logo
                                    Flexible(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4.0),
                                        child: Text(
                                          splitPoliName(_filteredData[index]
                                              ['nama_poliklinik']),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF06628A),
                                          ),
                                        ),
                                      ),
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
    );
  }
}

class DetailDataPage extends StatefulWidget {
  final Map ListData;
  const DetailDataPage({Key? key, required this.ListData}) : super(key: key);

  @override
  State<DetailDataPage> createState() => _DetailDataPageState();
}

class _DetailDataPageState extends State<DetailDataPage> {
  // ignore: unused_field
  List<Map<String, dynamic>> _listData = [];
  int Index = 0;

//=============================================================
  File? pictureFile;
  File? pictureFileTwo;
//=============================================================

  Future _getData() async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/api/layanan/read.php'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<Map<String, dynamic>> dataList =
            List<Map<String, dynamic>>.from(data);

        setState(() {
          _listData = dataList;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    _getData();
    super.initState();
  }

  final formKey = GlobalKey<FormState>();

  TextEditingController id_poli = TextEditingController();
  TextEditingController nama_poli = TextEditingController();
  TextEditingController detail = TextEditingController();

  @override
  Widget build(BuildContext context) {
    id_poli.text = widget.ListData['id_poliklinik'];
    nama_poli.text = widget.ListData['nama_poliklinik'];
    detail.text = widget.ListData['detail'];

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_outlined,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          flexibleSpace: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return FlexibleSpaceBar(
                title: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    "${widget.ListData['nama_poliklinik'].toUpperCase()}",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0, // Set a default font size
                    ),
                  ),
                ),
              );
            },
          ),
          backgroundColor: Color(0xFF06628A),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(15),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5.0),
                  child: () {
                    var imageUrl = widget.ListData['foto_rs'];
                    var completeImageUrl =
                        '$baseUrl/api/layanan/images/$imageUrl';
                    print('Complete Image URL: $completeImageUrl');

                    return imageUrl != null && imageUrl.isNotEmpty
                        ? Image.network(completeImageUrl)
                        : Container();
                  }(),
                ),
              ),
              Card(
                elevation: 4,
                margin: const EdgeInsets.all(15),
                child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            nama_poli.text,
                            style: const TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  detail.text,
                                  textAlign: TextAlign.justify,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.normal),
                                ),
                              ),
                            ],
                          )
                        ])),
              ),
            ],
          ),
        ));
  }
}
