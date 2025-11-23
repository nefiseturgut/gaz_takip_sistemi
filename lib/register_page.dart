import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kayıt Ol")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: "Kullanıcı Adı"),
            ),
            TextField(
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              decoration: const InputDecoration(labelText: "Şifre"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Kayıt işlemi buraya yazılacak
                // Kullanıcı bilgilerini kaydet (şimdilik sahte)
                // Giriş sayfasına geri dön
                Navigator.pop(context);
              },
              child: const Text("Kayıt Ol"),
            ),
          ],
        ),
      ),
    );
  }
}
