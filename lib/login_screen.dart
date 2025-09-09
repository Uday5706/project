import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:pokepedia/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey =
      GlobalKey<FormState>(); //Creates a global key of type FormState
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool obscureText = true;

  @override
  void initState() {
    super.initState();
    emailController.addListener(() {
      setState(() {}); // rebuild whenever text changes
    });
    passwordController.addListener(() {
      setState(() {});
    });
  }

  void loginUser() {
    if (passwordController.text == '') {
      Fluttertoast.showToast(
        msg: "Password cannot be blank",
        backgroundColor: Colors.redAccent,
      );
    } else {
      String email = emailController.text;
      String password = passwordController.text;
      FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password)
          .then((value) {
            // Navigator.pushReplacement(
            //   context,
            //   MaterialPageRoute(builder: (context) => HomeScreen()),
            // );
          })
          .catchError((e) {
            Fluttertoast.showToast(
              msg: 'Invalid Email or password',
              backgroundColor: Colors.redAccent,
            );
          });
    }
  }

  @override
  void dispose() {
    emailController.removeListener(() {
      listener:
      (context);
    });
    passwordController.removeListener(() {
      listener:
      (context);
    });

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
                  SizedBox(height: 30),
                  ClipRect(
                    child: Align(
                      alignment: Alignment.center, // focus on center part
                      widthFactor: 1, // adjust these factors to crop more/less
                      heightFactor: 1,
                      child: Lottie.asset(
                        'assets/animations/waterBowl.json',
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Text(
                    "Login",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Enter valid email and password to login",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
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
                        // onTapCancel: () {
                        //   setState(() {
                        //     obscureText = true;
                        //   });
                        // },
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
                  SizedBox(height: 5),
                  SizedBox(
                    width: double.infinity,
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: GestureDetector(
                        onTap: () {},
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      print("Logging In");
                      loginUser();
                      final form = formKey.currentState;
                      String email = emailController.text;
                      String password = passwordController.text;
                      if (form!.validate()) {
                        final email = emailController.text;
                        final password = passwordController.text;
                        print("Email: $email");
                        print("Password: $password");
                      } else {
                        print("Form is invalid");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent, // button background
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
                          "Login",
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
                        "Don't have an account? ",
                        style: TextStyle(color: Colors.black38),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RegistrationScreen(),
                            ),
                          );
                        },
                        child: Text(
                          "Sign up!",
                          style: TextStyle(color: Colors.blueAccent),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
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
