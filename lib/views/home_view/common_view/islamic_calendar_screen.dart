import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class IslamicCalendarScreen extends StatefulWidget {
  const IslamicCalendarScreen({super.key});

  @override
  State<IslamicCalendarScreen> createState() => _IslamicCalendarScreenState();
}

class _IslamicCalendarScreenState extends State<IslamicCalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  // App theme colors - matching app design
  static const Color primaryPurple = Color(0xFF8F66FF);
  static const Color darkPurple = Color(0xFF2D1B69);
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color starWhite = Color(0xFFF8F4E9);

  // Hijri months names
  final List<String> _hijriMonths = [
    'Muharram',
    'Safar',
    'Rabi al-Awwal',
    'Rabi al-Thani',
    'Jumada al-Awwal',
    'Jumada al-Thani',
    'Rajab',
    'Sha\'ban',
    'Ramadan',
    'Shawwal',
    'Dhu al-Qi\'dah',
    'Dhu al-Hijjah',
  ];

  // Islamic events
  final Map<String, Map<String, dynamic>> _islamicEvents = {
    '1-1': {'name': 'Islamic New Year', 'color': primaryPurple},
    '10-1': {'name': 'Day of Ashura', 'color': const Color(0xFF8B4789)},
    '12-3': {'name': 'Mawlid al-Nabi', 'color': goldAccent},
    '27-7': {'name': 'Isra and Mi\'raj', 'color': primaryPurple},
    '15-8': {'name': 'Laylat al-Bara\'at', 'color': darkPurple},
    '1-9': {'name': 'First Day of Ramadan', 'color': primaryPurple},
    '27-9': {'name': 'Laylat al-Qadr', 'color': goldAccent},
    '1-10': {'name': 'Eid al-Fitr', 'color': goldAccent},
    '9-12': {'name': 'Day of Arafah', 'color': primaryPurple},
    '10-12': {'name': 'Eid al-Adha', 'color': goldAccent},
  };

  Map<String, int> _getHijriDate(DateTime date) {
    final hijri = HijriCalendar.fromDate(date);
    return {'year': hijri.hYear, 'month': hijri.hMonth, 'day': hijri.hDay};
  }

  List<Map<String, dynamic>> _getEventsForDate(DateTime date) {
    final hijri = HijriCalendar.fromDate(date);
    final key = '${hijri.hDay}-${hijri.hMonth}';
    if (_islamicEvents.containsKey(key)) {
      return [_islamicEvents[key]!];
    }
    return [];
  }

  Color? _getEventColor(DateTime date) {
    final events = _getEventsForDate(date);
    if (events.isNotEmpty) return events.first['color'] as Color?;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final hijriDate = _getHijriDate(_selectedDate);
    final hijriMonthName = _hijriMonths[hijriDate['month']! - 1];

    return Scaffold(
      backgroundColor: starWhite,
      appBar: AppBar(
        backgroundColor: primaryPurple,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Islamic Calendar',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Hijri Date Card
            _buildHijriDateCard(hijriDate, hijriMonthName),

            // Calendar
            _buildCalendar(),

            // Hijri Months Grid
            _buildHijriMonthsSection(hijriDate),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHijriDateCard(Map<String, int> hijriDate, String hijriMonthName) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryPurple, darkPurple],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: goldAccent.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: primaryPurple.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Today\'s Hijri Date',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${hijriDate['day']} $hijriMonthName ${hijriDate['year']} AH',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: goldAccent,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryPurple.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TableCalendar<Map<String, dynamic>>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDate,
        calendarFormat: _calendarFormat,
        eventLoader: _getEventsForDate,
        startingDayOfWeek: StartingDayOfWeek.monday,
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          defaultTextStyle: GoogleFonts.poppins(
            color: Colors.grey[800],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          weekendTextStyle: GoogleFonts.poppins(
            color: primaryPurple,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          markersMaxCount: 1,
          markerDecoration: BoxDecoration(color: goldAccent, shape: BoxShape.circle),
          markerSize: 6,
          selectedDecoration: BoxDecoration(
            gradient: LinearGradient(colors: [primaryPurple, darkPurple]),
            shape: BoxShape.circle,
          ),
          selectedTextStyle: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          todayDecoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: primaryPurple, width: 2),
          ),
          todayTextStyle: GoogleFonts.poppins(
            color: primaryPurple,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: true,
          titleCentered: true,
          formatButtonShowsNext: false,
          headerPadding: const EdgeInsets.symmetric(vertical: 8),
          formatButtonDecoration: BoxDecoration(
            color: primaryPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: primaryPurple.withOpacity(0.3)),
          ),
          formatButtonTextStyle: GoogleFonts.poppins(
            color: primaryPurple,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          leftChevronIcon: Icon(Icons.chevron_left, color: primaryPurple, size: 26),
          rightChevronIcon: Icon(Icons.chevron_right, color: primaryPurple, size: 26),
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: GoogleFonts.poppins(
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          weekendStyle: GoogleFonts.poppins(
            color: primaryPurple.withOpacity(0.7),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            final eventColor = _getEventColor(day);
            if (eventColor != null) {
              return Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: eventColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: eventColor, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    '${day.day}',
                    style: GoogleFonts.poppins(
                      color: eventColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }
            return null;
          },
        ),
        selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
        onDaySelected: (selectedDay, focusedDay) {
          if (!isSameDay(_selectedDate, selectedDay)) {
            setState(() {
              _selectedDate = selectedDay;
              _focusedDate = focusedDay;
            });
            final events = _getEventsForDate(selectedDay);
            if (events.isNotEmpty) {
              _showEventDialog(events.first);
            }
          }
        },
        onFormatChanged: (format) {
          if (_calendarFormat != format) {
            setState(() => _calendarFormat = format);
          }
        },
        onPageChanged: (focusedDay) => setState(() => _focusedDate = focusedDay),
      ),
    );
  }

  Widget _buildHijriMonthsSection(Map<String, int> hijriDate) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_view_month, color: goldAccent, size: 20),
              const SizedBox(width: 8),
              Text(
                'Hijri Months',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2.5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _hijriMonths.length,
            itemBuilder: (context, index) {
              final isCurrentMonth = index == (hijriDate['month']! - 1);
              return Container(
                decoration: BoxDecoration(
                  gradient: isCurrentMonth
                      ? LinearGradient(colors: [primaryPurple, darkPurple])
                      : null,
                  color: isCurrentMonth ? null : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCurrentMonth ? goldAccent : primaryPurple.withOpacity(0.2),
                    width: isCurrentMonth ? 1.5 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isCurrentMonth
                          ? primaryPurple.withOpacity(0.2)
                          : Colors.black.withOpacity(0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _hijriMonths[index],
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: isCurrentMonth ? FontWeight.w600 : FontWeight.w500,
                      color: isCurrentMonth ? Colors.white : Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showEventDialog(Map<String, dynamic> event) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (event['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.event, color: event['color'], size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                event['name'],
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryPurple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            ),
            child: Text(
              'Close',
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
