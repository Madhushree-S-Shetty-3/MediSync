import 'package:flutter/material.dart';
import 'package:app/prescriptioncont.dart';
import 'package:app/up2.dart';
import 'package:app/upload.dart';

class Prescription extends StatelessWidget {
  final String documentId;

  const Prescription({super.key, required this.documentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            child: Container(
              child: IconButton(
                icon: const Icon(
                  Icons.account_circle,
                  color: Colors.white,
                  size: 30.0,
                ),
                iconSize: 43,
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Prescriptioncont(
                mainDocumentId: documentId,
                subDocumentId: documentId,
              ),
            ),
          );
        },
        child: Padding(
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
                          fontFamily: "inter",
                        ),
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      Upload(documentId: documentId),
                                ),
                              );
                              break;
                            case 'Option 2':
                              // Handle Option 2 selection
                              break;
                          }
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'Option 1',
                            child: ListTile(
                              leading:
                                  Icon(Icons.delete, color: Color(0XFFFFFFFF)),
                              title: Text(
                                'Remove',
                                style: TextStyle(
                                  color: Color(0XFFFFFFFF),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w200,
                                  fontFamily: "kumbh sans",
                                ),
                              ),
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'Option 2',
                            child: ListTile(
                              leading:
                                  Icon(Icons.edit, color: Color(0XFFFFFFFF)),
                              title: Text(
                                'Rename',
                                style: TextStyle(
                                  color: Color(0XFFFFFFFF),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w200,
                                  fontFamily: "kumbh sans",
                                ),
                              ),
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
                    width: 1,
                  ),
                ),
                child: IconButton(
                  icon: const Icon(Icons.home,
                      color: Color.fromRGBO(36, 30, 30, 1)),
                  onPressed: () {},
                ),
              ),
            ),
            const SizedBox(width: 30),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFEDEAF1),
                  border: Border.all(
                    color: const Color.fromRGBO(172, 145, 190, 1),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  icon: const Icon(Icons.add,
                      color: Color.fromRGBO(36, 30, 30, 1)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Up2(documentId: documentId),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
