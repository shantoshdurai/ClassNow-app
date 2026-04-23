// ─────────────────────────────────────────────────────────────
// AI CHAT — three variations
//   A. Prose       — editorial streaming, ink caret, pill chips
//   B. Answer Card — structured cards with inline schedule tiles
//   C. Timeline    — conversation as a day timeline w/ mono meta
// ─────────────────────────────────────────────────────────────
// Aesthetic commits to Glass tokens already in the project:
//   Display: Geist   Body: Inter   Mono: JetBrains Mono
//   Aurora accent: oklch(72% 0.18 230)
//   NO Gemini / Google branding. Assistant identity is "Nova"
//   — an original ClassNow-native helper.

const chat = {
  bg:        '#08090D',
  bg2:       '#0B0D13',
  surface:   'rgba(255,255,255,0.04)',
  surface2:  'rgba(255,255,255,0.07)',
  border:    'rgba(255,255,255,0.08)',
  border2:   'rgba(255,255,255,0.16)',
  ink:       '#F4F5F7',
  ink2:      '#B8BAC2',
  muted:     '#6C6F79',
  dim:       '#4A4D56',
  accent:    'oklch(72% 0.18 230)',
  accent2:   'oklch(78% 0.22 210)',
  accentSoft:'oklch(72% 0.18 230 / 0.16)',
  glow:      'oklch(72% 0.18 230 / 0.45)',
  ok:        'oklch(72% 0.18 160)',
  warm:      'oklch(74% 0.15 55)',
  sans:      '"Inter", -apple-system, system-ui, sans-serif',
  display:   '"Geist", "Inter", system-ui, sans-serif',
  mono:      '"JetBrains Mono", ui-monospace, monospace',
};

// ── tiny SVG spark (for assistant avatar) ───────────────────
function NovaMark({ size = 22 }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <defs>
        <radialGradient id="nvg" cx="50%" cy="45%" r="55%">
          <stop offset="0%" stopColor="oklch(88% 0.17 220)" />
          <stop offset="60%" stopColor="oklch(72% 0.18 230)" />
          <stop offset="100%" stopColor="oklch(45% 0.18 260)" />
        </radialGradient>
      </defs>
      <circle cx="12" cy="12" r="11" fill="url(#nvg)" />
      <path d="M12 5.5 13.2 10l4.5 1.2-4.5 1.2L12 17l-1.2-4.6L6.3 11.2 10.8 10Z"
        fill="#fff" opacity="0.95"/>
    </svg>
  );
}

// ── Streaming text hook — simulates token stream ────────────
function useStreamedText(full, active, speed = 22) {
  const [n, setN] = React.useState(active ? 0 : full.length);
  React.useEffect(() => {
    if (!active) { setN(full.length); return; }
    setN(0);
    let i = 0;
    const id = setInterval(() => {
      i += 1 + Math.floor(Math.random() * 3);
      if (i >= full.length) { setN(full.length); clearInterval(id); }
      else setN(i);
    }, speed);
    return () => clearInterval(id);
  }, [full, active]);
  return { shown: full.slice(0, n), done: n >= full.length };
}

// ── Typing dots (for "AI is thinking") ──────────────────────
function TypingDots({ color = chat.accent2 }) {
  return (
    <span style={{display:'inline-flex',gap:4,alignItems:'center',padding:'8px 2px'}}>
      {[0,1,2].map(i => (
        <span key={i} style={{
          width:6,height:6,borderRadius:10,background:color,opacity:0.4,
          animation:`novaBlink 1.2s ${i*0.16}s ease-in-out infinite`,
          boxShadow:`0 0 6px ${color}`,
        }}/>
      ))}
    </span>
  );
}

// ── Blinking ink caret ─────────────────────────────────────
function Caret({ c = chat.accent }) {
  return <span style={{
    display:'inline-block',width:2,height:'0.95em',background:c,borderRadius:2,
    marginLeft:2,verticalAlign:'-2px',animation:'novaCaret 0.9s steps(1) infinite',
    boxShadow:`0 0 8px ${c}`,
  }}/>;
}

