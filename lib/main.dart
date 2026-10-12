import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Tambahkan import provider
import 'package:google_fonts/google_fonts.dart'; // Import font
import 'providers/movie_provider.dart'; // Import file provider
import 'views/login_page.dart';



void main() {
  runApp(const MyMoviesApp());
}

class MyMoviesApp extends StatelessWidget {
  const MyMoviesApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Bungkus MaterialApp dengan MultiProvider
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => MovieProvider())],
      child: MaterialApp(
        title: 'MyMovies',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.teal,
          scaffoldBackgroundColor: Colors.white,
          textTheme:
              GoogleFonts.poppinsTextTheme(), // Menggunakan Poppins untuk seluruh aplikasi
        ),
        home: const LoginPage(),
      ),
    );
  }
}
