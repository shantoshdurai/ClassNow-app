// ─────────────────────────────────────────────────────────────
// VARIATION A — "PAPER"
// Editorial light UI, warm off-white, serif display, mono times
// ─────────────────────────────────────────────────────────────

const paper = {
  bg: '#F6F2EA',
  paper: '#FBF8F1',
  ink: '#15130F',
  ink2: '#3C382F',
  muted: '#7D7668',
  faint: '#D9D2C2',
  line: '#E7E1D2',
  accent: 'oklch(62% 0.18 48)', // amber
  accentSoft: 'oklch(94% 0.04 48)',
  accentInk: 'oklch(35% 0.12 48)',
  serif: '"Fraunces", "GT Sectra", "Playfair Display", Georgia, serif',
  sans:  '"Inter", -apple-system, system-ui, sans-serif',
  mono:  '"JetBrains Mono", ui-monospace, SFMono-Regular, monospace',
};

// ─ Status bar (paper theme) ─
function PaperStatus() {
  return (
    <div style={{
      height: 36, display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      padding: '0 22px', fontFamily: paper.mono, fontSize: 12, color: paper.ink, position: 'relative', letterSpacing: 0.4,
    }}>
      <span>9:30</span>
      <div style={{position:'absolute',left:'50%',top:10,transform:'translateX(-50%)',width:18,height:18,borderRadius:100,background:'#1a1a1a'}} />
      <div style={{display:'flex',alignItems:'center',gap:6,fontSize:11}}>
        <span>5G</span>
        <svg width="14" height="10" viewBox="0 0 14 10"><rect x="0.5" y="0.5" width="11" height="9" rx="1.5" stroke={paper.ink} fill="none"/><rect x="2" y="2" width="8" height="6" rx="0.5" fill={paper.ink}/><rect x="12" y="3.5" width="1.5" height="3" fill={paper.ink}/></svg>
      </div>
    </div>
  );
}

// ─ Tiny weekday pill ─
function PaperDay({ d }) {
  const active = d.active;
  return (
    <div style={{
      flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4,
      padding: '10px 0 8px', cursor: 'pointer',
      background: active ? paper.ink : 'transparent',
      color: active ? paper.paper : paper.ink,
      borderRadius: 14,
      opacity: d.off ? 0.35 : 1,
    }}>
      <span style={{fontFamily:paper.mono,fontSize:10,letterSpacing:1.2,textTransform:'uppercase',opacity:0.6}}>{d.key}</span>
      <span style={{fontFamily:paper.serif,fontSize:22,fontWeight:500,lineHeight:1}}>{d.date}</span>
    </div>
  );
}