// ── Shared <style> injection ───────────────────────────────
function ChatStyles() {
  return <style>{`
    @keyframes novaBlink { 0%,100% { opacity:.3; transform:translateY(0) } 50% { opacity:1; transform:translateY(-2px) } }
    @keyframes novaCaret { 0%,49% { opacity:1 } 50%,100% { opacity:0 } }
    @keyframes novaRiseIn { from { opacity:0; transform:translateY(6px) } to { opacity:1; transform:translateY(0) } }
    @keyframes novaBubblePop { 0% { opacity:0; transform:translateY(8px) scale(0.96) } 60% { opacity:1; transform:translateY(-1px) scale(1.01) } 100% { transform:translateY(0) scale(1) } }
    @keyframes novaShimmer { 0% { background-position: -200% 0 } 100% { background-position: 200% 0 } }
    @keyframes novaAur1 { 0%,100% { transform:translate(0,0) scale(1) } 50% { transform:translate(10px,-14px) scale(1.1) } }
    @keyframes novaAur2 { 0%,100% { transform:translate(0,0) scale(1) } 50% { transform:translate(-12px,10px) scale(1.06) } }
    @keyframes novaKey { 0%,100% { transform:translateY(0) } 50% { transform:translateY(-1px) } }
    @keyframes novaSend { 0% { transform:translate(0,0) rotate(0) } 70% { transform:translate(22px,-22px) rotate(45deg); opacity:0 } 100% { transform:translate(0,0) rotate(0); opacity:1 } }
  `}</style>;
}

// ═════════════════════════════════════════════════════════════
// 01 — PROSE: editorial streaming answer
// ═════════════════════════════════════════════════════════════

