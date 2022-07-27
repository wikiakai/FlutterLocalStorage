import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> todos = [];

  final todosBox = Hive.box('todos_box');

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    refreshTodo(); // Load data when app starts
  }

  void refreshTodo() {
    final data = todosBox.keys.map((key) {
      final value = todosBox.get(key);
      return {
        "key": key,
        "title": value["title"],
        "description": value['description'],
      };
    }).toList();

    setState(() {
      todos = data.reversed.toList();
    });
  }

  Future<void> createTodo(Map<String, dynamic> newTodo) async {
    await todosBox.add(newTodo);
    refreshTodo(); // update the UI
  }

  Future<void> updateTodo(int todoKey, Map<String, dynamic> item) async {
    await todosBox.put(todoKey, item);
    refreshTodo(); // Update the UI
  }

  Future<void> deleteTodo(int todoKey) async {
    await todosBox.delete(todoKey);
    refreshTodo(); // update the UI

    // Display a snackbar
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Deleted success!')));
  }

  void showForm(BuildContext context, int? todoKey) async {
    if (todoKey != null) {
      final currentTodo =
          todos.firstWhere((element) => element['key'] == todoKey);

      titleController.text = currentTodo['title'];
      descriptionController.text = currentTodo['description'];
    }

    showModalBottomSheet(
      backgroundColor: Colors.white.withOpacity(0.5),
      context: context,
      builder: (_) => Padding(
        padding: EdgeInsets.all(20),
        child: Column(children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(hintText: 'Title'),
          ),
          const SizedBox(
            height: 10,
          ),
          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(hintText: 'Description'),
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: () async {
              // Save new item
              if (todoKey == null) {
                createTodo({
                  "title": titleController.text,
                  "description": descriptionController.text,
                });
              }

              if (todoKey != null) {
                updateTodo(todoKey, {
                  "title": titleController.text.trim(),
                  "description": descriptionController.text.trim()
                });
              }

              titleController.text = '';
              descriptionController.text = '';

              Navigator.of(context).pop(); // Close the bottom sheet
            },
            child: Text(todoKey == null ? 'Send' : 'Update'),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment(0.8, 1),
          colors: <Color>[
            Color(0xff00265c),
            Color(0xff006fb1),
            Color(0xff00bbb9),
            Color(0xff12ff6d),
          ], // background: linear-gradient(120deg, #00265c, #006fb1, #00bbb9, #12ff6d);
          tileMode: TileMode.mirror,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Color.fromARGB(59, 255, 248, 248),
          title: Text(widget.title),
        ),
        body: todos.isEmpty
            ? const Center(
                child: Card(
                    child:
                        Text("There's no data, hit the button to add data!")),
              )
            : ListView.separated(
                separatorBuilder: (context, index) => const Divider(
                      color: Colors.transparent,
                    ),
                itemCount: todos.length,
                itemBuilder: (_, index) {
                  final todo = todos[index];
                  return Padding(
                    padding: const EdgeInsets.only(left: 13.0, right: 13.0),
                    child: Container(
                      margin: EdgeInsets.only(top: 20),
                      color: Colors.white.withOpacity(0.3),
                      child: ListTile(
                        // tileColor: Colors.white.withOpacity(0.4),
                        // leading: const Icon(Icons.today_outlined),
                        title: Text(
                          todo['title'],
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                        subtitle: Text(todo['description'],
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 15)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                                onPressed: () => showForm(context, todo['key']),
                                icon: const Icon(Icons.edit,
                                    color: Colors.white)),
                            IconButton(
                                onPressed: () => deleteTodo(todo['key']),
                                icon: const Icon(Icons.delete_forever_outlined,
                                    color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
        floatingActionButton: FloatingActionButton(
          onPressed: () => showForm(context, null),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
