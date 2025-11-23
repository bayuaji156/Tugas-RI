import 'package:flutter/material.dart';
import '../../config/theme.dart';

enum TaskFilter { semua, akademik, pengembanganDiri, istirahat }

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  TaskFilter _selectedFilter = TaskFilter.semua;

  // Sample data
  final List<TaskItem> _tasks = [
    TaskItem(
      id: '1',
      title: 'UTS - Kalkulus',
      daysRemaining: '2 hari lagi',
      category: TaskFilter.akademik,
      isHighPriority: true,
      isCompleted: false,
    ),
    TaskItem(
      id: '2',
      title: 'Tugas Rekayasa Interaksi',
      daysRemaining: '5 hari lagi',
      category: TaskFilter.akademik,
      isHighPriority: false,
      isCompleted: false,
    ),
    TaskItem(
      id: '3',
      title: 'Belajar React',
      daysRemaining: '6 hari lagi',
      category: TaskFilter.pengembanganDiri,
      isHighPriority: false,
      isCompleted: false,
    ),
    TaskItem(
      id: '4',
      title: 'Webinar UI/UX',
      daysRemaining: '4 hari lagi',
      category: TaskFilter.pengembanganDiri,
      isHighPriority: false,
      isCompleted: false,
    ),
  ];

  List<TaskItem> get filteredTasks {
    if (_selectedFilter == TaskFilter.semua) return _tasks;
    return _tasks.where((t) => t.category == _selectedFilter).toList();
  }

  List<TaskItem> get highPriorityTasks =>
      filteredTasks.where((t) => t.isHighPriority).toList();
  
  List<TaskItem> get regularTasks =>
      filteredTasks.where((t) => !t.isHighPriority).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Semua Task'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            color: AppColors.primary,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _buildFilterChip('Semua', TaskFilter.semua),
                    const SizedBox(width: 8),
                    _buildFilterChip('Akademik', TaskFilter.akademik),
                    const SizedBox(width: 8),
                    _buildFilterChip('Pengembangan', TaskFilter.pengembanganDiri),
                    const SizedBox(width: 8),
                    _buildFilterChip('Istirahat', TaskFilter.istirahat),
                  ],
                ),
              ),
            ),
          ),
          // Task List
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // High Priority Section
                  if (highPriorityTasks.isNotEmpty) ...[
                    const Text(
                      'Akademik-Prioritas Tinggi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...highPriorityTasks.map((task) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildTaskCard(task),
                    )),
                    const SizedBox(height: 20),
                  ],
                  // Regular Tasks Section
                  if (regularTasks.isNotEmpty) ...[
                    const Text(
                      'Pengembangan Diri',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...regularTasks.map((task) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildTaskCard(task),
                    )),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new task
          _showAddTaskDialog();
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterChip(String label, TaskFilter filter) {
    final isSelected = _selectedFilter == filter;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = filter),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.textSecondary.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCard(TaskItem task) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Checkbox
          GestureDetector(
            onTap: () {
              setState(() {
                final index = _tasks.indexWhere((t) => t.id == task.id);
                if (index != -1) {
                  _tasks[index] = task.copyWith(isCompleted: !task.isCompleted);
                }
              });
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: task.isCompleted ? AppColors.success : AppColors.textSecondary,
                  width: 2,
                ),
                color: task.isCompleted ? AppColors.success : Colors.transparent,
              ),
              child: task.isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          // Task Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  task.daysRemaining,
                  style: TextStyle(
                    fontSize: 12,
                    color: task.isHighPriority ? AppColors.error : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Priority indicator
          if (task.isHighPriority)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Penting',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showAddTaskDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Tambah Task Baru',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'Nama Task',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Deskripsi',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Simpan Task'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskItem {
  final String id;
  final String title;
  final String daysRemaining;
  final TaskFilter category;
  final bool isHighPriority;
  final bool isCompleted;

  TaskItem({
    required this.id,
    required this.title,
    required this.daysRemaining,
    required this.category,
    required this.isHighPriority,
    required this.isCompleted,
  });

  TaskItem copyWith({
    String? id,
    String? title,
    String? daysRemaining,
    TaskFilter? category,
    bool? isHighPriority,
    bool? isCompleted,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      daysRemaining: daysRemaining ?? this.daysRemaining,
      category: category ?? this.category,
      isHighPriority: isHighPriority ?? this.isHighPriority,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}