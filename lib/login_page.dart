import 'package:flutter/material.dart';
import 'package:gaz_takip_sistemi/main.dart';
import 'register_page.dart'; // Kayıt sayfasını buraya import ettik

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Giriş Yap')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Kullanıcı adı ve şifre alanları
            TextField(
              decoration: InputDecoration(labelText: "Kullanıcı Adı"),
            ),
            TextField(
              decoration: InputDecoration(labelText: "Şifre"),
              obscureText: true,
            ),
            const SizedBox(height: 20),

            ElevatedButton(

              
              onPressed: () {
                // Buraya giriş işlemi yazılabilir
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => AnaSayfa()),
                );
              },
              child: const Text("Giriş Yap"),
            ),

            const SizedBox(height: 20),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterPage()),
                );
              },
              child: const Text("Kayıt Ol"),
            ),
          ],
        ),
      ),
    );
  }
}
