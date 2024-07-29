import 'package:flutter/material.dart';

class Demo extends StatelessWidget {
  const Demo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF13171D),
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 30, left: 20),
            child: Center(
              child: Column(
                children: [
                  Container(
                    //Calender
                    width: 370,
                    height: 400,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color.fromARGB(147, 89, 89, 89).withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                  ),
                  const Row(
                    children: [
                      Column(
                        children: [
                          ClipOval(
                            
                          )
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
