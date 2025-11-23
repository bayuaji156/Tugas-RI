import 'package:flutter/material.dart';

class Schedule {
  final String id;
  final String title;
  final String? description;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String? location;
  final int? reminderMinutes;
  bool hasConflict;
  String? conflictWith;

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

  // Format waktu ke string
  String get timeRange {
    String format(TimeOfDay t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    return '${format(startTime)} - ${format(endTime)}';
  }

  String get startTimeString {
    return '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
  }

  String get endTimeString {
    return '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
  }

  // Konversi waktu ke menit untuk perbandingan
  int get startMinutes => startTime.hour * 60 + startTime.minute;
  int get endMinutes => endTime.hour * 60 + endTime.minute;

  // Cek apakah jadwal ini konflik dengan jadwal lain
  bool conflictsWith(Schedule other) {
    // Harus di tanggal yang sama
    if (date.year != other.date.year ||
        date.month != other.date.month ||
        date.day != other.date.day) {
      return false;
    }
    
    // Jangan cek dengan diri sendiri
    if (id == other.id) return false;

    // Cek overlap waktu
    return (startMinutes < other.endMinutes && endMinutes > other.startMinutes);
  }

  // Format tanggal
  String get formattedDate {
    const days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${days[date.weekday % 7]}, ${date.day} ${months[date.month - 1]} ${date.year}';
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

// Model untuk menyimpan data konflik
class ScheduleConflict {
  final String id;
  final Schedule schedule1;
  final Schedule schedule2;
  final DateTime date;

  ScheduleConflict({
    required this.id,
    required this.schedule1,
    required this.schedule2,
    required this.date,
  });

  String get formattedDate {
    const days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${days[date.weekday % 7]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }
}