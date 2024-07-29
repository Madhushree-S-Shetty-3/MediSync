import 'package:flutter/material.dart';
import 'package:app/up2.dart';
import 'package:app/profile_page.dart';
import 'dart:ui';

class Prescriptioncont extends StatelessWidget {
  final String mainDocumentId;
  final String subDocumentId;

  const Prescriptioncont(
      {super.key, required this.mainDocumentId, required this.subDocumentId});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFF13171D),
          appBar: AppBar(
            backgroundColor: const Color.fromRGBO(51, 54, 58, 1),
            title: const TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.white),
                hintText: 'Search..',
                hintStyle: TextStyle(color: Colors.white),
                border: InputBorder.none,
              ),
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(12),
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProfilePage(
                                documentId: subDocumentId,
                              )),
                    );
                  },
                  child: const Icon(
                    Icons.account_circle,
                    color: Colors.white,
                    size: 30.0,
                  ),
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Center(
              child: Column(
                children: [
                  Container(
                    width: 310,
                    height: 90,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B6D73),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.create_new_folder,
                              color: Color(0xFFFFFBFA)),
                          iconSize: 35,
                          onPressed: () {},
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "Prescription1",
                          style: TextStyle(
                              color: Color(0xFFFFFBFA),
                              fontSize: 20,
                              fontWeight: FontWeight.w300,
                              fontFamily: "inter"),
                        ),
                        const SizedBox(width: 10),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert,
                              color: Color(0xFFFFFBFA)),
                          color: const Color(0xFF31343C),
                          onSelected: (String value) {
                            // Handle menu item selection
                            switch (value) {
                              case 'Option 1':
                                // Handle Option 1 selection
                                break;
                              case 'Option 2':
                                // Handle Option 2 selection
                                break;
                            }
                          },
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<String>>[
                            PopupMenuItem<String>(
                              value: 'Option 1',
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Color(0XFFFFFFFF)),
                                    iconSize: 20,
                                    onPressed: () {},
                                  ),
                                  const Text(
                                    'Remove',
                                    style: TextStyle(
                                        color: Color(0XFFFFFFFF),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w200,
                                        fontFamily: "kumbh sans"),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'Option 2',
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Color(0XFFFFFFFF)),
                                    iconSize: 20,
                                    onPressed: () {},
                                  ),
                                  const Text(
                                    'Rename',
                                    style: TextStyle(
                                        color: Color(0XFFFFFFFF),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w200,
                                        fontFamily: "kumbh sans"),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            color: const Color(0xFF13171D),
            shape: const CircularNotchedRectangle(),
            notchMargin: 5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFEDEAF1),
                      border: Border.all(
                          color: const Color.fromRGBO(172, 145, 190, 1),
                          width: 1),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.home,
                          color: Color.fromRGBO(36, 30, 30, 1)),
                      onPressed: () {},
                    ),
                  ),
                ),
                const SizedBox(
                    width: 30), // Space for the floating action button
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFEDEAF1),
                      border: Border.all(
                          color: const Color.fromRGBO(172, 145, 190, 1),
                          width: 1),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add,
                          color: Color.fromRGBO(36, 30, 30, 1)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  Up2(documentId: mainDocumentId)),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
        ),
        Positioned.fill(
          child: Image.asset(
            'assets/overlay_image.jpg', // Replace with your image path
            fit: BoxFit.cover,
            width: 40,
            height: 50,
          ),
        ),
      ],
    );
  }
}
