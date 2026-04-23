// Shared data for the ClassNow redesign

const TODAY_LABEL = "Tue · 21 Apr";
const DAYS = [
  { key: 'Mon', date: 20 },
  { key: 'Tue', date: 21, active: true },
  { key: 'Wed', date: 22 },
  { key: 'Thu', date: 23 },
  { key: 'Fri', date: 24 },
  { key: 'Sat', date: 25, off: true },
];

// Subject color map (used subtly, not as heavy fills)
const SUBJECT_TONES = {
  'Operating Systems':       { hue: 'OS',  ink: '#6E4CF5' },
  'Environmental Science':   { hue: 'ES',  ink: '#2C8D5E' },
  'Discrete Mathematics':    { hue: 'DM',  ink: '#C2410C' },
  'Computational Intelligence': { hue: 'CI', ink: '#0369A1' },
  'Design Thinking':         { hue: 'DT',  ink: '#B91C6B' },
  'Break':                   { hue: '·',   ink: '#99938A' },
};

// Master schedule — a day of classes
const SCHEDULE = [
  { start: '08:30', end: '09:20', title: 'Operating Systems',       mentor: 'Mrs. Keerthanasri',  room: '704', block: 'Main Block',    code: 'CS31', status: 'done' },
  { start: '09:20', end: '10:10', title: 'Environmental Science',   mentor: 'Dr. K. Rajalakshmi', room: '704', block: 'Main Block',    code: 'CH11', status: 'done' },
  { start: '10:10', end: '11:00', title: 'Discrete Mathematics',    mentor: 'Mrs. N. Subashini',  room: '704', block: 'Main Block',    code: 'MA21', status: 'now' },
  { start: '11:00', end: '11:15', title: 'Break',                   mentor: null,                 room: null,  block: null,            code: null,    status: 'break' },
  { start: '11:15', end: '12:05', title: 'Computational Intelligence', mentor: 'Ms. P. Sudha',     room: '704', block: 'Main Block',    code: 'CS42', status: 'next' },
  { start: '12:05', end: '12:55', title: 'Design Thinking',         mentor: 'Mrs. N. Radha',      room: '612', block: 'Studio',        code: 'DS10', status: 'later' },
];

// User profile
const USER = {
  name: 'Aarav Rao',
  handle: '22csa117',
  program: 'B.Tech · CSE (AI)',
  year: '3rd Year · Semester 6',
  avatarInitials: 'AR',
  streak: 18,
  attendance: 87,
};

Object.assign(window, { TODAY_LABEL, DAYS, SUBJECT_TONES, SCHEDULE, USER });
