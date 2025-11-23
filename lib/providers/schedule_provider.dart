import 'package:flutter/material.dart';
import '../models/schedule.dart';

class ScheduleProvider extends ChangeNotifier {
  // Daftar semua jadwal
  final List<Schedule> _schedules = [];

  // Getter untuk semua jadwal
  List<Schedule> get schedules => List.unmodifiable(_schedules);

  // Getter untuk semua konflik yang terdeteksi
  List<ScheduleConflict> get conflicts => _detectAllConflicts();

  // Inisialisasi dengan data sample (opsional)
  ScheduleProvider() {
    // Tambahkan sample data untuk testing
    _addSampleData();
  }

  void _addSampleData() {
    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));

    _schedules.addAll([
      Schedule(
        id: '1',
        title: 'Kuliah Kalkulus',
        date: DateTime(today.year, today.month, today.day),
        startTime: const TimeOfDay(hour: 8, minute: 0),
        endTime: const TimeOfDay(hour: 10, minute: 0),
        location: 'Ruang 301',
      ),
      Schedule(
        id: '2',
        title: 'Praktikum Basis Data',
        date: DateTime(today.year, today.month, today.day),
        startTime: const TimeOfDay(hour: 9, minute: 30),
        endTime: const TimeOfDay(hour: 11, minute: 30),
        location: 'Lab Komputer',
      ),
      Schedule(
        id: '3',
        title: 'Rapat BEM',
        date: DateTime(today.year, today.month, today.day),
        startTime: const TimeOfDay(hour: 13, minute: 0),
        endTime: const TimeOfDay(hour: 15, minute: 0),
        location: 'Ruang Rapat',
      ),
      Schedule(
        id: '4',
        title: 'UTS Rekayasa Perangkat Lunak',
        date: DateTime(tomorrow.year, tomorrow.month, tomorrow.day),
        startTime: const TimeOfDay(hour: 8, minute: 0),
        endTime: const TimeOfDay(hour: 10, minute: 0),
        location: 'Gedung A',
      ),
      Schedule(
        id: '5',
        title: 'Seminar AI',
        date: DateTime(tomorrow.year, tomorrow.month, tomorrow.day),
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 11, minute: 0),
        location: 'Aula',
      ),
    ]);

    _updateConflictStatus();
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
  void addSchedule(Schedule schedule) {
    _schedules.add(schedule);
    _updateConflictStatus();
    notifyListeners();
  }

  // Update jadwal
  void updateSchedule(Schedule updatedSchedule) {
    final index = _schedules.indexWhere((s) => s.id == updatedSchedule.id);
    if (index != -1) {
      _schedules[index] = updatedSchedule;
      _updateConflictStatus();
      notifyListeners();
    }
  }

  // Hapus jadwal
  void deleteSchedule(String id) {
    _schedules.removeWhere((s) => s.id == id);
    _updateConflictStatus();
    notifyListeners();
  }

  // Reschedule - ubah waktu jadwal
  void reschedule(String scheduleId, TimeOfDay newStartTime, TimeOfDay newEndTime) {
    final index = _schedules.indexWhere((s) => s.id == scheduleId);
    if (index != -1) {
      _schedules[index] = _schedules[index].copyWith(
        startTime: newStartTime,
        endTime: newEndTime,
      );
      _updateConflictStatus();
      notifyListeners();
    }
  }

  // Pindah jadwal ke tanggal lain
  void moveToDate(String scheduleId, DateTime newDate) {
    final index = _schedules.indexWhere((s) => s.id == scheduleId);
    if (index != -1) {
      _schedules[index] = _schedules[index].copyWith(date: newDate);
      _updateConflictStatus();
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