function ChatProse() {
  // Simulated user typing in composer
  const [draft, setDraft] = React.useState('');
  const target = "when is my next class?";
  React.useEffect(() => {
    let i = 0;
    const id = setInterval(() => {
      i++;
      setDraft(target.slice(0, i));
      if (i >= target.length) clearInterval(id);
    }, 65);
    return () => clearInterval(id);
  }, []);

  // Streaming AI answer
  const answer = "Your next class is Computational Intelligence with Ms. P. Sudha — starting at 11:15 in Room 704. You've got a 15-minute break right after this one ends.";
  const { shown, done } = useStreamedText(answer, true, 16);

  return (
    <div style={{background:chat.bg,color:chat.ink,fontFamily:chat.sans,minHeight:'100%',display:'flex',flexDirection:'column',position:'relative',overflow:'hidden'}}>
      <ChatStyles/>

      {/* aurora */}
      <div style={{position:'absolute',inset:0,pointerEvents:'none',overflow:'hidden'}}>
        <div style={{position:'absolute',top:-80,right:-60,width:280,height:280,borderRadius:'50%',background:`radial-gradient(circle, ${chat.glow}, transparent 65%)`,filter:'blur(30px)',animation:'novaAur1 11s ease-in-out infinite'}}/>
        <div style={{position:'absolute',bottom:100,left:-100,width:260,height:260,borderRadius:'50%',background:'radial-gradient(circle, oklch(62% 0.22 310 / 0.28), transparent 65%)',filter:'blur(32px)',animation:'novaAur2 13s ease-in-out infinite'}}/>
      </div>

      {/* Header */}
      <div style={{position:'relative',padding:'14px 18px 10px',display:'flex',alignItems:'center',gap:10,borderBottom:`1px solid ${chat.border}`}}>
        <NovaMark size={30}/>
        <div style={{flex:1,minWidth:0}}>
          <div style={{fontFamily:chat.display,fontSize:16,fontWeight:600,letterSpacing:-0.3,lineHeight:1.1}}>Nova</div>
          <div style={{display:'flex',alignItems:'center',gap:6,marginTop:3,fontFamily:chat.mono,fontSize:9,letterSpacing:1.3,textTransform:'uppercase',color:chat.muted}}>
            <span style={{width:6,height:6,borderRadius:10,background:chat.ok,boxShadow:`0 0 6px ${chat.ok}`}}/>
            ClassNow assistant · online
          </div>
        </div>
        <button style={{border:`1px solid ${chat.border}`,background:chat.surface,color:chat.ink2,width:32,height:32,borderRadius:10,display:'flex',alignItems:'center',justifyContent:'center',fontFamily:chat.mono,fontSize:12}}>✕</button>
      </div>

      {/* Conversation */}
      <div style={{flex:1,padding:'18px 18px 12px',display:'flex',flexDirection:'column',gap:14,position:'relative',zIndex:1,overflow:'hidden'}}>

        {/* Day divider */}
        <div style={{display:'flex',alignItems:'center',gap:8,color:chat.muted,fontFamily:chat.mono,fontSize:9,letterSpacing:1.4,textTransform:'uppercase'}}>
          <span style={{flex:1,height:1,background:'rgba(255,255,255,0.05)'}}/>
          <span>Today · 10:34</span>
          <span style={{flex:1,height:1,background:'rgba(255,255,255,0.05)'}}/>
        </div>

        {/* Greeting — AI */}
        <AIBubbleProse first>
          <span style={{fontFamily:chat.display,fontWeight:500,fontSize:15,letterSpacing:-0.1}}>Good morning, Aarav.</span>{' '}
          Ask me about your schedule, a classroom, or your attendance — I'll keep it short.
        </AIBubbleProse>

        {/* Quick chips */}
        <div style={{display:'flex',gap:6,flexWrap:'wrap',marginLeft:36,marginTop:-6}}>
          {['Next class?','Attendance %','Find Rm 612','What\'s after lunch?'].map((t,i)=>(
            <button key={i} style={{
              fontFamily:chat.sans,fontSize:11,color:chat.ink2,background:chat.surface,
              border:`1px solid ${chat.border}`,borderRadius:100,padding:'6px 10px',cursor:'pointer',
            }}>{t}</button>
          ))}
        </div>

        {/* User bubble */}
        <UserBubbleProse text="when is my next class?"/>

        {/* AI streaming response */}
        <div style={{display:'flex',gap:10,alignItems:'flex-start',animation:'novaRiseIn 0.4s ease-out both'}}>
          <div style={{flexShrink:0,marginTop:2}}><NovaMark size={24}/></div>
          <div style={{flex:1,minWidth:0}}>
            <div style={{fontFamily:chat.mono,fontSize:9,letterSpacing:1.2,textTransform:'uppercase',color:chat.muted,marginBottom:5}}>
              Nova · <span style={{color:chat.accent2}}>answering</span>
            </div>
            <div style={{
              fontFamily:chat.display,fontSize:17,lineHeight:1.42,letterSpacing:-0.2,color:chat.ink,
              fontWeight:400,
            }}>
              {renderProse(shown)}
              {!done && <Caret/>}
            </div>

            {/* inline fact pills — appear after stream done */}
            {done && (
              <div style={{display:'flex',gap:6,flexWrap:'wrap',marginTop:10,animation:'novaRiseIn 0.35s ease-out both'}}>
                <FactPill mono="11:15" label="Computational Intelligence"/>
                <FactPill mono="Rm 704" label="Main block"/>
              </div>
            )}

            {/* reaction / followups */}
            {done && (
              <div style={{display:'flex',gap:6,marginTop:10,animation:'novaRiseIn 0.45s 0.05s ease-out both'}}>
                {['Remind me','Directions','Rest of day'].map((t,i)=>(
                  <button key={i} style={{fontFamily:chat.sans,fontSize:11,color:chat.accent2,background:chat.accentSoft,border:`1px solid ${chat.border2}`,borderRadius:8,padding:'6px 10px',cursor:'pointer'}}>{t}</button>
                ))}
              </div>
            )}
          </div>
        </div>

      </div>

      {/* Composer */}
      <ChatComposer draft={draft} typing/>
    </div>
  );
}

// Prose renderer — bolds subject titles & rooms inline
function renderProse(text) {
  const parts = text.split(/(Computational Intelligence|Ms\. P\. Sudha|11:15|Room 704|15-minute break)/g);
  return parts.map((p,i) => {
    if (p === 'Computational Intelligence') return <b key={i} style={{color:chat.ink,fontWeight:600}}>{p}</b>;
    if (p === 'Ms. P. Sudha') return <b key={i} style={{color:chat.ink,fontWeight:600}}>{p}</b>;
    if (p === '11:15') return <span key={i} style={{fontFamily:chat.mono,fontSize:'0.92em',color:chat.accent2,padding:'1px 6px',background:chat.accentSoft,borderRadius:6,letterSpacing:0.3,whiteSpace:'nowrap'}}>{p}</span>;
    if (p === 'Room 704') return <span key={i} style={{fontFamily:chat.mono,fontSize:'0.9em',color:chat.ink,whiteSpace:'nowrap'}}>{p}</span>;
    if (p === '15-minute break') return <span key={i} style={{color:chat.warm,fontWeight:500}}>{p}</span>;
    return p;
  });
}

