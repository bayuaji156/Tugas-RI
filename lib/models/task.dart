// lib/models/user.dart
class User {
  final String id;
  final String email;
  final String name;
  final String? noHp;
  final String? jurusan;
  final int? semester;
  final String? photoUrl;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.noHp,
    this.jurusan,
    this.semester,
    this.photoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'noHp': noHp,
      'jurusan': jurusan,
      'semester': semester,
      'photoUrl': photoUrl,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      name: map['name'],
      noHp: map['noHp'],
      jurusan: map['jurusan'],
      semester: map['semester'],
      photoUrl: map['photoUrl'],
    );
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? noHp,
    String? jurusan,
    int? semester,
    String? photoUrl,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      noHp: noHp ?? this.noHp,
      jurusan: jurusan ?? this.jurusan,
      semester: semester ?? this.semester,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}

// lib/models/task.dart
enum TaskCategory { akademik, pengembanganDiri, istirahat }
enum TaskPriority { tinggi, sedang, rendah }
enum TaskStatus { pending, inProgress, completed }

class Task {
  final String id;
  final String title;
  final String? description;
  final TaskCategory category;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime? dueDate;
  final DateTime? reminder;
  final DateTime createdAt;
  final bool isCompleted;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    required this.priority,
    this.status = TaskStatus.pending,
    this.dueDate,
    this.reminder,
    required this.createdAt,
    this.isCompleted = false,
  });

  String get categoryLabel {
    switch (category) {
      case TaskCategory.akademik:
        return 'Akademik';
      case TaskCategory.pengembanganDiri:
        return 'Pengembangan Diri';
      case TaskCategory.istirahat:
        return 'Istirahat';
    }
  }

  String get priorityLabel {
    switch (priority) {
      case TaskPriority.tinggi:
        return 'Prioritas Tinggi';
      case TaskPriority.sedang:
        return 'Prioritas Sedang';
      case TaskPriority.rendah:
        return 'Prioritas Rendah';
    }
  }

  String get daysRemaining {
    if (dueDate == null) return '';
    final diff = dueDate!.difference(DateTime.now()).inDays;
    if (diff < 0) return 'Terlambat';
    if (diff == 0) return 'Hari ini';
    return '$diff hari lagi';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.index,
      'priority': priority.index,
      'status': status.index,
      'dueDate': dueDate?.millisecondsSinceEpoch,
      'reminder': reminder?.millisecondsSinceEpoch,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      category: TaskCategory.values[map['category']],
      priority: TaskPriority.values[map['priority']],
      status: TaskStatus.values[map['status'] ?? 0],
      dueDate: map['dueDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dueDate'])
          : null,
      reminder: map['reminder'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['reminder'])
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      isCompleted: map['isCompleted'] == 1,
    );
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskCategory? category,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? dueDate,
    DateTime? reminder,
    DateTime? createdAt,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      reminder: reminder ?? this.reminder,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

// lib/models/schedule.dart
class Schedule {
  final String id;
  final String title;
  final String? description;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String? location;
  final int? reminderMinutes;
  final bool hasConflict;
  final String? conflictWith;

  Schedule({
    required this.id,
    required this.title,
    this.description,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.location,
    this.reminderMinutes,
    this.hasConflict = false,
    this.conflictWith,
  });

  String get timeRange {
    String formatTime(TimeOfDay t) {
      return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    }
    return '${formatTime(startTime)} - ${formatTime(endTime)}';
  }

  bool conflictsWith(Schedule other) {
    if (date.year != other.date.year ||
        date.month != other.date.month ||
        date.day != other.date.day) {
      return false;
    }
    
    final thisStart = startTime.hour * 60 + startTime.minute;
    final thisEnd = endTime.hour * 60 + endTime.minute;
    final otherStart = other.startTime.hour * 60 + other.startTime.minute;
    final otherEnd = other.endTime.hour * 60 + other.endTime.minute;
    
    return (thisStart < otherEnd && thisEnd > otherStart);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.millisecondsSinceEpoch,
      'startHour': startTime.hour,
      'startMinute': startTime.minute,
      'endHour': endTime.hour,
      'endMinute': endTime.minute,
      'location': location,
      'reminderMinutes': reminderMinutes,
    };
  }

  factory Schedule.fromMap(Map<String, dynamic> map) {
    return Schedule(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      startTime: TimeOfDay(hour: map['startHour'], minute: map['startMinute']),
      endTime: TimeOfDay(hour: map['endHour'], minute: map['endMinute']),
      location: map['location'],
      reminderMinutes: map['reminderMinutes'],
    );
  }

  Schedule copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String? location,
    int? reminderMinutes,
    bool? hasConflict,
    String? conflictWith,
  }) {
    return Schedule(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      hasConflict: hasConflict ?? this.hasConflict,
      conflictWith: conflictWith ?? this.conflictWith,
    );
  }
}

class TimeOfDay {
  final int hour;
  final int minute;

  const TimeOfDay({required this.hour, required this.minute});

  @override
  String toString() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}