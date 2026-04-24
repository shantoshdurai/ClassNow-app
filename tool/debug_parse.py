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
"""

blocks = text.split("Class Room No:")
blocks = [b.strip() for b in blocks if b.strip()]
print(len(blocks))
for b in blocks:
    sec = re.search(r'Section:\s*(\S+)', b)
    print("Sec:", sec.group(1) if sec else None)
    
    lines = b.split('\n')
    days = ['MON', 'TUE', 'WED', 'THU', 'FRI']
    for line in lines:
        for d in days:
            if line.startswith(d + ' '):
                print(d, line)
