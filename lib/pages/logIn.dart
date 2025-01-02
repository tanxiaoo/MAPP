import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../const.dart';
import '../components/my_textfield.dart';
import '../components/yellow_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void signUserIn() async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailController.text, 
      password: passwordController.text
    );
  }

  @override
  Widget build(BuildContext context) {
    //local variables
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        backgroundColor: AppColors.lightGreen,
        body: SingleChildScrollView(
          child: SafeArea(
              child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 180,
                ),
                // logo
                SizedBox(
                  width: 100,
                  height: 85,
                  child: Image.asset(
                    "lib/images/logo.png",
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(
                  height: 35,
                ),
                //Trenord - Travel
                const Text(
                  "Trenord - Travel",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                //life is elsewhere
                const Text(
                  "Life is Elsewhere",
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(
                  height: 120,
                ),
                //username textfield
                MyTextField(
                    controller: emailController,
                    hintText: "Email",
                    obscureText: false),
                const SizedBox(
                  height: 13,
                ),
                //password textfield
                MyTextField(
                    controller: passwordController,
                    hintText: "Password",
                    obscureText: true),
                const SizedBox(
                  height: 15,
                ),
                //forget password?
                const Text(
                  "Forget Password?",
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                //login button
                YellowButton(
                  width: screenWidth - 50,
                  onPressed: signUserIn,
                  iconUrl: 'lib/images/Login.svg',
                  label: "Log In",
                ),
                const SizedBox(
                  height: 15,
                ),
                //or continue with
                const Row(
                  children: [
                    Expanded(
                        child: Divider(
                      thickness: 0.5,
                      color: Colors.grey,
                    )),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "Or continue with",
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Expanded(
                        child: Divider(
                      thickness: 0.5,
                      color: Colors.grey,
                    )),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                //google sign in buttons
                SizedBox(
                  height: 40,
                  child: Image.asset(
                    "lib/images/google.png",
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                //Don't have any account? Register now
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have any account? Register now",
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Text(
                      "Register now",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.yellow,
                      ),
                    ),
                  ],
                )
              ],
            ),
          )),
        ));
  }
}
