import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/api_service.dart';

class TaskProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService.instance;
  final ApiService _apiService = ApiService.instance;

  List<Map<String, dynamic>> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get tasks by category
  List<Map<String, dynamic>> getTasksByCategory(String category) {
    return _tasks.where((task) => task['category'] == category).toList();
  }

  // Get completed tasks
  List<Map<String, dynamic>> get completedTasks {
    return _tasks.where((task) => task['isCompleted'] == 1).toList();
  }

  // Get pending tasks
  List<Map<String, dynamic>> get pendingTasks {
    return _tasks.where((task) => task['isCompleted'] == 0).toList();
  }

  // Load tasks from database
  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();

    try {
      final userId = await _apiService.getUserId();
      if (userId != null) {
        _tasks = await _dbService.getTasks(userId);
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load tasks: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Add new task
  Future<bool> addTask({
    required String title,
    String? description,
    required String category,
    required String priority,
    DateTime? dueDate,
  }) async {
    try {
      final userId = await _apiService.getUserId();
      if (userId == null) return false;

      final taskId = DateTime.now().millisecondsSinceEpoch.toString();
      final now = DateTime.now().millisecondsSinceEpoch;

      final taskData = {
        'id': taskId,
        'userId': userId,
        'title': title,
        'description': description,
        'category': category,
        'priority': priority,
        'dueDate': dueDate?.millisecondsSinceEpoch,
        'isCompleted': 0,
        'createdAt': now,
        'updatedAt': now,
      };

      await _dbService.insertTask(taskData);
      
      // PRODUCTION: Sync with API
      /*
      final response = await _apiService.createTask(
        title: title,
        description: description,
        category: category,
        priority: priority,
        dueDate: dueDate,
      );
      
      if (!response.isSuccess) {
        // Add to sync queue for later
        await _dbService.addToSyncQueue('create', 'tasks', jsonEncode(taskData));
      }
      */

      await loadTasks();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add task: $e';
      notifyListeners();
      return false;
    }
  }

  // Update task
  Future<bool> updateTask({
    required String taskId,
    String? title,
    String? description,
    String? category,
    String? priority,
    DateTime? dueDate,
    bool? isCompleted,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      
      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (category != null) updateData['category'] = category;
      if (priority != null) updateData['priority'] = priority;
      if (dueDate != null) updateData['dueDate'] = dueDate.millisecondsSinceEpoch;
      if (isCompleted != null) updateData['isCompleted'] = isCompleted ? 1 : 0;

      await _dbService.updateTask(taskId, updateData);

      // PRODUCTION: Sync with API
      /*
      final response = await _apiService.updateTask(
        taskId: taskId,
        title: title,
        description: description,
        category: category,
        priority: priority,
        dueDate: dueDate,
        isCompleted: isCompleted,
      );
      
      if (!response.isSuccess) {
        await _dbService.addToSyncQueue('update', 'tasks', jsonEncode({
          'id': taskId,
          ...updateData,
        }));
      }
      */

      await loadTasks();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update task: $e';
      notifyListeners();
      return false;
    }
  }

  // Toggle task completion
  Future<bool> toggleTaskCompletion(String taskId) async {
    try {
      final task = _tasks.firstWhere((t) => t['id'] == taskId);
      final isCompleted = task['isCompleted'] == 1;
      
      return await updateTask(
        taskId: taskId,
        isCompleted: !isCompleted,
      );
    } catch (e) {
      _errorMessage = 'Failed to toggle task: $e';
      notifyListeners();
      return false;
    }
  }

  // Delete task
  Future<bool> deleteTask(String taskId) async {
    try {
      await _dbService.deleteTask(taskId);

      // PRODUCTION: Sync with API
      /*
      final response = await _apiService.deleteTask(taskId);
      
      if (!response.isSuccess) {
        await _dbService.addToSyncQueue('delete', 'tasks', jsonEncode({'id': taskId}));
      }
      */

      await loadTasks();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete task: $e';
      notifyListeners();
      return false;
    }
  }

  // Sync with server
  Future<void> syncTasks() async {
    try {
      // PRODUCTION: Implement full sync logic
      /*
      final response = await _apiService.getTasks();
      
      if (response.isSuccess && response.data != null) {
        final userId = await _apiService.getUserId();
        if (userId != null) {
          // Clear local tasks
          await _dbService.clearAllData();
          
          // Insert server tasks
          for (final task in response.data!) {
            await _dbService.insertTask({
              ...task,
              'userId': userId,
            });
          }
          
          await loadTasks();
        }
      }
      */
    } catch (e) {
      _errorMessage = 'Failed to sync tasks: $e';
      notifyListeners();
    }
  }

  // Get statistics
  Map<String, int> getStatistics() {
    final akademikTasks = getTasksByCategory('akademik');
    final pengembanganTasks = getTasksByCategory('pengembangan');

    return {
      'totalTasks': _tasks.length,
      'completedTasks': completedTasks.length,
      'pendingTasks': pendingTasks.length,
      'akademikTotal': akademikTasks.length,
      'akademikCompleted': akademikTasks.where((t) => t['isCompleted'] == 1).length,
      'pengembanganTotal': pengembanganTasks.length,
      'pengembanganCompleted': pengembanganTasks.where((t) => t['isCompleted'] == 1).length,
    };
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}