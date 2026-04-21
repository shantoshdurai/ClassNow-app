// ─────────────────────────────────────────────────────────────
// VARIATION B — "GLASS" (dark premium w/ aurora glow)
// ─────────────────────────────────────────────────────────────

const glass = {
  bg:       '#08090D',
  bg2:      '#0E1016',
  surface:  'rgba(255,255,255,0.04)',
  surface2: 'rgba(255,255,255,0.06)',
  border:   'rgba(255,255,255,0.08)',
  border2:  'rgba(255,255,255,0.14)',
  ink:      '#F4F5F7',
  ink2:     '#B8BAC2',
  muted:    '#6C6F79',
  accent:   'oklch(72% 0.18 230)',
  accent2:  'oklch(78% 0.22 210)',
  accentGlow: 'oklch(72% 0.18 230 / 0.5)',
  sans:     '"Inter", -apple-system, system-ui, sans-serif',
  display:  '"Geist", "Inter", system-ui, sans-serif',
  mono:     '"JetBrains Mono", ui-monospace, monospace',
};

// Aurora background (SVG gradient blobs)
function Aurora() {
  return (
    <div style={{position:'absolute',inset:0,overflow:'hidden',pointerEvents:'none'}}>
      <div style={{position:'absolute',top:-120,right:-80,width:360,height:360,borderRadius:'50%',background:'radial-gradient(circle, oklch(72% 0.18 230 / 0.45), transparent 65%)',filter:'blur(20px)'}}/>
      <div style={{position:'absolute',top:200,left:-140,width:320,height:320,borderRadius:'50%',background:'radial-gradient(circle, oklch(62% 0.22 310 / 0.35), transparent 65%)',filter:'blur(20px)'}}/>
      <div style={{position:'absolute',bottom:-80,right:-60,width:280,height:280,borderRadius:'50%',background:'radial-gradient(circle, oklch(78% 0.22 170 / 0.25), transparent 65%)',filter:'blur(20px)'}}/>
      {/* hex/grid texture */}
      <svg width="100%" height="100%" style={{position:'absolute',inset:0,opacity:0.09}}>
        <defs>
          <pattern id="grid" width="18" height="18" patternUnits="userSpaceOnUse">
            <circle cx="1" cy="1" r="0.7" fill="#fff"/>
          </pattern>
        </defs>
        <rect width="100%" height="100%" fill="url(#grid)"/>
      </svg>
    </div>
  );
}

function GlassStatus() {
  return (
    <div style={{height:36,display:'flex',alignItems:'center',justifyContent:'space-between',padding:'0 22px',fontFamily:glass.mono,fontSize:12,color:glass.ink,position:'relative',letterSpacing:0.4,zIndex:2}}>
      <span>9:30</span>
      <div style={{position:'absolute',left:'50%',top:10,transform:'translateX(-50%)',width:18,height:18,borderRadius:100,background:'#000'}}/>
      <div style={{display:'flex',alignItems:'center',gap:6,fontSize:11}}>
        <span>5G</span>
        <svg width="14" height="10" viewBox="0 0 14 10"><rect x="0.5" y="0.5" width="11" height="9" rx="1.5" stroke={glass.ink} fill="none"/><rect x="2" y="2" width="8" height="6" rx="0.5" fill={glass.ink}/><rect x="12" y="3.5" width="1.5" height="3" fill={glass.ink}/></svg>
      </div>
    </div>
  );
}

// ─ Day pill ─
function GlassDay({ d }) {
  const active = d.active;
  return (
    <div style={{
      flex:1,display:'flex',flexDirection:'column',alignItems:'center',gap:3,padding:'8px 0 10px',borderRadius:14,
      background: active ? `linear-gradient(180deg, ${glass.accent}, oklch(55% 0.18 260))` : 'transparent',
      border: active ? '1px solid rgba(255,255,255,0.18)' : '1px solid transparent',
      color: active ? '#fff' : glass.ink2,
      boxShadow: active ? `0 0 0 0 ${glass.accent}, 0 8px 24px -6px ${glass.accentGlow}` : 'none',
      opacity: d.off ? 0.3 : 1,
    }}>
      <span style={{fontFamily:glass.mono,fontSize:9,letterSpacing:1.3,textTransform:'uppercase',opacity:0.8}}>{d.key}</span>
      <span style={{fontFamily:glass.display,fontSize:20,fontWeight:500,lineHeight:1}}>{d.date}</span>
    </div>
  );
}