function AIBubbleProse({ children, first }) {
  return (
    <div style={{display:'flex',gap:10,alignItems:'flex-start',animation:'novaRiseIn 0.4s ease-out both'}}>
      <div style={{flexShrink:0,marginTop:2}}><NovaMark size={24}/></div>
      <div style={{flex:1,minWidth:0,fontSize:14,lineHeight:1.5,color:chat.ink2,fontFamily:chat.sans}}>
        {children}
      </div>
    </div>
  );
}

function UserBubbleProse({ text }) {
  return (
    <div style={{display:'flex',justifyContent:'flex-end',animation:'novaBubblePop 0.45s cubic-bezier(0.2, 0.9, 0.3, 1.2) both'}}>
      <div style={{
        maxWidth:'78%',
        background:`linear-gradient(180deg, ${chat.accent}, oklch(55% 0.18 260))`,
        color:'#fff',borderRadius:'18px 18px 4px 18px',padding:'10px 14px',
        fontFamily:chat.sans,fontSize:14,lineHeight:1.4,fontWeight:500,letterSpacing:-0.1,
        boxShadow:`0 8px 20px -6px ${chat.glow}, inset 0 1px 0 rgba(255,255,255,0.18)`,
      }}>
        {text}
      </div>
    </div>
  );
}

function FactPill({ mono, label }) {
  return (
    <div style={{
      display:'inline-flex',alignItems:'center',gap:8,padding:'7px 10px 7px 8px',
      borderRadius:10,background:chat.surface,border:`1px solid ${chat.border}`,
    }}>
      <span style={{fontFamily:chat.mono,fontSize:11,color:chat.accent2,padding:'2px 6px',background:chat.accentSoft,borderRadius:5,letterSpacing:0.3}}>{mono}</span>
      <span style={{fontFamily:chat.sans,fontSize:11,color:chat.ink2}}>{label}</span>
    </div>
  );
}

// ═════════════════════════════════════════════════════════════
// Composer — shared, but prose uses the "typing" prop
// ═════════════════════════════════════════════════════════════
function ChatComposer({ draft = '', typing = false, onSend, placeholder = 'Ask Nova…' }) {
  const [focus, setFocus] = React.useState(true);
  const hasText = draft.length > 0;
  return (
    <div style={{position:'relative',padding:'10px 14px 14px',borderTop:`1px solid ${chat.border}`,background:'rgba(8,9,13,0.6)',backdropFilter:'blur(18px)',WebkitBackdropFilter:'blur(18px)'}}>
      <div style={{
        display:'flex',alignItems:'flex-end',gap:8,padding:'8px 8px 8px 14px',
        borderRadius:22,background:chat.surface,
        border:`1px solid ${focus ? chat.border2 : chat.border}`,
        boxShadow: focus ? `0 0 0 3px ${chat.accentSoft}` : 'none',
        transition:'all 0.18s ease',
      }}>
        <button style={{width:30,height:30,borderRadius:10,border:`1px solid ${chat.border}`,background:'transparent',color:chat.muted,display:'flex',alignItems:'center',justifyContent:'center',fontFamily:chat.mono,fontSize:18,lineHeight:1,flexShrink:0}}>＋</button>
        <div style={{flex:1,minHeight:30,display:'flex',alignItems:'center',flexWrap:'wrap',padding:'4px 2px',fontFamily:chat.sans,fontSize:14,lineHeight:1.35,color:chat.ink}}>
          {draft ? (
            <>
              <span>{draft}</span>
              {typing && <Caret c={chat.accent2}/>}
            </>
          ) : (
            <span style={{color:chat.muted}}>{placeholder}</span>
          )}
        </div>
        {/* mic/send morph */}
        {hasText ? (
          <button style={{
            width:36,height:36,borderRadius:12,flexShrink:0,
            background:`linear-gradient(180deg, ${chat.accent}, oklch(55% 0.18 260))`,
            border:'1px solid rgba(255,255,255,0.18)',color:'#fff',
            display:'flex',alignItems:'center',justifyContent:'center',
            boxShadow:`0 6px 16px -4px ${chat.glow}`,
            cursor:'pointer',
          }}>
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M12 19V5M5 12l7-7 7 7"/></svg>
          </button>
        ) : (
          <button style={{width:36,height:36,borderRadius:12,flexShrink:0,background:chat.surface2,border:`1px solid ${chat.border}`,color:chat.ink2,display:'flex',alignItems:'center',justifyContent:'center'}}>
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><rect x="9" y="3" width="6" height="12" rx="3"/><path d="M5 11a7 7 0 0 0 14 0M12 18v3"/></svg>
          </button>
        )}
      </div>
      {/* keyboard hint line */}
      <div style={{display:'flex',justifyContent:'space-between',alignItems:'center',marginTop:8,padding:'0 4px',fontFamily:chat.mono,fontSize:9,letterSpacing:1.3,textTransform:'uppercase',color:chat.muted}}>
        <span>Nova can access your schedule</span>
        <span style={{display:'flex',alignItems:'center',gap:4}}>
          <span style={{padding:'2px 6px',border:`1px solid ${chat.border}`,borderRadius:4,fontSize:8}}>↵</span>
          to send
        </span>
      </div>
    </div>
  );
}

