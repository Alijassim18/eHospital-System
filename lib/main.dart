import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'admin/AddHospital.dart';
import 'auth/login.dart';
import 'auth/signUp.dart';
import 'admin/addDoctor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyA6Bp_Bfwot4SF78fi0OWMmQx91xRSe_wQ",
      authDomain: "ehospital-system.firebaseapp.com",
      projectId: "ehospital-system",
      storageBucket: "ehospital-system.firebasestorage.app",
      messagingSenderId: "853238905839",
      appId: "1:853238905839:web:e1a830e59a6ea0c46d541a",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/welcome',
      routes: {
        '/welcome': (context) => Welcome(),
        '/add-hospital': (context) => AddHospitalPage(),
        '/signup': (context) => SignUpPage(),
        '/login': (context) => LoginPage(),
        '/doc': (context) => DoctorSignUpPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class Welcome extends StatefulWidget {
  const Welcome({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<Welcome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Column(
              children: <Widget>[
                SizedBox(height: 200.0, child: Image.asset('assets1/img.png')),
                Text(
                  'e-Hospital System',
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Pacifico',
                    fontSize: 45.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            SizedBox(height: 5.0),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Material(
                elevation: 5.0,
                color: Colors.blue.shade300,
                borderRadius: BorderRadius.circular(30.0),
                child: MaterialButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  minWidth: 200.0,
                  height: 42.0,
                  child: Text(
                    'Log In',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Material(
                color: Colors.blue.shade300,
                borderRadius: BorderRadius.circular(30.0),
                elevation: 5.0,
                child: MaterialButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  minWidth: 200.0,
                  height: 42.0,
                  child: Text(
                    'Register',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