// ─ NOW card — the hero ─
function GlassNowCard({ c }) {
  const pct = 44; // mock progress through class
  return (
    <div style={{
      position:'relative',margin:'14px 22px 18px',borderRadius:24,padding:'18px 20px 16px',overflow:'hidden',
      background: `linear-gradient(180deg, rgba(255,255,255,0.08), rgba(255,255,255,0.02))`,
      border: `1px solid ${glass.border2}`,
      backdropFilter: 'blur(20px)',
      WebkitBackdropFilter: 'blur(20px)',
      boxShadow: `0 24px 48px -24px ${glass.accentGlow}, 0 0 0 1px rgba(255,255,255,0.02) inset`,
    }}>
      {/* glow edge */}
      <div style={{position:'absolute',inset:-1,borderRadius:25,border:`1px solid ${glass.accent}`,opacity:0.4,pointerEvents:'none'}}/>

      <div style={{display:'flex',alignItems:'center',gap:8,marginBottom:8}}>
        <span style={{width:8,height:8,borderRadius:10,background:glass.accent,boxShadow:`0 0 10px ${glass.accent}`,animation:'gpulse 1.8s ease-in-out infinite'}}/>
        <span style={{fontFamily:glass.mono,fontSize:10,letterSpacing:1.8,textTransform:'uppercase',color:glass.accent2,fontWeight:600}}>Class in session</span>
        <span style={{flex:1}}/>
        <span style={{fontFamily:glass.mono,fontSize:11,color:glass.ink2}}>28m left</span>
      </div>

      <div style={{fontFamily:glass.display,fontSize:30,fontWeight:600,color:glass.ink,letterSpacing:-0.8,lineHeight:1.05}}>
        {c.title}
      </div>

      <div style={{display:'flex',alignItems:'center',gap:14,marginTop:10,fontFamily:glass.sans,fontSize:12,color:glass.ink2}}>
        <span style={{display:'flex',alignItems:'center',gap:5}}><I.User size={12}/> {c.mentor}</span>
        <span style={{color:glass.muted}}>·</span>
        <span style={{display:'flex',alignItems:'center',gap:5,fontFamily:glass.mono}}><I.Pin size={12}/> Rm {c.room}</span>
      </div>

      {/* Progress bar */}
      <div style={{marginTop:14,height:6,borderRadius:6,background:'rgba(255,255,255,0.06)',overflow:'hidden',position:'relative'}}>
        <div style={{width:`${pct}%`,height:'100%',background:`linear-gradient(90deg, ${glass.accent}, ${glass.accent2})`,boxShadow:`0 0 12px ${glass.accentGlow}`}}/>
      </div>
      <div style={{display:'flex',justifyContent:'space-between',marginTop:6,fontFamily:glass.mono,fontSize:10,color:glass.muted}}>
        <span>{c.start}</span><span>{c.end}</span>
      </div>
    </div>
  );
}

