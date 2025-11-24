import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../task.dart';
import '../task_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _filter = "all";
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  bool _sortAsc = true;
  bool _sortByDueDate = false;
  DateTime? _selectedDueDate;

  void _toggleSort() => setState(() {
    _sortAsc = !_sortAsc;
    _sortByDueDate = false;
  });

  void _toggleSortByDueDate() => setState(() {
    _sortByDueDate = true;
  });

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  Widget _buildFilterButton(String value, String text) {
    final selected = _filter == value;
    return ElevatedButton(
      onPressed: () => setState(() => _filter = value),
      style: ElevatedButton.styleFrom(
        backgroundColor: selected ? Colors.blue : Colors.grey,
      ),
      child: Text(text),
    );
  }

  List<Task> _applyFiltersAndSort(List<Task> tasks) {
    var list = List<Task>.from(tasks);

    // 상태 필터
    if (_filter != "all") list = list.where((t) => t.status == _filter).toList();

    // 검색
    final keyword = _searchController.text.trim();
    if (keyword.isNotEmpty) {
      list = list.where((t) => t.title.contains(keyword)).toList();
    }

    // 정렬
    if (_sortByDueDate) {
      list.sort((a, b) {
        if (a.dueDate == null && b.dueDate == null) return 0;
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      });
    } else {
      list.sort((a, b) =>
      _sortAsc ? a.title.compareTo(b.title) : b.title.compareTo(a.title));
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final taskListAsync = ref.watch(taskListProvider);
    final dateFormat = DateFormat('yyyy-MM-dd');
    final width = MediaQuery.of(context).size.width;

    int columns = 1;
    if (width >= 1200) columns = 3;
    else if (width >= 800) columns = 2;

    return Scaffold(
      appBar: AppBar(title: const Text("Todo 앱")),
      body: taskListAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("에러가 발생했습니다. 다시 시도해 주세요."),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.read(taskListProvider.notifier).loadTasks(),
                child: const Text("다시 시도"),
              ),
            ],
          ),
        ),
        data: (tasks) {
          final filteredTasks = _applyFiltersAndSort(tasks);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // 필터
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildFilterButton("all", "전체"),
                    _buildFilterButton("todo", "할 일"),
                    _buildFilterButton("doing", "진행중"),
                    _buildFilterButton("done", "완료"),
                  ],
                ),
                const SizedBox(height: 12),

                // 검색 + 정렬 아이콘
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: "검색",
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // 에러 버튼
                    IconButton(
                      tooltip: "에러 시뮬레이션 (테스트용)",
                      icon: const Icon(Icons.date_range),
                      onPressed: () {
                        ref.read(taskListProvider.notifier).simulateError();
                      },
                    ),

                    // 정렬
                    IconButton(
                      tooltip: "제목 정렬 (오름/내림)",
                      icon: Icon(_sortByDueDate
                          ? Icons.date_range
                          : (_sortAsc ? Icons.arrow_upward : Icons.arrow_downward)),
                      onPressed: _sortByDueDate ? null : _toggleSort,
                    ),

                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: "작업 추가 (제목 입력)",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: "마감일 선택",
                      icon: const Icon(Icons.calendar_today),
                      onPressed: _pickDueDate,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final title = _controller.text.trim();
                        if (title.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('제목을 입력해 주세요.')),
                          );
                          return;
                        }
                        ref.read(taskListProvider.notifier).addTask(title, _selectedDueDate);
                        _controller.clear();
                        setState(() {
                          _selectedDueDate = null;
                        });
                      },
                      child: const Text("추가"),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 목록
                filteredTasks.isEmpty
                    ? const Center(child: Text("표시할 작업이 없습니다."))
                    : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredTasks.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    childAspectRatio: 4.0,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    final task = filteredTasks[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.title,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  if (task.dueDate != null)
                                    Text(
                                      "마감: ${dateFormat.format(task.dueDate!)}",
                                      style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
                                    ),
                                ],
                              ),
                            ),
                            DropdownButton<String>(
                              value: task.status,
                              items: const [
                                DropdownMenuItem(value: "todo", child: Text("할 일")),
                                DropdownMenuItem(value: "doing", child: Text("진행중")),
                                DropdownMenuItem(value: "done", child: Text("완료")),
                              ],
                              onChanged: (s) {
                                if (s == null) return;
                                ref.read(taskListProvider.notifier).updateStatus(task.id, s);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
