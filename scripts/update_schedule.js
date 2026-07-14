const fs = require('fs');

const ocrText = `
==Start of OCR for page 1==
Section: 24AIDSA1 MENTOR: Mrs.N.Radha, AP/ AI&DS Class Room No: 509
MON 24CSE404 24OEC925 24AID501 24AID504 24CSE406 24CSE410
TUE 24AID504 24AID501 24CSE410 24CSE406 24CSE404 24AID501
WED 24OEC925 24AID504 24CSE406 24TPL102 24CSE410
THU 24CSE410 24CSE404 24CSE406 24AID501 24AID504
FRI 24TPL102 24AID504 24CSE404 24CSE410 24OEC925 Mentor

X1 Computer Architecture 24CSE404 Dr.A.Justin Diraviyam / Prof./AI&DS
X2 Data Science 24CSE406 Ms.S.Sathiya / AP/AI&DS
X3 Database Systems 24CSE410 Mrs.N.Radha/AP/AI&DS
X4 Intelligent Systems 24AID504 Mrs.S.Safeena Begum / AP/AI&DS
X5 Data Visualization using Tableau and Power BI 24AID501 Mr.K.Jeeva / AP/AI&DS
X6 Quantitative Skill Practice-II 24TPL102 Mr. Nagadinesh/ HRDC
X7 Introduction to Sensor Technology 24OEC925 New Faculty 4 / AP/ECE

==Start of OCR for page 2==
Section: 24AIDSA2 MENTOR: Mrs.M. Nalini, AP/ AI&DS Class Room No: 510
MON 24CSE404 24AID501 24AID504 24CSE410 24CSE406
TUE 24OEC925 24CSE410 24CSE404 24AID504 24TPL102
WED 24AID501 24AID504 24OEC925 24CSE406 24TPL102 24CSE410
THU 24CSE410 24AID501 24CSE406 24AID504 24CSE404 Mentor
FRI 24CSE406 24OEC925 24CSE410 24CSE404 24AID501 24AID501

X1 Computer Architecture 24CSE404 Dr.A.Kovalan /ASP/AI&DS
X2 Data Science 24CSE406 Ms.S.Swarnalatha/ AP/AI&DS
X3 Database Systems 24CSE410 Mrs.C.Merlyne Sandra Christina / AP/AI&DS
X4 Intelligent Systems 24AID504 Dr. J.Isralin Insulata /AP/AI&DS
X5 Data Visualization using Tableau and Power BI 24AID501 Mr.K.Jeeva / AP/AI&DS
X6 Quantitative Skill Practice-II 24TPL102 Ms. Dhishmaasree/ HRDC
X7 Introduction to Sensor Technology 24OEC925 New Faculty 10 / ECE

==Start of OCR for page 3==
Section: 24AIDSA3 Mentor : Mr. J. Manivanan AP/AI & DS Class Room No: 511
MON 24AID504 24AID501 24CSE404 24OEC925 24CSE410 Mentor
TUE 24TPL102 24AID501 24CSE406 24CSE410 24CSE404
WED 24OEC925 24CSE410 24AID504 24CSE404 24CSE406
THU 24TPL102 24AID501 24CSE404 24CSE406 24AID504 24AID501
FRI 24CSE410 24AID501 24OEC925 24AID504 24CSE406 24CSE410

X1 Computer Architecture 24CSE404 Dr.A.Kovalan /ASP/AI&DS
X2 Data Science 24CSE406 Ms.P.Sudha /AP/AI&DS
X3 Database Systems 24CSE410 Mr.Thangavel / AP/AI&DS
X4 Intelligent Systems 24AID504 Mr.P.Mounica / AP/AI&DS
X5 Data Visualization using Tableau and Power BI 24AID501 Mrs.M.Jayasri / AP/ AI&DS
X6 Quantitative Skill Practice-II 24TPL102 Ms. Dhishmaasree/ HRDC
X7 Introduction to Sensor Technology 24OEC925 New Faculty 6 / ECE

==Start of OCR for page 4==
Section: 24AIDSA4 Mentor : Ms.S.Sudha / AP/ AI&DS Class Room No: 512
MON 24CSE406 24AID501 24OEC925 24AID504 24CSE410
TUE 24CSE410 24AID504 24AID501 24CSE404 24CSE406
WED 24AID504 24CSE410 24TPL102 24AID501 24CSE404 24CSE410
THU 24OEC925 24CSE406 24CSE410 24CSE404 24TPL102 Mentor 24AID501
FRI 24CSE404 24CSE406 24AID504 24AID501 24OEC925

X1 Computer Architecture 24CSE404 Mrs.G.Mahalakshmi / AP/AI&DS
X2 Data Science 24CSE406 Ms.S.Sudha / AP/ AI&DS
X3 Database Systems 24CSE410 Mrs.P.Anitha / AP/ AI&DS
X4 Intelligent Systems 24AID504 Mrs.P.Mounica / AP/AI&DS
X5 Data Visualization using Tableau and Power BI 24AID501 Mrs.Pavithira / AP/ AI&DS
X6 Quantitative Skill Practice-II 24TPL102 Mr. Nagadinesh/ HRDC
X7 Introduction to Sensor Technology 24OEC925 Mr.P.Subramanian / AP/ ECE

==Start of OCR for page 5==
Section: 24AIDSA5 Mentor : Mrs P.Mounica AP/AI&DS Class Room No: 513
MON 24CSE410 24AID501 24CSE406 24OEC925 24AID504 Mentor
TUE 24AID501 24CSE404 24TPL102 24CSE406 24CSE410 24AID501
WED 24AID504 24CSE404 24CSE410 24CSE406 24OEC925
THU 24TPL102 24CSE406 24AID501 24CSE404 24AID504 24CSE410
FRI 24OEC925 24AID501 24AID504 24CSE410 24CSE404

X1 Computer Architecture 24CSE404 Mrs.J.Siva sankari/ AP/AI&DS
X2 Data Science 24CSE406 Mrs.P.Mounica/ AP/AI&DS
X3 Database Systems 24CSE410 Mrs.J.Anitha / AP/AI&DS
X4 Intelligent Systems 24AID504 New Faculty 4 / AP/ AI&DS
X5 Data Visualization using Tableau and Power BI 24AID501 Mrs.M.Sheeba/ AP/AI&DS
X6 Quantitative Skill Practice-II 24TPL102 Mr. Nagadinesh/ HRDC
X7 Introduction to Sensor Technology 24OEC925 Mrs.S.Anitha/ AP/AI&DS

==Start of OCR for page 6==
Section: 24AIDSB1 Mentor : Mrs J. Anitha, AP/AI&DS Class Room No: 509
MON 24CSE404 24AID501 24CSE410 24OEC925 24CSE406
TUE 24CSE410 24OEC925 24TPL102 24CSE406 24AID504 24AID504
WED 24AID504 24CSE404 24CSE406 24CSE410 24CSE410
THU Mentor 24CSE410 24AID501 24OEC925 24CSE404 24CSE404
FRI 24AID501 24CSE406 24AID504 24TPL102 24AID501 24AID501

X1 Computer Architecture 24CSE404 Dr.A.Justin Diraviyam / Prof./AI&DS
X2 Data Science 24CSE406 Mrs.S.Swarnalatha / AP/AI&DS
X3 Database Systems 24CSE410 Ms.J.Anitha / AP/AI&DS
X4 Intelligent Systems 24AID504 New Faculty 4 / AP/AI&DS
X5 Data Visualization using Tableau and Power BI 24AID501 Mrs.M.Sheeba / AP/ AI&DS
X6 Quantitative Skill Practice-II 24TPL102 Mr. Nagadinesh/ HRDC
X7 Introduction to Sensor Technology 24OEC925 New Faculty 4 / AP/ECE

==Start of OCR for page 7==
Section: 24AIDSB2 Mentor : Mr. K. Jeeva, AP/AI&DS Class Room No: 510
MON 24CSE404 24AID501 24CSE410 24OEC925 24CSE406
TUE 24AID501 24CSE404 24TPL102 24AID504 24CSE406 24CSE406
WED 24AID501 24CSE404 24AID504 24CSE410 24CSE410
THU Mentor 24OEC925 24CSE410 24CSE406 24AID501 24AID501
FRI 24CSE410 24CSE404 24TPL102 24OEC925 24AID504 24AID504

X1 Computer Architecture 24CSE404 Mrs. G. Mahalakshmi/ AP/AI&DS
X2 Data Science 24CSE406 Mr. V.V. Shabeer/AP/AI&DS
X3 Database Systems 24CSE410 Mrs.C.Merlyne Sandra Christina / AP/AI&DS
X4 Intelligent Systems 24AID504 Mrs.S.Safeena Begum / AP/AI&DS
X5 Data Visualization using Tableau and Power BI 24AID501 Mr.K.Jeeva /AP/AI&DS
X6 Quantitative Skill Practice-II 24TPL102 Ms. Dhishmaasree/ HRDC
X7 Introduction to Sensor Technology 24OEC925 New Faculty 9/ECE

==Start of OCR for page 8==
Section: 24AIDSB3 Mentor : Mrs G. Archana, AP/AI&DS Class Room No: 511
MON 24AID501 24CSE406 24CSE404 24OEC925 24AID504
TUE Mentor 24TPL102 24OEC925 24CSE410 24CSE406 24AID504
WED 24CSE410 24CSE404 24AID504 24TPL102 24AID501 24AID501
THU 24AID501 24AID504 24AID501 24CSE410 24CSE406 24CSE404
FRI 24OEC925 24CSE404 24CSE406 24CSE410 24CSE410

X1 Computer Architecture 24CSE404 Mrs.J.Sivasangari / AP/AI&DS
X2 Data Science 24CSE406 Ms.P.Sudha/ AP/AI&DS
X3 Database Systems 24CSE410 Ms.N.Radha / AP/AI&DS
X4 Intelligent Systems 24AID504 Dr.J.Israelin Insulatta / AP/AI&DS
X5 Data Visualization using Tableau and Power BI 24AID501 Mrs.M.Jayasri/ AP/AI&DS
X6 Quantitative Skill Practice-II 24TPL102 Ms. Dhishmaasree/ HRDC
X7 Introduction to Sensor Technology 24OEC925 New Faculty 6/ECE

==Start of OCR for page 9==
Section: 24AIDSB4 Mentor : Mrs M. Suguna, AP/AI&DS Class Room No: 512
MON 24CSE410 24AID504 24CSE410 24CSE404 24AID501 24AID501
TUE 24AID501 24AID504 24CSE410 24CSE406 24CSE406
WED 24CSE404 24AID501 24TPL102 24OEC925 24CSE406
THU 24OEC925 24AID504 24TPL102 24CSE404 24CSE406
FRI 24AID501 Mentor 24AID504 24CSE404 24OEC925 24CSE410 24CSE410

X1 Computer Architecture 24CSE404 Mr. A. Kovalan/ASP/AI&DS
X2 Data Science 24CSE406 Ms.S.Sathya/AP/AI&DS
X3 Database Systems 24CSE410 Ms. P.Anitha / AP/AI&DS
X4 Intelligent Systems 24AID504 Mrs.S.Safeena Begam /AP/AI&DS
X5 Data Visualization using Tableau and Power BI 24AID501 Ms.N.Pavithra/AP/AI&DS
X6 Quantitative Skill Practice-II 24TPL102 Mr. Nagadinesh/ HRDC
X7 Introduction to Sensor Technology 24OEC925 New Faculty10/ECE

==Start of OCR for page 10==
Section: 24AIDSB5 Mentor : Mrs N. Pavithra, AP/AI&DS Class Room No: 513
MON Mentor 24AID501 24CSE404 24OEC925 24CSE410 24CSE410
TUE 24CSE406 24CSE404 24AID501 24AID504 24OEC925
WED 24AID501 24TPL102 24CSE410 24CSE406 24AID504 24AID504
THU 24TPL102 24AID501 24CSE410 24AID504 24CSE404
FRI 24CSE410 24AID501 24OEC925 24CSE404 24CSE406 24CSE406

X1 Computer Architecture 24CSE404 Dr.A.Kovalan/ ASP/AI&DS
X2 Data Science 24CSE406 Mrs.J.Mounica/AP/AI&DS
X3 Database Systems 24CSE410 Dr.P.Thangavel/ ASP/AI&DS
X4 Intelligent Systems 24AID504 Dr. J.Isralin Insulata /AP/AI&DS
X5 Data Visualization using Tableau and Power BI 24AID501 Mrs. N. Pavithra /AP/AI&DS
X6 Quantitative Skill Practice-II 24TPL102 Ms. Mahalakshmi/ HRDC
X7 Introduction to Sensor Technology 24OEC925 New Faculty10/ECE
`;