// ─ Compact upcoming row ─
function GlassRow({ c }) {
  const isNext = c.status === 'next';
  const isDone = c.status === 'done';
  const isBreak = c.status === 'break';
  if (isBreak) {
    return (
      <div style={{display:'flex',alignItems:'center',gap:10,padding:'6px 24px',color:glass.muted,fontFamily:glass.mono,fontSize:10,letterSpacing:1,textTransform:'uppercase'}}>
        <span style={{flex:1,height:1,background:'rgba(255,255,255,0.06)'}}/>
        <span>Break · 15m</span>
        <span style={{flex:1,height:1,background:'rgba(255,255,255,0.06)'}}/>
      </div>
    );
  }
  return (
    <div style={{
      margin:'0 22px 10px',padding:'14px 16px',borderRadius:18,
      background: isNext ? 'linear-gradient(180deg, rgba(255,255,255,0.06), rgba(255,255,255,0.01))' : 'transparent',
      border: isNext ? `1px solid ${glass.border}` : `1px solid transparent`,
      display:'flex',alignItems:'center',gap:14,
      opacity: isDone ? 0.5 : 1,
    }}>
      <div style={{fontFamily:glass.mono,fontSize:11,color:glass.ink2,textAlign:'right',minWidth:40,lineHeight:1.3}}>
        <div>{c.start}</div>
        <div style={{color:glass.muted,fontSize:10}}>{c.end}</div>
      </div>
      <div style={{width:2,alignSelf:'stretch',borderRadius:2,background: isNext ? `linear-gradient(180deg, ${glass.accent}, transparent)` : 'rgba(255,255,255,0.08)'}}/>
      <div style={{flex:1,minWidth:0}}>
        <div style={{fontFamily:glass.display,fontSize:15,fontWeight:500,color:glass.ink,letterSpacing:-0.2,textDecoration:isDone?'line-through':'none'}}>{c.title}</div>
        <div style={{fontFamily:glass.sans,fontSize:11,color:glass.muted,marginTop:2,display:'flex',gap:8}}>
          <span>{c.mentor}</span>
          <span>·</span>
          <span style={{fontFamily:glass.mono}}>Rm {c.room}</span>
        </div>
      </div>
      {isNext && (
        <div style={{fontFamily:glass.mono,fontSize:9,letterSpacing:1,textTransform:'uppercase',color:glass.accent2,padding:'4px 8px',borderRadius:6,background:'rgba(0,150,255,0.12)',border:`1px solid ${glass.border}`}}>Up next</div>
      )}
      {isDone && (
        <div style={{width:20,height:20,borderRadius:20,background:'rgba(255,255,255,0.04)',display:'flex',alignItems:'center',justifyContent:'center',color:glass.muted}}>
          <I.Check size={12} sw={2}/>
        </div>
      )}
    </div>
  );
}

