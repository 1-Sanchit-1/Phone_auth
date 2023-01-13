import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phone Auth',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Myapp(),
    );
  }
}

class Myapp extends StatefulWidget {
  const Myapp({Key? key}) : super(key: key);

  @override
  State<Myapp> createState() => _MyappState();
}

class _MyappState extends State<Myapp> {

  String? verId;
  String? phone;
  bool codeSent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Phone Auth"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            codeSent
                ? OTPTextField(
              length: 6,
              width: MediaQuery.of(context).size.width,
              fieldWidth: 30,
              style: TextStyle(fontSize: 20),
              textFieldAlignment: MainAxisAlignment.spaceAround,
              fieldStyle: FieldStyle.underline,
              onCompleted: (pin) {
                verifyPin(pin);
              },
            )
                : IntlPhoneField(
              decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(borderSide: BorderSide())),
              initialCountryCode: 'IN',
              onChanged: (phoneNumber) {
                setState(() {
                  phone = phoneNumber.completeNumber;
                });
              },
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: () {
                  verifyPhone();
                },
                child: Text("Verify"))
          ],
        ),
      ),
    );
  }

  verifyPhone() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          final snackBar = SnackBar(content: Text("Login Success"));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        },
        verificationFailed: (FirebaseAuthException e) {
          final snackBar = SnackBar(content: Text("${e.message}"));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            verId = verificationId;
          });
        },
        timeout: Duration(seconds: 60),
        codeSent: (String verificationId, int? forceResendingToken) {
          setState(() {
            codeSent = true;
            verId = verificationId;
          });
        });
  }
  verifyPin(String pin) async {
    PhoneAuthCredential credential =
    PhoneAuthProvider.credential(verificationId: verId!, smsCode: pin);

    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
      final snackBar = SnackBar(content: Text("Login Success"));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } on FirebaseAuthException catch (e) {
      final snackBar = SnackBar(content: Text("${e.message}"));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

}
