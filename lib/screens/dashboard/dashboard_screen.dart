import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/schedule_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<TaskItem> tasks = [];
  
  int akademikCompleted = 0;
  int akademikTotal = 0;
  int pengembanganCompleted = 0;
  int pengembanganTotal = 0;

  @override
  void initState() {
    super.initState();
    _updateTaskCounts();
  }

  void _updateTaskCounts() {
    akademikCompleted = tasks.where((t) => t.category == 'akademik' && t.isCompleted).length;
    akademikTotal = tasks.where((t) => t.category == 'akademik').length;
    pengembanganCompleted = tasks.where((t) => t.category == 'pengembangan' && t.isCompleted).length;
    pengembanganTotal = tasks.where((t) => t.category == 'pengembangan').length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildTimeDistributionCard(),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Minggu Ini',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            '$akademikCompleted/$akademikTotal',
                            'Tugas Akademik',
                            AppColors.akademik,
                            Icons.school,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSummaryCard(
                            '$pengembanganCompleted/$pengembanganTotal',
                            'Pengembangan Diri',
                            AppColors.devDiri,
                            Icons.trending_up,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildMotivationalCard(),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tugas Mendatang',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _showAddTaskDialog,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Tambah'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (tasks.isEmpty)
                      _buildEmptyState()
                    else
                      ...tasks.map((task) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _buildTaskItem(task),
                      )),
                  ],
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTaskDialog,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah Task', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/main-menu');
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                    tooltip: 'Kembali ke Menu',
                  ),
                  const Text(
                    'Dashboard',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Consumer<ScheduleProvider>(
                    builder: (context, provider, child) {
                      final conflicts = provider.conflicts.length;
                      if (conflicts > 0) {
                        return Stack(
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/schedule-safe');
                              },
                              icon: const Icon(
                                Icons.warning_amber_rounded,
                                color: AppColors.secondary,
                              ),
                            ),
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.error,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '$conflicts',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 48),
            child: Text(
              'Selamat datang kembali! 👋',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeDistributionCard() {
    final akademikPercent = akademikTotal > 0 ? akademikCompleted / akademikTotal : 0.0;
    final pengembanganPercent = pengembanganTotal > 0 ? pengembanganCompleted / pengembanganTotal : 0.0;
    final istirahatPercent = 0.2;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Distribusi Waktu Minggu Ini',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildProgressIndicator(
                'Akademik',
                akademikPercent,
                AppColors.akademik,
                '${(akademikPercent * 100).toInt()}%',
              ),
              _buildProgressIndicator(
                'Dev Diri',
                pengembanganPercent,
                AppColors.devDiri,
                '${(pengembanganPercent * 100).toInt()}%',
              ),
              _buildProgressIndicator(
                'Istirahat',
                istirahatPercent,
                AppColors.istirahat,
                '${(istirahatPercent * 100).toInt()}%',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(String label, double value, Color color, String percentage) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 70,
              height: 70,
              child: CircularProgressIndicator(
                value: value,
                strokeWidth: 8,
                backgroundColor: color.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Text(
              percentage,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String value, String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMotivationalCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondary.withOpacity(0.2),
            AppColors.secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lightbulb,
              color: AppColors.secondary,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tips Hari Ini',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tasks.isEmpty
                      ? 'Mulai hari dengan membuat task pertamamu!'
                      : 'Tetap fokus dan selesaikan satu tugas dalam satu waktu!',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.task_outlined,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada tugas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap tombol + untuk menambah tugas baru',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(TaskItem task) {
    Color priorityColor;
    switch (task.priority) {
      case 'tinggi':
        priorityColor = AppColors.error;
        break;
      case 'sedang':
        priorityColor = AppColors.warning;
        break;
      default:
        priorityColor = AppColors.success;
    }

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Hapus Task'),
            content: Text('Yakin ingin menghapus "${task.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Hapus', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        setState(() {
          tasks.removeWhere((t) => t.id == task.id);
          _updateTaskCounts();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${task.title} dihapus'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                setState(() {
                  tasks.add(task);
                  _updateTaskCounts();
                });
              },
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: task.isCompleted
              ? Border.all(color: AppColors.success, width: 2)
              : null,
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
            GestureDetector(
              onTap: () {
                setState(() {
                  final index = tasks.indexWhere((t) => t.id == task.id);
                  tasks[index] = task.copyWith(isCompleted: !task.isCompleted);
                  _updateTaskCounts();
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: task.category == 'akademik'
                              ? AppColors.akademik.withOpacity(0.1)
                              : AppColors.devDiri.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          task.category == 'akademik' ? 'Akademik' : 'Pengembangan',
                          style: TextStyle(
                            fontSize: 10,
                            color: task.category == 'akademik'
                                ? AppColors.akademik
                                : AppColors.devDiri,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        task.dueDate,
                        style: TextStyle(
                          fontSize: 12,
                          color: priorityColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditTaskDialog(task);
                } else if (value == 'delete') {
                  _deleteTask(task);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Hapus', style: TextStyle(color: AppColors.error)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    String selectedCategory = 'akademik';
    String selectedPriority = 'sedang';
    String selectedDueDate = '3 hari lagi';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
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
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Nama Task',
                    hintText: 'Contoh: UTS Kalkulus',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Kategori',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildCategoryChip(
                        'Akademik',
                        'akademik',
                        selectedCategory,
                        AppColors.akademik,
                        (value) => setModalState(() => selectedCategory = value),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildCategoryChip(
                        'Pengembangan',
                        'pengembangan',
                        selectedCategory,
                        AppColors.devDiri,
                        (value) => setModalState(() => selectedCategory = value),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Prioritas',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildPriorityChip(
                        'Tinggi',
                        'tinggi',
                        selectedPriority,
                        AppColors.error,
                        (value) => setModalState(() => selectedPriority = value),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildPriorityChip(
                        'Sedang',
                        'sedang',
                        selectedPriority,
                        AppColors.warning,
                        (value) => setModalState(() => selectedPriority = value),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildPriorityChip(
                        'Rendah',
                        'rendah',
                        selectedPriority,
                        AppColors.success,
                        (value) => setModalState(() => selectedPriority = value),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedDueDate,
                  decoration: InputDecoration(
                    labelText: 'Deadline',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Hari ini', child: Text('Hari ini')),
                    DropdownMenuItem(value: '1 hari lagi', child: Text('1 hari lagi')),
                    DropdownMenuItem(value: '3 hari lagi', child: Text('3 hari lagi')),
                    DropdownMenuItem(value: '1 minggu lagi', child: Text('1 minggu lagi')),
                    DropdownMenuItem(value: '2 minggu lagi', child: Text('2 minggu lagi')),
                  ],
                  onChanged: (value) => setModalState(() => selectedDueDate = value!),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (titleController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Nama task tidak boleh kosong'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                        return;
                      }

                      final newTask = TaskItem(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: titleController.text,
                        category: selectedCategory,
                        priority: selectedPriority,
                        dueDate: selectedDueDate,
                        isCompleted: false,
                      );

                      setState(() {
                        tasks.add(newTask);
                        _updateTaskCounts();
                      });

                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Task berhasil ditambahkan!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Tambah Task'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditTaskDialog(TaskItem task) {
    final titleController = TextEditingController(text: task.title);
    String selectedCategory = task.category;
    String selectedPriority = task.priority;
    String selectedDueDate = task.dueDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Edit Task',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Nama Task',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Kategori', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildCategoryChip(
                        'Akademik',
                        'akademik',
                        selectedCategory,
                        AppColors.akademik,
                        (value) => setModalState(() => selectedCategory = value),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildCategoryChip(
                        'Pengembangan',
                        'pengembangan',
                        selectedCategory,
                        AppColors.devDiri,
                        (value) => setModalState(() => selectedCategory = value),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedDueDate,
                  decoration: InputDecoration(
                    labelText: 'Deadline',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Hari ini', child: Text('Hari ini')),
                    DropdownMenuItem(value: '1 hari lagi', child: Text('1 hari lagi')),
                    DropdownMenuItem(value: '3 hari lagi', child: Text('3 hari lagi')),
                    DropdownMenuItem(value: '1 minggu lagi', child: Text('1 minggu lagi')),
                    DropdownMenuItem(value: '2 minggu lagi', child: Text('2 minggu lagi')),
                  ],
                  onChanged: (value) => setModalState(() => selectedDueDate = value!),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (titleController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Nama task tidak boleh kosong'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                        return;
                      }

                      setState(() {
                        final index = tasks.indexWhere((t) => t.id == task.id);
                        if (index != -1) {
                          tasks[index] = TaskItem(
                            id: task.id,
                            title: titleController.text,
                            category: selectedCategory,
                            priority: selectedPriority,
                            dueDate: selectedDueDate,
                            isCompleted: task.isCompleted,
                          );
                          _updateTaskCounts();
                        }
                      });

                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Task berhasil diupdate!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                    child: const Text('Simpan Perubahan'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _deleteTask(TaskItem task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Task'),
        content: Text('Yakin ingin menghapus "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                tasks.removeWhere((t) => t.id == task.id);
                _updateTaskCounts();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${task.title} dihapus'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Hapus', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(
    String label,
    String value,
    String selectedValue,
    Color color,
    Function(String) onSelect,
  ) {
    final isSelected = value == selectedValue;
    return GestureDetector(
      onTap: () => onSelect(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? color : Colors.grey,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityChip(
    String label,
    String value,
    String selectedValue,
    Color color,
    Function(String) onSelect,
  ) {
    final isSelected = value == selectedValue;
    return GestureDetector(
      onTap: () => onSelect(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? color : Colors.grey,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

// Task Model
class TaskItem {
  final String id;
  final String title;
  final String category;
  final String priority;
  final String dueDate;
  final bool isCompleted;

  TaskItem({
    required this.id,
    required this.title,
    required this.category,
    required this.priority,
    required this.dueDate,
    required this.isCompleted,
  });

  TaskItem copyWith({
    String? id,
    String? title,
    String? category,
    String? priority,
    String? dueDate,
    bool? isCompleted,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}