// ═════════════════════════════════════════════════════════════
// 02 — ANSWER CARDS: structured, with inline schedule tile
// ═════════════════════════════════════════════════════════════

function ChatCards() {
  const [draft, setDraft] = React.useState('');
  const target = "what's my schedule today?";
  React.useEffect(() => {
    let i = 0;
    const id = setInterval(() => {
      i++;
      setDraft(target.slice(0, i));
      if (i >= target.length) clearInterval(id);
    }, 55);
    return () => clearInterval(id);
  }, []);

  const intro = "Here's your Tuesday — you're currently in Discrete Maths, and two more classes after that.";
  const { shown, done } = useStreamedText(intro, true, 18);

  return (
    <div style={{background:chat.bg,color:chat.ink,fontFamily:chat.sans,minHeight:'100%',display:'flex',flexDirection:'column',position:'relative',overflow:'hidden'}}>
      <ChatStyles/>

      {/* aurora (subtler) */}
      <div style={{position:'absolute',inset:0,pointerEvents:'none',overflow:'hidden'}}>
        <div style={{position:'absolute',top:-40,left:-80,width:260,height:260,borderRadius:'50%',background:`radial-gradient(circle, oklch(72% 0.18 230 / 0.28), transparent 65%)`,filter:'blur(30px)',animation:'novaAur1 12s ease-in-out infinite'}}/>
      </div>

      {/* compact header */}
      <div style={{position:'relative',padding:'12px 16px',display:'flex',alignItems:'center',gap:10,borderBottom:`1px solid ${chat.border}`,background:'rgba(10,12,18,0.5)'}}>
        <button style={{width:30,height:30,borderRadius:10,border:`1px solid ${chat.border}`,background:chat.surface,color:chat.ink2,fontFamily:chat.mono,fontSize:14,display:'flex',alignItems:'center',justifyContent:'center'}}>‹</button>
        <NovaMark size={22}/>
        <div style={{flex:1,fontFamily:chat.display,fontSize:14,fontWeight:600,letterSpacing:-0.2}}>Nova</div>
        <div style={{fontFamily:chat.mono,fontSize:9,letterSpacing:1.3,textTransform:'uppercase',color:chat.muted,display:'flex',alignItems:'center',gap:5}}>
          <span style={{width:6,height:6,borderRadius:10,background:chat.ok,boxShadow:`0 0 6px ${chat.ok}`}}/>
          online
        </div>
      </div>

      {/* stream */}
      <div style={{flex:1,overflow:'hidden',padding:'16px 14px 10px',display:'flex',flexDirection:'column',gap:14,position:'relative',zIndex:1}}>

        {/* User */}
        <UserBubbleProse text="what's my schedule today?"/>

        {/* AI answer card */}
        <div style={{animation:'novaRiseIn 0.4s ease-out both'}}>
          <div style={{display:'flex',alignItems:'center',gap:8,marginBottom:8,paddingLeft:2}}>
            <NovaMark size={20}/>
            <span style={{fontFamily:chat.display,fontSize:12,fontWeight:600,letterSpacing:-0.1}}>Nova</span>
            <span style={{fontFamily:chat.mono,fontSize:9,letterSpacing:1.2,textTransform:'uppercase',color:chat.muted}}>· 10:34</span>
          </div>
          <div style={{
            background:`linear-gradient(180deg, rgba(255,255,255,0.06), rgba(255,255,255,0.015))`,
            border:`1px solid ${chat.border2}`,
            borderRadius:20,padding:'14px 14px 12px',
            boxShadow:`0 20px 40px -24px ${chat.glow}, inset 0 1px 0 rgba(255,255,255,0.04)`,
          }}>
            <div style={{fontFamily:chat.display,fontSize:15,lineHeight:1.35,letterSpacing:-0.1,color:chat.ink,fontWeight:400}}>
              {shown}{!done && <Caret/>}
            </div>

            {done && (
              <>
                <div style={{display:'flex',alignItems:'center',gap:8,margin:'12px 0 8px',fontFamily:chat.mono,fontSize:9,letterSpacing:1.3,textTransform:'uppercase',color:chat.muted,animation:'novaRiseIn 0.35s ease-out both'}}>
                  <span style={{flex:1,height:1,background:'rgba(255,255,255,0.05)'}}/>
                  <span>Tue · 21 Apr · 3 ahead</span>
                  <span style={{flex:1,height:1,background:'rgba(255,255,255,0.05)'}}/>
                </div>
                {/* Inline schedule tiles */}
                <div style={{display:'flex',flexDirection:'column',gap:6,animation:'novaRiseIn 0.4s 0.05s ease-out both'}}>
                  <MiniClass c={{start:'10:10',end:'11:00',title:'Discrete Mathematics',mentor:'Mrs. N. Subashini',room:'704'}} status="now"/>
                  <MiniClass c={{start:'11:15',end:'12:05',title:'Computational Intelligence',mentor:'Ms. P. Sudha',room:'704'}} status="next"/>
                  <MiniClass c={{start:'12:05',end:'12:55',title:'Design Thinking',mentor:'Mrs. N. Radha',room:'612'}} status="later"/>
                </div>
                <div style={{display:'flex',gap:6,marginTop:10,flexWrap:'wrap',animation:'novaRiseIn 0.45s 0.1s ease-out both'}}>
                  <button style={{fontFamily:chat.sans,fontSize:11,color:chat.accent2,background:chat.accentSoft,border:`1px solid ${chat.border2}`,borderRadius:8,padding:'6px 10px'}}>Open full day</button>
                  <button style={{fontFamily:chat.sans,fontSize:11,color:chat.ink2,background:chat.surface,border:`1px solid ${chat.border}`,borderRadius:8,padding:'6px 10px'}}>Add to reminders</button>
                </div>
              </>
            )}
          </div>
        </div>

        {/* Next user (thinking indicator) */}
        <div style={{display:'flex',justifyContent:'flex-end',animation:'novaBubblePop 0.4s cubic-bezier(0.2,0.9,0.3,1.2) 0.15s both',opacity: draft.length > 0 ? 1 : 0}}>
          <div style={{
            maxWidth:'78%',
            background:`linear-gradient(180deg, ${chat.accent}, oklch(55% 0.18 260))`,
            color:'#fff',borderRadius:'18px 18px 4px 18px',padding:'10px 14px',
            fontFamily:chat.sans,fontSize:14,lineHeight:1.4,fontWeight:500,letterSpacing:-0.1,
            boxShadow:`0 8px 20px -6px ${chat.glow}, inset 0 1px 0 rgba(255,255,255,0.18)`,
          }}>
            {draft}<Caret c="#fff"/>
          </div>
        </div>

      </div>

      <ChatComposer draft={draft} typing/>
    </div>
  );
}