// Helper arrays
const slotsWithLunch = [
    { start: "08:30", end: "09:20" },
    { start: "09:20", end: "10:10" },
    { start: "10:10", end: "11:00" },
    { start: "11:15", end: "12:05" },
    { start: "12:05", end: "12:55" },
    { start: "01:25", end: "02:15" },
    { start: "02:15", end: "03:05" },
    { start: "03:20", end: "04:10" },
    { start: "04:10", end: "05:00" },
    { start: "05:00", end: "05:50" }
];

async function run() {
    const lines = ocrText.split('\n');
    let currentSection = null;
    let room = "";
    let sectionsData = {};

    for (let line of lines) {
        line = line.trim();
        if (!line) continue;

        if (line.startsWith('Section:')) {
            const m = line.match(/Section:\s*([A-Z0-9]+).*Class Room No:\s*(\d+)/);
            if (m) {
                currentSection = m[1];
                room = m[2];
                sectionsData[currentSection] = { room, days: [], subjectsMap: {} };
            }
        }
        else if (currentSection && (line.startsWith('MON') || line.startsWith('TUE') || line.startsWith('WED') || line.startsWith('THU') || line.startsWith('FRI'))) {
            const parts = line.split(/\s+/);
            const dayStr = parts[0];
            const dayMap = { "MON": "Monday", "TUE": "Tuesday", "WED": "Wednesday", "THU": "Thursday", "FRI": "Friday" };
            const day = dayMap[dayStr];
            
            let codes = parts.slice(1);
            sectionsData[currentSection].days.push({ day, codes });
        }
        else if (currentSection && line.startsWith('X')) {
            const parts = line.split(/\s+/);
            const codeIndex = parts.findIndex(p => p.match(/^24[A-Z]{2,3}\d+$/));
            if (codeIndex !== -1) {
                const code = parts[codeIndex];
                const name = parts.slice(1, codeIndex).join(' ');
                const faculty = parts.slice(codeIndex + 1).join(' ');
                sectionsData[currentSection].subjectsMap[code] = { name, faculty };
            }
        }
    }

    // Now push to firestore
    for (const [sectionId, data] of Object.entries(sectionsData)) {
        console.log("Processing section " + sectionId + "...");
        const url = "https://firestore.googleapis.com/v1/projects/studio-4155999944-16272/databases/(default)/documents/departments/school-of-engineering-and-technology/years/2024/sections/" + sectionId + "/schedule";
        
        try {
            const fetchRes = await fetch(url);
            if (fetchRes.ok) {
                const existing = await fetchRes.json();
                if (existing.documents) {
                    for (const doc of existing.documents) {
                        await fetch("https://firestore.googleapis.com/v1/" + doc.name, { method: 'DELETE' });
                    }
                }
            }

            for (const d of data.days) {
                for (let i = 0; i < d.codes.length; i++) {
                    const code = d.codes[i];
                    if (!slotsWithLunch[i]) continue;
                    
                    const slot = slotsWithLunch[i];

                    let subjectName = code;
                    let mentorName = code;

                    if (data.subjectsMap[code]) {
                        subjectName = data.subjectsMap[code].name;
                        mentorName = data.subjectsMap[code].faculty;
                    } else if (code.toLowerCase() === 'mentor') {
                        subjectName = "Mentoring";
                        mentorName = "Mentor";
                    }

                    const body = {
                        fields: {
                            room: { stringValue: data.room },
                            endTime: { stringValue: slot.end },
                            startTime: { stringValue: slot.start },
                            day: { stringValue: d.day },
                            code: { stringValue: code },
                            subject: { stringValue: subjectName },
                            mentor: { stringValue: mentorName }
                        }
                    };

                    const postUrl = "https://firestore.googleapis.com/v1/projects/studio-4155999944-16272/databases/(default)/documents/departments/school-of-engineering-and-technology/years/2024/sections/" + sectionId + "/schedule";
                    
                    const res = await fetch(postUrl, {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify(body)
                    });
                    
                    if (!res.ok) {
                        console.error("Failed to post " + code + " for " + sectionId + ": ", await res.text());
                    }
                }
            }
            console.log("Finished section " + sectionId + "!");
        } catch (e) {
            console.error("Error processing section", sectionId, e);
        }
    }
}

run();
