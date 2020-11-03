import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memecentral/home.dart';
import 'package:memecentral/signup.dart';
import 'package:memecentral/variables.dart';

class NavigationPage extends StatefulWidget {
  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  bool signedIn = false;
  initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User user) {
      print(user);
      if (user != null) {
        setState(() {
          signedIn = true;
        });
      } else {
        setState(() {
          signedIn = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: signedIn == false ? Login() : HomePage(),
    );
  }
}

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Welcome to",
              style: fontStyle(25, Colors.grey[500], FontWeight.w700),
            ),
            Text(
              "Meme Central",
              style: fontStyle(35, Colors.orange, FontWeight.w700),
            ),
            SizedBox(height: 50),
            Text(
              "Login",
              style: fontStyle(25, Colors.white, FontWeight.w600),
            ),
            SizedBox(height: 10),
            Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.only(left: 20, right: 20),
              child: TextField(
                controller: emailController,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  hintText: 'Email',
                  hintStyle: fontStyle(20),
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            SizedBox(height: 15),
            Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.only(left: 20, right: 20),
              child: TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  prefixIcon: Icon(Icons.lock),
                  hintText: 'Password',
                  hintStyle: fontStyle(20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            SizedBox(height: 15),
            InkWell(
              onTap: () {
                try {
                  FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: emailController.text,
                    password: passwordController.text,
                  );
                } catch (error) {
                  SnackBar snackBar = SnackBar(
                    content: Text("Incorrect email or password."),
                  );
                  Scaffold.of(context).showSnackBar(snackBar);
                }
              },
              child: Container(
                width: MediaQuery.of(context).size.width / 2,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    "Login",
                    style: fontStyle(20, Colors.white, FontWeight.w700),
                  ),
                ),
              ),
            ),
            SizedBox(height: 15),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(
                "Don't have an account?",
                style: fontStyle(20, Colors.grey[500]),
              ),
              SizedBox(width: 8),
              InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SignUp(),
                  ),
                ),
                child: Text(
                  "Register",
                  style: fontStyle(20, Colors.blue[400]),
                ),
              ),
            ])
          ],
        ),
      ),
    );
  }
}
