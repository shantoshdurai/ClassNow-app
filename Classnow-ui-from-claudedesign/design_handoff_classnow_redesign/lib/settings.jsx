// Settings / Profile screens — Paper + Glass

// ────────────────── PAPER SETTINGS ──────────────────
function PaperSettings() {
  const Row = ({ icon: Ico, title, meta, last, children }) => (
    <div style={{display:'flex',alignItems:'center',gap:12,padding:'14px 18px',borderBottom:last?'none':`1px solid ${paper.line}`}}>
      <div style={{width:34,height:34,borderRadius:10,background:paper.bg,border:`1px solid ${paper.line}`,display:'flex',alignItems:'center',justifyContent:'center',color:paper.ink}}><Ico size={16}/></div>
      <div style={{flex:1,minWidth:0}}>
        <div style={{fontFamily:paper.sans,fontSize:14,fontWeight:500,color:paper.ink}}>{title}</div>
        {meta && <div style={{fontFamily:paper.sans,fontSize:12,color:paper.muted,marginTop:1}}>{meta}</div>}
      </div>
      {children || <I.ChevR size={16} stroke={paper.muted}/>}
    </div>
  );

  const Toggle = ({on}) => (
    <div style={{width:36,height:20,borderRadius:20,background:on?paper.ink:paper.faint,padding:2,display:'flex',alignItems:'center',justifyContent:on?'flex-end':'flex-start'}}>
      <div style={{width:16,height:16,borderRadius:20,background:paper.paper,boxShadow:'0 1px 3px rgba(0,0,0,0.2)'}}/>
    </div>
  );

  return (
    <div style={{background:paper.bg,minHeight:'100%',fontFamily:paper.sans,color:paper.ink,paddingBottom:100}}>
      <PaperStatus/>
      {/* Top bar */}
      <div style={{padding:'8px 18px 20px',display:'flex',alignItems:'center',justifyContent:'space-between'}}>
        <button style={{width:36,height:36,borderRadius:12,border:`1px solid ${paper.line}`,background:paper.paper,display:'flex',alignItems:'center',justifyContent:'center'}}><I.ChevL size={16}/></button>
        <div style={{fontFamily:paper.mono,fontSize:10,letterSpacing:1.5,textTransform:'uppercase',color:paper.muted}}>Profile</div>
        <button style={{width:36,height:36,borderRadius:12,border:`1px solid ${paper.line}`,background:paper.paper,display:'flex',alignItems:'center',justifyContent:'center'}}><I.Cog size={16}/></button>
      </div>

      {/* Profile header card */}
      <div style={{margin:'0 18px',padding:'22px 20px',background:paper.paper,border:`1px solid ${paper.line}`,borderRadius:22,textAlign:'center',position:'relative'}}>
        <div style={{width:72,height:72,margin:'0 auto',borderRadius:24,background:paper.ink,color:paper.paper,display:'flex',alignItems:'center',justifyContent:'center',fontFamily:paper.serif,fontSize:28,fontWeight:500,letterSpacing:-0.5}}>AR</div>
        <div style={{fontFamily:paper.serif,fontSize:24,fontWeight:500,letterSpacing:-0.4,marginTop:14}}>Aarav Rao</div>
        <div style={{fontFamily:paper.mono,fontSize:11,color:paper.muted,marginTop:2,letterSpacing:0.4}}>22CSA117 · B.Tech CSE (AI)</div>

        <div style={{display:'grid',gridTemplateColumns:'1fr 1fr 1fr',gap:10,marginTop:18,paddingTop:16,borderTop:`1px solid ${paper.line}`}}>
          <div>
            <div style={{fontFamily:paper.serif,fontSize:22,fontWeight:500}}>3<span style={{fontFamily:paper.sans,fontSize:12,color:paper.muted}}>rd</span></div>
            <div style={{fontFamily:paper.mono,fontSize:9,letterSpacing:1.3,textTransform:'uppercase',color:paper.muted,marginTop:2}}>Year</div>
          </div>
          <div style={{borderLeft:`1px solid ${paper.line}`,borderRight:`1px solid ${paper.line}`}}>
            <div style={{fontFamily:paper.serif,fontSize:22,fontWeight:500}}>18</div>
            <div style={{fontFamily:paper.mono,fontSize:9,letterSpacing:1.3,textTransform:'uppercase',color:paper.muted,marginTop:2}}>Day streak</div>
          </div>
          <div>
            <div style={{fontFamily:paper.serif,fontSize:22,fontWeight:500,color:paper.accentInk}}>87<span style={{fontFamily:paper.sans,fontSize:12,color:paper.muted}}>%</span></div>
            <div style={{fontFamily:paper.mono,fontSize:9,letterSpacing:1.3,textTransform:'uppercase',color:paper.muted,marginTop:2}}>Attendance</div>
          </div>
        </div>
      </div>

      {/* Sections */}
      <div style={{padding:'24px 18px 0'}}>
        <div style={{fontFamily:paper.mono,fontSize:10,letterSpacing:1.5,textTransform:'uppercase',color:paper.muted,padding:'0 4px 10px'}}>Schedule</div>
        <div style={{background:paper.paper,border:`1px solid ${paper.line}`,borderRadius:18,overflow:'hidden'}}>
          <Row icon={I.Clock} title="Notifications" meta="15 min before each class"/>
          <Row icon={I.Pin} title="Default block" meta="Main Block"/>
          <Row icon={I.Wand} title="Auto-sync with MyCamu" meta="Last synced 6:40 AM" last><Toggle on/></Row>
        </div>
      </div>

      <div style={{padding:'22px 18px 0'}}>
        <div style={{fontFamily:paper.mono,fontSize:10,letterSpacing:1.5,textTransform:'uppercase',color:paper.muted,padding:'0 4px 10px'}}>Appearance</div>
        <div style={{background:paper.paper,border:`1px solid ${paper.line}`,borderRadius:18,overflow:'hidden'}}>
          <Row icon={I.Sun} title="Theme" meta="Paper (light)"/>
          <Row icon={I.Grid} title="Home widget" meta="Next class · Medium"/>
          <Row icon={I.Book} title="Display" meta="Timeline view" last/>
        </div>
      </div>

      <div style={{padding:'22px 18px 0'}}>
        <div style={{fontFamily:paper.mono,fontSize:10,letterSpacing:1.5,textTransform:'uppercase',color:paper.muted,padding:'0 4px 10px'}}>Account</div>
        <div style={{background:paper.paper,border:`1px solid ${paper.line}`,borderRadius:18,overflow:'hidden'}}>
          <Row icon={I.User} title="Edit profile"/>
          <Row icon={I.Lock} title="Privacy" meta="Manage data"/>
          <Row icon={I.Log} title="Sign out" last><div style={{width:16}}/></Row>
        </div>
        <div style={{textAlign:'center',fontFamily:paper.mono,fontSize:10,color:paper.muted,marginTop:22,letterSpacing:0.5}}>ClassNow · v3.2.1</div>
      </div>
    </div>
  );
}

