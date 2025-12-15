import 'package:flutter/material.dart';
import '../models/schedule.dart';
import '../services/database_service.dart';
import '../services/api_service.dart';

class ScheduleProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService.instance;
  final ApiService _apiService = ApiService.instance;

  // Daftar semua jadwal
  final List<Schedule> _schedules = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getter untuk semua jadwal
  List<Schedule> get schedules => List.unmodifiable(_schedules);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Getter untuk semua konflik yang terdeteksi
  List<ScheduleConflict> get conflicts => _detectAllConflicts();

  // Inisialisasi dengan data dari database
  ScheduleProvider() {
    loadSchedules();
  }

  // Load schedules from database
  Future<void> loadSchedules() async {
    _isLoading = true;
    notifyListeners();

    try {
      final userId = await _apiService.getUserId();
      if (userId != null) {
        final scheduleData = await _dbService.getSchedules(userId);
        _schedules.clear();
        
        for (final data in scheduleData) {
          _schedules.add(Schedule(
            id: data['id'],
            title: data['title'],
            description: data['description'],
            date: DateTime.fromMillisecondsSinceEpoch(data['date']),
            startTime: TimeOfDay(hour: data['startHour'], minute: data['startMinute']),
            endTime: TimeOfDay(hour: data['endHour'], minute: data['endMinute']),
            location: data['location'],
            reminderMinutes: data['reminderMinutes'],
          ));
        }
        
        _updateConflictStatus();
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load schedules: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Ambil jadwal berdasarkan tanggal
  List<Schedule> getSchedulesForDate(DateTime date) {
    return _schedules.where((s) =>
      s.date.year == date.year &&
      s.date.month == date.month &&
      s.date.day == date.day
    ).toList()
      ..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
  }

  // Ambil semua tanggal yang memiliki jadwal
  Map<DateTime, List<Schedule>> get schedulesByDate {
    final map = <DateTime, List<Schedule>>{};
    for (final schedule in _schedules) {
      final dateKey = DateTime(
        schedule.date.year,
        schedule.date.month,
        schedule.date.day,
      );
      map.putIfAbsent(dateKey, () => []).add(schedule);
    }
    return map;
  }

  // Tambah jadwal baru
  Future<void> addSchedule(Schedule schedule) async {
    try {
      final userId = await _apiService.getUserId();
      if (userId == null) return;

      final scheduleData = {
        'id': schedule.id,
        'userId': userId,
        'title': schedule.title,
        'description': schedule.description,
        'date': schedule.date.millisecondsSinceEpoch,
        'startHour': schedule.startTime.hour,
        'startMinute': schedule.startTime.minute,
        'endHour': schedule.endTime.hour,
        'endMinute': schedule.endTime.minute,
        'location': schedule.location,
        'reminderMinutes': schedule.reminderMinutes,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };

      await _dbService.insertSchedule(scheduleData);
      
      // PRODUCTION: Sync with API
      /*
      await _apiService.createSchedule(
        title: schedule.title,
        description: schedule.description,
        date: schedule.date,
        startHour: schedule.startTime.hour,
        startMinute: schedule.startTime.minute,
        endHour: schedule.endTime.hour,
        endMinute: schedule.endTime.minute,
        location: schedule.location,
        reminderMinutes: schedule.reminderMinutes,
      );
      */

      await loadSchedules();
    } catch (e) {
      _errorMessage = 'Failed to add schedule: $e';
      notifyListeners();
    }
  }

  // Update jadwal
  Future<void> updateSchedule(Schedule updatedSchedule) async {
    try {
      final scheduleData = {
        'title': updatedSchedule.title,
        'description': updatedSchedule.description,
        'date': updatedSchedule.date.millisecondsSinceEpoch,
        'startHour': updatedSchedule.startTime.hour,
        'startMinute': updatedSchedule.startTime.minute,
        'endHour': updatedSchedule.endTime.hour,
        'endMinute': updatedSchedule.endTime.minute,
        'location': updatedSchedule.location,
        'reminderMinutes': updatedSchedule.reminderMinutes,
      };

      await _dbService.updateSchedule(updatedSchedule.id, scheduleData);
      
      // PRODUCTION: Sync with API
      /*
      await _apiService.updateSchedule(
        scheduleId: updatedSchedule.id,
        title: updatedSchedule.title,
        description: updatedSchedule.description,
        date: updatedSchedule.date,
        startHour: updatedSchedule.startTime.hour,
        startMinute: updatedSchedule.startTime.minute,
        endHour: updatedSchedule.endTime.hour,
        endMinute: updatedSchedule.endTime.minute,
        location: updatedSchedule.location,
        reminderMinutes: updatedSchedule.reminderMinutes,
      );
      */

      await loadSchedules();
    } catch (e) {
      _errorMessage = 'Failed to update schedule: $e';
      notifyListeners();
    }
  }

  // Hapus jadwal
  Future<void> deleteSchedule(String id) async {
    try {
      await _dbService.deleteSchedule(id);
      
      // PRODUCTION: Sync with API
      // await _apiService.deleteSchedule(id);

      await loadSchedules();
    } catch (e) {
      _errorMessage = 'Failed to delete schedule: $e';
      notifyListeners();
    }
  }

  // Reschedule - ubah waktu jadwal
  Future<void> reschedule(String scheduleId, TimeOfDay newStartTime, TimeOfDay newEndTime) async {
    try {
      final index = _schedules.indexWhere((s) => s.id == scheduleId);
      if (index != -1) {
        final updated = _schedules[index].copyWith(
          startTime: newStartTime,
          endTime: newEndTime,
        );
        await updateSchedule(updated);
      }
    } catch (e) {
      _errorMessage = 'Failed to reschedule: $e';
      notifyListeners();
    }
  }

  // Pindah jadwal ke tanggal lain
  Future<void> moveToDate(String scheduleId, DateTime newDate) async {
    try {
      final index = _schedules.indexWhere((s) => s.id == scheduleId);
      if (index != -1) {
        final updated = _schedules[index].copyWith(date: newDate);
        await updateSchedule(updated);
      }
    } catch (e) {
      _errorMessage = 'Failed to move schedule: $e';
      notifyListeners();
    }
  }

  // Deteksi semua konflik
  List<ScheduleConflict> _detectAllConflicts() {
    final conflicts = <ScheduleConflict>[];
    final processed = <String>{};

    for (int i = 0; i < _schedules.length; i++) {
      for (int j = i + 1; j < _schedules.length; j++) {
        final s1 = _schedules[i];
        final s2 = _schedules[j];

        if (s1.conflictsWith(s2)) {
          final conflictId = '${s1.id}-${s2.id}';
          if (!processed.contains(conflictId)) {
            processed.add(conflictId);
            conflicts.add(ScheduleConflict(
              id: conflictId,
              schedule1: s1,
              schedule2: s2,
              date: s1.date,
            ));
          }
        }
      }
    }

    return conflicts;
  }

  // Update status konflik pada setiap jadwal
  void _updateConflictStatus() {
    // Reset semua status konflik
    for (int i = 0; i < _schedules.length; i++) {
      _schedules[i] = _schedules[i].copyWith(
        hasConflict: false,
        conflictWith: null,
      );
    }

    // Tandai jadwal yang konflik
    for (int i = 0; i < _schedules.length; i++) {
      for (int j = i + 1; j < _schedules.length; j++) {
        if (_schedules[i].conflictsWith(_schedules[j])) {
          _schedules[i] = _schedules[i].copyWith(
            hasConflict: true,
            conflictWith: _schedules[j].title,
          );
          _schedules[j] = _schedules[j].copyWith(
            hasConflict: true,
            conflictWith: _schedules[i].title,
          );
        }
      }
    }
  }

  // Cek apakah ada konflik pada tanggal tertentu
  bool hasConflictOnDate(DateTime date) {
    final daySchedules = getSchedulesForDate(date);
    for (int i = 0; i < daySchedules.length; i++) {
      for (int j = i + 1; j < daySchedules.length; j++) {
        if (daySchedules[i].conflictsWith(daySchedules[j])) {
          return true;
        }
      }
    }
    return false;
  }

  // Generate ID unik
  String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Cari slot waktu kosong pada tanggal tertentu
  List<TimeSlot> findAvailableSlots(DateTime date, int durationMinutes) {
    final daySchedules = getSchedulesForDate(date);
    final slots = <TimeSlot>[];

    // Jam operasional: 07:00 - 22:00
    const startOfDay = 7 * 60; // 07:00
    const endOfDay = 22 * 60; // 22:00

    if (daySchedules.isEmpty) {
      slots.add(TimeSlot(
        start: const TimeOfDay(hour: 7, minute: 0),
        end: const TimeOfDay(hour: 22, minute: 0),
      ));
      return slots;
    }

    // Sort by start time
    daySchedules.sort((a, b) => a.startMinutes.compareTo(b.startMinutes));

    // Cek slot sebelum jadwal pertama
    if (daySchedules.first.startMinutes - startOfDay >= durationMinutes) {
      slots.add(TimeSlot(
        start: const TimeOfDay(hour: 7, minute: 0),
        end: TimeOfDay(
          hour: daySchedules.first.startTime.hour,
          minute: daySchedules.first.startTime.minute,
        ),
      ));
    }

    // Cek slot antar jadwal
    for (int i = 0; i < daySchedules.length - 1; i++) {
      final gap = daySchedules[i + 1].startMinutes - daySchedules[i].endMinutes;
      if (gap >= durationMinutes) {
        slots.add(TimeSlot(
          start: daySchedules[i].endTime,
          end: daySchedules[i + 1].startTime,
        ));
      }
    }

    // Cek slot setelah jadwal terakhir
    if (endOfDay - daySchedules.last.endMinutes >= durationMinutes) {
      slots.add(TimeSlot(
        start: daySchedules.last.endTime,
        end: const TimeOfDay(hour: 22, minute: 0),
      ));
    }

    return slots;
  }
}

// Model untuk slot waktu kosong
class TimeSlot {
  final TimeOfDay start;
  final TimeOfDay end;

  TimeSlot({required this.start, required this.end});

  String get formatted {
    String format(TimeOfDay t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    return '${format(start)} - ${format(end)}';
  }
}