import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do List',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TodoListPage(),
    );
  }
}

class TodoListPage extends StatefulWidget {
  const TodoListPage({Key? key}) : super(key: key);

  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class TodoItem {
  TodoItem({required this.title, this.isDone = false});

  String title;
  bool isDone;

  void toggleDone() {
    isDone = !isDone;
  }
}

class _TodoListPageState extends State<TodoListPage> {
  List<TodoItem> _todoItems = [];

  @override
  void initState() {
    super.initState();
    _loadTodoItems();
  }

  void _addTodoItem(TodoItem item) {
    setState(() => _todoItems.add(item));
_saveTodoItems();
}

void _toggleTodoItem(int index) {
setState(() => _todoItems[index].toggleDone());
_saveTodoItems();
}

void _editTodoItem(int index, String newTitle) {
setState(() => _todoItems[index].title = newTitle);
_saveTodoItems();
}

void _removeTodoItem(int index) {
setState(() => _todoItems.removeAt(index));
_saveTodoItems();
}

Widget _buildTodoList() {
  return ListView.builder(
    itemCount: _todoItems.length,
    itemBuilder: (BuildContext context, int index) {
      return InkWell(
        onLongPress: () {
          _promptEditTodoItem(index);
        },
        child: CheckboxListTile(
          title: Text(_todoItems[index].title),
          value: _todoItems[index].isDone,
          onChanged: (bool? value) {
            _toggleTodoItem(index);
          },
        ),
      );
    },
  );
}


@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: const Text('To-Do List')),
body: _buildTodoList(),
floatingActionButton: FloatingActionButton(
onPressed: ()=> _promptAddTodoItem(),
tooltip: 'Add task',
child: const Icon(Icons.add),
),
);
}

void _promptAddTodoItem() {
TextEditingController controller = TextEditingController();
showDialog(
  context: context,
  builder: (BuildContext context) {
    return AlertDialog(
      title: const Text('Add a task to your list'),
      content: TextField(
        controller: controller,
        autofocus: true,
        onSubmitted: (value) {
          _addTodoItem(TodoItem(title: value));
          Navigator.pop(context);
        },
        decoration: const InputDecoration(
          hintText: 'Enter task name',
        ),
      ),
    );
  },
);
}

void _promptEditTodoItem(int index) {
TextEditingController controller =
TextEditingController(text: _todoItems[index].title);

showDialog(
  context: context,
  builder: (BuildContext context) {
    return AlertDialog(
      title: const Text('Edit task'),
      content: TextField(
        controller: controller,
        autofocus: true,
        onSubmitted: (value) {
          _editTodoItem(index, value);
          Navigator.pop(context);
        },
        decoration: const InputDecoration(
          hintText: 'Enter new task name',
        ),
      ),
    );
  },
);
}

Future<void> _loadTodoItems() async {
SharedPreferences prefs = await SharedPreferences.getInstance();
String? encodedTodoItems = prefs.getString('todoItems');
if (encodedTodoItems != null) {
List<dynamic> decodedTodoItems = jsonDecode(encodedTodoItems);
_todoItems = decodedTodoItems
.map((dynamic item) =>
TodoItem(title: item['title'], isDone: item['isDone']))
.toList()
.cast<TodoItem>();
setState(() {});
}
}

Future<void> _saveTodoItems() async {
SharedPreferences prefs = await SharedPreferences.getInstance();
List<Map<String, dynamic>> encodedTodoItems = _todoItems
.map((TodoItem item) => {'title': item.title, 'isDone': item.isDone})
.toList();
prefs.setString('todoItems', jsonEncode(encodedTodoItems));
}
}