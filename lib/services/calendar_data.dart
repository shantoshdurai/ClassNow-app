/// Academic Calendar data for 2026
/// This file contains official holidays, exam dates, and vacations.
class CalendarData {
  static const String academicYear = "2026";
  
  static const String calendarContext = """
=== ACADEMIC CALENDAR 2026 ===
Official Holidays and Key Dates for Dhanalakshmi Srinivasan University (DSU):

JANUARY 2026:
- Jan 1: New Year Holiday
- Jan 5: Reopening Day (Day 1)
- Jan 12 - Jan 18: Pongal Holidays (University Closed)
- Jan 19: Commencement of 1st Year - 2nd Semester (Day 7)
- Jan 25: Holiday (Sunday)
- Jan 26: Republic Day (Holiday)

FEBRUARY 2026:
- Feb 1: Thai Poosam (Holiday)
- Feb 25: CAT Exam-1 Starts (Day 36)

MARCH 2026:
- March 3: CAT Exam-1 Ends (Day 41)
- March 20 - March 22: Telugu New Year Holidays (University Closed)
- March 31: Mahavir Jayanti (Holiday)

APRIL 2026:
- April 2: CAT Exam-2 Starts (Day 62)
- April 3: Good Friday (Holiday)
- April 11: CAT Exam-2 Ends (Day 68)
- April 12 - April 22: Summer Vacation (University Closed)
- April 23: Election Holiday

MAY 2026:
- May 1: May Day (Holiday)
- May 13: Model Exam Starts (Day 83)
- May 20: Model Exam Ends (Day 89)
- May 25: University Practical Exams Start
- May 28: Bakrid (Holiday)
- May 31: University Practical Exams End

JUNE 2026:
- June 1: University Theory Exams Start
- June 29: Odd Semester Starts (Day 1)

INSTRUCTIONS FOR AI:
- Use this calendar to answer questions about holidays and "free periods".
- If a user asks "is tomorrow a holiday?", check this calendar against the current date.
- If a user asks about "free periods" or "leaves", remind them of upcoming holidays or vacations.
- For attendance calculations, if the period they are taking leave for includes these holidays, do NOT count those days as missed classes since there are no classes on holidays.
""";

  /// Returns the calendar context string
  static String getContext() => calendarContext;
}
