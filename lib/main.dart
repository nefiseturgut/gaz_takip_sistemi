import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter motorunu başlat
  await Firebase.initializeApp(); // Firebase başlatılır
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gaz Takip Sistemi',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: GirisEkrani(),
    );
  }
}

class SensorDataReader extends StatefulWidget {
  const SensorDataReader({super.key});

  @override
  State<SensorDataReader> createState() => _SensorDataReaderState();
}

class _SensorDataReaderState extends State<SensorDataReader> {
  String _sensorStatus = "Veri bekleniyor...";
  Timer? _timer;
  final String esp32IpAddress = '192.168.4.1';
  final AudioPlayer _alarmPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _startFetchingSensorData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _alarmPlayer.dispose();
    super.dispose();
  }

  Future<void> _fetchSensorData() async {
    try {
      final response = await http.get(Uri.parse('http://$esp32IpAddress/'));
      print('Gelen ham veri: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final sensorValue = jsonData['sensor_status'].toString();
        
        setState(() {
          _sensorStatus = sensorValue;
        });

        // ASCII 0 (NULL) ve 8 (BACKSPACE) için özel işleme
        if (sensorValue == "N" || sensorValue == "0") {
          _playAlarmIfNotPlaying();
        } else if (sensorValue == "B" || sensorValue == "1") {
          _alarmPlayer.stop();
        }
        
        print('Sensör Verisi Başarıyla Alındı: $_sensorStatus');
      } else {
        setState(() {
          _sensorStatus = "HTTP Hatası: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _sensorStatus = "Hata: ${e.toString()}";
      });
      print('İstisna oluştu: $e');
    }
  }

  Future<void> _playAlarmIfNotPlaying() async {
    try {
      final state = await _alarmPlayer.state;
      if (state != PlayerState.playing) {
        await _alarmPlayer.play(AssetSource('alarm.wav'));
      }
    } catch (e) {
      print('Alarm çalma hatası: $e');
    }
  }

  void _startFetchingSensorData() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _fetchSensorData();
    });
  }

  String _getStatusText() {
    switch (_sensorStatus) {
      case '0':
        return 'DÜŞÜK';
      case '1':
        return 'YÜKSEK';
      case 'N':
        return 'TEHLİKE (NULL)';
      case 'B':
        return 'UYARI (BACKSPACE)';
      default:
        return _sensorStatus;
    }
  }

  Color _getStatusColor() {
    switch (_sensorStatus) {
      case '0':
      case 'N':
        return Colors.red;
      case '1':
      case 'B':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ESP32 Sensör Verisi'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'STM32 Sensör Durumu:',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              _getStatusText(),
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: _getStatusColor(),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _fetchSensorData,
              child: const Text('Veriyi Tekrar Çek'),
            ),
          ],
        ),
      ),
    );
  }
}

class YanginGazSistemiApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Akıllı Yangın ve Gaz Sistemi',
      debugShowCheckedModeBanner: false,
      home: GirisEkrani(),
    );
  }
}

class GirisEkrani extends StatelessWidget {
  final TextEditingController kullaniciAdiController = TextEditingController();
  final TextEditingController sifreController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Giriş Yap',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 24),
              TextField(
                controller: kullaniciAdiController,
                decoration: InputDecoration(
                  labelText: 'Kullanıcı Adı',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: sifreController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Şifre',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final email = kullaniciAdiController.text.trim();
                    final password = sifreController.text.trim();

                    await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: email,
                      password: password,
                    );

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => AnaSayfa()),
                    );
                  } catch (e) { 
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Giriş başarısız: $e")),
                    );
                  }
                },
                child: Text('Giriş'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final email = kullaniciAdiController.text.trim();
                    final password = sifreController.text.trim();

                    await FirebaseAuth.instance.createUserWithEmailAndPassword(
                      email: email,
                      password: password,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Kayıt başarılı! Şimdi giriş yapabilirsiniz.")),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Kayıt başarısız: $e")),
                    );
                  }
                },
                child: Text('Kayıt Ol'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnaSayfa extends StatefulWidget {
  @override
  _AnaSayfaState createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  final AudioPlayer _alarmPlayer = AudioPlayer();
  bool _alarmCaliyor = false;

  void alarmCal() async {
    await _alarmPlayer.play(AssetSource('alarm.wav'));
    setState(() {
      _alarmCaliyor = true;
    });
  }

  void alarmDurdur() async {
    await _alarmPlayer.stop();
    setState(() {
      _alarmCaliyor = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('🔥', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 8),
              const Text(
                'Akıllı Yangın ve\nGaz Sistemi',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFFF4F4F4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Sistem Durumu: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Aktif', style: TextStyle(color: Colors.green)),
                    SizedBox(height: 12),
                    Text('Sensör Verileri:', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('☁ Duman: Tespit Edildi'),
                    Text('💨 Gaz Seviyesi: 289 ppm'),
                    Text('🔥 Alev: Yok'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '⚠ ALARM DURUMU: AKTİF',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  ButonKarti(ikon: Icons.volume_up, yazi: 'Alarmı Başlat', onTap: () {alarmCal();},),
                  ButonKarti(ikon: Icons.notifications_off, yazi: 'Alarmı Sustur', onTap: () {if (_alarmCaliyor) {alarmDurdur();}},),
                  ButonKarti(ikon: Icons.air, yazi: 'Havalandırmayı Aç'),
                  ButonKarti(ikon: Icons.phone, yazi: '112\'yi Ara', onTap: () {aramaYap('112');},),
                  ButonKarti(ikon: Icons.sms, yazi: 'Aileye Bildir', onTap: () {smsGonder('05356544655', 'Acil durum algılandı! Lütfen kontrol edin.');},),
                  ButonKarti(ikon: Icons.sensors, yazi: 'Sensör Verisi', onTap: () {Navigator.push(context,MaterialPageRoute(builder: (context) => const SensorDataReader()),);},),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

void aramaYap(String numara) async {
  final Uri uri = Uri(scheme: 'tel', path: numara);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    throw 'Arama yapılamıyor: $numara';
  }
}

void smsGonder(String telefonNumarasi, String mesaj) async {
  final Uri uri = Uri.parse('sms:$telefonNumarasi?body=${Uri.encodeComponent(mesaj)}');

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    throw 'SMS gönderilemiyor: $telefonNumarasi';
  }
}

class ButonKarti extends StatelessWidget {
  final IconData ikon;
  final String yazi;
  final VoidCallback? onTap;

  const ButonKarti({required this.ikon, required this.yazi, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 140,
        height: 80,
        decoration: BoxDecoration(
          color: Color(0xFFF4F4F4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(ikon, size: 28),
            const SizedBox(height: 6),
            Text(yazi, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}