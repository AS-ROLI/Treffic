import 'package:flutter/material.dart';
import 'package:sts/login_screen.dart';
import 'package:sts/patient_info_fill.dart';
import 'package:sts/registration.dart';
import 'package:sts/single_patient.dart';
import 'package:sts/patient_list.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sts/traffic_police.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  //await Firebase.initializeApp();
  runApp(Terrific_Lights());
}
class Terrific_Lights extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        initialRoute:login_screen.id,
        routes : {
          login_screen.id : (context) => login_screen(),
          registration.id : (context) => registration(),
          patient_info_fill.id : (context) => patient_info_fill(),
          single_patient_info_doc.id : (context) => single_patient_info_doc(),
          patient_list.id : (context) => patient_list(),
          traffic_police.id : (context) => traffic_police(),
        }
    );
  }
}