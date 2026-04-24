import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

const jsonData = r'''[
  {
    "section": "24AIDSA1",
    "day": "Monday",
    "startTime": "08:30",
    "endTime": "09:20",
    "subject": "Discrete Mathematics",
    "code": "24MAT205",
    "mentor": "Mrs. Jeraldine Ruby",
    "room": "701"
  },
  {
    "section": "24AIDSA1",
    "day": "Monday",
    "startTime": "09:20",
    "endTime": "10:10",
    "subject": "Computational Intelligence",
    "code": "24AID502",
    "mentor": "Dr. P. Thangavel",
    "room": "701"
  },
  {
    "section": "24AIDSA1",
    "day": "Monday",
    "startTime": "10:10",
    "endTime": "11:00",
    "subject": "Design and Analysis of Algorithms",
    "code": "24CSE407",
    "mentor": "Mr. Jeeva",
    "room": "701"
  },
  {
    "section": "24AIDSA1",
    "day": "Monday",
    "startTime": "11:15",
    "endTime": "12:05",
    "subject": "Digital Electronics and Microprocessors",
    "code": "24ECE305",
    "mentor": "Dr. V. Ramya",
    "room": "701"
  },
  {
    "section": "24AIDSA1",
    "day": "Monday",
    "startTime": "12:05",
    "endTime": "12:55",
    "subject": "HRDC",
    "code": "HRDC",
    "mentor": "N/A",
    "room": "701"
  },
  {
    "section": "24AIDSA1",
    "day": "Tuesday",
    "startTime": "08:30",
    "endTime": "09:20",
    "subject": "Digital Electronics and Microprocessors",
    "code": "24ECE305",
    "mentor": "Dr. V. Ramya",
    "room": "701"
  },
  {
    "section": "24AIDSA1",
    "day": "Tuesday",
    "startTime": "09:20",
    "endTime": "10:10",
    "subject": "Introduction to Computational Biology",
    "code": "24OEC912",
    "mentor": "Dr. M. Santhosh",
    "room": "701"
  },
  {
    "section": "24AIDSA1",
    "day": "Tuesday",
    "startTime": "10:10",
    "endTime": "11:00",
    "subject": "Operating Systems",
    "code": "24CSE408",
    "mentor": "Mrs. N. Radha",
    "room": "701"
  },
  {
    "section": "24AIDSA1",
    "day": "Tuesday",
    "startTime": "11:15",
    "endTime": "12:05",
    "subject": "Environmental Science",
    "code": "24MAC003",
    "mentor": "Dr. Sharad Porwal",
    "room": "701"
  },
  {
    "section": "24AIDSA1",
    "day": "Wednesday",
    "startTime": "08:30",
    "endTime": "09:20",
    "subject": "Design Thinking",
    "code": "24CSE303",
    "mentor": "Mrs. Keerthanasri",
    "room": "701"
  },
  {
    "section": "24AIDSA1",
    "day": "Wednesday",
    "startTime": "09:20",
    "endTime": "10:10",
    "subject": "Discrete Mathematics",
    "code": "24MAT205",
    "mentor": "Mrs. Jeraldine Ruby",
    "room": "701"
  },
  {
    "section": "24AIDSA1",
    "day": "Wednesday",
    "startTime": "10:10",
    "endTime": "11:00",
    "subject": "Computational Intelligence",
    "code": "24AID502",
    "mentor": "Dr. P. Thangavel",
    "room": "701"
  },
  {
    "section": "24AIDSA1",
    "day": "Wednesday",
    "startTime": "11:15",
    "endTime": "12:05",
    "subject": "Design and Analysis of Algorithms",
    "code": "24CSE407",
    "mentor": "Mr. Jeeva",
    "room": "701"
  },
  {
    "section": "24AIDSA1",
    "day": "Wednesday",
    "startTime": "12:05",
    "endTime": "12:55",
    "subject": "Digital Electronics and Microprocessors",
    "code": "24ECE305",
    "mentor": "Dr. V. Ramya",
    "room": "701"
  },
  {
    "section": "24AIDSA1",
    "day": "Thursday",
    "startTime": "08:30",
    "endTime": "09:20",
    "subject": "Design and Analysis of Algorithms",
    "code": "24CSE407",
    "mentor": "Mr. Jeeva",
    "room": "701"
  },
  {
    "section": "24AIDSA1",
    "day": "Thursday",
    "startTime": "09:20",
    "endTime": "10:10",
    "subject": "Computational Intelligence",
    "code": "24AID502",
    "mentor": "Dr. P. Thangavel",
    "room": "701"
  },
  {
    "section": "24AIDSA1",
    "day": "Thursday",
    "startTime": "10:10",
    "endTime": "11:00",
    "subject": "Introduction to Computational Biology",
    "code": "24OEC912",
    "mentor": "Dr. M. Santhosh",
    "room": "701"
  },
  {
    "section": "24AIDSA1",
    "day": "Thursday",
    "startTime": "11:15",
    "endTime": "12:05",
    "subject": "Operating Systems",
    "code": "24CSE408",
    "mentor": "Mrs. N. Radha",
    "room": "701"
  },
  {
    "section": "24AIDSA1",
    "day": "Thursday",
    "startTime": "12:05",
    "endTime": "12:55",
    "subject": "Discrete Mathematics",
    "code": "24MAT205",
    "mentor": "Mrs. Jeraldine Ruby",
    "room": "701"
  },
  {
    "section": "24AIDSA1",
    "day": "Friday",
    "startTime": "08:30",
    "endTime": "09:20",
    "subject": "Operating Systems",
    "code": "24CSE408",
    "mentor": "Mrs. N. Radha",
    "room": "701"
  },
  {
    "section": "24AIDSA1",
    "day": "Friday",
    "startTime": "09:20",
    "endTime": "10:10",
    "subject": "Design Thinking",
    "code": "24CSE303",
    "mentor": "Mrs. Keerthanasri",
    "room": "701"
  },
  {
    "section": "24AIDSA1",
    "day": "Friday",
    "startTime": "10:10",
    "endTime": "11:00",
    "subject": "Environmental Science",
    "code": "24MAC003",
    "mentor": "Dr. Sharad Porwal",
    "room": "701"
  },
  {
    "section": "24AIDSA1",
    "day": "Friday",
    "startTime": "11:15",
    "endTime": "12:05",
    "subject": "Discrete Mathematics",
    "code": "24MAT205",
    "mentor": "Mrs. Jeraldine Ruby",
    "room": "701"
  },
  {
    "section": "24AIDSA1",
    "day": "Friday",
    "startTime": "12:05",
    "endTime": "12:55",
    "subject": "Introduction to Computational Biology",
    "code": "24OEC912",
    "mentor": "Dr. M. Santhosh",
    "room": "701"
  },
  {
    "section": "24AIDSA2",
    "day": "Monday",
    "startTime": "08:30",
    "endTime": "09:20",
    "subject": "Digital Electronics and Microprocessors",
    "code": "24ECE305",
    "mentor": "Mrs. S. Anitha",
    "room": "702"
  },
  {
    "section": "24AIDSA2",
    "day": "Monday",
    "startTime": "09:20",
    "endTime": "10:10",
    "subject": "Operating Systems",
    "code": "24CSE408",
    "mentor": "Mr. J. Manivannan",
    "room": "702"
  },
  {
    "section": "24AIDSA2",
    "day": "Monday",
    "startTime": "10:10",
    "endTime": "11:00",
    "subject": "Introduction to Computational Biology",
    "code": "24OEC912",
    "mentor": "Ms. M. Kowsalya",
    "room": "702"
  },
  {
    "section": "24AIDSA2",
    "day": "Monday",
    "startTime": "11:15",
    "endTime": "12:05",
    "subject": "Discrete Mathematics",
    "code": "24MAT205",
    "mentor": "Mrs. Jeraldine Ruby",
    "room": "702"
  },
  {
    "section": "24AIDSA2",
    "day": "Monday",
    "startTime": "12:05",
    "endTime": "12:55",
    "subject": "Design and Analysis of Algorithms",
    "code": "24CSE407",
    "mentor": "Mr. K. Jeeva",
    "room": "702"
  },
  {
    "section": "24AIDSA2",
    "day": "Tuesday",
    "startTime": "08:30",
    "endTime": "09:20",
    "subject": "Design and Analysis of Algorithms",
    "code": "24CSE407",
    "mentor": "Mr. K. Jeeva",
    "room": "702"
  },
  {
    "section": "24AIDSA2",
    "day": "Tuesday",
    "startTime": "09:20",
    "endTime": "10:10",
    "subject": "Environmental Science",
    "code": "24MAC003",
    "mentor": "Mr. P. Karthick Kannan",
    "room": "702"
  },
  {
    "section": "24AIDSA2",
    "day": "Tuesday",
    "startTime": "10:10",
    "endTime": "11:00",
    "subject": "Design Thinking",
    "code": "24CSE303",
    "mentor": "Mrs. J. Siva Sangari",
    "room": "702"
  },
  {
    "section": "24AIDSA2",
    "day": "Tuesday",
    "startTime": "11:15",
    "endTime": "12:05",
    "subject": "Computational Intelligence",
    "code": "24AID502",
    "mentor": "Ms. N. Pavithra",
    "room": "702"
  },
  {
    "section": "24AIDSA2",
    "day": "Tuesday",
    "startTime": "12:05",
    "endTime": "12:55",
    "subject": "Discrete Mathematics",
    "code": "24MAT205",
    "mentor": "Mrs. Jeraldine Ruby",
    "room": "702"
  },
  {
    "section": "24AIDSA2",
    "day": "Wednesday",
    "startTime": "08:30",
    "endTime": "09:20",
    "subject": "HRDC",
    "code": "HRDC",
    "mentor": "N/A",
    "room": "702"
  },
  {
    "section": "24AIDSA2",
    "day": "Wednesday",
    "startTime": "09:20",
    "endTime": "10:10",
    "subject": "Digital Electronics and Microprocessors",
    "code": "24ECE305",
    "mentor": "Mrs. S. Anitha",
    "room": "702"
  },
  {
    "section": "24AIDSA2",
    "day": "Wednesday",
    "startTime": "10:10",
    "endTime": "11:00",
    "subject": "Introduction to Computational Biology",
    "code": "24OEC912",
    "mentor": "Ms. M. Kowsalya",
    "room": "702"
  },
  {
    "section": "24AIDSA2",
    "day": "Wednesday",
    "startTime": "11:15",
    "endTime": "12:05",
    "subject": "Operating Systems",
    "code": "24CSE408",
    "mentor": "Mr. J. Manivannan",
    "room": "702"
  },
  {
    "section": "24AIDSA2",
    "day": "Wednesday",
    "startTime": "12:05",
    "endTime": "12:55",
    "subject": "Computational Intelligence",
    "code": "24AID502",
    "mentor": "Ms. N. Pavithra",
    "room": "702"
  },
  {
    "section": "24AIDSA2",
    "day": "Thursday",
    "startTime": "08:30",
    "endTime": "09:20",
    "subject": "Operating Systems",
    "code": "24CSE408",
    "mentor": "Mr. J. Manivannan",
    "room": "702"
  },
  {
    "section": "24AIDSA2",
    "day": "Thursday",
    "startTime": "09:20",
    "endTime": "10:10",
    "subject": "Discrete Mathematics",
    "code": "24MAT205",
    "mentor": "Mrs. Jeraldine Ruby",
    "room": "702"
  },
  {
    "section": "24AIDSA2",
    "day": "Thursday",
    "startTime": "10:10",
    "endTime": "11:00",
    "subject": "Digital Electronics and Microprocessors",
    "code": "24ECE305",
    "mentor": "Mrs. S. Anitha",
    "room": "702"
  },
  {
    "section": "24AIDSA2",
    "day": "Thursday",
    "startTime": "11:15",
    "endTime": "12:05",
    "subject": "Design and Analysis of Algorithms",
    "code": "24CSE407",
    "mentor": "Mr. K. Jeeva",
    "room": "702"
  },
  {
    "section": "24AIDSA2",
    "day": "Thursday",
    "startTime": "12:05",
    "endTime": "12:55",
    "subject": "Computational Intelligence",
    "code": "24AID502",
    "mentor": "Ms. N. Pavithra",
    "room": "702"
  },
  {
    "section": "24AIDSA2",
    "day": "Friday",
    "startTime": "08:30",
    "endTime": "09:20",
    "subject": "Design Thinking",
    "code": "24CSE303",
    "mentor": "Mrs. J. Siva Sangari",
    "room": "702"
  },
  {
    "section": "24AIDSA2",
    "day": "Friday",
    "startTime": "09:20",
    "endTime": "10:10",
    "subject": "Discrete Mathematics",
    "code": "24MAT205",
    "mentor": "Mrs. Jeraldine Ruby",
    "room": "702"
  },
  {
    "section": "24AIDSA2",
    "day": "Friday",
    "startTime": "10:10",
    "endTime": "11:00",
    "subject": "Introduction to Computational Biology",
    "code": "24OEC912",
    "mentor": "Ms. M. Kowsalya",
    "room": "702"
  },
  {
    "section": "24AIDSA2",
    "day": "Friday",
    "startTime": "11:15",
    "endTime": "12:05",
    "subject": "Environmental Science",
    "code": "24MAC003",
    "mentor": "Mr. P. Karthick Kannan",
    "room": "702"
  },
  {
    "section": "24AIDSA3",
    "day": "Monday",
    "startTime": "08:30",
    "endTime": "09:20",
    "subject": "Design Thinking",
    "code": "24CSE303",
    "mentor": "Dr. A. Justin Diraviam",
    "room": "703"
  },
  {
    "section": "24AIDSA3",
    "day": "Monday",
    "startTime": "09:20",
    "endTime": "10:10",
    "subject": "Environmental Science",
    "code": "24MAC003",
    "mentor": "Dr. R. Elancheran",
    "room": "703"
  },
  {
    "section": "24AIDSA3",
    "day": "Monday",
    "startTime": "10:10",
    "endTime": "11:00",
    "subject": "Computational Intelligence",
    "code": "24AID502",
    "mentor": "Ms. P. Sudha",
    "room": "703"
  },
  {
    "section": "24AIDSA3",
    "day": "Monday",
    "startTime": "11:15",
    "endTime": "12:05",
    "subject": "Design and Analysis of Algorithms",
    "code": "24CSE407",
    "mentor": "Mrs. G. Mahalakshmi",
    "room": "703"
  },
  {
    "section": "24AIDSA3",
    "day": "Monday",
    "startTime": "12:05",
    "endTime": "12:55",
    "subject": "Discrete Mathematics",
    "code": "24MAT205",
    "mentor": "Mrs. R. Priyadharshini",
    "room": "703"
  },
  {
    "section": "24AIDSA3",
    "day": "Tuesday",
    "startTime": "08:30",
    "endTime": "09:20",
    "subject": "Design and Analysis of Algorithms",
    "code": "24CSE407",
    "mentor": "Mrs. G. Mahalakshmi",
    "room": "703"
  },
  {
    "section": "24AIDSA3",
    "day": "Tuesday",
    "startTime": "09:20",
    "endTime": "10:10",
    "subject": "Discrete Mathematics",
    "code": "24MAT205",
    "mentor": "Mrs. R. Priyadharshini",
    "room": "703"
  },
  {
    "section": "24AIDSA3",
    "day": "Tuesday",
    "startTime": "10:10",
    "endTime": "11:00",
    "subject": "Introduction to Computational Biology",
    "code": "24OEC912",
    "mentor": "Ms. M. Kowsalya",
    "room": "703"
  },
  {
    "section": "24AIDSA3",
    "day": "Tuesday",
    "startTime": "11:15",
    "endTime": "12:05",
    "subject": "Operating Systems",
    "code": "24CSE408",
    "mentor": "Mr. J. Manivannan",
    "room": "703"
  },
  {
    "section": "24AIDSA3",
    "day": "Tuesday",
    "startTime": "12:05",
    "endTime": "12:55",
    "subject": "Digital Electronics and Microprocessors",
    "code": "24ECE305",
    "mentor": "Mrs. K. Kalpana",
    "room": "703"
  },
  {
    "section": "24AIDSA3",
    "day": "Wednesday",
    "startTime": "08:30",
    "endTime": "09:20",
    "subject": "HRDC",
    "code": "HRDC",
    "mentor": "N/A",
    "room": "703"
  },
  {
    "section": "24AIDSA3",
    "day": "Wednesday",
    "startTime": "09:20",
    "endTime": "10:10",
    "subject": "Design Thinking",
    "code": "24CSE303",
    "mentor": "Dr. A. Justin Diraviam",
    "room": "703"
  },
  {
    "section": "24AIDSA3",
    "day": "Wednesday",
    "startTime": "10:10",
    "endTime": "11:00",
    "subject": "Digital Electronics and Microprocessors",
    "code": "24ECE305",
    "mentor": "Mrs. K. Kalpana",
    "room": "703"
  },
  {
    "section": "24AIDSA3",
    "day": "Wednesday",
    "startTime": "11:15",
    "endTime": "12:05",
    "subject": "Computational Intelligence",
    "code": "24AID502",
    "mentor": "Ms. P. Sudha",
    "room": "703"
  },
  {
    "section": "24AIDSA3",
    "day": "Thursday",
    "startTime": "08:30",
    "endTime": "09:20",
    "subject": "Computational Intelligence",
    "code": "24AID502",
    "mentor": "Ms. P. Sudha",
    "room": "703"
  },
  {
    "section": "24AIDSA3",
    "day": "Thursday",
    "startTime": "09:20",
    "endTime": "10:10",
    "subject": "Design and Analysis of Algorithms",
    "code": "24CSE407",
    "mentor": "Mrs. G. Mahalakshmi",
    "room": "703"
  },
  {
    "section": "24AIDSA3",
    "day": "Thursday",
    "startTime": "10:10",
    "endTime": "11:00",
    "subject": "Discrete Mathematics",
    "code": "24MAT205",
    "mentor": "Mrs. R. Priyadharshini",
    "room": "703"
  },
  {
    "section": "24AIDSA3",
    "day": "Thursday",
    "startTime": "11:15",
    "endTime": "12:05",
    "subject": "Introduction to Computational Biology",
    "code": "24OEC912",
    "mentor": "Ms. M. Kowsalya",
    "room": "703"
  },
  {
    "section": "24AIDSA3",
    "day": "Thursday",
    "startTime": "12:05",
    "endTime": "12:55",
    "subject": "Operating Systems",
    "code": "24CSE408",
    "mentor": "Mr. J. Manivannan",
    "room": "703"
  },
  {
    "section": "24AIDSA3",
    "day": "Friday",
    "startTime": "08:30",
    "endTime": "09:20",
    "subject": "Introduction to Computational Biology",
    "code": "24OEC912",
    "mentor": "Ms. M. Kowsalya",
    "room": "703"
  },
  {
    "section": "24AIDSA3",
    "day": "Friday",
    "startTime": "09:20",
    "endTime": "10:10",
    "subject": "Operating Systems",
    "code": "24CSE408",
    "mentor": "Mr. J. Manivannan",
    "room": "703"
  },
  {
    "section": "24AIDSA3",
    "day": "Friday",
    "startTime": "10:10",
    "endTime": "11:00",
    "subject": "Digital Electronics and Microprocessors",
    "code": "24ECE305",
    "mentor": "Mrs. K. Kalpana",
    "room": "703"
  },
  {
    "section": "24AIDSA3",
    "day": "Friday",
    "startTime": "11:15",
    "endTime": "12:05",
    "subject": "Environmental Science",
    "code": "24MAC003",
    "mentor": "Dr. R. Elancheran",
    "room": "703"
  },
  {
    "section": "24AIDSA3",
    "day": "Friday",
    "startTime": "12:05",
    "endTime": "12:55",
    "subject": "Discrete Mathematics",
    "code": "24MAT205",
    "mentor": "Mrs. R. Priyadharshini",
    "room": "703"
  },
  {
    "section": "24AIDSA4",
    "day": "Monday",
    "startTime": "08:30",
    "endTime": "09:20",
    "subject": "Design and Analysis of Algorithms",
    "code": "24CSE407",
    "mentor": "Mr. K. Jeeva",
    "room": "704"
  },
  {
    "section": "24AIDSA4",
    "day": "Monday",
    "startTime": "09:20",
    "endTime": "10:10",
    "subject": "Discrete Mathematics",
    "code": "24MAT205",
    "mentor": "Mrs. N. Subashini",
    "room": "704"
  },
  {
    "section": "24AIDSA4",
    "day": "Monday",
    "startTime": "10:10",
    "endTime": "11:00",
    "subject": "Introduction to Computational Biology",
    "code": "24OEC912",
    "mentor": "Mrs. K. Bharathi",
    "room": "704"
  },
  {
    "section": "24AIDSA4",
    "day": "Monday",
    "startTime": "11:15",
    "endTime": "12:05",
    "subject": "Operating Systems",
    "code": "24CSE408",
    "mentor": "Mrs. Keerthanasri",
    "room": "704"
  },
  {
    "section": "24AIDSA4",
    "day": "Monday",
    "startTime": "12:05",
    "endTime": "12:55",
    "subject": "Digital Electronics and Microprocessors",
    "code": "24ECE305",
    "mentor": "Mrs. Kalpana",
    "room": "704"
  },
  {
    "section": "24AIDSA4",
    "day": "Tuesday",
    "startTime": "08:30",
    "endTime": "09:20",
    "subject": "Operating Systems",
    "code": "24CSE408",
    "mentor": "Mrs. Keerthanasri",
    "room": "704"
  },
  {
    "section": "24AIDSA4",
    "day": "Tuesday",
    "startTime": "09:20",
    "endTime": "10:10",
    "subject": "Environmental Science",
    "code": "24MAC003",
    "mentor": "Dr. K. Rajalakshmi",
    "room": "704"
  },
  {
    "section": "24AIDSA4",
    "day": "Tuesday",
    "startTime": "10:10",
    "endTime": "11:00",
    "subject": "Discrete Mathematics",
    "code": "24MAT205",
    "mentor": "Mrs. N. Subashini",
    "room": "704"
  },
  {
    "section": "24AIDSA4",
    "day": "Tuesday",
    "startTime": "11:15",
    "endTime": "12:05",
    "subject": "Computational Intelligence",
    "code": "24AID502",
    "mentor": "Ms. P. Sudha",
    "room": "704"
  },
  {
    "section": "24AIDSA4",
    "day": "Tuesday",
    "startTime": "12:05",
    "endTime": "12:55",
    "subject": "Design Thinking",
    "code": "24CSE303",
    "mentor": "Mrs. N. Radha",
    "room": "704"
  },
  {
    "section": "24AIDSA4",
    "day": "Wednesday",
    "startTime": "08:30",
    "endTime": "09:20",
    "subject": "HRDC",
    "code": "HRDC",
    "mentor": "N/A",
    "room": "704"
  },
  {
    "section": "24AIDSA4",
    "day": "Wednesday",
    "startTime": "09:20",
    "endTime": "10:10",
    "subject": "Design and Analysis of Algorithms",
    "code": "24CSE407",
    "mentor": "Mr. K. Jeeva",
    "room": "704"
  },
  {
    "section": "24AIDSA4",
    "day": "Wednesday",
    "startTime": "10:10",
    "endTime": "11:00",
    "subject": "Computational Intelligence",
    "code": "24AID502",
    "mentor": "Ms. P. Sudha",
    "room": "704"
  },
  {
    "section": "24AIDSA4",
    "day": "Wednesday",
    "startTime": "11:15",
    "endTime": "12:05",
    "subject": "Introduction to Computational Biology",
    "code": "24OEC912",
    "mentor": "Mrs. K. Bharathi",
    "room": "704"
  },
  {
    "section": "24AIDSA4",
    "day": "Thursday",
    "startTime": "08:30",
    "endTime": "09:20",
    "subject": "Introduction to Computational Biology",
    "code": "24OEC912",
    "mentor": "Mrs. K. Bharathi",
    "room": "704"
  },
  {
    "section": "24AIDSA4",
    "day": "Thursday",
    "startTime": "09:20",
    "endTime": "10:10",
    "subject": "Computational Intelligence",
    "code": "24AID502",
    "mentor": "Ms. P. Sudha",
    "room": "704"
  },
  {
    "section": "24AIDSA4",
    "day": "Thursday",
    "startTime": "10:10",
    "endTime": "11:00",
    "subject": "Digital Electronics and Microprocessors",
    "code": "24ECE305",
    "mentor": "Mrs. Kalpana",
    "room": "704"
  },
  {
    "section": "24AIDSA4",
    "day": "Thursday",
    "startTime": "11:15",
    "endTime": "12:05",
    "subject": "Discrete Mathematics",
    "code": "24MAT205",
    "mentor": "Mrs. N. Subashini",
    "room": "704"
  },
  {
    "section": "24AIDSA4",
    "day": "Thursday",
    "startTime": "12:05",
    "endTime": "12:55",
    "subject": "Design and Analysis of Algorithms",
    "code": "24CSE407",
    "mentor": "Mr. K. Jeeva",
    "room": "704"
  },
  {
    "section": "24AIDSA4",
    "day": "Friday",
    "startTime": "08:30",
    "endTime": "09:20",
    "subject": "Environmental Science",
    "code": "24MAC003",
    "mentor": "Dr. K. Rajalakshmi",
    "room": "704"
  },
  {
    "section": "24AIDSA4",
    "day": "Friday",
    "startTime": "09:20",
    "endTime": "10:10",
    "subject": "Discrete Mathematics",
    "code": "24MAT205",
    "mentor": "Mrs. N. Subashini",
    "room": "704"
  },
  {
    "section": "24AIDSA4",
    "day": "Friday",
    "startTime": "10:10",
    "endTime": "11:00",
    "subject": "Operating Systems",
    "code": "24CSE408",
    "mentor": "Mrs. Keerthanasri",
    "room": "704"
  },
  {
    "section": "24AIDSA4",
    "day": "Friday",
    "startTime": "11:15",
    "endTime": "12:05",
    "subject": "Design Thinking",
    "code": "24CSE303",
    "mentor": "Mrs. N. Radha",
    "room": "704"
  },
  {
    "section": "24AIDSA4",
    "day": "Friday",
    "startTime": "12:05",
    "endTime": "12:55",
    "subject": "Digital Electronics and Microprocessors",
    "code": "24ECE305",
    "mentor": "Mrs. Kalpana",
    "room": "704"
  },
  {
    "section": "24AIDSA5",
    "day": "Monday",
    "startTime": "08:30",
    "endTime": "09:20",
    "subject": "Operating Systems",
    "code": "24CSE408",
    "mentor": "Mr. V. V. Sabeer",
    "room": "705"
  },
  {
    "section": "24AIDSA5",
    "day": "Monday",
    "startTime": "09:20",
    "endTime": "10:10",
    "subject": "Digital Electronics and Microprocessors",
    "code": "24ECE305",
    "mentor": "Mrs. S. Anitha",
    "room": "705"
  },
  {
    "section": "24AIDSA5",
    "day": "Monday",
    "startTime": "10:10",
    "endTime": "11:00",
    "subject": "Environmental Science",
    "code": "24MAC003",
    "mentor": "Dr. C. Bhaskar",
    "room": "705"
  },
  {
    "section": "24AIDSA5",
    "day": "Monday",
    "startTime": "11:15",
    "endTime": "12:05",
    "subject": "Computational Intelligence",
    "code": "24AID502",
    "mentor": "Ms. P. Sudha",
    "room": "705"
  },
  {
    "section": "24AIDSA5",
    "day": "Monday",
    "startTime": "12:05",
    "endTime": "12:55",
    "subject": "Discrete Mathematics",
    "code": "24MAT205",
    "mentor": "Dr. R. Abinaya",
    "room": "705"
  },
  {
    "section": "24AIDSA5",
    "day": "Tuesday",
    "startTime": "08:30",
    "endTime": "09:20",
    "subject": "Computational Intelligence",
    "code": "24AID502",
    "mentor": "Ms. P. Sudha",
    "room": "705"
  },
  {
    "section": "24AIDSA5",
    "day": "Tuesday",
    "startTime": "09:20",
    "endTime": "10:10",
    "subject": "Discrete Mathematics",
    "code": "24MAT205",
    "mentor": "Dr. R. Abinaya",
    "room": "705"
  },
  {
    "section": "24AIDSA5",
    "day": "Tuesday",
    "startTime": "10:10",
    "endTime": "11:00",
    "subject": "Design Thinking",
    "code": "24CSE303",
    "mentor": "Mrs. J. Anitha",
    "room": "705"
  },
  {
    "section": "24AIDSA5",
    "day": "Tuesday",
    "startTime": "11:15",
    "endTime": "12:05",
    "subject": "Introduction to Computational Biology",
    "code": "24OEC912",
    "mentor": "Mr. V. Vikram",
    "room": "705"
  },
  {
    "section": "24AIDSA5",
    "day": "Tuesday",
    "startTime": "12:05",
    "endTime": "12:55",
    "subject": "Design and Analysis of Algorithms",
    "code": "24CSE407",
    "mentor": "Mrs. M. Suguna",
    "room": "705"
  },
  {
    "section": "24AIDSA5",
    "day": "Wednesday",
    "startTime": "08:30",
    "endTime": "09:20",
    "subject": "Digital Electronics and Microprocessors",
    "code": "24ECE305",
    "mentor": "Mrs. S. Anitha",
    "room": "705"
  },
  {
    "section": "24AIDSA5",
    "day": "Wednesday",
    "startTime": "09:20",
    "endTime": "10:10",
    "subject": "Operating Systems",
    "code": "24CSE408",
    "mentor": "Mr. V. V. Sabeer",
    "room": "705"
  },
  {
    "section": "24AIDSA5",
    "day": "Wednesday",
    "startTime": "10:10",
    "endTime": "11:00",
    "subject": "Design and Analysis of Algorithms",
    "code": "24CSE407",
    "mentor": "Mrs. M. Suguna",
    "room": "705"
  },
  {
    "section": "24AIDSA5",
    "day": "Wednesday",
    "startTime": "11:15",
    "endTime": "12:05",
    "subject": "HRDC",
    "code": "HRDC",
    "mentor": "N/A",
    "room": "705"
  },
  {
    "section": "24AIDSA5",
    "day": "Wednesday",
    "startTime": "12:05",
    "endTime": "12:55",
    "subject": "Environmental Science",
    "code": "24MAC003",
    "mentor": "Dr. C. Bhaskar",
    "room": "705"
  },
  {
    "section": "24AIDSA5",
    "day": "Thursday",
    "startTime": "08:30",
    "endTime": "09:20",
    "subject": "Design and Analysis of Algorithms",
    "code": "24CSE407",
    "mentor": "Mrs. M. Suguna",
    "room": "705"
  },
  {
    "section": "24AIDSA5",
    "day": "Thursday",
    "startTime": "09:20",
    "endTime": "10:10",
    "subject": "Introduction to Computational Biology",
    "code": "24OEC912",
    "mentor": "Mr. V. Vikram",
    "room": "705"
  },
  {
    "section": "24AIDSA5",
    "day": "Thursday",
    "startTime": "10:10",
    "endTime": "11:00",
    "subject": "Discrete Mathematics",
    "code": "24MAT205",
    "mentor": "Dr. R. Abinaya",
    "room": "705"
  },
  {
    "section": "24AIDSA5",
    "day": "Thursday",
    "startTime": "11:15",
    "endTime": "12:05",
    "subject": "Operating Systems",
    "code": "24CSE408",
    "mentor": "Mr. V. V. Sabeer",
    "room": "705"
  },
  {
    "section": "24AIDSA5",
    "day": "Friday",
    "startTime": "08:30",
    "endTime": "09:20",
    "subject": "Discrete Mathematics",
    "code": "24MAT205",
    "mentor": "Dr. R. Abinaya",
    "room": "705"
  },
  {
    "section": "24AIDSA5",
    "day": "Friday",
    "startTime": "09:20",
    "endTime": "10:10",
    "subject": "Introduction to Computational Biology",
    "code": "24OEC912",
    "mentor": "Mr. V. Vikram",
    "room": "705"
  },
  {
    "section": "24AIDSA5",
    "day": "Friday",
    "startTime": "10:10",
    "endTime": "11:00",
    "subject": "Digital Electronics and Microprocessors",
    "code": "24ECE305",
    "mentor": "Mrs. S. Anitha",
    "room": "705"
  },
  {
    "section": "24AIDSA5",
    "day": "Friday",
    "startTime": "11:15",
    "endTime": "12:05",
    "subject": "Design Thinking",
    "code": "24CSE303",
    "mentor": "Mrs. J. Anitha",
    "room": "705"
  },
  {
    "section": "24AIDSA5",
    "day": "Friday",
    "startTime": "12:05",
    "endTime": "12:55",
    "subject": "Computational Intelligence",
    "code": "24AID502",
    "mentor": "Ms. P. Sudha",
    "room": "705"
  },
  {
    "section": "24AIDSB1",
    "day": "Monday",
    "startTime": "01:25",
    "endTime": "02:15",
    "subject": "Discrete Mathematics",
    "code": "24MAT205",
    "mentor": "New Faculty 4",
    "room": "701"
  },
  {
    "section": "24AIDSB1",
    "day": "Monday",
    "startTime": "02:15",
    "endTime": "03:05",
    "subject": "Computational Intelligence",
    "code": "24AID502",
    "mentor": "Ms. N. Pavithra",
    "room": "701"
  },
  {
    "section": "24AIDSB1",
    "day": "Monday",
    "startTime": "03:20",
    "endTime": "04:10",
    "subject": "Design and Analysis of Algorithms",
    "code": "24CSE407",
    "mentor": "Mrs. G. Mahalakshmi",
    "room": "701"
  },
  {
    "section": "24AIDSB1",
    "day": "Monday",
    "startTime": "04:10",
    "endTime": "05:00",
    "subject": "Digital Electronics and Microprocessors",
    "code": "24ECE305",
    "mentor": "Dr. V. Ramya",
    "room": "701"
  },
  {
    "section": "24AIDSB1",
    "day": "Tuesday",
    "startTime": "01:25",
    "endTime": "02:15",
    "subject": "Digital Electronics and Microprocessors",
    "code": "24ECE305",
    "mentor": "Dr. V. Ramya",
    "room": "701"
  },
  {
    "section": "24AIDSB1",
    "day": "Tuesday",
    "startTime": "02:15",
    "endTime": "03:05",
    "subject": "Introduction to Computational Biology",
    "code": "24OEC912",
    "mentor": "Ms. J. Jane Yazhini",
    "room": "701"
  },
  {
    "section": "24AIDSB1",
    "day": "Tuesday",
    "startTime": "03:20",
    "endTime": "04:10",
    "subject": "Operating Systems",
    "code": "24CSE408",
    "mentor": "Mrs. M. Suguna",
    "room": "701"
  },
  {
    "section": "24AIDSB1",
    "day": "Tuesday",
    "startTime": "04:10",
    "endTime": "05:00",
    "subject": "Discrete Mathematics",
    "code": "24MAT205",
    "mentor": "New Faculty 4",
    "room": "701"
  },
  {
    "section": "24AIDSB1",
    "day": "Tuesday",
    "startTime": "05:00",
    "endTime": "05:50",
    "subject": "Environmental Science",
    "code": "24MAC003",
    "mentor": "Mr. A. Azhaguvel",
    "room": "701"
  },
  {
    "section": "24AIDSB1",
    "day": "Wednesday",
    "startTime": "01:25",
    "endTime": "02:15",
    "subject": "HRDC",
    "code": "HRDC",
    "mentor": "N/A",
    "room": "701"
  },
  {
    "section": "24AIDSB1",
    "day": "Wednesday",
    "startTime": "02:15",
    "endTime": "03:05",
    "subject": "Computational Intelligence",
    "code": "24AID502",
    "mentor": "Ms. N. Pavithra",
    "room": "701"
  },
  {
    "section": "24AIDSB1",
    "day": "Wednesday",
    "startTime": "03:20",
    "endTime": "04:10",
    "subject": "Discrete Mathematics",
    "code": "24MAT205",
    "mentor": "New Faculty 4",
    "room": "701"
  },
  {
    "section": "24AIDSB1",
    "day": "Wednesday",
    "startTime": "04:10",
    "endTime": "05:00",
    "subject": "Design Thinking",
    "code": "24CSE303",
    "mentor": "Mrs. J. Anitha",
    "room": "701"
  },
  {
    "section": "24AIDSB1",
    "day": "Wednesday",
    "startTime": "05:00",
    "endTime": "05:50",
    "subject": "Design and Analysis of Algorithms",
    "code": "24CSE407",
    "mentor": "Mrs. G. Mahalakshmi",
    "room": "701"
  },
  {
    "section": "24AIDSB1",
    "day": "Thursday",
    "startTime": "01:25",
    "endTime": "02:15",
    "subject": "Design and Analysis of Algorithms",
    "code": "24CSE407",
    "mentor": "Mrs. G. Mahalakshmi",
    "room": "701"
  },
  {
    "section": "24AIDSB1",
    "day": "Thursday",
    "startTime": "02:15",
    "endTime": "03:05",
    "subject": "Digital Electronics and Microprocessors",
    "code": "24ECE305",
    "mentor": "Dr. V. Ramya",
    "room": "701"
  },
  {
    "section": "24AIDSB1",
    "day": "Thursday",
    "startTime": "03:20",
    "endTime": "04:10",
    "subject": "Introduction to Computational Biology",
    "code": "24OEC912",
    "mentor": "Ms. J. Jane Yazhini",
    "room": "701"
  },
  {
    "section": "24AIDSB1",
    "day": "Thursday",
    "startTime": "04:10",
    "endTime": "05:00",
    "subject": "Operating Systems",
    "code": "24CSE408",
    "mentor": "Mrs. M. Suguna",
    "room": "701"
  },
  {
    "section": "24AIDSB1",
    "day": "Thursday",
    "startTime": "05:00",
    "endTime": "05:50",
    "subject": "Discrete Mathematics",
    "code": "24MAT205",
    "mentor": "New Faculty 4",
    "room": "701"
  },
  {
    "section": "24AIDSB1",
    "day": "Friday",
    "startTime": "01:25",
    "endTime": "02:15",
    "subject": "Operating Systems",
    "code": "24CSE408",
    "mentor": "Mrs. M. Suguna",
    "room": "701"
  },
  {
    "section": "24AIDSB1",
    "day": "Friday",
    "startTime": "02:15",
    "endTime": "03:05",
    "subject": "Design Thinking",
    "code": "24CSE303",
    "mentor": "Mrs. J. Anitha",
    "room": "701"
  },
  {
    "section": "24AIDSB1",
    "day": "Friday",
    "startTime": "03:20",
    "endTime": "04:10",
    "subject": "Environmental Science",
    "code": "24MAC003",
    "mentor": "Mr. A. Azhaguvel",
    "room": "701"
  },
  {
    "section": "24AIDSB1",
    "day": "Friday",
    "startTime": "04:10",
    "endTime": "05:00",
    "subject": "Computational Intelligence",
    "code": "24AID502",
    "mentor": "Ms. N. Pavithra",
    "room": "701"
  },
  {
    "section": "24AIDSB1",
    "day": "Friday",
    "startTime": "05:00",
    "endTime": "05:50",
    "subject": "Introduction to Computational Biology",
    "code": "24OEC912",
    "mentor": "Ms. J. Jane Yazhini",
    "room": "701"
  },
  {
    "section": "24AIDSB2",
    "day": "Monday",
    "startTime": "01:25",
    "endTime": "02:15",
    "subject": "Computational Intelligence",
    "code": "24AID502",
    "mentor": "Mr. B. Shanawaz Baig",
    "room": "702"
  },
  {
    "section": "24AIDSB2",
    "day": "Monday",
    "startTime": "02:15",
    "endTime": "03:05",
    "subject": "Introduction to Computational Biology",
    "code": "24OEC912",
    "mentor": "Ms. J. Jane Yazhini",
    "room": "702"
  },
  {
    "section": "24AIDSB2",
    "day": "Monday",
    "startTime": "03:20",
    "endTime": "04:10",
    "subject": "Operating Systems",
    "code": "24CSE408",
    "mentor": "Mrs. Keerthanasri",
    "room": "702"
  },
  {
    "section": "24AIDSB2",
    "day": "Monday",
    "startTime": "04:10",
    "endTime": "05:00",
    "subject": "Design and Analysis of Algorithms",
    "code": "24CSE407",
    "mentor": "Mr. K. Jeeva",
    "room": "702"
  },
  {
    "section": "24AIDSB2",
    "day": "Monday",
    "startTime": "05:00",
    "endTime": "05:50",
    "subject": "Discrete Mathematics",
    "code": "24MAT205",
    "mentor": "New Faculty 2",
    "room": "702"
  },
  {
    "section": "24AIDSB2",
    "day": "Tuesday",
    "startTime": "01:25",
    "endTime": "02:15",
    "subject": "Digital Electronics and Microprocessors",
    "code": "24ECE305",
    "mentor": "Mrs. S. Antiha",
    "room": "702"
  },
  {
    "section": "24AIDSB2",
    "day": "Tuesday",
    "startTime": "02:15",
    "endTime": "03:05",
    "subject": "Environmental Science",
    "code": "24MAC003",
    "mentor": "Dr. A. Krishnamoorthy",
    "room": "702"
  },
  {
    "section": "24AIDSB2",
    "day": "Tuesday",
    "startTime": "03:20",
    "endTime": "04:10",
    "subject": "Discrete Mathematics",
    "code": "24MAT205",
    "mentor": "New Faculty 2",
    "room": "702"
  },
  {
    "section": "24AIDSB2",
    "day": "Tuesday",
    "startTime": "04:10",
    "endTime": "05:00",
    "subject": "Operating Systems",
    "code": "24CSE408",
    "mentor": "Mrs. Keerthanasri",
    "room": "702"
  },
  {
    "section": "24AIDSB2",
    "day": "Tuesday",
    "startTime": "05:00",
    "endTime": "05:50",
    "subject": "Design Thinking",
    "code": "24CSE303",
    "mentor": "Mr. V. V. Sabeer",
    "room": "702"
  },
  {
    "section": "24AIDSB2",
    "day": "Wednesday",
    "startTime": "01:25",
    "endTime": "02:15",
    "subject": "HRDC",
    "code": "HRDC",
    "mentor": "N/A",
    "room": "702"
  },
  {
    "section": "24AIDSB2",
    "day": "Wednesday",
    "startTime": "02:15",
    "endTime": "03:05",
    "subject": "Design Thinking",
    "code": "24CSE303",
    "mentor": "Mr. V. V. Sabeer",
    "room": "702"
  },
  {
    "section": "24AIDSB2",
    "day": "Wednesday",
    "startTime": "03:20",
    "endTime": "04:10",
    "subject": "Digital Electronics and Microprocessors",
    "code": "24ECE305",
    "mentor": "Mrs. S. Antiha",
    "room": "702"
  },
  {
    "section": "24AIDSB2",
    "day": "Wednesday",
    "startTime": "04:10",
    "endTime": "05:00",
    "subject": "Introduction to Computational Biology",
    "code": "24OEC912",
    "mentor": "Ms. J. Jane Yazhini",
    "room": "702"
  },
  {
    "section": "24AIDSB2",
    "day": "Wednesday",
    "startTime": "05:00",
    "endTime": "05:50",
    "subject": "Environmental Science",
    "code": "24MAC003",
    "mentor": "Dr. A. Krishnamoorthy",
    "room": "702"
  },
  {
    "section": "24AIDSB2",
    "day": "Thursday",
    "startTime": "01:25",
    "endTime": "02:15",
    "subject": "Design and Analysis of Algorithms",
    "code": "24CSE407",
    "mentor": "Mr. K. Jeeva",
    "room": "702"
  },
  {
    "section": "24AIDSB2",
    "day": "Thursday",
    "startTime": "02:15",
    "endTime": "03:05",
    "subject": "Computational Intelligence",
    "code": "24AID502",
    "mentor": "Mr. B. Shanawaz Baig",
    "room": "702"
  },
  {
    "section": "24AIDSB2",
    "day": "Thursday",
    "startTime": "03:20",
    "endTime": "04:10",
    "subject": "Digital Electronics and Microprocessors",
    "code": "24ECE305",
    "mentor": "Mrs. S. Antiha",
    "room": "702"
  },
  {
    "section": "24AIDSB2",
    "day": "Thursday",
    "startTime": "04:10",
    "endTime": "05:00",
    "subject": "Discrete Mathematics",
    "code": "24MAT205",
    "mentor": "New Faculty 2",
    "room": "702"
  },
  {
    "section": "24AIDSB2",
    "day": "Friday",
    "startTime": "01:25",
    "endTime": "02:15",
    "subject": "Discrete Mathematics",
    "code": "24MAT205",
    "mentor": "New Faculty 2",
    "room": "702"
  },
  {
    "section": "24AIDSB2",
    "day": "Friday",
    "startTime": "02:15",
    "endTime": "03:05",
    "subject": "Operating Systems",
    "code": "24CSE408",
    "mentor": "Mrs. Keerthanasri",
    "room": "702"
  },
  {
    "section": "24AIDSB2",
    "day": "Friday",
    "startTime": "03:20",
    "endTime": "04:10",
    "subject": "Design and Analysis of Algorithms",
    "code": "24CSE407",
    "mentor": "Mr. K. Jeeva",
    "room": "702"
  },
  {
    "section": "24AIDSB2",
    "day": "Friday",
    "startTime": "04:10",
    "endTime": "05:00",
    "subject": "Introduction to Computational Biology",
    "code": "24OEC912",
    "mentor": "Ms. J. Jane Yazhini",
    "room": "702"
  },
  {
    "section": "24AIDSB3",
    "day": "Monday",
    "startTime": "01:25",
    "endTime": "02:15",
    "subject": "Computational Intelligence",
    "code": "24AID502",
    "mentor": "Ms. P. Sudha",
    "room": "703"
  },
  {
    "section": "24AIDSB3",
    "day": "Monday",
    "startTime": "02:15",
    "endTime": "03:05",
    "subject": "Environmental Science",
    "code": "24MAC003",
    "mentor": "Dr. A. Kalaiyarasi",
    "room": "703"
  },
  {
    "section": "24AIDSB3",
    "day": "Monday",
    "startTime": "03:20",
    "endTime": "04:10",
    "subject": "Design and Analysis of Algorithms",
    "code": "24CSE407",
    "mentor": "Mr. J. Manivannan",
    "room": "703"
  },
  {
    "section": "24AIDSB3",
    "day": "Monday",
    "startTime": "04:10",
    "endTime": "05:00",
    "subject": "Design Thinking",
    "code": "24CSE303",
    "mentor": "Mr. V. V. Shabeer",
    "room": "703"
  },
  {
    "section": "24AIDSB3",
    "day": "Tuesday",
    "startTime": "01:25",
    "endTime": "02:15",
    "subject": "Digital Electronics and Microprocessors",
    "code": "24ECE305",
    "mentor": "Mrs. K. Kalpana",
    "room": "703"
  },
  {
    "section": "24AIDSB3",
    "day": "Tuesday",
    "startTime": "02:15",
    "endTime": "03:05",
    "subject": "Discrete Mathematics",
    "code": "24MAT205",
    "mentor": "New Faculty 3",
    "room": "703"
  },
  {
    "section": "24AIDSB3",
    "day": "Tuesday",
    "startTime": "03:20",
    "endTime": "04:10",
    "subject": "Computational Intelligence",
    "code": "24AID502",
    "mentor": "Ms. P. Sudha",
    "room": "703"
  },
  {
    "section": "24AIDSB3",
    "day": "Tuesday",
    "startTime": "04:10",
    "endTime": "05:00",
    "subject": "Operating Systems",
    "code": "24CSE408",
    "mentor": "Mr. Manivannan",
    "room": "703"
  },
  {
    "section": "24AIDSB3",
    "day": "Tuesday",
    "startTime": "05:00",
    "endTime": "05:50",
    "subject": "Introduction to Computational Biology",
    "code": "24OEC912",
    "mentor": "Ms. A. Winny",
    "room": "703"
  },
  {
    "section": "24AIDSB3",
    "day": "Wednesday",
    "startTime": "01:25",
    "endTime": "02:15",
    "subject": "Discrete Mathematics",
    "code": "24MAT205",
    "mentor": "New Faculty 3",
    "room": "703"
  },
  {
    "section": "24AIDSB3",
    "day": "Wednesday",
    "startTime": "02:15",
    "endTime": "03:05",
    "subject": "Operating Systems",
    "code": "24CSE408",
    "mentor": "Mr. Manivannan",
    "room": "703"
  },
  {
    "section": "24AIDSB3",
    "day": "Wednesday",
    "startTime": "03:20",
    "endTime": "04:10",
    "subject": "Digital Electronics and Microprocessors",
    "code": "24ECE305",
    "mentor": "Mrs. K. Kalpana",
    "room": "703"
  },
  {
    "section": "24AIDSB3",
    "day": "Wednesday",
    "startTime": "04:10",
    "endTime": "05:00",
    "subject": "Environmental Science",
    "code": "24MAC003",
    "mentor": "Dr. A. Kalaiyarasi",
    "room": "703"
  },
  {
    "section": "24AIDSB3",
    "day": "Thursday",
    "startTime": "01:25",
    "endTime": "02:15",
    "subject": "HRDC",
    "code": "HRDC",
    "mentor": "N/A",
    "room": "703"
  },
  {
    "section": "24AIDSB3",
    "day": "Thursday",
    "startTime": "02:15",
    "endTime": "03:05",
    "subject": "Design and Analysis of Algorithms",
    "code": "24CSE407",
    "mentor": "Mr. J. Manivannan",
    "room": "703"
  },
  {
    "section": "24AIDSB3",
    "day": "Thursday",
    "startTime": "03:20",
    "endTime": "04:10",
    "subject": "Computational Intelligence",
    "code": "24AID502",
    "mentor": "Ms. P. Sudha",
    "room": "703"
  },
  {
    "section": "24AIDSB3",
    "day": "Thursday",
    "startTime": "04:10",
    "endTime": "05:00",
    "subject": "Discrete Mathematics",
    "code": "24MAT205",
    "mentor": "New Faculty 3",
    "room": "703"
  },
  {
    "section": "24AIDSB3",
    "day": "Thursday",
    "startTime": "05:00",
    "endTime": "05:50",
    "subject": "Introduction to Computational Biology",
    "code": "24OEC912",
    "mentor": "Ms. A. Winny",
    "room": "703"
  },
  {
    "section": "24AIDSB3",
    "day": "Friday",
    "startTime": "01:25",
    "endTime": "02:15",
    "subject": "Introduction to Computational Biology",
    "code": "24OEC912",
    "mentor": "Ms. A. Winny",
    "room": "703"
  },
  {
    "section": "24AIDSB3",
    "day": "Friday",
    "startTime": "02:15",
    "endTime": "03:05",
    "subject": "Digital Electronics and Microprocessors",
    "code": "24ECE305",
    "mentor": "Mrs. K. Kalpana",
    "room": "703"
  },
  {
    "section": "24AIDSB3",
    "day": "Friday",
    "startTime": "03:20",
    "endTime": "04:10",
    "subject": "Operating Systems",
    "code": "24CSE408",
    "mentor": "Mr. Manivannan",
    "room": "703"
  },
  {
    "section": "24AIDSB3",
    "day": "Friday",
    "startTime": "04:10",
    "endTime": "05:00",
    "subject": "Design and Analysis of Algorithms",
    "code": "24CSE407",
    "mentor": "Mr. J. Manivannan",
    "room": "703"
  },
  {
    "section": "24AIDSB3",
    "day": "Friday",
    "startTime": "05:00",
    "endTime": "05:50",
    "subject": "Discrete Mathematics",
    "code": "24MAT205",
    "mentor": "New Faculty 3",
    "room": "703"
  },
  {
    "section": "24AIDSB4",
    "day": "Monday",
    "startTime": "01:25",
    "endTime": "02:15",
    "subject": "Design Thinking",
    "code": "24CSE303",
    "mentor": "Mr. J. Manivannan",
    "room": "704"
  },
  {
    "section": "24AIDSB4",
    "day": "Monday",
    "startTime": "02:15",
    "endTime": "03:05",
    "subject": "Discrete Mathematics",
    "code": "24MAT205",
    "mentor": "Mr. K. Keerthi Raj",
    "room": "704"
  },
  {
    "section": "24AIDSB4",
    "day": "Monday",
    "startTime": "03:20",
    "endTime": "04:10",
    "subject": "Introduction to Computational Biology",
    "code": "24OEC912",
    "mentor": "Ms. J. Jane Yazhini",
    "room": "704"
  },
  {
    "section": "24AIDSB4",
    "day": "Monday",
    "startTime": "04:10",
    "endTime": "05:00",
    "subject": "Computational Intelligence",
    "code": "24AID502",
    "mentor": "Ms. N. Pavithra",
    "room": "704"
  },
  {
    "section": "24AIDSB4",
    "day": "Monday",
    "startTime": "05:00",
    "endTime": "05:50",
    "subject": "Digital Electronics and Microprocessors",
    "code": "24ECE305",
    "mentor": "Dr. V. Ramya",
    "room": "704"
  },
  {
    "section": "24AIDSB4",
    "day": "Tuesday",
    "startTime": "01:25",
    "endTime": "02:15",
    "subject": "Computational Intelligence",
    "code": "24AID502",
    "mentor": "Ms. N. Pavithra",
    "room": "704"
  },
  {
    "section": "24AIDSB4",
    "day": "Tuesday",
    "startTime": "02:15",
    "endTime": "03:05",
    "subject": "Environmental Science",
    "code": "24MAC003",
    "mentor": "Dr. L. Bhuvana",
    "room": "704"
  },
  {
    "section": "24AIDSB4",
    "day": "Tuesday",
    "startTime": "03:20",
    "endTime": "04:10",
    "subject": "Design and Analysis of Algorithms",
    "code": "24CSE407",
    "mentor": "Mrs. G. Mahalakshmi",
    "room": "704"
  },
  {
    "section": "24AIDSB4",
    "day": "Tuesday",
    "startTime": "04:10",
    "endTime": "05:00",
    "subject": "Operating Systems",
    "code": "24CSE408",
    "mentor": "Mrs. M. Suguna",
    "room": "704"
  },
  {
    "section": "24AIDSB4",
    "day": "Tuesday",
    "startTime": "05:00",
    "endTime": "05:50",
    "subject": "Discrete Mathematics",
    "code": "24MAT205",
    "mentor": "Mr. K. Keerthi Raj",
    "room": "704"
  },
  {
    "section": "24AIDSB4",
    "day": "Wednesday",
    "startTime": "01:25",
    "endTime": "02:15",
    "subject": "Discrete Mathematics",
    "code": "24MAT205",
    "mentor": "Mr. K. Keerthi Raj",
    "room": "704"
  },
  {
    "section": "24AIDSB4",
    "day": "Wednesday",
    "startTime": "02:15",
    "endTime": "03:05",
    "subject": "Operating Systems",
    "code": "24CSE408",
    "mentor": "Mrs. M. Suguna",
    "room": "704"
  },
  {
    "section": "24AIDSB4",
    "day": "Wednesday",
    "startTime": "03:20",
    "endTime": "04:10",
    "subject": "Digital Electronics and Microprocessors",
    "code": "24ECE305",
    "mentor": "Dr. V. Ramya",
    "room": "704"
  },
  {
    "section": "24AIDSB4",
    "day": "Wednesday",
    "startTime": "04:10",
    "endTime": "05:00",
    "subject": "Introduction to Computational Biology",
    "code": "24OEC912",
    "mentor": "Ms. J. Jane Yazhini",
    "room": "704"
  },
  {
    "section": "24AIDSB4",
    "day": "Wednesday",
    "startTime": "05:00",
    "endTime": "05:50",
    "subject": "Design and Analysis of Algorithms",
    "code": "24CSE407",
    "mentor": "Mrs. G. Mahalakshmi",
    "room": "704"
  },
  {
    "section": "24AIDSB4",
    "day": "Thursday",
    "startTime": "01:25",
    "endTime": "02:15",
    "subject": "HRDC",
    "code": "HRDC",
    "mentor": "N/A",
    "room": "704"
  },
  {
    "section": "24AIDSB4",
    "day": "Thursday",
    "startTime": "02:15",
    "endTime": "03:05",
    "subject": "Introduction to Computational Biology",
    "code": "24OEC912",
    "mentor": "Ms. J. Jane Yazhini",
    "room": "704"
  },
  {
    "section": "24AIDSB4",
    "day": "Thursday",
    "startTime": "03:20",
    "endTime": "04:10",
    "subject": "Design and Analysis of Algorithms",
    "code": "24CSE407",
    "mentor": "Mrs. G. Mahalakshmi",
    "room": "704"
  },
  {
    "section": "24AIDSB4",
    "day": "Thursday",
    "startTime": "04:10",
    "endTime": "05:00",
    "subject": "Environmental Science",
    "code": "24MAC003",
    "mentor": "Dr. L. Bhuvana",
    "room": "704"
  },
  {
    "section": "24AIDSB4",
    "day": "Thursday",
    "startTime": "05:00",
    "endTime": "05:50",
    "subject": "Design Thinking",
    "code": "24CSE303",
    "mentor": "Mr. J. Manivannan",
    "room": "704"
  },
  {
    "section": "24AIDSB4",
    "day": "Friday",
    "startTime": "01:25",
    "endTime": "02:15",
    "subject": "Digital Electronics and Microprocessors",
    "code": "24ECE305",
    "mentor": "Dr. V. Ramya",
    "room": "704"
  },
  {
    "section": "24AIDSB4",
    "day": "Friday",
    "startTime": "02:15",
    "endTime": "03:05",
    "subject": "Computational Intelligence",
    "code": "24AID502",
    "mentor": "Ms. N. Pavithra",
    "room": "704"
  },
  {
    "section": "24AIDSB4",
    "day": "Friday",
    "startTime": "03:20",
    "endTime": "04:10",
    "subject": "Discrete Mathematics",
    "code": "24MAT205",
    "mentor": "Mr. K. Keerthi Raj",
    "room": "704"
  },
  {
    "section": "24AIDSB4",
    "day": "Friday",
    "startTime": "04:10",
    "endTime": "05:00",
    "subject": "Operating Systems",
    "code": "24CSE408",
    "mentor": "Mrs. M. Suguna",
    "room": "704"
  },
  {
    "section": "24AIDSB5",
    "day": "Monday",
    "startTime": "01:25",
    "endTime": "02:15",
    "subject": "HRDC",
    "code": "HRDC",
    "mentor": "N/A",
    "room": "705"
  },
  {
    "section": "24AIDSB5",
    "day": "Monday",
    "startTime": "02:15",
    "endTime": "03:05",
    "subject": "Computational Intelligence",
    "code": "24AID502",
    "mentor": "Ms. N. Pavithra",
    "room": "705"
  },
  {
    "section": "24AIDSB5",
    "day": "Monday",
    "startTime": "03:20",
    "endTime": "04:10",
    "subject": "Digital Electronics and Microprocessors",
    "code": "24ECE305",
    "mentor": "Mr. V. Vivek",
    "room": "705"
  },
  {
    "section": "24AIDSB5",
    "day": "Monday",
    "startTime": "04:10",
    "endTime": "05:00",
    "subject": "Environmental Science",
    "code": "24MAC003",
    "mentor": "Dr. C. Bhaskar",
    "room": "705"
  },
  {
    "section": "24AIDSB5",
    "day": "Monday",
    "startTime": "05:00",
    "endTime": "05:50",
    "subject": "Design and Analysis of Algorithms",
    "code": "24CSE407",
    "mentor": "Mrs. G. Mahalakshmi",
    "room": "705"
  },
  {
    "section": "24AIDSB5",
    "day": "Tuesday",
    "startTime": "01:25",
    "endTime": "02:15",
    "subject": "Design Thinking",
    "code": "24CSE303",
    "mentor": "Mrs. J. Anitha",
    "room": "705"
  },
  {
    "section": "24AIDSB5",
    "day": "Tuesday",
    "startTime": "02:15",
    "endTime": "03:05",
    "subject": "Discrete Mathematics",
    "code": "24MAT205",
    "mentor": "New Faculty 4",
    "room": "705"
  },
  {
    "section": "24AIDSB5",
    "day": "Tuesday",
    "startTime": "03:20",
    "endTime": "04:10",
    "subject": "Digital Electronics and Microprocessors",
    "code": "24ECE305",
    "mentor": "Mr. V. Vivek",
    "room": "705"
  },
  {
    "section": "24AIDSB5",
    "day": "Tuesday",
    "startTime": "04:10",
    "endTime": "05:00",
    "subject": "Introduction to Computational Biology",
    "code": "24OEC912",
    "mentor": "Ms. A. Winny",
    "room": "705"
  },
  {
    "section": "24AIDSB5",
    "day": "Wednesday",
    "startTime": "01:25",
    "endTime": "02:15",
    "subject": "Design and Analysis of Algorithms",
    "code": "24CSE407",
    "mentor": "Mrs. G. Mahalakshmi",
    "room": "705"
  },
  {
    "section": "24AIDSB5",
    "day": "Wednesday",
    "startTime": "02:15",
    "endTime": "03:05",
    "subject": "Computational Intelligence",
    "code": "24AID502",
    "mentor": "Ms. N. Pavithra",
    "room": "705"
  },
  {
    "section": "24AIDSB5",
    "day": "Wednesday",
    "startTime": "03:20",
    "endTime": "04:10",
    "subject": "Operating Systems",
    "code": "24CSE408",
    "mentor": "Mr. V. V. Sabeer",
    "room": "705"
  },
  {
    "section": "24AIDSB5",
    "day": "Wednesday",
    "startTime": "04:10",
    "endTime": "05:00",
    "subject": "Discrete Mathematics",
    "code": "24MAT205",
    "mentor": "New Faculty 4",
    "room": "705"
  },
  {
    "section": "24AIDSB5",
    "day": "Thursday",
    "startTime": "01:25",
    "endTime": "02:15",
    "subject": "Environmental Science",
    "code": "24MAC003",
    "mentor": "Dr. C. Bhaskar",
    "room": "705"
  },
  {
    "section": "24AIDSB5",
    "day": "Thursday",
    "startTime": "02:15",
    "endTime": "03:05",
    "subject": "Design Thinking",
    "code": "24CSE303",
    "mentor": "Mrs. J. Anitha",
    "room": "705"
  },
  {
    "section": "24AIDSB5",
    "day": "Thursday",
    "startTime": "03:20",
    "endTime": "04:10",
    "subject": "Computational Intelligence",
    "code": "24AID502",
    "mentor": "Ms. N. Pavithra",
    "room": "705"
  },
  {
    "section": "24AIDSB5",
    "day": "Thursday",
    "startTime": "04:10",
    "endTime": "05:00",
    "subject": "Operating Systems",
    "code": "24CSE408",
    "mentor": "Mr. V. V. Sabeer",
    "room": "705"
  },
  {
    "section": "24AIDSB5",
    "day": "Thursday",
    "startTime": "05:00",
    "endTime": "05:50",
    "subject": "Introduction to Computational Biology",
    "code": "24OEC912",
    "mentor": "Ms. A. Winny",
    "room": "705"
  },
  {
    "section": "24AIDSB5",
    "day": "Friday",
    "startTime": "01:25",
    "endTime": "02:15",
    "subject": "Discrete Mathematics",
    "code": "24MAT205",
    "mentor": "New Faculty 4",
    "room": "705"
  },
  {
    "section": "24AIDSB5",
    "day": "Friday",
    "startTime": "02:15",
    "endTime": "03:05",
    "subject": "Introduction to Computational Biology",
    "code": "24OEC912",
    "mentor": "Ms. A. Winny",
    "room": "705"
  },
  {
    "section": "24AIDSB5",
    "day": "Friday",
    "startTime": "03:20",
    "endTime": "04:10",
    "subject": "Design and Analysis of Algorithms",
    "code": "24CSE407",
    "mentor": "Mrs. G. Mahalakshmi",
    "room": "705"
  },
  {
    "section": "24AIDSB5",
    "day": "Friday",
    "startTime": "04:10",
    "endTime": "05:00",
    "subject": "Digital Electronics and Microprocessors",
    "code": "24ECE305",
    "mentor": "Mr. V. Vivek",
    "room": "705"
  },
  {
    "section": "24AIDSB5",
    "day": "Friday",
    "startTime": "05:00",
    "endTime": "05:50",
    "subject": "Operating Systems",
    "code": "24CSE408",
    "mentor": "Mr. V. V. Sabeer",
    "room": "705"
  }
]''';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ImportApp());
}