// ────────────────── GLASS SETTINGS ──────────────────
function GlassSettings() {
  const Row = ({ icon: Ico, title, meta, last, children, accent }) => (
    <div style={{display:'flex',alignItems:'center',gap:12,padding:'14px 16px',borderBottom:last?'none':`1px solid ${glass.border}`}}>
      <div style={{width:34,height:34,borderRadius:10,background:'rgba(255,255,255,0.04)',border:`1px solid ${glass.border}`,display:'flex',alignItems:'center',justifyContent:'center',color:accent||glass.ink}}><Ico size={16}/></div>
      <div style={{flex:1,minWidth:0}}>
        <div style={{fontFamily:glass.sans,fontSize:14,fontWeight:500,color:glass.ink}}>{title}</div>
        {meta && <div style={{fontFamily:glass.sans,fontSize:12,color:glass.muted,marginTop:1}}>{meta}</div>}
      </div>
      {children || <I.ChevR size={16} stroke={glass.muted}/>}
    </div>
  );

  const Toggle = ({on}) => (
    <div style={{width:38,height:22,borderRadius:20,background:on?`linear-gradient(90deg, ${glass.accent}, ${glass.accent2})`:'rgba(255,255,255,0.08)',padding:2,display:'flex',alignItems:'center',justifyContent:on?'flex-end':'flex-start',boxShadow:on?`0 0 12px ${glass.accentGlow}`:'none'}}>
      <div style={{width:18,height:18,borderRadius:20,background:'#fff',boxShadow:'0 2px 4px rgba(0,0,0,0.3)'}}/>
    </div>
  );

  return (
    <div style={{background:glass.bg,minHeight:'100%',color:glass.ink,fontFamily:glass.sans,paddingBottom:100,position:'relative',overflow:'hidden'}}>
      <Aurora/>
      <div style={{position:'relative',zIndex:1}}>
        <GlassStatus/>
        {/* Top bar */}
        <div style={{padding:'8px 18px 14px',display:'flex',alignItems:'center',justifyContent:'space-between'}}>
          <button style={{width:38,height:38,borderRadius:12,background:glass.surface,border:`1px solid ${glass.border}`,color:glass.ink,display:'flex',alignItems:'center',justifyContent:'center'}}><I.ChevL size={16}/></button>
          <div style={{fontFamily:glass.mono,fontSize:10,letterSpacing:1.8,textTransform:'uppercase',color:glass.muted}}>Profile</div>
          <button style={{width:38,height:38,borderRadius:12,background:glass.surface,border:`1px solid ${glass.border}`,color:glass.ink,display:'flex',alignItems:'center',justifyContent:'center'}}><I.Share size={16}/></button>
        </div>

        {/* Hero profile card */}
        <div style={{margin:'6px 18px 0',padding:'22px 20px 20px',borderRadius:24,background:'linear-gradient(180deg, rgba(255,255,255,0.08), rgba(255,255,255,0.02))',border:`1px solid ${glass.border2}`,backdropFilter:'blur(18px)',position:'relative',overflow:'hidden'}}>
          <div style={{position:'absolute',top:-40,right:-20,width:160,height:160,borderRadius:'50%',background:`radial-gradient(circle, ${glass.accentGlow}, transparent 65%)`,filter:'blur(20px)'}}/>
          <div style={{display:'flex',alignItems:'center',gap:14,position:'relative'}}>
            <div style={{width:64,height:64,borderRadius:20,background:`linear-gradient(135deg, ${glass.accent}, oklch(55% 0.18 260))`,border:`1px solid ${glass.border2}`,display:'flex',alignItems:'center',justifyContent:'center',fontFamily:glass.display,fontSize:22,fontWeight:700,letterSpacing:-0.4,boxShadow:`0 0 20px ${glass.accentGlow}`}}>AR</div>
            <div style={{flex:1}}>
              <div style={{fontFamily:glass.display,fontSize:19,fontWeight:600,letterSpacing:-0.3}}>Aarav Rao</div>
              <div style={{fontFamily:glass.mono,fontSize:11,color:glass.ink2,marginTop:2,letterSpacing:0.4}}>22CSA117 · CSE (AI)</div>
              <div style={{display:'inline-flex',alignItems:'center',gap:6,marginTop:8,padding:'3px 8px',borderRadius:6,background:'rgba(255,255,255,0.06)',border:`1px solid ${glass.border}`,fontFamily:glass.mono,fontSize:9,letterSpacing:1.2,textTransform:'uppercase',color:glass.accent2}}><I.Star size={10} fill={glass.accent2} stroke={glass.accent2}/> Year 3 · Sem 6</div>
            </div>
          </div>
          <div style={{display:'grid',gridTemplateColumns:'1fr 1fr 1fr',gap:8,marginTop:18}}>
            {[
              {label:'Streak',value:'18',unit:'d', icon:I.Flame},
              {label:'Attendance',value:'87',unit:'%', icon:I.Badge},
              {label:'GPA',value:'8.4',unit:'/10', icon:I.Star},
            ].map((s,i) => {
              const Ico = s.icon;
              return (
                <div key={i} style={{padding:'10px 12px',borderRadius:14,background:'rgba(255,255,255,0.04)',border:`1px solid ${glass.border}`}}>
                  <div style={{display:'flex',alignItems:'center',gap:4,color:glass.muted}}><Ico size={10} stroke={glass.accent2}/><span style={{fontFamily:glass.mono,fontSize:8,letterSpacing:1.2,textTransform:'uppercase'}}>{s.label}</span></div>
                  <div style={{fontFamily:glass.display,fontSize:20,fontWeight:600,marginTop:4,letterSpacing:-0.3}}>{s.value}<span style={{fontSize:11,color:glass.muted,fontWeight:400}}>{s.unit}</span></div>
                </div>
              );
            })}
          </div>
        </div>

        {/* Section: schedule */}
        <div style={{padding:'22px 18px 0'}}>
          <div style={{fontFamily:glass.mono,fontSize:10,letterSpacing:1.5,textTransform:'uppercase',color:glass.muted,padding:'0 4px 10px'}}>Schedule</div>
          <div style={{background:glass.surface,border:`1px solid ${glass.border}`,borderRadius:18,backdropFilter:'blur(18px)',overflow:'hidden'}}>
            <Row icon={I.Clock} accent={glass.accent2} title="Class reminders" meta="15 minutes before">
              <Toggle on/>
            </Row>
            <Row icon={I.Wand} accent="oklch(72% 0.2 310)" title="Auto-sync" meta="MyCamu · 6:40 AM"/>
            <Row icon={I.Pin} title="Default room map" meta="Main Block · 7th floor" last/>
          </div>
        </div>

        <div style={{padding:'18px 18px 0'}}>
          <div style={{fontFamily:glass.mono,fontSize:10,letterSpacing:1.5,textTransform:'uppercase',color:glass.muted,padding:'0 4px 10px'}}>Appearance</div>
          <div style={{background:glass.surface,border:`1px solid ${glass.border}`,borderRadius:18,backdropFilter:'blur(18px)',overflow:'hidden'}}>
            <Row icon={I.Moon} accent={glass.accent} title="Dark mode" meta="Glass theme · Aurora"><Toggle on/></Row>
            <Row icon={I.Grid} title="Home widget" meta="Now playing · Large"/>
            <Row icon={I.Bell} title="In-class do-not-disturb" meta="Mutes during sessions" last><Toggle on/></Row>
          </div>
        </div>

        <div style={{padding:'18px 18px 0'}}>
          <div style={{fontFamily:glass.mono,fontSize:10,letterSpacing:1.5,textTransform:'uppercase',color:glass.muted,padding:'0 4px 10px'}}>Account</div>
          <div style={{background:glass.surface,border:`1px solid ${glass.border}`,borderRadius:18,backdropFilter:'blur(18px)',overflow:'hidden'}}>
            <Row icon={I.User} title="Edit profile"/>
            <Row icon={I.Lock} title="Privacy & data"/>
            <Row icon={I.Log} accent="oklch(65% 0.2 25)" title="Sign out" last><div style={{width:16}}/></Row>
          </div>
          <div style={{textAlign:'center',fontFamily:glass.mono,fontSize:10,color:glass.muted,marginTop:22,letterSpacing:0.5}}>ClassNow · v3.2.1</div>
        </div>
      </div>
    </div>
  );
}

Object.assign(window, { PaperSettings, GlassSettings });