// ─ Schedule row (timeline spine) ─
function PaperClass({ c, first, last }) {
  const isNow = c.status === 'now';
  const isDone = c.status === 'done';
  const isBreak = c.status === 'break';
  if (isBreak) {
    return (
      <div style={{display:'grid',gridTemplateColumns:'64px 1fr',gap:14,alignItems:'center',padding:'6px 0'}}>
        <div style={{fontFamily:paper.mono,fontSize:11,color:paper.muted,textAlign:'right'}}>{c.start}</div>
        <div style={{display:'flex',alignItems:'center',gap:10,color:paper.muted,fontSize:12,letterSpacing:0.5,textTransform:'uppercase'}}>
          <span style={{flex:1,height:1,background:paper.line}}/>
          <span style={{fontFamily:paper.mono}}>Break · {parseInt(c.end)-parseInt(c.start)}m… but actually 15m</span>
        </div>
      </div>
    );
  }
  return (
    <div style={{display:'grid',gridTemplateColumns:'64px 1fr',gap:14,alignItems:'stretch'}}>
      {/* left time + spine */}
      <div style={{position:'relative',paddingTop:14}}>
        <div style={{fontFamily:paper.mono,fontSize:11,color:isNow?paper.accentInk:paper.ink,textAlign:'right',lineHeight:1.2}}>
          {c.start}
        </div>
        <div style={{fontFamily:paper.mono,fontSize:10,color:paper.muted,textAlign:'right',marginTop:2}}>{c.end}</div>
        {/* dot */}
        <div style={{
          position:'absolute',right:-6,top:18,width:10,height:10,borderRadius:20,
          background: isNow ? paper.accent : (isDone ? paper.faint : paper.paper),
          border: `2px solid ${isNow ? paper.accent : paper.ink}`,
          boxShadow: isNow ? `0 0 0 4px ${paper.accentSoft}` : 'none',
        }}/>
        {/* spine */}
        {!last && <div style={{position:'absolute',right:-2,top:28,bottom:-4,width:1,background:paper.line}}/>}
      </div>
      {/* right: card */}
      <div style={{
        background: isNow ? paper.paper : 'transparent',
        border: isNow ? `1px solid ${paper.line}` : 'none',
        borderRadius: 18,
        padding: isNow ? '16px 18px' : '10px 0 18px',
        position: 'relative',
        boxShadow: isNow ? '0 1px 0 rgba(0,0,0,0.02), 0 12px 24px -18px rgba(0,0,0,0.25)' : 'none',
        opacity: isDone ? 0.55 : 1,
      }}>
        {isNow && (
          <div style={{display:'flex',alignItems:'center',gap:6,marginBottom:6}}>
            <span style={{width:6,height:6,borderRadius:10,background:paper.accent,boxShadow:`0 0 0 3px ${paper.accentSoft}`}}/>
            <span style={{fontFamily:paper.mono,fontSize:10,letterSpacing:1.5,textTransform:'uppercase',color:paper.accentInk,fontWeight:600}}>In session · 28m left</span>
          </div>
        )}
        <div style={{fontFamily:paper.serif,fontSize:isNow?24:18,fontWeight:500,color:paper.ink,letterSpacing:-0.3,lineHeight:1.15, textDecoration: isDone?'line-through':'none'}}>{c.title}</div>
        <div style={{display:'flex',alignItems:'center',gap:14,marginTop:6,fontFamily:paper.sans,fontSize:12,color:paper.muted}}>
          <span>{c.mentor}</span>
          <span style={{color:paper.faint}}>·</span>
          <span style={{fontFamily:paper.mono}}>Room {c.room}</span>
          <span style={{color:paper.faint}}>·</span>
          <span style={{fontFamily:paper.mono,letterSpacing:0.5}}>{c.code}</span>
        </div>
        {isNow && (
          <div style={{display:'flex',gap:8,marginTop:14}}>
            <button style={{flex:1,background:paper.ink,color:paper.paper,border:'none',borderRadius:12,padding:'10px 12px',fontFamily:paper.sans,fontSize:12,fontWeight:600,letterSpacing:0.2,cursor:'pointer',display:'flex',alignItems:'center',justifyContent:'center',gap:6}}>
              <I.Map size={14}/> Directions
            </button>
            <button style={{flex:1,background:'transparent',color:paper.ink,border:`1px solid ${paper.line}`,borderRadius:12,padding:'10px 12px',fontFamily:paper.sans,fontSize:12,fontWeight:600,letterSpacing:0.2,cursor:'pointer',display:'flex',alignItems:'center',justifyContent:'center',gap:6}}>
              <I.Book size={14}/> Notes
            </button>
          </div>
        )}
      </div>
    </div>
  );
}

