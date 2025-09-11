import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'login_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final formKey =
      GlobalKey<FormState>(); //Creates a global key of type FormState
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool obscureText = true;

  @override
  void initState() {
    super.initState();
    nameController.addListener(() {
      setState(() {}); // rebuild whenever text changes
    });
    emailController.addListener(() {
      setState(() {}); // rebuild whenever text changes
    });
    passwordController.addListener(() {
      setState(() {});
    });
  }

  void registerUser() {
    if (passwordController.text.length == "") {
      Fluttertoast.showToast(
        msg: "Password cannot be blank",
        backgroundColor: Colors.redAccent,
      );
    } else if (emailController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: "Email cannot be blank",
        backgroundColor: Colors.redAccent,
      );
    } else if (nameController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: "Name cannot be blank",
        backgroundColor: Colors.redAccent,
      );
    } else {
      String email = emailController.text.trim();
      String password = passwordController.text.trim();

      FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) {
            var user = value.user;
            if (user != null) {
              var userUid = user.uid;
              addUserData(userUid);
            }
          })
          .catchError((error) {
            if (error is FirebaseAuthException) {
              String msg;
              switch (error.code) {
                case "email-already-in-use":
                  msg = "This email is already registered. Try logging in.";
                  break;
                case "invalid-email":
                  msg = "The email address is not valid.";
                  break;
                case "weak-password":
                  msg = "Password is too weak. Please use a stronger one.";
                  break;
                default:
                  msg = "Something went wrong. Please try again.";
              }
              Fluttertoast.showToast(
                msg: msg,
                backgroundColor: Colors.redAccent,
              );
            } else {
              Fluttertoast.showToast(
                msg: "Unexpected error: $error",
                backgroundColor: Colors.redAccent,
              );
            }
          });
    }
  }

  void addUserData(String uid) {
    Map<String, dynamic> usersData = {
      'name': nameController.text,
      'email': emailController.text,
      'password': passwordController.text,
      'uid': uid,
    };
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set(usersData)
        .then((value) {
          Fluttertoast.showToast(
            msg: "Sign-Up successfully!",
            backgroundColor: Colors.greenAccent,
          );
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(builder: (context) => HomeScreen()),
          // );
        })
        .catchError((error) {
          Fluttertoast.showToast(
            msg: "Unexpected error: $error",
            backgroundColor: Colors.redAccent,
          );
        });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: Form(
            key: formKey,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 30),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  // ClipRect(
                  //   child: Align(
                  //     alignment: Alignment.center, // focus on center part
                  //     heightFactor: 0.8,
                  //     child: Lottie.asset(
                  //       'assets/animations/waterFilling.json',
                  //       width: 300,
                  //       height: 300,
                  //       fit: BoxFit.cover,
                  //     ),
                  //   ),
                  // ),
                  SizedBox(height: 20),
                  Text(
                    "Sign Up",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Input Correct Information",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 50),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      labelStyle: TextStyle(color: Colors.black54),
                      // errorText: ageError,
                      hintText: "Enter your name",
                      prefixIcon: Icon(Icons.person),
                      suffixIcon: nameController.text.isEmpty
                          ? Container(width: 0)
                          : IconButton(
                              onPressed: () {
                                nameController.clear();
                              },
                              icon: Icon(Icons.close, color: Colors.black54),
                            ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.black38),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          width: 2,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.text,
                    autofillHints: [AutofillHints.name],
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Colors.black54),
                      // errorText: ageError,
                      hintText: "Enter Valid Email",
                      prefixIcon: Icon(Icons.email),
                      suffixIcon: emailController.text.isEmpty
                          ? Container(width: 0)
                          : IconButton(
                              onPressed: () {
                                emailController.clear();
                              },
                              icon: Icon(Icons.close, color: Colors.black54),
                            ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.black38),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          width: 2,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: [AutofillHints.email],
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.black54),
                      hintText: "Enter Password",
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: GestureDetector(
                        onLongPress: () {
                          setState(() {
                            obscureText = false;
                          });
                        },
                        onLongPressUp: () {
                          setState(() {
                            obscureText = true;
                          });
                        },
                        child: Icon(
                          obscureText
                              ? Icons.remove_red_eye
                              : Icons.remove_red_eye_outlined,
                          color: Colors.black,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.black38),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          width: 2,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                    obscureText: obscureText,
                    autofillHints: [AutofillHints.password],
                  ),

                  SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      registerUser();
                      final form = formKey.currentState;
                      String name = nameController.text;
                      String email = emailController.text;
                      String password = passwordController.text;
                      if (form!.validate()) {
                        final email = emailController.text;
                        final password = passwordController.text;
                        print("Email: $email");
                        print("Password: $password");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent, // button background
                      foregroundColor: Colors.white, // text (and icon) color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          8,
                        ), // optional: rounded corners
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ), // optional
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: TextStyle(color: Colors.black38),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                          );
                        },
                        child: Text(
                          "Login!",
                          style: TextStyle(color: Colors.blueAccent),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 50),
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.grey, // line color
                          thickness: 1, // line thickness
                          endIndent: 10, // space between line and OR
                        ),
                      ),
                      Text(
                        "OR",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.grey,
                          thickness: 1,
                          indent: 10, // space between OR and line
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white, // button background
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ), // optional
                        ),
                        child: SizedBox(
                          width: 110,
                          height: 20,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: Image.asset(
                                  "assets/images/google.jpg",
                                  fit: BoxFit.cover,
                                ),
                              ),

                              SizedBox(width: 10),
                              Text(
                                "Google",
                                style: TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white, // button background
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              8,
                            ), // optional: rounded corners
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ), // optional
                        ),
                        child: SizedBox(
                          width: 110,
                          height: 20,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Icon(
                                Icons.facebook,
                                color: Colors.blueAccent,
                                size: 25,
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Facebook",
                                style: TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
