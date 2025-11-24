import 'dart:async';
import '../task.dart';

class TaskService {
  final List<Task> _tasks = [
    Task(
      id: 1,
      title: "첫 번째 작업",
      status: "todo",
      dueDate: DateTime.now().add(Duration(days: 2)),
    ),
    Task(
      id: 2,
      title: "두 번째 작업",
      status: "doing",
      dueDate: DateTime.now().add(Duration(days: 5)),
    ),
    Task(id: 3, title: "세 번째 작업", status: "done"),
  ];


  Future<List<Task>> fetchTasks() async {
    await Future.delayed(const Duration(seconds: 1));

    return List.from(_tasks);
  }

  Future<void> addTask(String title, DateTime? dueDate) async {
    final newTask = Task(id: _tasks.length + 1, title: title, dueDate: dueDate);
    _tasks.add(newTask);
  }

  void updateStatus(int id, String status) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) _tasks[index].status = status;
  }
}
