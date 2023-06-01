import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sharing_taxi/models/passenger.dart';
import 'package:sharing_taxi/screens/c_home_screen.dart';
import 'package:sharing_taxi/screens/b_register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final loginFormKey = GlobalKey<FormState>();
  final Future<FirebaseApp> firebase = Firebase.initializeApp();
  Passenger passenger = Passenger();
  bool isObscure = true;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: firebase,
        builder: ((context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(),
              body: Center(
                child: Text("${snapshot.error}"),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
              body: SingleChildScrollView(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
                  child: SafeArea(
                      child: IntrinsicHeight(
                    child: Container(
                        height: MediaQuery.of(context).size.height -
                            MediaQuery.of(context).padding.top,
                        padding: const EdgeInsets.fromLTRB(0, 120, 0, 0),
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                              opacity: 1,
                              image: AssetImage("assets/taxi-bggg.jpg"),
                              fit: BoxFit.cover),
                        ),
                        child: Form(
                            key: loginFormKey,
                            child: Center(
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.7,
                                child: Column(
                                  children: [
                                    Text("T A X I",
                                        style: GoogleFonts.ptSans(
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.2,
                                            fontWeight: FontWeight.normal,
                                            color: const Color.fromARGB(
                                                255, 255, 255, 255))),
                                    //Image.asset("assets/title3.png"),
                                    const SizedBox(
                                      height: 40,
                                    ),
                                    //username
                                    SizedBox(
                                      width: double.infinity,
                                      child: TextFormField(
                                          style: const TextStyle(fontSize: 17),
                                          onSaved: (String? email) {
                                            passenger.email = email;
                                          },
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          validator: MultiValidator([
                                            RequiredValidator(
                                                errorText: "email required*"),
                                            EmailValidator(
                                                errorText: "invalid email")
                                          ]),
                                          decoration: InputDecoration(
                                            prefixIcon: const Icon(Icons.email),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 18,
                                                    horizontal: 25),
                                            fillColor: const Color.fromARGB(
                                                250, 255, 255, 255),
                                            hintText: 'Email',
                                            hintStyle:
                                                const TextStyle(fontSize: 16),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              borderSide: const BorderSide(
                                                width: 1,
                                                style: BorderStyle.none,
                                              ),
                                            ),
                                            filled: true,
                                          )),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    //password
                                    SizedBox(
                                      width: double.infinity,
                                      child: TextFormField(
                                          style: const TextStyle(fontSize: 17),
                                          obscureText: isObscure,
                                          onSaved: (String? password) {
                                            passenger.password = password;
                                          },
                                          validator: MultiValidator([
                                            RequiredValidator(
                                                errorText:
                                                    'password required*'),
                                            MinLengthValidator(8,
                                                errorText:
                                                    'password at least 8 character'),
                                          ]),
                                          decoration: InputDecoration(
                                            prefixIcon: const Icon(Icons.lock),
                                            suffixIcon: IconButton(
                                                icon: Icon(isObscure
                                                    ? Icons.visibility
                                                    : Icons.visibility_off),
                                                onPressed: () {
                                                  setState(() {
                                                    isObscure = !isObscure;
                                                  });
                                                }),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 18,
                                                    horizontal: 25),
                                            fillColor: const Color.fromARGB(
                                                250, 255, 255, 255),
                                            hintText: 'Password',
                                            hintStyle:
                                                const TextStyle(fontSize: 16),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              borderSide: const BorderSide(
                                                width: 1,
                                                style: BorderStyle.none,
                                              ),
                                            ),
                                            filled: true,
                                          )),
                                    ),
                                    const SizedBox(
                                      height: 60,
                                    ),

                                    SizedBox(
                                      width: 130,
                                      height: 45,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          if (loginFormKey.currentState!
                                              .validate()) {
                                            loginFormKey.currentState!.save();
                                            try {
                                              await FirebaseAuth.instance
                                                  .signInWithEmailAndPassword(
                                                      email: (passenger.email)
                                                          .toString(),
                                                      password:
                                                          (passenger.password)
                                                              .toString())
                                                  .then((value) {
                                                FirebaseFirestore.instance
                                                    .collection('passengers')
                                                    .doc(value.user?.uid)
                                                    .get()
                                                    .then((value) async {
                                                  if (value.exists) {
                                                    loginFormKey.currentState
                                                        ?.reset();
                                                    Navigator.pushReplacement(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) {
                                                      return const HomeScreen();
                                                    }));
                                                  } else {
                                                    await FirebaseAuth.instance
                                                        .signOut();
                                                    Fluttertoast.showToast(
                                                        msg:
                                                            'It seem like you are a driver',
                                                        gravity: ToastGravity
                                                            .BOTTOM);
                                                  }
                                                });
                                              });
                                            } on FirebaseAuthException catch (e) {
                                              Fluttertoast.showToast(
                                                  msg: e.message.toString(),
                                                  gravity: ToastGravity.BOTTOM);
                                            }
                                          }
                                        },
                                        style: ButtonStyle(
                                            elevation:
                                                MaterialStateProperty.all(10),
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    const Color.fromARGB(
                                                        255, 250, 45, 45)),
                                            overlayColor:
                                                MaterialStateProperty.all(
                                                    Colors.amber),
                                            shape: MaterialStateProperty.all<
                                                    RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(27.0),
                                              //side: BorderSide(color: Colors.red)
                                            ))),
                                        child: Text("LOG IN",
                                            style: GoogleFonts.cairo(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.white)),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 12,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text("Don't have an account? ",
                                            style: GoogleFonts.cairo(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                color: const Color.fromARGB(
                                                    190, 255, 255, 255))),
                                        InkWell(
                                          child: Text("Sign-up",
                                              style: GoogleFonts.cairo(
                                                  decoration:
                                                      TextDecoration.underline,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                  color: const Color.fromARGB(
                                                      190, 255, 255, 255))),
                                          onTap: () {
                                            Navigator.push(context,
                                                MaterialPageRoute(
                                                    builder: (context) {
                                              return const RegisterScreen();
                                            }));
                                          },
                                        ),
                                      ],
                                    ),
                                    const Expanded(
                                      child: SizedBox(),
                                    )
                                  ],
                                ),
                              ),
                            ))),
                  )),
                ),
              ),
            );
          }

          return Scaffold(
            body: SingleChildScrollView(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
                child: SafeArea(
                    child: IntrinsicHeight(
                  child: Container(
                      height: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 120, horizontal: 65),
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                            opacity: 1,
                            image: AssetImage("assets/taxi-bggg.jpg"),
                            fit: BoxFit.cover),
                      ),
                      child: Form(
                          child: Center(
                        child: Column(
                          children: [
                            Text("T A X I",
                                style: GoogleFonts.ptSans(
                                    fontSize: 90,
                                    fontWeight: FontWeight.normal,
                                    color: const Color.fromARGB(
                                        255, 255, 255, 255))),
                            //Image.asset("assets/title3.png"),
                            const SizedBox(
                              height: 60,
                            ),

                            const SizedBox(
                              width: 120,
                              height: 120,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 10,
                              ),
                            ),

                            const SizedBox(
                              height: 190,
                            )
                          ],
                        ),
                      ))),
                )),
              ),
            ),
          );
        }));
  }
}
