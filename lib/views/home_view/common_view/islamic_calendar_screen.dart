import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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

  // App theme colors - Purple palette matching the app
  static const Color primary = Color(0xFF8F66FF);
  static const Color darkPurple = Color(0xFF2D1B69);
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color moonWhite = Color(0xFFF8F4E9);
  static const Color darkBg = Color(0xFF1A1A2E);
  static const Color cardBg = Color(0xFF2A2A3E);

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

  // Islamic events - using Hijri dates with app colors
  final Map<String, Map<String, dynamic>> _islamicEvents = {
    '1-1': {
      'name': 'Islamic New Year',
      'color': primary,
      'description': 'The beginning of the Islamic lunar year',
    },
    '10-1': {
      'name': 'Day of Ashura',
      'color': const Color(0xFF8B4789),
      'description': 'Day of fasting and remembrance',
    },
    '12-3': {
      'name': 'Mawlid al-Nabi',
      'color': goldAccent,
      'description': 'Birthday of Prophet Muhammad (PBUH)',
    },
    '27-7': {
      'name': 'Isra and Mi\'raj',
      'color': primary,
      'description': 'Night Journey and Ascension',
    },
    '15-8': {
      'name': 'Laylat al-Bara\'at',
      'color': darkPurple,
      'description': 'Night of Forgiveness',
    },
    '1-9': {
      'name': 'First Day of Ramadan',
      'color': primary,
      'description': 'Beginning of the holy month',
    },
    '21-9': {'name': 'Laylat al-Qadr', 'color': goldAccent, 'description': 'The Night of Power'},
    '27-9': {
      'name': 'Possible Laylat al-Qadr',
      'color': const Color(0xFFE6B84D),
      'description': 'One of the odd nights',
    },
    '1-10': {
      'name': 'Eid al-Fitr',
      'color': goldAccent,
      'description': 'Festival of Breaking the Fast',
    },
    '9-12': {
      'name': 'Day of Arafah',
      'color': primary,
      'description': 'The most important day of Hajj',
    },
    '10-12': {'name': 'Eid al-Adha', 'color': goldAccent, 'description': 'Festival of Sacrifice'},
  };

  @override
  Widget build(BuildContext context) {
    final hijriDate = _getHijriDate(_selectedDate);
    final hijriMonthName = _hijriMonths[hijriDate['month']! - 1];

    return Scaffold(
      backgroundColor: darkBg,
      body: CustomScrollView(
        slivers: [
          // Beautiful App Bar
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            backgroundColor: darkPurple,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: moonWhite.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back, color: moonWhite, size: 20),
              ),
              onPressed: () => Get.back(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [darkPurple, primary.withOpacity(0.8), darkPurple],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: goldAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: goldAccent.withOpacity(0.5), width: 2),
                          ),
                          child: Icon(Icons.calendar_month, color: goldAccent, size: 28),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Islamic Calendar',
                              style: GoogleFonts.cinzel(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: moonWhite,
                                letterSpacing: 1,
                              ),
                            ),
                            Text(
                              'Hijri & Gregorian Dates',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: moonWhite.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Current Hijri Date Card
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primary.withOpacity(0.8), darkPurple],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: goldAccent.withOpacity(0.3), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, goldAccent, Colors.transparent],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Today\'s Hijri Date',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: moonWhite.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: moonWhite.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: goldAccent.withOpacity(0.3)),
                    ),
                    child: Text(
                      '${hijriDate['day']} $hijriMonthName ${hijriDate['year']} AH',
                      style: GoogleFonts.cinzel(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: goldAccent,
                        letterSpacing: 1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today, color: moonWhite.withOpacity(0.6), size: 14),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
                        style: GoogleFonts.poppins(fontSize: 13, color: moonWhite.withOpacity(0.7)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, goldAccent, Colors.transparent],
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0),
          ),

          // Calendar Section
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: primary.withOpacity(0.3), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
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
                  defaultTextStyle: TextStyle(
                    color: moonWhite,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  weekendTextStyle: TextStyle(
                    color: goldAccent.withOpacity(0.8),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  markersMaxCount: 1,
                  markerDecoration: BoxDecoration(color: goldAccent, shape: BoxShape.circle),
                  selectedDecoration: BoxDecoration(
                    gradient: LinearGradient(colors: [primary, primary.withOpacity(0.7)]),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: primary.withOpacity(0.5), blurRadius: 8, spreadRadius: 2),
                    ],
                  ),
                  selectedTextStyle: TextStyle(
                    color: moonWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  todayDecoration: BoxDecoration(
                    color: goldAccent.withOpacity(0.3),
                    shape: BoxShape.circle,
                    border: Border.all(color: goldAccent, width: 2),
                  ),
                  todayTextStyle: TextStyle(
                    color: goldAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: true,
                  titleCentered: true,
                  formatButtonShowsNext: false,
                  headerPadding: const EdgeInsets.symmetric(vertical: 12),
                  formatButtonDecoration: BoxDecoration(
                    gradient: LinearGradient(colors: [primary, primary.withOpacity(0.7)]),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: goldAccent.withOpacity(0.3)),
                  ),
                  formatButtonTextStyle: GoogleFonts.poppins(
                    color: moonWhite,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  leftChevronIcon: Icon(Icons.chevron_left, color: goldAccent, size: 28),
                  rightChevronIcon: Icon(Icons.chevron_right, color: goldAccent, size: 28),
                  titleTextStyle: GoogleFonts.cinzel(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: moonWhite,
                    letterSpacing: 1,
                  ),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: GoogleFonts.poppins(
                    color: moonWhite.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  weekendStyle: GoogleFonts.poppins(
                    color: goldAccent.withOpacity(0.8),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    final eventColor = _getEventColor(day);
                    if (eventColor != null) {
                      final isWeekend =
                          day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;
                      return Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [eventColor.withOpacity(0.3), eventColor.withOpacity(0.1)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: eventColor, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: eventColor.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '${day.day}',
                            style: GoogleFonts.poppins(
                              color: isWeekend ? goldAccent : moonWhite,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
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
                onPageChanged: (focusedDay) {
                  setState(() => _focusedDate = focusedDay);
                },
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Upcoming Events
          if (_getUpcomingEvents().isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Row(
                  children: [
                    Icon(Icons.star, color: goldAccent, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Upcoming Islamic Events',
                      style: GoogleFonts.cinzel(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: moonWhite,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ..._getUpcomingEvents().map(
              (event) => SliverToBoxAdapter(child: _buildEventCard(event)),
            ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Hijri Months
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                children: [
                  Icon(Icons.calendar_view_month, color: goldAccent, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Hijri Months',
                    style: GoogleFonts.cinzel(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: moonWhite,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final isCurrentMonth = index == (hijriDate['month']! - 1);
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: isCurrentMonth
                        ? LinearGradient(
                            colors: [primary.withOpacity(0.6), darkPurple.withOpacity(0.8)],
                          )
                        : null,
                    color: isCurrentMonth ? null : cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isCurrentMonth ? goldAccent : primary.withOpacity(0.3),
                      width: isCurrentMonth ? 2 : 1,
                    ),
                    boxShadow: isCurrentMonth
                        ? [
                            BoxShadow(
                              color: primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}. ${_hijriMonths[index]}',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: isCurrentMonth ? FontWeight.w600 : FontWeight.w500,
                        color: isCurrentMonth ? goldAccent : moonWhite.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: (index * 50).ms);
              }, childCount: _hijriMonths.length),
            ),
          ),
        ],
      ),
    );
  }

  void _showEventDialog(Map<String, dynamic> event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: goldAccent.withOpacity(0.3), width: 2),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [(event['color'] as Color).withOpacity(0.3), Colors.transparent],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.event, color: event['color'], size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                event['name'],
                style: GoogleFonts.cinzel(
                  fontWeight: FontWeight.w600,
                  color: moonWhite,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          event['description'],
          style: GoogleFonts.poppins(color: moonWhite.withOpacity(0.8), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              backgroundColor: primary.withOpacity(0.2),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Close',
              style: TextStyle(color: goldAccent, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Map<String, String> event) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primary.withOpacity(0.2), cardBg],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primary.withOpacity(0.3), darkPurple.withOpacity(0.5)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: goldAccent.withOpacity(0.3), width: 2),
            ),
            child: Icon(Icons.star, color: goldAccent, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['name']!,
                  style: GoogleFonts.cinzel(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: moonWhite,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: goldAccent.withOpacity(0.7), size: 14),
                    const SizedBox(width: 6),
                    Text(
                      event['date']!,
                      style: GoogleFonts.poppins(fontSize: 12, color: moonWhite.withOpacity(0.7)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0);
  }

  List<Map<String, String>> _getUpcomingEvents() {
    return [
      {'name': 'Laylat al-Qadr (Night of Power)', 'date': '27th Ramadan'},
      {'name': 'Eid al-Fitr', 'date': '1st Shawwal'},
      {'name': 'Day of Arafah', 'date': '9th Dhu al-Hijjah'},
      {'name': 'Eid al-Adha', 'date': '10th Dhu al-Hijjah'},
    ];
  }
}