function MiniClass({ c, status }) {
  const isNow = status === 'now';
  const isNext = status === 'next';
  const isLater = status === 'later';
  return (
    <div style={{
      display:'flex',alignItems:'center',gap:12,padding:'10px 12px',borderRadius:14,
      background: isNow ? `linear-gradient(90deg, ${chat.accentSoft}, transparent)` : 'rgba(255,255,255,0.025)',
      border: `1px solid ${isNow ? 'rgba(72,165,255,0.22)' : 'rgba(255,255,255,0.05)'}`,
      opacity: isLater ? 0.78 : 1,
    }}>
      <div style={{fontFamily:chat.mono,fontSize:10,color:chat.ink2,textAlign:'right',minWidth:34,lineHeight:1.3}}>
        <div style={{color:chat.ink}}>{c.start}</div>
        <div style={{color:chat.muted,fontSize:9}}>{c.end}</div>
      </div>
      <div style={{width:2,alignSelf:'stretch',borderRadius:2,background: isNow ? chat.accent : isNext ? 'rgba(72,165,255,0.5)' : 'rgba(255,255,255,0.1)',boxShadow: isNow ? `0 0 6px ${chat.glow}` : 'none'}}/>
      <div style={{flex:1,minWidth:0}}>
        <div style={{fontFamily:chat.display,fontSize:13,fontWeight:500,color:chat.ink,letterSpacing:-0.1,lineHeight:1.2,whiteSpace:'nowrap',overflow:'hidden',textOverflow:'ellipsis'}}>{c.title}</div>
        <div style={{fontFamily:chat.sans,fontSize:10,color:chat.muted,marginTop:2}}>{c.mentor} · <span style={{fontFamily:chat.mono}}>Rm {c.room}</span></div>
      </div>
      {isNow && <span style={{fontFamily:chat.mono,fontSize:8,letterSpacing:1.2,textTransform:'uppercase',color:'#fff',padding:'3px 6px',borderRadius:5,background:chat.accent,boxShadow:`0 0 8px ${chat.glow}`}}>Now</span>}
      {isNext && <span style={{fontFamily:chat.mono,fontSize:8,letterSpacing:1.2,textTransform:'uppercase',color:chat.accent2,padding:'3px 6px',borderRadius:5,border:`1px solid ${chat.border2}`,background:chat.surface}}>Next</span>}
    </div>
  );
}

