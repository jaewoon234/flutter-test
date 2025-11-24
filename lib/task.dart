class Task {
  final int id;
  final String title;
  String status; // "todo", "doing", "done"
  DateTime? dueDate;

  Task({
    required this.id,
    required this.title,
    this.status = "todo",
    this.dueDate,
  });

  Task copyWith({int? id, String? title, String? status, DateTime? dueDate}) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
    );
  }
}
