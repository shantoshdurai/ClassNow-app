// Minimal stroke icon set — no external libs
const Icon = ({ path, size = 20, stroke = 'currentColor', fill = 'none', sw = 1.6, style = {} }) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill={fill} stroke={stroke}
    strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" style={style}>
    {path}
  </svg>
);

const I = {
  Bell:     (p) => <Icon {...p} path={<><path d="M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9"/><path d="M10.3 21a1.94 1.94 0 0 0 3.4 0"/></>} />,
  Lock:     (p) => <Icon {...p} path={<><rect x="4" y="11" width="16" height="10" rx="2"/><path d="M8 11V7a4 4 0 1 1 8 0v4"/></>} />,
  Plus:     (p) => <Icon {...p} path={<><path d="M12 5v14M5 12h14"/></>} />,
  Wand:     (p) => <Icon {...p} path={<><path d="M15 4V2M15 10V8M12.5 6.5H11M19 6.5h-1.5M4 20 16 8l-4-4L0 16"/></>} />,
  Pin:      (p) => <Icon {...p} path={<><path d="M12 21s-7-6-7-11a7 7 0 1 1 14 0c0 5-7 11-7 11Z"/><circle cx="12" cy="10" r="2.5"/></>} />,
  User:     (p) => <Icon {...p} path={<><circle cx="12" cy="8" r="4"/><path d="M4 21a8 8 0 0 1 16 0"/></>} />,
  Chat:     (p) => <Icon {...p} path={<><path d="M21 15a2 2 0 0 1-2 2H8l-5 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2Z"/></>} />,
  Clock:    (p) => <Icon {...p} path={<><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/></>} />,
  ChevR:    (p) => <Icon {...p} path={<><path d="m9 6 6 6-6 6"/></>} />,
  ChevL:    (p) => <Icon {...p} path={<><path d="m15 6-6 6 6 6"/></>} />,
  Search:   (p) => <Icon {...p} path={<><circle cx="11" cy="11" r="7"/><path d="m21 21-4.3-4.3"/></>} />,
  Moon:     (p) => <Icon {...p} path={<><path d="M20 14.5A8 8 0 1 1 9.5 4a7 7 0 0 0 10.5 10.5Z"/></>} />,
  Sun:      (p) => <Icon {...p} path={<><circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M4.93 4.93l1.42 1.42M17.66 17.66l1.41 1.41M2 12h2M20 12h2M4.93 19.07l1.42-1.42M17.66 6.34l1.41-1.41"/></>} />,
  Check:    (p) => <Icon {...p} path={<><path d="m5 12 5 5L20 7"/></>} />,
  Cog:      (p) => <Icon {...p} path={<><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 1 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 1 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 1 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.6 1.65 1.65 0 0 0 10 3.09V3a2 2 0 1 1 4 0v.09A1.65 1.65 0 0 0 15 4.6a1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 1 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 1 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1Z"/></>} />,
  Door:     (p) => <Icon {...p} path={<><path d="M4 21h16M6 21V4a1 1 0 0 1 1-1h10a1 1 0 0 1 1 1v17"/><circle cx="15" cy="12" r="1" fill="currentColor"/></>} />,
  Map:      (p) => <Icon {...p} path={<><path d="M9 3 3 5v16l6-2 6 2 6-2V3l-6 2Z"/><path d="M9 3v16M15 5v16"/></>} />,
  Arrow:    (p) => <Icon {...p} path={<><path d="M5 12h14M13 6l6 6-6 6"/></>} />,
  Book:     (p) => <Icon {...p} path={<><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20V3H6.5A2.5 2.5 0 0 0 4 5.5Z"/></>} />,
  Flame:    (p) => <Icon {...p} path={<><path d="M12 2s4 4 4 8a4 4 0 0 1-8 0 4 4 0 0 1 2-3.5C11 10 12 8 12 2Z"/><path d="M12 22a6 6 0 0 0 6-6c0-2-1-3-2-4 0 2-2 3-4 3s-4-1-4-3c-1 1-2 2-2 4a6 6 0 0 0 6 6Z"/></>} />,
  Grid:     (p) => <Icon {...p} path={<><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/></>} />,
  List:     (p) => <Icon {...p} path={<><path d="M8 6h13M8 12h13M8 18h13M3 6h.01M3 12h.01M3 18h.01"/></>} />,
  Share:    (p) => <Icon {...p} path={<><path d="M4 12v7a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-7"/><path d="M16 6 12 2 8 6M12 2v14"/></>} />,
  Log:      (p) => <Icon {...p} path={<><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4M16 17l5-5-5-5M21 12H9"/></>} />,
  Star:     (p) => <Icon {...p} path={<><path d="m12 2 3 7 7 .5-5.5 4.5L18 21l-6-4-6 4 1.5-7L2 9.5 9 9Z"/></>} />,
  Badge:    (p) => <Icon {...p} path={<><circle cx="12" cy="8" r="6"/><path d="M8.5 13 7 22l5-3 5 3-1.5-9"/></>} />,
};

Object.assign(window, { Icon, I });