// ═════════════════════════════════════════════════════════════
// 03 — TIMELINE: conversation as a day-spine thread
// ═════════════════════════════════════════════════════════════

function ChatTimeline() {
  const [draft, setDraft] = React.useState('');
  const target = "remind me 5 min before my next class";
  React.useEffect(() => {
    let i = 0;
    const id = setInterval(() => {
      i++;
      setDraft(target.slice(0, i));
      if (i >= target.length) clearInterval(id);
    }, 48);
    return () => clearInterval(id);
  }, []);

  return (
    <div style={{background:chat.bg,color:chat.ink,fontFamily:chat.sans,minHeight:'100%',display:'flex',flexDirection:'column',position:'relative',overflow:'hidden'}}>
      <ChatStyles/>

      {/* subtle grid */}
      <div style={{position:'absolute',inset:0,pointerEvents:'none',opacity:0.06}}>
        <svg width="100%" height="100%"><defs><pattern id="cgrid" width="18" height="18" patternUnits="userSpaceOnUse"><circle cx="1" cy="1" r="0.7" fill="#fff"/></pattern></defs><rect width="100%" height="100%" fill="url(#cgrid)"/></svg>
      </div>
      <div style={{position:'absolute',top:-60,right:-40,width:220,height:220,borderRadius:'50%',background:`radial-gradient(circle, ${chat.glow}, transparent 65%)`,filter:'blur(32px)',animation:'novaAur1 10s ease-in-out infinite',pointerEvents:'none'}}/>

      {/* Header */}
      <div style={{position:'relative',padding:'14px 18px',borderBottom:`1px solid ${chat.border}`}}>
        <div style={{fontFamily:chat.mono,fontSize:9,letterSpacing:1.4,textTransform:'uppercase',color:chat.muted}}>Conversation · Tue · 21 Apr</div>
        <div style={{display:'flex',alignItems:'center',gap:10,marginTop:4}}>
          <div style={{fontFamily:chat.display,fontSize:20,fontWeight:600,letterSpacing:-0.5,lineHeight:1}}>Ask Nova</div>
          <span style={{flex:1}}/>
          <span style={{width:8,height:8,borderRadius:10,background:chat.ok,boxShadow:`0 0 6px ${chat.ok}`}}/>
          <span style={{fontFamily:chat.mono,fontSize:10,color:chat.ink2}}>online</span>
        </div>
      </div>

      {/* Timeline */}
      <div style={{flex:1,overflow:'hidden',padding:'16px 14px 8px',position:'relative',zIndex:1}}>
        <div style={{position:'relative',paddingLeft:44}}>

          {/* spine */}
          <div style={{position:'absolute',left:14,top:12,bottom:12,width:2,background:'linear-gradient(180deg, rgba(255,255,255,0.12), rgba(255,255,255,0.02))',borderRadius:2}}/>

          <TimelineRow role="nova" time="10:30">
            <span style={{fontFamily:chat.display,fontWeight:500,fontSize:15,letterSpacing:-0.1,color:chat.ink}}>Morning.</span>{' '}
            <span style={{color:chat.ink2}}>You finished 2 classes, halfway through Discrete Maths.</span>
          </TimelineRow>

          <TimelineRow role="user" time="10:32">
            how's my attendance looking this week
          </TimelineRow>

          <TimelineRow role="nova" time="10:32" streaming={false}>
            <span style={{color:chat.ink2}}>Steady.</span>{' '}
            <span style={{fontFamily:chat.mono,color:chat.ok,background:'oklch(72% 0.18 160 / 0.14)',padding:'1px 6px',borderRadius:5,fontSize:13}}>92%</span>{' '}
            <span style={{color:chat.ink2}}>this week — up from</span>{' '}
            <span style={{fontFamily:chat.mono,color:chat.ink,fontSize:13}}>87%</span>{' '}
            <span style={{color:chat.ink2}}>overall.</span>
          </TimelineRow>

          <TimelineRow role="user" time="10:33" draft={draft} typing/>

          <TimelineRow role="nova" time="" typing>
            <TypingDots/>
          </TimelineRow>

        </div>
      </div>

      <ChatComposer draft={draft} typing/>
    </div>
  );
}