class ImportApp extends StatelessWidget {
  const ImportApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ImportScreen(),
    );
  }
}

class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key});

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  String _status = "Initializing...";
  bool _isDone = false;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _runImport();
  }

  Future<void> _runImport() async {
    try {
      setState(() => _status = "Decoding data...");
      await Future.delayed(const Duration(milliseconds: 500));
      
      final List<dynamic> classes = jsonDecode(jsonData);
      
      final firestore = FirebaseFirestore.instance;

      setState(() => _status = "Clearing existing schedule data (this may take a while)...");
      await Future.delayed(const Duration(milliseconds: 500));
      
      final deptRef = firestore.collection('departments').doc('school-of-engineering-and-technology');
      final yearRef = deptRef.collection('years').doc('2024');
      final sectionsSnapshot = await yearRef.collection('sections').get();

      // We'll process deletions in batches or one by one with delays to avoid UI freeze
      int totalSectionsToClear = sectionsSnapshot.docs.length;
      int sectionsCleared = 0;

      for (var sectionDoc in sectionsSnapshot.docs) {
        final scheduleSnapshot = await sectionDoc.reference.collection('schedule').get();
        
        WriteBatch batch = firestore.batch();
        int opCount = 0;
        
        for (var classDoc in scheduleSnapshot.docs) {
          batch.delete(classDoc.reference);
          opCount++;
          
          if (opCount == 500) {
             await batch.commit();
             batch = firestore.batch();
             opCount = 0;
          }
        }
        if (opCount > 0) {
           await batch.commit();
        }
        
        sectionsCleared++;
        setState(() => _status = "Cleared \${sectionsCleared} / \${totalSectionsToClear} old sections...");
      }

      setState(() => _status = "Importing new classes...");
      int importedCount = 0;
      final departmentName = 'School of Engineering and Technology';
      final yearName = '2024';

      for (int i = 0; i < classes.length; i++) {
        var classData = classes[i];
        final sectionName = classData['section'];
        if (sectionName == null) continue;

        await deptRef.set({'name': departmentName, 'code': 'SET'}, SetOptions(merge: true));
        await yearRef.set({'name': yearName}, SetOptions(merge: true));
        
        final sectionRef = yearRef.collection('sections').doc(sectionName);
        await sectionRef.set({'name': sectionName}, SetOptions(merge: true));

        await sectionRef.collection('schedule').add({
          'subject': classData['subject'],
          'code': classData['code'],
          'mentor': classData['mentor'],
          'room': classData['room'],
          'day': classData['day'],
          'startTime': classData['startTime'],
          'endTime': classData['endTime'],
        });
        importedCount++;
        
        if (i % 5 == 0) { // Update UI less frequently to avoid lag
           setState(() {
               _progress = (i + 1) / classes.length;
               _status = "Imported \$importedCount/\${classes.length}\n\${classData['subject']} (\${classData['day']})";
           });
           await Future.delayed(const Duration(milliseconds: 10)); // Yield to event loop
        }
      }

      setState(() {
        _progress = 1.0;
        _status = "✅ Successfully imported \$importedCount classes!\nYou can close this app now and run your main app.";
        _isDone = true;
      });
      print('--- Finished importing \$importedCount classes for all days. ---');
    } catch (e) {
      setState(() {
        _status = "❌ Error:\n\$e";
        _isDone = true;
      });
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Updating Timetable Data')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isDone) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                LinearProgressIndicator(value: _progress),
                const SizedBox(height: 20),
              ] else ...[
                const Icon(Icons.check_circle, color: Colors.green, size: 80),
                const SizedBox(height: 20),
              ],
              Text(
                _status, 
                textAlign: TextAlign.center, 
                style: const TextStyle(fontSize: 18)
              ),
            ],
          ),
        ),
      ),
    );
  }
}
