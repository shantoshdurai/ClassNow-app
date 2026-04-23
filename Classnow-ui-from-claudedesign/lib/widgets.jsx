// Home-screen widgets — Paper + Glass, two sizes each

// ─ Shared android homescreen wallpaper background ─
function HomescreenBg({ dark, children }) {
  const bg = dark
    ? 'linear-gradient(160deg, #0a0614 0%, #1a0a2e 40%, #2a0e3a 70%, #0a0614 100%)'
    : 'linear-gradient(160deg, #d7c9b5 0%, #e4d9c6 40%, #efe6d4 70%, #d2c3ac 100%)';
  return (
    <div style={{width:'100%',height:'100%',background:bg,position:'relative',overflow:'hidden',padding:'8px 10px'}}>
      {/* Android clock widget */}
      <div style={{position:'absolute',top:14,left:16,color:dark?'#fff':'#1a1a1a',fontFamily:'"Inter", sans-serif'}}>
        <div style={{fontSize:52,fontWeight:200,letterSpacing:-2,lineHeight:1}}>10:42</div>
        <div style={{fontSize:12,opacity:0.7,marginTop:2,letterSpacing:0.5}}>Tue, April 21 · 28° Partly cloudy</div>
      </div>
      <div style={{position:'absolute',top:130,left:10,right:10}}>{children}</div>

      {/* Dock */}
      <div style={{position:'absolute',bottom:16,left:10,right:10,display:'flex',justifyContent:'space-around',padding:'10px 14px',background:dark?'rgba(0,0,0,0.3)':'rgba(255,255,255,0.3)',backdropFilter:'blur(18px)',borderRadius:28}}>
        {['#3B82F6','#10B981','#EC4899','#F59E0B','#8B5CF6'].map((c,i) => (
          <div key={i} style={{width:44,height:44,borderRadius:12,background:c,boxShadow:'0 4px 8px rgba(0,0,0,0.2)'}}/>
        ))}
      </div>
    </div>
  );
}

// ─ Paper widget (medium) ─
function PaperWidgetMedium() {
  return (
    <div style={{background:paper.paper,border:`1px solid ${paper.line}`,borderRadius:24,padding:'16px 18px',boxShadow:'0 8px 20px rgba(0,0,0,0.08)',fontFamily:paper.sans}}>
      <div style={{display:'flex',alignItems:'center',justifyContent:'space-between',marginBottom:10}}>
        <div style={{display:'flex',alignItems:'center',gap:6}}>
          <span style={{width:8,height:8,borderRadius:10,background:paper.accent,boxShadow:`0 0 0 3px ${paper.accentSoft}`}}/>
          <span style={{fontFamily:paper.mono,fontSize:9,letterSpacing:1.5,textTransform:'uppercase',color:paper.accentInk,fontWeight:700}}>In session</span>
        </div>
        <span style={{fontFamily:paper.mono,fontSize:10,color:paper.muted}}>28m left</span>
      </div>
      <div style={{fontFamily:paper.serif,fontSize:20,fontWeight:500,letterSpacing:-0.4,color:paper.ink,lineHeight:1.1}}>Discrete Mathematics</div>
      <div style={{display:'flex',alignItems:'center',gap:10,marginTop:6,fontSize:11,color:paper.muted}}>
        <span>Mrs. N. Subashini</span>
        <span style={{color:paper.faint}}>·</span>
        <span style={{fontFamily:paper.mono}}>Room 704</span>
      </div>
      {/* progress */}
      <div style={{marginTop:12,height:3,borderRadius:3,background:paper.faint,position:'relative',overflow:'hidden'}}>
        <div style={{width:'44%',height:'100%',background:paper.ink}}/>
      </div>
      <div style={{display:'flex',justifyContent:'space-between',marginTop:4,fontFamily:paper.mono,fontSize:9,color:paper.muted,letterSpacing:0.5}}>
        <span>10:10</span><span>11:00</span>
      </div>
      {/* next */}
      <div style={{marginTop:10,paddingTop:10,borderTop:`1px solid ${paper.line}`,display:'flex',alignItems:'center',gap:8}}>
        <span style={{fontFamily:paper.mono,fontSize:9,letterSpacing:1.3,textTransform:'uppercase',color:paper.muted}}>Next</span>
        <span style={{fontSize:11,fontWeight:500,color:paper.ink}}>Computational Intelligence</span>
        <span style={{flex:1}}/>
        <span style={{fontFamily:paper.mono,fontSize:10,color:paper.muted}}>11:15</span>
      </div>
    </div>
  );
}

