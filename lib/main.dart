import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class Task {
  String title;
  String description;
  bool isCompleted;

  Task({
    required this.title,
    required this.description,
    this.isCompleted = false,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lista de Tareas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF113946), // Cambia el color del AppBar
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            primary: Color(0xFF113946), // Cambia el color de los botones
          ),
        ),
        scaffoldBackgroundColor: Color(0xFFFFF2D8), // Cambia el color de fondo
        fontFamily: 'Roboto',
        textTheme: TextTheme(
          headline6: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          bodyText2: TextStyle(
            fontSize: 16.0,
          ),
        ),
      ),
      home: const TaskListPage(),
    );
  }
}

class TaskListPage extends StatefulWidget {
  const TaskListPage({Key? key}) : super(key: key);

  @override
  _TaskListPageState createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  final List<Task> tasks = [];

  void _addTask(Task task) {
    setState(() {
      tasks.add(task);
    });
  }

  void _updateTask(int index, Task updatedTask) {
    setState(() {
      tasks[index] = updatedTask;
    });
  }

  void _deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
  }

  void _showTaskForm(BuildContext context, [Task? task]) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute<Task?>(
        builder: (context) => TaskFormPage(task: task),
      ),
    );

    if (result != null) {
      if (task == null) {
        _addTask(result);
      } else {
        final index = tasks.indexOf(task);
        _updateTask(index, result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Tareas'),
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return Card(
            elevation: 2.0,
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: ListTile(
              title: Text(
                task.title,
                style: TextStyle(
                  decoration:
                      task.isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
              subtitle: Text(
                task.description,
                style: TextStyle(
                  decoration:
                      task.isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
              trailing: Checkbox(
                value: task.isCompleted,
                onChanged: (value) {
                  final updatedTask = Task(
                    title: task.title,
                    description: task.description,
                    isCompleted: value ?? false,
                  );
                  _updateTask(index, updatedTask);
                },
              ),
              onLongPress: () {
                _showDeleteTaskDialog(context, index);
              },
              onTap: () => _showTaskForm(context, task),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskForm(context),
        child: Icon(Icons.add),
      ),
    );
  }

  void _showDeleteTaskDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar Tarea'),
          content:
              const Text('¿Estás seguro de que deseas eliminar esta tarea?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _deleteTask(index);
                Navigator.of(context).pop();
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }
}

class TaskFormPage extends StatefulWidget {
  final Task? task;

  const TaskFormPage({Key? key, this.task}) : super(key: key);

  @override
  _TaskFormPageState createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _isCompleted = widget.task!.isCompleted;
    }
  }

  void _saveTask() {
    final title = _titleController.text;
    final description = _descriptionController.text;
    final newTask = Task(
      title: title,
      description: description,
      isCompleted: _isCompleted,
    );

    Navigator.of(context).pop(newTask);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Nueva Tarea' : 'Editar Tarea'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              // Establecer el número de líneas deseadas
            ),
            CheckboxListTile(
              title: const Text('Completada'),
              value: _isCompleted,
              onChanged: (value) {
                setState(() {
                  _isCompleted = value ?? false;
                });
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveTask,
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
