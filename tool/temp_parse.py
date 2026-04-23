import json
import re

text = """
Class Room No: 701
08.30-09.20 09.20-10.10 10.10-11.00 11.00-11.15 11.15-12.05 12.05-12.55 12.55-01.25 01.25-02.15 02.15-03.05 03.05-03.20 03.20-04.10 04.10-05.00 05.00-05.50

MON 24MAT205 24AID502 24CSE407 24ECE305 HRDC
TUE 24ECE305 24OEC912 24CSE408 24MAC003
WED 24CSE303 24MAT205 24AID502 24CSE407 24ECE305
THU 24CSE407 24AID502 24OEC912 24CSE408 24MAT205
FRI 24CSE408 24CSE303 24MAC003 24MAT205 24OEC912

Order Course Code Credits Hours
X1 24MAT205 4 4
X2 24ECE305 3 3
X3 24CSE303 2 2
X4 24CSE407 3 3
X5 24CSE408 4 5
X6 24AID502 3 3
X7 24OEC912 3 3
X8 24MAC003 0 2

Total 22 Credits 25 Hours

Course Name – Name of the Faculty
24CSE408 Computational Intelligence – Dr. P. Thangavel / ASP / AIDS
Introduction to Computational Biology – Dr. M. Santhosh / AP / BTE
Environmental Science – Dr. Sharad Porwal / ASP / CHEM
Design Thinking – Mrs. Keerthanasri / AP / AIDS
Design and Analysis of Algorithms – Mr. Jeeva / AP / AIDS
Operating Systems – Mrs. N. Radha / AP / AIDS
Discrete Mathematics – Mrs. Jeraldine Ruby / AP / MATHS
Digital Electronics and Microprocessors – Dr. V. Ramya / AP / ECE

SCHOOL OF ENGINEERING AND TECHNOLOGY
B.Tech – Artificial Intelligence and Data Science
Academic Year 2025-2026 / Even Semester
II Year / IV Semester – Slot I
Section: 24AIDSA1

Class Room No: 702
08.30-09.20 09.20-10.10 10.10-11.00 11.00-11.15 11.15-12.05 12.05-12.55 12.55-01.25 01.25-02.15 02.15-03.05 03.05-03.20 03.20-04.10 04.10-05.00 05.00-05.50

MON 24ECE305 24CSE408 24OEC912 24MAT205 24CSE407
TUE 24CSE407 24MAC003 24CSE303 24AID502 24MAT205
WED HRDC 24ECE305 24OEC912 24CSE408 24AID502
THU 24CSE408 24MAT205 24ECE305 24CSE407 24AID502
FRI 24CSE303 24MAT205 24OEC912 24MAC003

Order Course Code Credits Hours
X1 24ECE305 3 3
X2 24CSE303 2 2
X3 24CSE407 3 3
X4 24CSE408 4 5
X5 24AID502 3 3
X6 24OEC912 3 3
X7 24MAC003 0 2
X8 24MAT205 4 4

Total 22 Credits 25 Hours

Course Name – Name of the Faculty
Discrete Mathematics – Mrs. Jeraldine Ruby / AP / MATHS
Digital Electronics and Microprocessors – Mrs. S. Anitha / AP / ECE
Design Thinking – Mrs. J. Siva Sangari / AP / AIDS
Environmental Science – Mr. P. Karthick Kannan / RS / CHEM
Introduction to Computational Biology – Ms. M. Kowsalya / AP / BTE
Design and Analysis of Algorithms – Mr. K. Jeeva / AP / AIDS
Operating Systems – Mr. J. Manivannan / AP / AIDS
Computational Intelligence – Ms. N. Pavithra / AP / AIDS

SCHOOL OF ENGINEERING AND TECHNOLOGY
Department of Artificial Intelligence and Data Science
Academic Year 2025-2026 / Even Semester
II Year / IV Semester – Slot I
Section: 24AIDSA2

Class Room No: 703
08.30-09.20 09.20-10.10 10.10-11.00 11.00-11.15 11.15-12.05 12.05-12.55 12.55-01.25 01.25-02.15 02.15-03.05 03.05-03.20 03.20-04.10 04.10-05.00 05.00-05.50

MON 24CSE303 24MAC003 24AID502 24CSE407 24MAT205
TUE 24CSE407 24MAT205 24OEC912 24CSE408 24ECE305
WED HRDC 24CSE303 24ECE305 24AID502
THU 24AID502 24CSE407 24MAT205 24OEC912 24CSE408
FRI 24OEC912 24CSE408 24ECE305 24MAC003 24MAT205

Order Course Code Credits Hours
X1 24CSE303 2 2
X2 24CSE407 3 3
X3 24CSE408 4 5
X4 24AID502 3 3
X5 24OEC912 3 3
X6 24MAC003 0 2
X7 24MAT205 4 4
X8 24ECE305 3 3

Total 22 Credits 25 Hours

Course Name – Name of the Faculty
24CSE408 Design Thinking – Dr. A. Justin Diraviam / Prof / AI&DS
Environmental Science – Dr. R. Elancheran / ASP / CHEM
Discrete Mathematics – Mrs. R. Priyadharshini / AP / Maths
Digital Electronics and Microprocessors – Mrs. K. Kalpana / AP / ECE
Operating Systems – Mr. J. Manivannan / AP / AIDS
Computational Intelligence – Ms. P. Sudha / AP / AIDS
Introduction to Computational Biology – Ms. M. Kowsalya / AP / BTE
Design and Analysis of Algorithms – Mrs. G. Mahalakshmi / AP / AIDS

SCHOOL OF ENGINEERING AND TECHNOLOGY
Department of Artificial Intelligence and Data Science
Academic Year 2025-2026 / Even Semester
II Year / IV Semester – Slot I
Section: 24AIDSA3

Class Room No: 704
08.30-09.20 09.20-10.10 10.10-11.00 11.00-11.15 11.15-12.05 12.05-12.55 12.55-01.25 01.25-02.15 02.15-03.05 03.05-03.20 03.20-04.10 04.10-05.00 05.00-05.50

MON 24CSE407 24MAT205 24OEC912 24CSE408 24ECE305
TUE 24CSE408 24MAC003 24MAT205 24AID502 24CSE303
WED HRDC 24CSE407 24AID502 24OEC912
THU 24OEC912 24AID502 24ECE305 24MAT205 24CSE407
FRI 24MAC003 24MAT205 24CSE408 24CSE303 24ECE305

Order Course Code Credits Hours
X1 24CSE407 3 3
X2 24CSE408 4 5
X3 24AID502 3 3
X4 24OEC912 3 3
X5 24MAC003 0 2
X6 24MAT205 4 4
X7 24ECE305 3 3
X8 24CSE303 2 2

Total 22 Credits 25 Hours

Course Name – Name of the Faculty
24CSE408 Design Thinking – Mrs. N. Radha / AP / AIDS
Discrete Mathematics – Mrs. N. Subashini / AP / MATHS
Digital Electronics and Microprocessors – Mrs. Kalpana / AP / ECE
Computational Intelligence – Ms. P. Sudha / AP / AIDS
Introduction to Computational Biology – Mrs. K. Bharathi / AP / BTE
Environmental Science – Dr. K. Rajalakshmi / ASP / CHEM
Operating Systems – Mrs. Keerthanasri / AP / AIDS
Design and Analysis of Algorithms – Mr. K. Jeeva / AP / AIDS

SCHOOL OF ENGINEERING AND TECHNOLOGY
Department of Artificial Intelligence and Data Science
Academic Year 2025-2026 / Even Semester
II Year / IV Semester – Slot I
Section: 24AIDSA4

Class Room No: 705
08.30-09.20 09.20-10.10 10.10-11.00 11.00-11.15 11.15-12.05 12.05-12.55 12.55-01.25 01.25-02.15 02.15-03.05 03.05-03.20 03.20-04.10 04.10-05.00 05.00-05.50

MON 24CSE408 24ECE305 24MAC003 24AID502 24MAT205
TUE 24AID502 24MAT205 24CSE303 24OEC912 24CSE407
WED 24ECE305 24CSE408 24CSE407 HRDC 24MAC003
THU 24CSE407 24OEC912 24MAT205 24CSE408
FRI 24MAT205 24OEC912 24ECE305 24CSE303 24AID502

Order Course Code Credits Hours
X1 24CSE408 4 5
X2 24AID502 3 3
X3 24OEC912 3 3
X4 24MAC003 0 2
X5 24MAT205 4 4
X6 24ECE305 3 3
X7 24CSE303 2 2
X8 24CSE407 3 3

Total 22 Credits 25 Hours

Course Name – Name of the Faculty
24CSE408 Design Thinking – Mrs. J. Anitha / AP / AIDS
Digital Electronics and Microprocessors – Mrs. S. Anitha / AP / ECE
Design and Analysis of Algorithms – Mrs. M. Suguna / AP / AIDS
Introduction to Computational Biology – Mr. V. Vikram / AP / BTE
Environmental Science – Dr. C. Bhaskar / AP / CHEM
Discrete Mathematics – Dr. R. Abinaya / AP / MATHS
Operating Systems – Mr. V. V. Sabeer / AP / AIDS
Computational Intelligence – Ms. P. Sudha / AP / AIDS

SCHOOL OF ENGINEERING AND TECHNOLOGY
Department of Artificial Intelligence and Data Science
Academic Year 2025-2026 / Even Semester
II Year / IV Semester – Slot I
Section: 24AIDSA5

Class Room No: 701
08.30-09.20 09.20-10.10 10.10-11.00 11.00-11.15 11.15-12.05 12.05-12.55 12.55-01.25 01.25-02.15 02.15-03.05 03.05-03.20 03.20-04.10 04.10-05.00 05.00-05.50

MON 24MAT205 24AID502 24CSE407 24ECE305
TUE 24ECE305 24OEC912 24CSE408 24MAT205 24MAC003
WED HRDC 24AID502 24MAT205 24CSE303 24CSE407
THU 24CSE407 24ECE305 24OEC912 24CSE408 24MAT205
FRI 24CSE408 24CSE303 24MAC003 24AID502 24OEC912

Order Course Code Credits Hours
Y1 24MAT205 4 4
Y2 24ECE305 3 3
Y3 24CSE303 2 2
Y4 24CSE407 3 3
Y5 24CSE408 4 5
Y6 24AID502 3 3
Y7 24OEC912 3 3
Y8 24MAC003 0 2

Total 22 Credits 25 Hours

Course Name – Name of the Faculty
24CSE408 Computational Intelligence – Ms. N. Pavithra / AP / AIDS
Introduction to Computational Biology – Ms. J. Jane Yazhini / AP / BTE
Environmental Science – Mr. A. Azhaguvel / RS / Chem
Design Thinking – Mrs. J. Anitha / AP / AIDS
Design and Analysis of Algorithms – Mrs. G. Mahalakshmi / AP / AIDS
Operating Systems – Mrs. M. Suguna / AP / AIDS
Discrete Mathematics – New Faculty 4 / Maths
Digital Electronics and Microprocessors – Dr. V. Ramya / AP / ECE

SCHOOL OF ENGINEERING AND TECHNOLOGY
Department of Artificial Intelligence and Data Science
Academic Year 2025-2026 / Even Semester
II Year / IV Semester – Slot II
Section: 24AIDSB1

Class Room No: 702
08.30-09.20 09.20-10.10 10.10-11.00 11.00-11.15 11.15-12.05 12.05-12.55 12.55-01.25 01.25-02.15 02.15-03.05 03.05-03.20 03.20-04.10 04.10-05.00 05.00-05.50

MON 24AID502 24OEC912 24CSE408 24CSE407 24MAT205
TUE 24ECE305 24MAC003 24MAT205 24CSE408 24CSE303
WED HRDC 24CSE303 24ECE305 24OEC912 24MAC003 24AID502
THU 24CSE407 24AID502 24ECE305 24MAT205
FRI 24MAT205 24CSE408 24CSE407 24OEC912

Order Course Code Credits Hours
Y1 24ECE305 3 3
Y2 24CSE303 2 2
Y3 24CSE407 3 3
Y4 24CSE408 4 5
Y5 24AID502 3 3
Y6 24OEC912 3 3
Y7 24MAC003 0 2
Y8 24MAT205 4 4

Total 22 Credits 25 Hours

Course Name – Name of the Faculty
24CSE408 Introduction to Computational Biology – Ms. J. Jane Yazhini / AP / BTE
Environmental Science – Dr. A. Krishnamoorthy / ASP / Chem
Discrete Mathematics – New Faculty 2 / MATHS
Design and Analysis of Algorithms – Mr. K. Jeeva / AP / AIDS
Operating Systems – Mrs. Keerthanasri / AP / AIDS
Computational Intelligence – Mr. B. Shanawaz Baig / AP / AIDS
Design Thinking – Mr. V. V. Sabeer / AP / AIDS
Digital Electronics and Microprocessors – Mrs. S. Antiha / AP / ECE

SCHOOL OF ENGINEERING AND TECHNOLOGY
Department of Artificial Intelligence and Data Science
Academic Year 2025-2026 / Even Semester
II Year / IV Semester – Slot II
Section: 24AIDSB2

Class Room No: 703
08.30-09.20 09.20-10.10 10.10-11.00 11.00-11.15 11.15-12.05 12.05-12.55 12.55-01.25 01.25-02.15 02.15-03.05 03.05-03.20 03.20-04.10 04.10-05.00 05.00-05.50

MON 24AID502 24MAC003 24CSE407 24CSE303
TUE 24ECE305 24MAT205 24AID502 24CSE408 24OEC912
WED 24MAT205 24CSE408 24ECE305 24MAC003
THU HRDC 24CSE407 24AID502 24MAT205 24OEC912 24CSE303
FRI 24OEC912 24ECE305 24CSE408 24CSE407 24MAT205

Order Course Code Credits Hours
Y1 24CSE303 2 2
Y2 24CSE407 3 3
Y3 24CSE408 4 5
Y4 24AID502 3 3
Y5 24OEC912 3 3
Y6 24MAC003 0 2
Y7 24MAT205 4 4
Y8 24ECE305 3 3

Total 22 Credits 25 Hours

Course Name – Name of the Faculty
24CSE408 Design Thinking – Mr. V. V. Shabeer / AP / AIDS
Environmental Science – Dr. A. Kalaiyarasi / AP / Chem
Discrete Mathematics – New Faculty 3 / MATHS
Digital Electronics and Microprocessors – Mrs. K. Kalpana / AP / ECE
Operating Systems – Mr. Manivannan / AP / AIDS
Computational Intelligence – Ms. P. Sudha / AP / AIDS
Introduction to Computational Biology – Ms. A. Winny / AP / BTE
Design and Analysis of Algorithms – Mr. J. Manivannan / AP / AIDS

SCHOOL OF ENGINEERING AND TECHNOLOGY
Department of Artificial Intelligence and Data Science
Academic Year 2025-2026 / Even Semester
II Year / IV Semester – Slot II
Section: 24AIDSB3

Class Room No: 704
08.30-09.20 09.20-10.10 10.10-11.00 11.00-11.15 11.15-12.05 12.05-12.55 12.55-01.25 01.25-02.15 02.15-03.05 03.05-03.20 03.20-04.10 04.10-05.00 05.00-05.50

MON 24CSE303 24MAT205 24OEC912 24AID502 24ECE305
TUE 24AID502 24MAC003 24CSE407 24CSE408 24MAT205
WED 24MAT205 24CSE408 24ECE305 24OEC912 24CSE407
THU HRDC 24OEC912 24CSE407 24MAC003 24CSE303
FRI 24ECE305 24AID502 24MAT205 24CSE408

Order Course Code Credits Hours
Y1 24CSE407 3 3
Y2 24CSE408 4 5
Y3 24AID502 3 3
Y4 24OEC912 3 3
Y5 24MAC003 0 2
Y6 24MAT205 4 4
Y7 24ECE305 3 3
Y8 24CSE303 2 2

Total 22 Credits 25 Hours

Course Name – Name of the Faculty
24CSE408 Design and Analysis of Algorithms – Mrs. G. Mahalakshmi / AP / AIDS
Discrete Mathematics – Mr. K. Keerthi Raj / RS / MATHS
Digital Electronics and Microprocessors – Dr. V. Ramya / AP / ECE
Design Thinking – Mr. J. Manivannan / AP / AIDS
Computational Intelligence – Ms. N. Pavithra / AP / AIDS
Introduction to Computational Biology – Ms. J. Jane Yazhini / AP / BTE
Environmental Science – Dr. L. Bhuvana / AP / CHEM
Operating Systems – Mrs. M. Suguna / AP / AIDS

SCHOOL OF ENGINEERING AND TECHNOLOGY
Department of Artificial Intelligence and Data Science
Academic Year 2025-2026 / Even Semester
II Year / IV Semester – Slot II
Section: 24AIDSB4

Class Room No: 705
08.30-09.20 09.20-10.10 10.10-11.00 11.00-11.15 11.15-12.05 12.05-12.55 12.55-01.25 01.25-02.15 02.15-03.05 03.05-03.20 03.20-04.10 04.10-05.00 05.00-05.50

MON HRDC 24AID502 24ECE305 24MAC003 24CSE407 24MAT205
TUE 24CSE303 24MAT205 24ECE305 24OEC912
WED 24CSE407 24AID502 24CSE408 24MAT205
THU 24MAC003 24CSE303 24AID502 24CSE408 24OEC912
FRI 24MAT205 24OEC912 24CSE407 24ECE305 24CSE408

Order Course Code Credits Hours
Y1 24CSE408 4 5
Y2 24AID502 3 3
Y3 24OEC912 3 3
Y4 24MAC003 0 2
Y5 24MAT205 4 4
Y6 24ECE305 3 3
Y7 24CSE303 2 2
Y8 24CSE407 3 3

Total 22 Credits 25 Hours

Course Name – Name of the Faculty
24CSE408 Operating Systems – Mr. V. V. Sabeer / AP / AIDS
Digital Electronics and Microprocessors – Mr. V. Vivek / AP / ECE
Design Thinking – Mrs. J. Anitha / AP / AIDS
Design and Analysis of Algorithms – Mrs. G. Mahalakshmi / AP / AIDS
Introduction to Computational Biology – Ms. A. Winny / AP / BTE
Environmental Science – Dr. C. Bhaskar / AP / CHEM
Discrete Mathematics – New Faculty 4 / Maths
Computational Intelligence – Ms. N. Pavithra / AP / AIDS

SCHOOL OF ENGINEERING AND TECHNOLOGY
Department of Artificial Intelligence and Data Science
Academic Year 2025-2026 / Even Semester
II Year / IV Semester – Slot II
Section: 24AIDSB5
"""