// ─ Full Paper dashboard ─
function PaperDashboard() {
  return (
    <div style={{background:paper.bg,minHeight:'100%',fontFamily:paper.sans,color:paper.ink,paddingBottom:100}}>
      <PaperStatus/>

      {/* Header */}
      <div style={{padding:'10px 22px 8px',display:'flex',alignItems:'center',justifyContent:'space-between'}}>
        <div>
          <div style={{fontFamily:paper.mono,fontSize:10,letterSpacing:1.5,textTransform:'uppercase',color:paper.muted}}>Today</div>
          <div style={{fontFamily:paper.serif,fontSize:28,fontWeight:500,color:paper.ink,letterSpacing:-0.6,marginTop:2}}>Tuesday, 21</div>
        </div>
        <div style={{display:'flex',gap:6}}>
          <button style={{width:40,height:40,borderRadius:14,border:`1px solid ${paper.line}`,background:paper.paper,display:'flex',alignItems:'center',justifyContent:'center',color:paper.ink,cursor:'pointer'}}><I.Search size={18}/></button>
          <button style={{width:40,height:40,borderRadius:14,border:`1px solid ${paper.line}`,background:paper.paper,display:'flex',alignItems:'center',justifyContent:'center',color:paper.ink,cursor:'pointer',position:'relative'}}>
            <I.Bell size={18}/>
            <span style={{position:'absolute',top:10,right:10,width:6,height:6,borderRadius:10,background:paper.accent}}/>
          </button>
        </div>
      </div>

      {/* Week strip */}
      <div style={{display:'flex',gap:4,padding:'10px 18px 18px'}}>
        {DAYS.map(d => <PaperDay key={d.key} d={d}/>)}
      </div>

      {/* Hero stats strip */}
      <div style={{margin:'0 22px 22px',display:'grid',gridTemplateColumns:'1fr 1fr 1fr',background:paper.paper,border:`1px solid ${paper.line}`,borderRadius:18,padding:'14px 4px'}}>
        <div style={{textAlign:'center',borderRight:`1px solid ${paper.line}`}}>
          <div style={{fontFamily:paper.serif,fontSize:22,fontWeight:500}}>6</div>
          <div style={{fontFamily:paper.mono,fontSize:9,letterSpacing:1.2,textTransform:'uppercase',color:paper.muted,marginTop:2}}>Classes</div>
        </div>
        <div style={{textAlign:'center',borderRight:`1px solid ${paper.line}`}}>
          <div style={{fontFamily:paper.serif,fontSize:22,fontWeight:500}}>2<span style={{fontFamily:paper.sans,fontSize:13,color:paper.muted,fontWeight:400}}>h</span>28<span style={{fontFamily:paper.sans,fontSize:13,color:paper.muted,fontWeight:400}}>m</span></div>
          <div style={{fontFamily:paper.mono,fontSize:9,letterSpacing:1.2,textTransform:'uppercase',color:paper.muted,marginTop:2}}>Left today</div>
        </div>
        <div style={{textAlign:'center'}}>
          <div style={{fontFamily:paper.serif,fontSize:22,fontWeight:500,color:paper.accentInk}}>87<span style={{fontFamily:paper.sans,fontSize:13,color:paper.muted,fontWeight:400}}>%</span></div>
          <div style={{fontFamily:paper.mono,fontSize:9,letterSpacing:1.2,textTransform:'uppercase',color:paper.muted,marginTop:2}}>Attendance</div>
        </div>
      </div>

      {/* Schedule timeline */}
      <div style={{padding:'0 22px',display:'flex',flexDirection:'column',gap:2}}>
        <div style={{display:'flex',alignItems:'center',justifyContent:'space-between',marginBottom:10}}>
          <div style={{fontFamily:paper.mono,fontSize:10,letterSpacing:1.5,textTransform:'uppercase',color:paper.muted}}>Today's schedule</div>
          <div style={{fontFamily:paper.mono,fontSize:10,letterSpacing:1,color:paper.muted,display:'flex',alignItems:'center',gap:4}}>List <I.ChevR size={12}/></div>
        </div>
        {SCHEDULE.map((c,i) => <PaperClass key={i} c={c} first={i===0} last={i===SCHEDULE.length-1}/>)}
      </div>
    </div>
  );
}

// Bottom nav shared for paper
function PaperNav() {
  const items = [
    { key: 'home', icon: I.Grid, label: 'Today', active: true },
    { key: 'week', icon: I.List, label: 'Week' },
    { key: 'map',  icon: I.Map, label: 'Rooms' },
    { key: 'me',   icon: I.User, label: 'Me' },
  ];
  return (
    <div style={{position:'absolute',bottom:10,left:12,right:12,borderRadius:22,background:paper.paper,border:`1px solid ${paper.line}`,boxShadow:'0 14px 32px -18px rgba(0,0,0,0.35)',display:'flex',padding:6,fontFamily:paper.sans}}>
      {items.map(it => {
        const Ico = it.icon;
        return (
          <div key={it.key} style={{flex:1,display:'flex',flexDirection:'column',alignItems:'center',justifyContent:'center',gap:2,padding:'8px 0',background:it.active?paper.ink:'transparent',color:it.active?paper.paper:paper.muted,borderRadius:16}}>
            <Ico size={18}/>
            <span style={{fontSize:10,fontWeight:600,letterSpacing:0.3}}>{it.label}</span>
          </div>
        );
      })}
    </div>
  );
}

Object.assign(window, { paper, PaperDashboard, PaperNav, PaperStatus });