function GlassDashboard() {
  const now = SCHEDULE.find(s => s.status === 'now');
  return (
    <div style={{background:glass.bg,minHeight:'100%',color:glass.ink,fontFamily:glass.sans,paddingBottom:100,position:'relative',overflow:'hidden'}}>
      <style>{`@keyframes gpulse {0%,100%{opacity:1;transform:scale(1)}50%{opacity:.55;transform:scale(1.3)}}`}</style>
      <Aurora/>
      <div style={{position:'relative',zIndex:1}}>
        <GlassStatus/>

        {/* Header */}
        <div style={{padding:'10px 22px 0',display:'flex',alignItems:'center',justifyContent:'space-between'}}>
          <div style={{display:'flex',alignItems:'center',gap:10}}>
            <div style={{width:36,height:36,borderRadius:12,background:`linear-gradient(135deg, ${glass.accent}, oklch(55% 0.18 260))`,display:'flex',alignItems:'center',justifyContent:'center',fontFamily:glass.display,fontSize:13,fontWeight:700,color:'#fff',letterSpacing:-0.3}}>AR</div>
            <div>
              <div style={{fontFamily:glass.mono,fontSize:9,letterSpacing:1.5,textTransform:'uppercase',color:glass.muted}}>Good morning,</div>
              <div style={{fontFamily:glass.display,fontSize:16,fontWeight:600,color:glass.ink,letterSpacing:-0.3,marginTop:1}}>Aarav</div>
            </div>
          </div>
          <div style={{display:'flex',gap:6}}>
            <button style={{width:38,height:38,borderRadius:12,border:`1px solid ${glass.border}`,background:glass.surface,color:glass.ink,display:'flex',alignItems:'center',justifyContent:'center'}}><I.Search size={16}/></button>
            <button style={{width:38,height:38,borderRadius:12,border:`1px solid ${glass.border}`,background:glass.surface,color:glass.ink,display:'flex',alignItems:'center',justifyContent:'center',position:'relative'}}>
              <I.Bell size={16}/>
              <span style={{position:'absolute',top:9,right:9,width:7,height:7,borderRadius:10,background:glass.accent,boxShadow:`0 0 6px ${glass.accent}`}}/>
            </button>
          </div>
        </div>

        {/* Week */}
        <div style={{display:'flex',gap:4,padding:'14px 18px 4px'}}>
          {DAYS.map(d => <GlassDay key={d.key} d={d}/>)}
        </div>

        {/* NOW hero card */}
        {now && <GlassNowCard c={now}/>}

        {/* Schedule */}
        <div style={{padding:'4px 0 0'}}>
          <div style={{display:'flex',alignItems:'center',justifyContent:'space-between',padding:'0 24px 12px'}}>
            <div style={{fontFamily:glass.mono,fontSize:10,letterSpacing:1.5,textTransform:'uppercase',color:glass.muted}}>Rest of the day · 3 classes</div>
            <I.ChevR size={14} stroke={glass.muted}/>
          </div>
          {SCHEDULE.filter(s => s.status !== 'now' && s.status !== 'done').map((c,i) => <GlassRow key={i} c={c}/>)}
        </div>

        {/* Small callouts grid */}
        <div style={{padding:'12px 22px 0',display:'grid',gridTemplateColumns:'1fr 1fr',gap:10}}>
          <div style={{padding:'14px',borderRadius:18,background:glass.surface,border:`1px solid ${glass.border}`}}>
            <div style={{display:'flex',alignItems:'center',gap:6,fontFamily:glass.mono,fontSize:9,letterSpacing:1.3,textTransform:'uppercase',color:glass.muted}}><I.Flame size={12} stroke="oklch(72% 0.2 40)"/> Streak</div>
            <div style={{fontFamily:glass.display,fontSize:24,fontWeight:600,marginTop:6,letterSpacing:-0.5}}>18 <span style={{fontSize:12,color:glass.muted,fontWeight:400}}>days</span></div>
          </div>
          <div style={{padding:'14px',borderRadius:18,background:glass.surface,border:`1px solid ${glass.border}`}}>
            <div style={{display:'flex',alignItems:'center',gap:6,fontFamily:glass.mono,fontSize:9,letterSpacing:1.3,textTransform:'uppercase',color:glass.muted}}><I.Badge size={12} stroke={glass.accent2}/> Attendance</div>
            <div style={{fontFamily:glass.display,fontSize:24,fontWeight:600,marginTop:6,letterSpacing:-0.5}}>87<span style={{fontSize:13,color:glass.muted}}>%</span></div>
          </div>
        </div>
      </div>
    </div>
  );
}

function GlassNav() {
  const items = [
    { key: 'home', icon: I.Grid, label: 'Today', active: true },
    { key: 'week', icon: I.List, label: 'Week' },
    { key: 'map',  icon: I.Map, label: 'Rooms' },
    { key: 'me',   icon: I.User, label: 'Me' },
  ];
  return (
    <div style={{position:'absolute',bottom:10,left:12,right:12,borderRadius:22,background:'rgba(12,14,20,0.75)',backdropFilter:'blur(24px)',WebkitBackdropFilter:'blur(24px)',border:`1px solid ${glass.border2}`,boxShadow:'0 14px 32px -6px rgba(0,0,0,0.6)',display:'flex',padding:6,fontFamily:glass.sans,zIndex:5}}>
      {items.map(it => {
        const Ico = it.icon;
        return (
          <div key={it.key} style={{flex:1,display:'flex',flexDirection:'column',alignItems:'center',justifyContent:'center',gap:2,padding:'8px 0',background:it.active?`linear-gradient(180deg, rgba(255,255,255,0.08), rgba(255,255,255,0.02))`:'transparent',color:it.active?glass.ink:glass.muted,borderRadius:16,border:it.active?`1px solid ${glass.border}`:'1px solid transparent'}}>
            <Ico size={18}/>
            <span style={{fontSize:10,fontWeight:600,letterSpacing:0.3}}>{it.label}</span>
          </div>
        );
      })}
    </div>
  );
}

Object.assign(window, { glass, GlassDashboard, GlassNav, GlassStatus, Aurora });
