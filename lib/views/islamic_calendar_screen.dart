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

  @override
  void initState() {
    super.initState();
  }

  // Helper method to get Hijri date from Gregorian
  Map<String, int> _getHijriDate(DateTime date) {
    final hijri = HijriCalendar.fromDate(date);
    return {'year': hijri.hYear, 'month': hijri.hMonth, 'day': hijri.hDay};
  }

  // Check if a date has Islamic events
  List<Map<String, dynamic>> _getEventsForDate(DateTime date) {
    final hijri = HijriCalendar.fromDate(date);
    final key = '${hijri.hDay}-${hijri.hMonth}';

    if (_islamicEvents.containsKey(key)) {
      return [_islamicEvents[key]!];
    }
    return [];
  }

  // Get event color for date
  Color? _getEventColor(DateTime date) {
    final events = _getEventsForDate(date);
    if (events.isNotEmpty) {
      return events.first['color'] as Color?;
    }
    return null;
  }

  // Hijri months names
  final List<String> _hijriMonths = [
    'Muharram',
    'Safar',
    'Rabi\' al-awwal',
    'Rabi\' al-thani',
    'Jumada al-awwal',
    'Jumada al-thani',
    'Rajab',
    'Sha\'ban',
    'Ramadan',
    'Shawwal',
    'Dhu al-Qi\'dah',
    'Dhu al-Hijjah',
  ];

  // Islamic events - using Hijri dates
  final Map<String, Map<String, dynamic>> _islamicEvents = {
    // Muharram Events
    '1-1': {
      'name': 'Islamic New Year (Hijri New Year)',
      'color': const Color(0xFF1B5E20),
      'description': 'The beginning of the Islamic lunar year',
    },
    '10-1': {
      'name': 'Day of Ashura',
      'color': const Color(0xFF8B0000),
      'description': 'Day of fasting and remembrance',
    },
    // Rabi' al-awwal Events
    '12-3': {
      'name': 'Mawlid al-Nabi (Prophet\'s Birthday)',
      'color': const Color(0xFF4CAF50),
      'description': 'Birthday of Prophet Muhammad (PBUH)',
    },
    // Rajab Events
    '27-7': {
      'name': 'Isra and Mi\'raj',
      'color': const Color(0xFF9C27B0),
      'description': 'Night Journey and Ascension of the Prophet',
    },
    // Sha'ban Events
    '15-8': {
      'name': 'Laylat al-Bara\'at (Night of Forgiveness)',
      'color': const Color(0xFF3F51B5),
      'description': 'Night of seeking forgiveness and blessings',
    },
    // Ramadan Events
    '1-9': {
      'name': 'First Day of Ramadan',
      'color': const Color(0xFFFF5722),
      'description': 'Beginning of the holy month of fasting',
    },
    '21-9': {
      'name': 'Laylat al-Qadr (Night of Power)',
      'color': const Color(0xFFFFD700),
      'description': 'The most blessed night of the year',
    },
    '27-9': {
      'name': 'Possible Laylat al-Qadr',
      'color': const Color(0xFFFFC107),
      'description': 'One of the odd nights when Laylat al-Qadr may occur',
    },
    // Shawwal Events
    '1-10': {
      'name': 'Eid al-Fitr',
      'color': const Color(0xFF4CAF50),
      'description': 'Festival of Breaking the Fast',
    },
    // Dhu al-Hijjah Events
    '8-12': {
      'name': 'Tarwiyah Day',
      'color': const Color(0xFF795548),
      'description': 'Pilgrims travel to Mina',
    },
    '9-12': {
      'name': 'Day of Arafah',
      'color': const Color(0xFF607D8B),
      'description': 'The most important day of Hajj',
    },
    '10-12': {
      'name': 'Eid al-Adha',
      'color': const Color(0xFF4CAF50),
      'description': 'Festival of Sacrifice',
    },
  };

  Color get primary => const Color(0xFF1B5E20);

  @override
  Widget build(BuildContext context) {
    final hijriDate = _getHijriDate(_selectedDate);
    final hijriMonthName = _hijriMonths[hijriDate['month']! - 1];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primary,
        title: Text(
          'Islamic Calendar',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // Current Hijri Date Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primary, primary.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Today\'s Hijri Date',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${hijriDate['day']} $hijriMonthName ${hijriDate['year']} AH',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.white.withOpacity(0.8)),
                ),
              ],
            ),
          ),

          // Calendar Widget with Event Highlighting
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Enhanced Calendar with TableCalendar
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
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

                      // Calendar Styling
                      calendarStyle: CalendarStyle(
                        outsideDaysVisible: false,

                        // Default day text styling - make dates black
                        defaultTextStyle: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),

                        // Weekend styling
                        weekendTextStyle: TextStyle(
                          color: Colors.red[600],
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),

                        // Holiday styling
                        holidayTextStyle: TextStyle(
                          color: Colors.blue[600],
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),

                        // Event marker styling
                        markersMaxCount: 1,
                        markerDecoration: BoxDecoration(color: primary, shape: BoxShape.circle),

                        // Selected day styling
                        selectedDecoration: BoxDecoration(color: primary, shape: BoxShape.circle),
                        selectedTextStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),

                        // Today styling
                        todayDecoration: BoxDecoration(
                          color: primary.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        todayTextStyle: TextStyle(
                          color: primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      // Header styling
                      headerStyle: HeaderStyle(
                        formatButtonVisible: true,
                        titleCentered: true,
                        formatButtonShowsNext: false,
                        headerPadding: const EdgeInsets.symmetric(vertical: 8),
                        formatButtonDecoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        formatButtonTextStyle: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        leftChevronIcon: Icon(Icons.chevron_left, color: primary, size: 28),
                        rightChevronIcon: Icon(Icons.chevron_right, color: primary, size: 28),
                        titleTextStyle: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),

                      // Days of week styling
                      daysOfWeekStyle: DaysOfWeekStyle(
                        weekdayStyle: GoogleFonts.poppins(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        weekendStyle: GoogleFonts.poppins(
                          color: Colors.red[600],
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),

                      // Day builder with event highlighting
                      calendarBuilders: CalendarBuilders(
                        defaultBuilder: (context, day, focusedDay) {
                          final eventColor = _getEventColor(day);
                          if (eventColor != null) {
                            // Check if it's a weekend day
                            final isWeekend =
                                day.weekday == DateTime.saturday || day.weekday == DateTime.friday;

                            return Container(
                              margin: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: eventColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: eventColor, width: 2),
                              ),
                              child: Center(
                                child: Text(
                                  '${day.day}',
                                  style: TextStyle(
                                    color: isWeekend ? Colors.red[700] : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            );
                          }
                          return null;
                        },
                      ),

                      // Selected day callback
                      selectedDayPredicate: (day) {
                        return isSameDay(_selectedDate, day);
                      },

                      onDaySelected: (selectedDay, focusedDay) {
                        if (!isSameDay(_selectedDate, selectedDay)) {
                          setState(() {
                            _selectedDate = selectedDay;
                            _focusedDate = focusedDay;
                          });

                          // Show event details if selected day has events
                          final events = _getEventsForDate(selectedDay);
                          if (events.isNotEmpty) {
                            _showEventDialog(events.first);
                          }
                        }
                      },

                      onFormatChanged: (format) {
                        if (_calendarFormat != format) {
                          setState(() {
                            _calendarFormat = format;
                          });
                        }
                      },

                      onPageChanged: (focusedDay) {
                        setState(() {
                          _focusedDate = focusedDay;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Selected Date Events
                  if (_getEventsForDate(_selectedDate).isNotEmpty) ...[
                    Text(
                      'Events on Selected Date',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._getEventsForDate(_selectedDate).map((event) => _buildEventCard(event)),
                    const SizedBox(height: 24),
                  ],

                  // Upcoming Events Section
                  Text(
                    'Upcoming Islamic Events',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: primary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Events List
                  ...(_getUpcomingEvents().map((event) => _buildUpcomingEventCard(event))),

                  const SizedBox(height: 24),

                  // Hijri Months Grid
                  Text(
                    'Hijri Months',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: primary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _hijriMonths.length,
                    itemBuilder: (context, index) {
                      final isCurrentMonth = index == (hijriDate['month']! - 1);
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isCurrentMonth ? primary.withOpacity(0.1) : Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isCurrentMonth ? primary : Colors.grey[300]!,
                            width: isCurrentMonth ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}. ${_hijriMonths[index]}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: isCurrentMonth ? FontWeight.w600 : FontWeight.w500,
                              color: isCurrentMonth ? primary : Colors.grey[700],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Event Dialog
  void _showEventDialog(Map<String, dynamic> event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          event['name'],
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: primary),
        ),
        content: Text(event['description'], style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close', style: TextStyle(color: primary)),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // Event Card Widget for specific date events
  Widget _buildEventCard(Map<String, dynamic> event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: event['color']),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: (event['color'] as Color).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.event, color: event['color'], size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['name'],
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event['description'],
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Upcoming Event Card Widget
  Widget _buildUpcomingEventCard(Map<String, String> event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.event, color: primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['name']!,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event['date']!,
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Get upcoming events
  List<Map<String, String>> _getUpcomingEvents() {
    return [
      {'name': 'Laylat al-Qadr (Night of Power)', 'date': '27th Ramadan'},
      {'name': 'Eid al-Fitr', 'date': '1st Shawwal'},
      {'name': 'Day of Arafah', 'date': '9th Dhu al-Hijjah'},
      {'name': 'Eid al-Adha', 'date': '10th Dhu al-Hijjah'},
    ];
  }
}