// ─ Paper widget (small) ─
function PaperWidgetSmall() {
  return (
    <div style={{background:paper.paper,border:`1px solid ${paper.line}`,borderRadius:22,padding:'14px',fontFamily:paper.sans,height:'100%',display:'flex',flexDirection:'column',justifyContent:'space-between',boxShadow:'0 8px 20px rgba(0,0,0,0.08)'}}>
      <div style={{display:'flex',alignItems:'center',gap:5}}>
        <span style={{width:6,height:6,borderRadius:10,background:paper.accent}}/>
        <span style={{fontFamily:paper.mono,fontSize:8,letterSpacing:1.3,textTransform:'uppercase',color:paper.accentInk,fontWeight:700}}>Now · 28m</span>
      </div>
      <div>
        <div style={{fontFamily:paper.serif,fontSize:14,fontWeight:500,color:paper.ink,letterSpacing:-0.2,lineHeight:1.1}}>Discrete Math</div>
        <div style={{fontFamily:paper.mono,fontSize:9,color:paper.muted,marginTop:4}}>Rm 704 · 10:10–11:00</div>
      </div>
    </div>
  );
}

// ─ Glass widget (medium) ─
function GlassWidgetMedium() {
  return (
    <div style={{background:'linear-gradient(180deg, rgba(20,25,35,0.85), rgba(10,12,18,0.85))',border:`1px solid ${glass.border2}`,borderRadius:26,padding:'16px 18px',backdropFilter:'blur(20px)',fontFamily:glass.sans,color:glass.ink,position:'relative',overflow:'hidden',boxShadow:`0 16px 36px -10px rgba(0,0,0,0.6), 0 0 0 1px rgba(255,255,255,0.03) inset, 0 0 40px -10px ${glass.accentGlow}`}}>
      {/* glow */}
      <div style={{position:'absolute',top:-30,right:-30,width:140,height:140,borderRadius:'50%',background:`radial-gradient(circle, ${glass.accentGlow}, transparent 65%)`,filter:'blur(10px)'}}/>
      <div style={{position:'relative'}}>
        <div style={{display:'flex',alignItems:'center',justifyContent:'space-between',marginBottom:10}}>
          <div style={{display:'flex',alignItems:'center',gap:6}}>
            <span style={{width:8,height:8,borderRadius:10,background:glass.accent,boxShadow:`0 0 8px ${glass.accent}`}}/>
            <span style={{fontFamily:glass.mono,fontSize:9,letterSpacing:1.8,textTransform:'uppercase',color:glass.accent2,fontWeight:700}}>In session</span>
          </div>
          <span style={{fontFamily:glass.mono,fontSize:10,color:glass.ink2}}>28m left</span>
        </div>
        <div style={{fontFamily:glass.display,fontSize:20,fontWeight:600,letterSpacing:-0.5,lineHeight:1.05}}>Discrete Mathematics</div>
        <div style={{display:'flex',alignItems:'center',gap:8,marginTop:6,fontSize:11,color:glass.ink2}}>
          <span>Mrs. N. Subashini</span>
          <span style={{color:glass.muted}}>·</span>
          <span style={{fontFamily:glass.mono}}>Rm 704</span>
        </div>
        {/* progress */}
        <div style={{marginTop:12,height:4,borderRadius:6,background:'rgba(255,255,255,0.08)',overflow:'hidden'}}>
          <div style={{width:'44%',height:'100%',background:`linear-gradient(90deg, ${glass.accent}, ${glass.accent2})`,boxShadow:`0 0 12px ${glass.accentGlow}`}}/>
        </div>
        <div style={{display:'flex',justifyContent:'space-between',marginTop:6,fontFamily:glass.mono,fontSize:9,color:glass.muted,letterSpacing:0.5}}>
          <span>10:10</span><span>11:00</span>
        </div>
        <div style={{marginTop:10,paddingTop:10,borderTop:`1px solid ${glass.border}`,display:'flex',alignItems:'center',gap:8}}>
          <span style={{fontFamily:glass.mono,fontSize:9,letterSpacing:1.3,textTransform:'uppercase',color:glass.muted}}>Next</span>
          <span style={{fontSize:11,fontWeight:500,color:glass.ink}}>Comp. Intelligence</span>
          <span style={{flex:1}}/>
          <span style={{fontFamily:glass.mono,fontSize:10,color:glass.ink2}}>11:15</span>
        </div>
      </div>
    </div>
  );
}