# Let's write code to parse this text intelligently.
sections = re.split(r'Section:\s*(24AIDS[A|B]\d)', text)

# sections[0] has A1, then sections[1] is '24AIDSB1' etc.
# Wait, A1's section string is at the end of its block!
# Let's split by "Class Room No:" and then the section name is at the bottom of the block, EXCEPT for A1 which is at the bottom.
# Actually, the block for A1 starts at "Class Room No: 701"
# Let's split by "Class Room No:"
text = text.replace('\r', '')
blocks = text.split("Class Room No:")
blocks = [b.strip() for b in blocks if b.strip()]

out_json = []

time_periods_slot1 = [
    ("08:30", "09:20"),
    ("09:20", "10:10"),
    ("10:10", "11:00"),
    ("11:15", "12:05"),
    ("12:05", "12:55")
]

time_periods_slot2 = [
    ("01:25", "02:15"),
    ("02:15", "03:05"),
    ("03:20", "04:10"),
    ("04:10", "05:00"),
    ("05:00", "05:50")
]

for block in blocks:
    lines = block.split('\n')
    room_str = lines[0].strip()
    
    # Extract Section which is usually at the bottom
    section_match = re.search(r'Section:\s*(\S+)', block)
    if not section_match:
        continue
    section = section_match.group(1)
    
    is_slot2 = 'Slot II' in block or 'B' in section
    
    # periods to use sequentially
    periods = time_periods_slot2 if is_slot2 else time_periods_slot1
    
    # extract timetable
    days = ['MON', 'TUE', 'WED', 'THU', 'FRI']
    day_schedules = {d: [] for d in days}
    
    for line in lines:
        for d in days:
            if line.startswith(d + ' '):
                parts = line.split()
                # courses are parts[1:]
                day_schedules[d] = parts[1:]

    # extract courses mapping
    # Course Name – Name of the Faculty
    # find everything between "Course Name" and "SCHOOL OF ENGINEERING"
    faculty_part = re.split(r'Course Name\s*–\s*Name of the Faculty', block)
    if len(faculty_part) > 1:
        faculty_text = re.split(r'SCHOOL OF ENGINEERING', faculty_part[1])[0]
    else:
        faculty_text = ""
        
    faculties = {}
    subjects = {}
    
    # We also need code to subject name mapping. Wait, the faculty list has 
    # "24CSE408 Computational Intelligence – Dr. P. Thangavel..." or just "Computational Biology - Dr..."
    # The prompt actually omits course code for most courses in the faculty list! 
    # Example:
    # 24CSE408 Computational Intelligence – Dr. P. ...
    # Introduction to ... – Dr. ...
    # Let's just use a hardcoded mapping for course codes to names based on the text.
    
    code_to_subject = {
        "24MAT205": "Discrete Mathematics",
        "24ECE305": "Digital Electronics and Microprocessors",
        "24CSE303": "Design Thinking",
        "24CSE407": "Design and Analysis of Algorithms",
        "24CSE408": "Operating Systems", # wait, sometimes CSE408 is Computational Intelligence!
        "24AID502": "Computational Intelligence",
        "24OEC912": "Introduction to Computational Biology",
        "24MAC003": "Environmental Science",
        "HRDC": "HRDC"
    }
    
    # Some sections have 24CSE408 as Design Thinking? Let's check text: "24CSE408 Design Thinking – Dr. A. Justin..." 
    # This might be a typo in the user's PDF, but I'll write logic to parse the faculty lines.
    fac_lines = [line.strip() for line in faculty_text.strip().split('\n') if '–' in line or '-' in line]
    
    for line in fac_lines:
        line = line.replace('–', '-').strip()
        if ' - ' in line:
            subj_mentor = line.split(' - ')
            subj = subj_mentor[0].strip()
            mentor_full = subj_mentor[1].strip()
            mentor_name = mentor_full.split('/')[0].strip()
            
            # sometimes subject has the code prefix like "24CSE408 Computational Intelligence"
            parts = subj.split(' ')
            if re.match(r'^[0-9A-Z]{8}$', parts[0]):
                code = parts[0]
                subj = ' '.join(parts[1:])
            else:
                # search by name in our general mapping
                code = None
                for c, s in code_to_subject.items():
                    if s.lower() in subj.lower():
                        code = c
                        break
            
            if not code: 
                # reverse match
                def sanitize(txt): return re.sub(r'[^a-zA-Z0-9]', '', txt.lower())
                for c, s in code_to_subject.items():
                     if sanitize(s) == sanitize(subj): code = c
            
            # if we found code or assume general mapping
            # store it!
            faculties[subj.lower()] = mentor_name
            if code:
                faculties[code] = mentor_name
                subjects[code] = subj

    day_names = {
        'MON': 'Monday',
        'TUE': 'Tuesday',
        'WED': 'Wednesday',
        'THU': 'Thursday',
        'FRI': 'Friday'
    }

    # Now assign periods
    for day in days:
        courses = day_schedules[day]
        for i, code in enumerate(courses):
            # assign sequentially
            period_idx = i
            if period_idx >= len(periods):
                break # safety config
            
            start_time, end_time = periods[period_idx]
            
            subj_name = subjects.get(code, code_to_subject.get(code, code))
            mentor = faculties.get(code, faculties.get(subj_name.lower(), "Unknown"))
            
            if code == "HRDC":
                subj_name = "HRDC"
                mentor = "N/A"
            
            
            out_json.append({
                "section": section,
                "day": day_names[day],
                "startTime": start_time,
                "endTime": end_time,
                "subject": subj_name,
                "code": code,
                "mentor": mentor,
                "room": room_str
            })
    print(f"Section {section}: Added {len([c for c in day_schedules.values() for c in c])} courses text")

with open("tool/new_timetable.json", "w") as f:
    json.dump(out_json, f, indent=2)

print("Parsed successfully!")
