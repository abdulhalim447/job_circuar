import 'package:flutter/material.dart';

class AgeCalculatorApp extends StatelessWidget {
  const AgeCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Age Calculator',
      color: Colors.green,
      theme: ThemeData(
        fontFamily: 'Arial',
        scaffoldBackgroundColor: const Color(0xFFF0F4F8),
      ),
      home: const AgeCalculatorScreen(),
    );
  }
}

class AgeCalculatorScreen extends StatefulWidget {
  const AgeCalculatorScreen({super.key});

  @override
  State<AgeCalculatorScreen> createState() => _AgeCalculatorScreenState();
}

class _AgeCalculatorScreenState extends State<AgeCalculatorScreen> {
  // Constants
  final List<int> days = List.generate(31, (index) => index + 1);
  final List<String> months = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
  ];
  late final List<int> years;

  // State Variables
  int? dobDay;
  int? dobMonth;
  int? dobYear;

  late int findDay;
  late int findMonth;
  late int findYear;

  // Results
  bool showResult = false;
  String errorMessage = "";

  int ageYears = 0, ageMonths = 0, ageDays = 0;
  int totalMonths = 0, totalWeeks = 0, totalDays = 0;
  int totalHours = 0, totalMinutes = 0, totalSeconds = 0;

  int nbMonths = 0, nbRemainingDays = 0;
  String nextBdayDayOfWeek = "";
  String nextBdayStr = "";

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    findDay = now.day;
    findMonth = now.month;
    findYear = now.year;

    // Generate years (1900 to currentYear)
    years = List.generate(now.year - 1900 + 1, (index) => now.year - index);
  }

  void _calculateAge() {
    if (dobDay == null || dobMonth == null || dobYear == null) {
      setState(() {
        errorMessage = "Please select all dates.";
        showResult = false;
      });
      return;
    }

    DateTime dob = DateTime(dobYear!, dobMonth!, dobDay!);
    DateTime today = DateTime(findYear, findMonth, findDay);

    if (dob.isAfter(today)) {
      setState(() {
        errorMessage = "Date of Birth cannot be after 'Find Age on' date.";
        showResult = false;
      });
      return;
    }

    // Logic equivalent to the JS implementation
    int calcYears = today.year - dob.year;
    int calcMonths = today.month - dob.month;
    int calcDays = today.day - dob.day;

    if (calcDays < 0) {
      calcMonths--;
      // Get days in the previous month
      int prevMonth = today.month - 1;
      int prevYear = today.year;
      if (prevMonth == 0) {
        prevMonth = 12;
        prevYear--;
      }
      calcDays += DateTime(prevYear, prevMonth + 1, 0).day;
    }

    if (calcMonths < 0) {
      calcYears--;
      calcMonths += 12;
    }

    // Calculate Totals
    final duration = today.difference(dob);
    final tDays = duration.inDays;

    // Next Birthday Logic
    DateTime nextBday = DateTime(today.year, dob.month, dob.day);
    if (nextBday.isBefore(today)) {
      nextBday = DateTime(today.year + 1, dob.month, dob.day);
    }
    final diffNextBday = nextBday.difference(today).inDays;

    final weekdays = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday",
    ];

    setState(() {
      errorMessage = "";
      ageYears = calcYears;
      ageMonths = calcMonths;
      ageDays = calcDays;

      totalMonths = (ageYears * 12) + ageMonths;
      totalDays = tDays;
      totalWeeks = tDays ~/ 7;
      totalHours = tDays * 24;
      totalMinutes = totalHours * 60;
      totalSeconds = totalMinutes * 60;

      nbMonths = diffNextBday ~/ 30;
      nbRemainingDays = diffNextBday % 30;
      nextBdayDayOfWeek = weekdays[nextBday.weekday - 1];
      nextBdayStr =
          "${nextBday.month}/${nextBday.day}/${nextBday.year}"; // Basic format

      showResult = true;
    });
  }

  void _resetForm() {
    final now = DateTime.now();
    setState(() {
      dobDay = null;
      dobMonth = null;
      dobYear = null;

      findDay = now.day;
      findMonth = now.month;
      findYear = now.year;

      showResult = false;
      errorMessage = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: const Text("", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: double.infinity,
            // maxWidth: 500,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Center(
                  child: Text(
                    "Age Calculator",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1C1C1C),
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                _buildLabel("Date of Birth:"),
                _buildDropdownRow(
                  dayValue: dobDay,
                  monthValue: dobMonth,
                  yearValue: dobYear,
                  onDayChanged: (v) => setState(() => dobDay = v),
                  onMonthChanged: (v) => setState(() => dobMonth = v),
                  onYearChanged: (v) => setState(() => dobYear = v),
                ),

                const SizedBox(height: 20),

                _buildLabel("Find Age on:"),
                _buildDropdownRow(
                  dayValue: findDay,
                  monthValue: findMonth,
                  yearValue: findYear,
                  onDayChanged: (v) => setState(() => findDay = v!),
                  onMonthChanged: (v) => setState(() => findMonth = v!),
                  onYearChanged: (v) => setState(() => findYear = v!),
                ),

                const SizedBox(height: 25),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed: _calculateAge,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF22C55E),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Calculate",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _resetForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF60A5FA),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Reset",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                if (errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Center(
                      child: Text(
                        errorMessage,
                        style: const TextStyle(
                          color: Color(0xFFE74C3C),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                if (showResult) _buildResultSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildDropdownRow({
    required int? dayValue,
    required int? monthValue,
    required int? yearValue,
    required ValueChanged<int?> onDayChanged,
    required ValueChanged<int?> onMonthChanged,
    required ValueChanged<int?> onYearChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildDropdown(
            value: dayValue,
            items: days
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(e.toString().padLeft(2, '0')),
                  ),
                )
                .toList(),
            hint: "DD",
            onChanged: onDayChanged,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildDropdown(
            value: monthValue,
            items: List.generate(
              12,
              (index) => DropdownMenuItem(
                value: index + 1,
                child: Text(months[index]),
              ),
            ),
            hint: "MM",
            onChanged: onMonthChanged,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildDropdown(
            value: yearValue,
            items: years
                .map(
                  (e) => DropdownMenuItem(value: e, child: Text(e.toString())),
                )
                .toList(),
            hint: "YYYY",
            onChanged: onYearChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required int? value,
    required List<DropdownMenuItem<int>> items,
    required String hint,
    required ValueChanged<int?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFDCDCDC)),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: value,
          hint: Text(hint, style: const TextStyle(fontSize: 14)),
          isExpanded: true,
          items: items,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
        ),
      ),
    );
  }

  Widget _buildResultSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSummaryBox(
                  ageYears.toString(),
                  "Years",
                  const Color(0xFF000066),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSummaryBox(
                  ageMonths.toString(),
                  "Months",
                  const Color(0xFF005510),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSummaryBox(
                  ageDays.toString(),
                  "Days",
                  const Color(0xFF6600CC),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailText("Total Months:", totalMonths.toString()),
                _buildDetailText("Total Weeks:", totalWeeks.toString()),
                _buildDetailText("Total Days:", totalDays.toString()),
                _buildDetailText("Total Hours:", _formatNumber(totalHours)),
                _buildDetailText("Total Minutes:", _formatNumber(totalMinutes)),
                _buildDetailText("Total Seconds:", _formatNumber(totalSeconds)),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F0FC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    const Text(
                      "Next Birthday in:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    _buildPill("$nbMonths Months"),
                    _buildPill("$nbRemainingDays Days"),
                  ],
                ),
                const SizedBox(height: 10),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black, fontSize: 14),
                    children: [
                      TextSpan(
                        text: "Your next birthday ($nextBdayStr) is on ",
                      ),
                      TextSpan(
                        text: nextBdayDayOfWeek,
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(text: "."),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBox(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailText(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Color(0xFF333333), fontSize: 14),
          children: [
            TextSpan(
              text: "$title ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _buildPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF3071D2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  // Helper function to format large numbers with commas
  String _formatNumber(int number) {
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String Function(Match) mathFunc = (Match match) => '${match[1]},';
    return number.toString().replaceAllMapped(reg, mathFunc);
  }
}