function TimelineRow({ role, time, children, draft, typing }) {
  const isUser = role === 'user';
  return (
    <div style={{position:'relative',marginBottom:16,animation:'novaRiseIn 0.4s ease-out both'}}>
      {/* node */}
      <div style={{position:'absolute',left:-34,top:4,width:26,height:26,borderRadius:'50%',display:'flex',alignItems:'center',justifyContent:'center',
        background: isUser ? `linear-gradient(180deg, ${chat.accent}, oklch(55% 0.18 260))` : chat.bg2,
        border: isUser ? '1px solid rgba(255,255,255,0.18)' : `1px solid ${chat.border2}`,
        boxShadow: isUser ? `0 4px 12px -4px ${chat.glow}` : 'none',
      }}>
        {isUser ? (
          <span style={{fontFamily:chat.mono,fontSize:10,fontWeight:600,color:'#fff',letterSpacing:0.3}}>AR</span>
        ) : <NovaMark size={18}/>}
      </div>

      <div style={{display:'flex',alignItems:'center',gap:6,marginBottom:4}}>
        <span style={{fontFamily:chat.display,fontSize:11,fontWeight:600,letterSpacing:0.1,color: isUser ? chat.accent2 : chat.ink}}>
          {isUser ? 'You' : 'Nova'}
        </span>
        {time && <span style={{fontFamily:chat.mono,fontSize:9,color:chat.muted,letterSpacing:1}}>{time}</span>}
      </div>
      <div style={{fontFamily:chat.sans,fontSize:13,lineHeight:1.5,color:chat.ink,paddingBottom:2}}>
        {draft !== undefined ? (
          <>
            <span>{draft}</span>
            {typing && <Caret c={chat.accent2}/>}
          </>
        ) : children}
      </div>
    </div>
  );
}

Object.assign(window, {
  chat, NovaMark, ChatProse, ChatCards, ChatTimeline,
  Caret, TypingDots, ChatComposer,
});
