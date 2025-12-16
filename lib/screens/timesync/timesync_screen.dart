import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../config/theme.dart';
import '../../models/schedule.dart';
import '../../providers/schedule_provider.dart';

class TimeSyncScreen extends StatefulWidget {
  const TimeSyncScreen({super.key});

  @override
  State<TimeSyncScreen> createState() => _TimeSyncScreenState();
}

class _TimeSyncScreenState extends State<TimeSyncScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // 🔍 SEARCH CONTROLLER (FITUR BARU)
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ScheduleProvider>(
      builder: (context, provider, child) {
        // 🔍 FILTER JADWAL BERDASARKAN SEARCH
        final selectedDaySchedules = _selectedDay != null
            ? provider
                .getSchedulesForDate(_selectedDay!)
                .where((schedule) =>
                    schedule.title
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()))
                .toList()
            : <Schedule>[];

        final hasConflictToday = _selectedDay != null &&
            provider.hasConflictOnDate(_selectedDay!);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('TimeSync'),
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/main-menu'),
            ),
            actions: [
              if (provider.conflicts.isNotEmpty)
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.warning_amber_rounded),
                      onPressed: () =>
                          Navigator.pushNamed(context, '/schedule-safe'),
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
                          '${provider.conflicts.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          body: Column(
            children: [
              _buildMonthSelector(),
              _buildCalendar(provider),
              if (hasConflictToday) _buildConflictWarning(),
              Expanded(child: _buildScheduleList(selectedDaySchedules, provider)),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppColors.primary,
            onPressed: () => _showAddScheduleDialog(provider),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }

  // ================= UI SECTIONS =================

  Widget _buildMonthSelector() {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _getMonthYearText(_focusedDay),
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.white),
                onPressed: () => setState(() {
                  _focusedDay =
                      DateTime(_focusedDay.year, _focusedDay.month - 1);
                }),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.white),
                onPressed: () => setState(() {
                  _focusedDay =
                      DateTime(_focusedDay.year, _focusedDay.month + 1);
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(ScheduleProvider provider) {
    return Container(
      color: Colors.white,
      child: TableCalendar<Schedule>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onFormatChanged: (format) =>
            setState(() => _calendarFormat = format),
        onPageChanged: (focusedDay) => _focusedDay = focusedDay,
        eventLoader: (day) => provider.getSchedulesForDate(day),
        headerVisible: false,
      ),
    );
  }

  Widget _buildConflictWarning() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning, color: AppColors.error),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Ada konflik jadwal pada hari ini!',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleList(
      List<Schedule> schedules, ScheduleProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // 🔍 SEARCH BAR (FITUR BARU)
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() => _searchQuery = value);
            },
            decoration: InputDecoration(
              hintText: 'Cari jadwal...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: schedules.isNotEmpty
                ? ListView.builder(
                    itemCount: schedules.length,
                    itemBuilder: (context, index) =>
                        _buildScheduleCard(schedules[index], provider),
                  )
                : const Center(
                    child: Text(
                      'Tidak ada jadwal',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ================= HELPERS =================

  String _getMonthYearText(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  Widget _buildScheduleCard(Schedule schedule, ScheduleProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(schedule.title),
        subtitle: Text(schedule.timeRange),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              _showEditScheduleDialog(schedule, provider);
            } else {
              _showDeleteConfirmation(schedule, provider);
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(
              value: 'delete',
              child: Text('Hapus', style: TextStyle(color: AppColors.error)),
            ),
          ],
        ),
      ),
    );
  }

  // ================= DIALOGS =================

  void _showAddScheduleDialog(ScheduleProvider provider) {}
  void _showEditScheduleDialog(Schedule s, ScheduleProvider p) {}
  void _showDeleteConfirmation(Schedule s, ScheduleProvider p) {}
}
