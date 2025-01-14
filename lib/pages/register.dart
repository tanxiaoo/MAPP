import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../const.dart';
import '../components/my_textfield.dart';
import '../components/yellow_button.dart';
import 'package:google_sign_in/google_sign_in.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void signUserIn() async {
    // show loading circle
    showDialog(
        context: context,
        builder: (context) {
          return const Center(child: CircularProgressIndicator());
        });

    // try sign in
    try {
      //check if password is confirmed
      if(passwordController.text == confirmPasswordController.text){
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      navigator?.pop(context);
      Get.offNamed('/auth_page');
      }else{
        navigator?.pop(context);
        // show error message,password don't match
        Get.snackbar("Error", "password don't match!",
            snackPosition: SnackPosition.BOTTOM);
      }
    } on FirebaseAuthException catch (e) {
      navigator?.pop(context);
      if (e.code == "email-already-in-use") {
      Get.snackbar(
        "Error",
        "Email is already registered. Please use another email.",
        snackPosition: SnackPosition.BOTTOM,
      );
    } else if (e.code == "invalid-email") {
      Get.snackbar(
        "Error",
        "Invalid email format. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
      );
    } else if (e.code == "weak-password") {
      Get.snackbar(
        "Error",
        "Password is too weak. Please use a stronger password.",
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        "Error",
        e.message ?? "An error occurred. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  } catch (e) {
    navigator?.pop(context);
    Get.snackbar(
      "Error",
      "Unexpected error occurred. Please try again.",
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

  void signInWithGoogle() async {
    try {
      // show loading circle
      showDialog(
        context: context,
        builder: (context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        navigator?.pop(context);
        return;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      navigator?.pop(context);
      Get.offNamed('/auth_page');
    } catch (e) {
      navigator?.pop(context);
      Get.snackbar(
        "Error",
        "Google Sign-In failed. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
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
                  height: 100,
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
                  height: 13,
                ),
                MyTextField(
                    controller: confirmPasswordController,
                    hintText: "Confirm Password",
                    obscureText: true),
                const SizedBox(
                  height: 15,
                ),
                //login button
                YellowButton(
                  width: screenWidth - 50,
                  onPressed: signUserIn,
                  iconUrl: 'lib/images/Login.svg',
                  label: "Register Now",
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
                  child: GestureDetector(
                    onTap: signInWithGoogle,
                    child: Image.asset(
                      "lib/images/google.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                //Don't have any account? Register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account?",
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.toNamed("/login");
                      },
                      child: Text(
                        "Log In",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.yellow,
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          )),
        ));
  }
}
