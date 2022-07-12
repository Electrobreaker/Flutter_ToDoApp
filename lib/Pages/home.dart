import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  void initFirebase() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  }

  String inputValue = '';
  List todoList = [];

  @override
  void initState() {
    super.initState();
    initFirebase();
    todoList.addAll(['Buy apples', 'Wash dishes', 'Clean home']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.deepOrangeAccent,
        title: const Text('ToDo list'),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('items').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if(!snapshot.hasData) return const Text('пусто');
          return ListView.builder(
            itemCount: snapshot.data?.docs.length,
            itemBuilder: (BuildContext context, int index) {
              return Dismissible(
                key: Key(snapshot.data!.docs[index].id),
                child: Card(
                  child: ListTile(
                    title: Text(snapshot.data!.docs[index].get('item')),
                    trailing: IconButton(
                      onPressed: () {
                        FirebaseFirestore.instance.collection('items').doc(snapshot.data!.docs[index].id).delete();
                      },
                      icon: const Icon(Icons.delete_sweep_rounded),
                      color: Colors.deepOrangeAccent,
                    ),
                  ),
                ),
                onDismissed: (direction) {
                  FirebaseFirestore.instance.collection('items').doc(snapshot.data!.docs[index].id).delete();
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton (
        backgroundColor: Colors.greenAccent,
        onPressed: () {
          showDialog(context: context, builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Add element'),
              content: TextField(
                onChanged: (String value) {
                  inputValue = value;
                },
              ),
              actions: [
                ElevatedButton(onPressed: () {
                  FirebaseFirestore.instance.collection('items').add({'item': inputValue});
                  Navigator.of(context).pop();
                }, child: const Text('add'))
              ],
            );
          });
        },
        child: const Icon(
          Icons.add,
          size: 40,
          color: Colors.white,
        ),
      ),
    );
  }
}
