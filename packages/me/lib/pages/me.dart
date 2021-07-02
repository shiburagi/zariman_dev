import 'package:flutter/material.dart';
import 'package:me/views/me.dart';

class MePage extends StatefulWidget {
  MePage({Key? key}) : super(key: key);

  @override
  _MePageState createState() => _MePageState();
}

class _MePageState extends State<MePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  color: Color(0xffCD5C5C),
                ),
              ),
              Expanded(
                flex: 5,
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(blurRadius: 10, color: Colors.black38)
                    ],
                    color: Color(0xffFFE4E1),
                  ),
                ),
              ),
            ],
          ),
          Center(
            child: SingleChildScrollView(
              child: MeView(),
            ),
          ),
        ],
      ),
    );
  }
}