// ─ Glass widget (small) ─
function GlassWidgetSmall() {
  return (
    <div style={{background:'linear-gradient(180deg, rgba(20,25,35,0.85), rgba(10,12,18,0.85))',border:`1px solid ${glass.border2}`,borderRadius:22,padding:'14px',fontFamily:glass.sans,color:glass.ink,height:'100%',display:'flex',flexDirection:'column',justifyContent:'space-between',position:'relative',overflow:'hidden',boxShadow:`0 10px 28px -8px rgba(0,0,0,0.6), 0 0 24px -8px ${glass.accentGlow}`}}>
      <div style={{position:'absolute',top:-20,right:-20,width:90,height:90,borderRadius:'50%',background:`radial-gradient(circle, ${glass.accentGlow}, transparent 65%)`,filter:'blur(8px)'}}/>
      <div style={{position:'relative',display:'flex',alignItems:'center',gap:5}}>
        <span style={{width:6,height:6,borderRadius:10,background:glass.accent,boxShadow:`0 0 6px ${glass.accent}`}}/>
        <span style={{fontFamily:glass.mono,fontSize:8,letterSpacing:1.3,textTransform:'uppercase',color:glass.accent2,fontWeight:700}}>Now · 28m</span>
      </div>
      <div style={{position:'relative'}}>
        <div style={{fontFamily:glass.display,fontSize:14,fontWeight:600,letterSpacing:-0.3,lineHeight:1.1}}>Discrete Math</div>
        <div style={{fontFamily:glass.mono,fontSize:9,color:glass.muted,marginTop:4}}>Rm 704 · 10:10–11:00</div>
      </div>
    </div>
  );
}

// ─ Full widget screens (homescreen with app icons around) ─
function PaperHomescreen() {
  return (
    <HomescreenBg dark={false}>
      <div style={{marginBottom:14}}><PaperWidgetMedium/></div>
      <div style={{display:'grid',gridTemplateColumns:'1fr 1fr',gap:12,height:150}}>
        <PaperWidgetSmall/>
        <div style={{background:'rgba(255,255,255,0.28)',borderRadius:22,backdropFilter:'blur(18px)',padding:'14px',display:'flex',flexDirection:'column',gap:8,fontFamily:paper.sans}}>
          <div style={{fontFamily:paper.mono,fontSize:9,letterSpacing:1.3,textTransform:'uppercase',color:'#3a3a3a',fontWeight:700}}>This week</div>
          <div style={{flex:1,display:'flex',alignItems:'end',gap:4}}>
            {[50,80,65,90,40].map((h,i) => (
              <div key={i} style={{flex:1,height:`${h}%`,background:i===1?paper.ink:'rgba(0,0,0,0.35)',borderRadius:4}}/>
            ))}
          </div>
          <div style={{fontFamily:paper.mono,fontSize:8,color:'#3a3a3a',display:'flex',justifyContent:'space-between'}}>
            <span>M</span><span>T</span><span>W</span><span>T</span><span>F</span>
          </div>
        </div>
      </div>
    </HomescreenBg>
  );
}

function GlassHomescreen() {
  return (
    <HomescreenBg dark={true}>
      <div style={{marginBottom:14}}><GlassWidgetMedium/></div>
      <div style={{display:'grid',gridTemplateColumns:'1fr 1fr',gap:12,height:150}}>
        <GlassWidgetSmall/>
        <div style={{background:'rgba(20,25,35,0.6)',borderRadius:22,backdropFilter:'blur(18px)',border:`1px solid ${glass.border}`,padding:'14px',display:'flex',flexDirection:'column',gap:8,fontFamily:glass.sans,color:glass.ink,position:'relative',overflow:'hidden'}}>
          <div style={{fontFamily:glass.mono,fontSize:9,letterSpacing:1.3,textTransform:'uppercase',color:glass.accent2,fontWeight:700}}>Streak</div>
          <div style={{fontFamily:glass.display,fontSize:36,fontWeight:600,letterSpacing:-1,lineHeight:1}}>18<span style={{fontSize:14,color:glass.muted,fontWeight:400}}>d</span></div>
          <div style={{flex:1,display:'flex',alignItems:'end',gap:3}}>
            {Array.from({length:14}).map((_,i) => (
              <div key={i} style={{flex:1,height:i===13?'100%':`${30+Math.random()*60}%`,background:i===13?glass.accent:`rgba(255,255,255,${0.15+i/40})`,borderRadius:3,boxShadow:i===13?`0 0 6px ${glass.accent}`:'none'}}/>
            ))}
          </div>
        </div>
      </div>
    </HomescreenBg>
  );
}

Object.assign(window, { PaperWidgetMedium, PaperWidgetSmall, GlassWidgetMedium, GlassWidgetSmall, PaperHomescreen, GlassHomescreen });
