import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../task.dart';
import '../service.dart';

final taskServiceProvider = Provider<TaskService>((ref) => TaskService());

final taskListProvider = StateNotifierProvider<TaskListNotifier, AsyncValue<List<Task>>>((ref) {
  final service = ref.watch(taskServiceProvider);
  return TaskListNotifier(service);
});

class TaskListNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  final TaskService _service;
  TaskListNotifier(this._service) : super(const AsyncValue.loading()) {
    loadTasks();
  }


  Future<void> loadTasks() async {
    try {
      state = const AsyncValue.loading();
      final tasks = await _service.fetchTasks();
      state = AsyncValue.data(tasks);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addTask(String title, DateTime? dueDate) async {
    try {
      await _service.addTask(title, dueDate);
      await loadTasks();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void updateStatus(int id, String status) {
    _service.updateStatus(id, status);
    state = AsyncValue.data(state.value ?? []);
  }


  void simulateError() {
    state = AsyncValue.error(
      Exception('Simulated error'),
      StackTrace.current,
    );
  }

}
