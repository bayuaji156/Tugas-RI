import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/schedule.dart';
import '../../providers/schedule_provider.dart';

class ScheduleSafeScreen extends StatefulWidget {
  const ScheduleSafeScreen({super.key});

  @override
  State<ScheduleSafeScreen> createState() => _ScheduleSafeScreenState();
}

class _ScheduleSafeScreenState extends State<ScheduleSafeScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Consumer<ScheduleProvider>(
      builder: (context, provider, child) {
        final conflicts = provider.conflicts;
        final todaySchedules = provider.getSchedulesForDate(_selectedDate);
        final hasConflictToday = provider.hasConflictOnDate(_selectedDate);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('ScheduleSafe'),
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pushReplacementNamed(context, '/main-menu'),
              tooltip: 'Kembali ke Menu',
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Selector
                _buildDateSelector(),
                const SizedBox(height: 16),

                // Conflict Summary Alert
                _buildConflictSummary(conflicts),
                const SizedBox(height: 24),

                // Conflict List Section
                if (conflicts.isNotEmpty) ...[
                  const Text(
                    'Daftar Konflik',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...conflicts.map((conflict) => _buildConflictCard(conflict, provider)),
                  const SizedBox(height: 24),
                ],

                // Today's Schedule Section
                _buildScheduleHeader(hasConflictToday),
                const SizedBox(height: 12),

                if (todaySchedules.isEmpty)
                  _buildEmptySchedule()
                else
                  ...todaySchedules.map((schedule) => _buildScheduleItem(schedule, provider)),

                const SizedBox(height: 24),

                // Refresh Button
                _buildRefreshButton(conflicts),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.subtract(const Duration(days: 1));
              });
            },
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _selectDate(context),
              child: Text(
                _formatDate(_selectedDate),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.add(const Duration(days: 1));
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildConflictSummary(List<ScheduleConflict> conflicts) {
    if (conflicts.isNotEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.error.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning_rounded, color: AppColors.error, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${conflicts.length} Konflik Terdeteksi!',
                    style: const TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Segera selesaikan konflik jadwal Anda',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.success.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: AppColors.success, size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tidak Ada Konflik',
                    style: TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Semua jadwal Anda aman',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildScheduleHeader(bool hasConflictToday) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Jadwal ${_isToday(_selectedDate) ? "Hari Ini" : _formatShortDate(_selectedDate)}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        if (hasConflictToday)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Ada Konflik',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptySchedule() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_available,
            size: 48,
            color: AppColors.textSecondary.withOpacity(0.3),
          ),
          const SizedBox(height: 12),
          Text(
            'Tidak ada jadwal',
            style: TextStyle(color: AppColors.textSecondary.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildRefreshButton(List<ScheduleConflict> conflicts) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                conflicts.isEmpty
                    ? 'Tidak ada konflik ditemukan'
                    : '${conflicts.length} konflik terdeteksi',
              ),
              backgroundColor: conflicts.isEmpty ? AppColors.success : AppColors.warning,
            ),
          );
        },
        icon: const Icon(Icons.refresh),
        label: const Text('Periksa Ulang Konflik'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Widget _buildConflictCard(ScheduleConflict conflict, ScheduleProvider provider) {
    return GestureDetector(
      onTap: () => _showConflictDetail(conflict, provider),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.error.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                const SizedBox(width: 8),
                Text(
                  conflict.formattedDate,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildConflictScheduleBox(
                    conflict.schedule1,
                    AppColors.error.withOpacity(0.1),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.compare_arrows, color: AppColors.error),
                ),
                Expanded(
                  child: _buildConflictScheduleBox(
                    conflict.schedule2,
                    AppColors.warning.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConflictScheduleBox(Schedule schedule, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            schedule.title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            schedule.timeRange,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(Schedule schedule, ScheduleProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: schedule.hasConflict
            ? Border.all(color: AppColors.error.withOpacity(0.5))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 50,
            decoration: BoxDecoration(
              color: schedule.hasConflict ? AppColors.error : AppColors.success,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schedule.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      schedule.timeRange,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                if (schedule.hasConflict && schedule.conflictWith != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Konflik: ${schedule.conflictWith}',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.error.withOpacity(0.8),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (schedule.hasConflict)
            IconButton(
              icon: const Icon(Icons.edit_calendar, color: AppColors.primary),
              onPressed: () => _showQuickReschedule(schedule, provider),
            ),
        ],
      ),
    );
  }

  void _showConflictDetail(ScheduleConflict conflict, ScheduleProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
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
              'Detail Konflik',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              conflict.formattedDate,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildDetailCard(conflict.schedule1, 'Jadwal 1', AppColors.error),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDetailCard(conflict.schedule2, 'Jadwal 2', AppColors.warning),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: AppColors.info, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Saran: Reschedule salah satu jadwal ke waktu berbeda.',
                      style: TextStyle(fontSize: 12, color: AppColors.info),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Biarkan'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showRescheduleDialog(conflict, provider);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                    child: const Text('Reschedule'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(Schedule schedule, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Text(
            schedule.title,
            style: const TextStyle(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            schedule.timeRange,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  void _showRescheduleDialog(ScheduleConflict conflict, ScheduleProvider provider) {
    Schedule? selectedSchedule = conflict.schedule1;
    TimeOfDay newStartTime = const TimeOfDay(hour: 13, minute: 0);
    TimeOfDay newEndTime = const TimeOfDay(hour: 15, minute: 0);
    final availableSlots = provider.findAvailableSlots(conflict.date, 60);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.65,
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
              const Text('Reschedule', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text('Pilih jadwal:', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              _buildOptionButton(
                conflict.schedule1.title,
                selectedSchedule?.id == conflict.schedule1.id,
                () => setModalState(() => selectedSchedule = conflict.schedule1),
              ),
              const SizedBox(height: 8),
              _buildOptionButton(
                conflict.schedule2.title,
                selectedSchedule?.id == conflict.schedule2.id,
                () => setModalState(() => selectedSchedule = conflict.schedule2),
              ),
              const SizedBox(height: 20),
              const Text('Slot Tersedia:', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              if (availableSlots.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: availableSlots.map((slot) {
                    final isSelected = newStartTime == slot.start;
                    return GestureDetector(
                      onTap: () {
                        setModalState(() {
                          newStartTime = slot.start;
                          final endMinutes = slot.start.hour * 60 + slot.start.minute + 120;
                          newEndTime = TimeOfDay(
                            hour: (endMinutes ~/ 60).clamp(0, 23),
                            minute: endMinutes % 60,
                          );
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : Colors.grey.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          slot.formatted,
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? AppColors.primary : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.w600 : null,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                )
              else
                const Text('Tidak ada slot tersedia', style: TextStyle(fontStyle: FontStyle.italic)),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedSchedule != null
                      ? () {
                          provider.reschedule(selectedSchedule!.id, newStartTime, newEndTime);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Jadwal berhasil di-reschedule!'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      : null,
                  child: const Text('Konfirmasi Reschedule'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQuickReschedule(Schedule schedule, ScheduleProvider provider) {
    TimeOfDay newStartTime = schedule.startTime;
    TimeOfDay newEndTime = schedule.endTime;
    final availableSlots = provider.findAvailableSlots(schedule.date, 60);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.5,
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
              Text('Reschedule: ${schedule.title}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Saat ini: ${schedule.timeRange}', style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 20),
              const Text('Pilih waktu baru:', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 12),
              if (availableSlots.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: availableSlots.map((slot) {
                    final isSelected = newStartTime == slot.start;
                    return GestureDetector(
                      onTap: () {
                        setModalState(() {
                          newStartTime = slot.start;
                          final duration = schedule.endMinutes - schedule.startMinutes;
                          final endMinutes = slot.start.hour * 60 + slot.start.minute + duration;
                          newEndTime = TimeOfDay(
                            hour: (endMinutes ~/ 60).clamp(0, 23),
                            minute: endMinutes % 60,
                          );
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.withOpacity(0.3)),
                        ),
                        child: Text(
                          slot.formatted,
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? AppColors.primary : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.w600 : null,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                )
              else
                const Text('Tidak ada slot tersedia', style: TextStyle(fontStyle: FontStyle.italic)),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    provider.reschedule(schedule.id, newStartTime, newEndTime);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Berhasil di-reschedule!'), backgroundColor: AppColors.success),
                    );
                  },
                  child: const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton(String title, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.textSecondary.withOpacity(0.3),
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: selected ? AppColors.primary.withOpacity(0.05) : null,
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.primary : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    const months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    return '${days[date.weekday % 7]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatShortDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${date.day} ${months[date.month - 1]}';
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
}