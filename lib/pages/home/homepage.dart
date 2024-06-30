import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notes_app_firebase/services/firestore.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  //get Firestore
  final FirestoreService firestoreService = FirestoreService();
//text controller
  final TextEditingController textController = TextEditingController();

//open dialogue
  void openDialogue({String? docID}) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: TextField(
                controller: textController,
              ),
              actions: [
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                MaterialButton(
                  onPressed: () {
                    if (docID == null) {
                      firestoreService.addNote(textController.text);
                    } else {
                      firestoreService.updateNote(docID, textController.text);
                    }

                    //clear the text controller
                    textController.clear();

                    //close the box
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                )
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes App'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openDialogue,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder(
        stream: firestoreService.getNotesStream(),
        builder: (context, snapshot) {
          //if we have data get all docs
          if (snapshot.hasData) {
            List notesList = snapshot.data!.docs;

            //display as list
            return ListView.builder(
              itemCount: notesList.length,
              itemBuilder: (context, index) {
                //get each individual doc

                DocumentSnapshot document = notesList[index];
                String docID = document.id;

                //get note from each Doc
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                String noteText = data['note'];

                //display as a list tile
                return ListTile(
                    title: Text(noteText),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => openDialogue(docID: docID),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => firestoreService.deletNote(docID),
                        ),
                      ],
                    ));
              },
            );
          } else {
            return const Text('No notes...');
          }
        },
      ),
    );
  }
}
