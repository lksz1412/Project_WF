import pathlib,re,json,sys,hashlib,collections
sys.stdout.reconfigure(encoding='utf-8')
ROOT=pathlib.Path(r'D:\Projects\Project_WF')
base=ROOT/'SourceArchive/2022-11-19/extracted/Interface/addons/!DevilUI/Profile'
pat=re.compile(r'(?P<ws>\s+)|(?P<comment>--\[\[.*?\]\]|--[^\n]*)|(?P<long>\[\[.*?\]\])|(?P<string>"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\')|(?P<number>-?(?:0x[0-9A-Fa-f]+|\d+(?:\.\d*)?(?:[eE][+-]?\d+)?))|(?P<id>[A-Za-z_][A-Za-z_0-9]*)|(?P<punct>[{}\[\]=,;])',re.S)
def unquote(s):
    if s.startswith('[['):return s[2:-2]
    s=s[1:-1]
    def repl(m):
        c=m.group(1)
        if c.isdigit():return chr(int(c))
        return {'n':'\n','r':'\r','t':'\t','a':'\a','b':'\b','f':'\f','v':'\v','\\':'\\','"':'"',"'":"'"}.get(c,c)
    return re.sub(r'\\(\d{1,3}|.)',repl,s,flags=re.S)
class Parser:
    def __init__(self,text):
        self.text=text;self.ts=[];self.pos=0;self.spans={};self.dups=[]
        at=0;line=1
        while at<len(text):
            m=pat.match(text,at)
            if not m:raise ValueError(('unrecognized token',line,text[at:at+40]))
            kind=m.lastgroup;val=m.group();start=line;line+=val.count('\n');at=m.end()
            if kind not in ('ws','comment'):self.ts.append((kind,val,start,line))
    def take(self,value=None):
        t=self.ts[self.pos];self.pos+=1
        if value is not None and t[1]!=value:raise ValueError(('expected',value,'got',t))
        return t
    def peek(self):return self.ts[self.pos][1] if self.pos<len(self.ts) else None
    def value(self,path):
        start=self.ts[self.pos][2];kind,s,_,_=self.take()
        if s=='{':
            val={};auto=1
            while self.peek()!='}':
                if self.peek()=='[':
                    self.take('[');k=self.value(path+('/<key>',));self.take(']');self.take('=')
                elif self.ts[self.pos][0]=='id' and self.pos+1<len(self.ts) and self.ts[self.pos+1][1]=='=':
                    k=self.take()[1];self.take('=')
                else:k=auto;auto+=1
                subpath=path+(str(k),);v=self.value(subpath)
                if k in val:self.dups.append({'path':list(subpath),'line':self.ts[self.pos-1][3]})
                val[k]=v
                if self.peek() in (',',';'):self.take()
                elif self.peek()!='}':raise ValueError(('expected separator',self.ts[self.pos]))
            end=self.take('}')[3]
        elif kind in ('string','long'):val=unquote(s);end=self.ts[self.pos-1][3]
        elif kind=='number':val=float(s) if any(c in s for c in '.eE') else int(s,0 if s.lower().startswith(('0x','-0x')) else 10);end=self.ts[self.pos-1][3]
        elif s in ('true','false','nil'):val={'true':True,'false':False,'nil':None}[s];end=self.ts[self.pos-1][3]
        else:raise ValueError(('not literal',kind,s,start))
        self.spans['/'.join(path)]=[start,end]
        return val
    def parse(self):
        result={}
        while self.peek() is not None:
            name=self.take()[1];self.take('=');result[name]=self.value((name,))
            if self.peek()==';':self.take()
        return result
all_data={};evidence={};overview=[]
for name in ('Dominos','PitBull4','kgPanels','SexyMap','Quartz','Masque','ChocolateBar'):
    p=base/(name+'.lua');text=p.read_text(encoding='utf-8-sig');parser=Parser(text);data=parser.parse()
    all_data[name]={'data':data,'spans':parser.spans,'source':str(p.relative_to(ROOT)),'duplicates':parser.dups}
    root=list(data)[0];d=data[root]
    profiles=list(d.get('profiles',{})) if isinstance(d,dict) else []
    overview.append({'file':name+'.lua','lines':len(text.splitlines()),'root_assignments':list(data),'literal_tokens':len(parser.ts),'duplicate_keys':len(parser.dups),'profiles':profiles,'top_keys':list(d)[:20]})
    print(json.dumps(overview[-1],ensure_ascii=False))
    if name in ('Dominos','PitBull4','kgPanels','Masque','ChocolateBar'):
        target=d.get('profiles',{}).get('loaf');span=parser.spans.get(root+'/profiles/loaf')
        print('LOAF',name,'lines',span,'keys',list(target) if isinstance(target,dict) else target)
        evidence[name]={'source':str(p.relative_to(ROOT)),'loaf_span':span,'loaf':target,'profile_labels':profiles}
        if name=='kgPanels':evidence[name]['global']=d.get('global');evidence[name]['global_span']=parser.spans.get(root+'/global')
    elif name=='SexyMap':
        evidence[name]={'source':str(p.relative_to(ROOT)),'loaf_span':parser.spans.get(root+'/loaf'),'loaf':d.get('loaf')}
        print('LOAF',name,'lines',parser.spans.get(root+'/loaf'),'keys',list(d.get('loaf',{})))
    elif name=='Quartz':evidence[name]={'source':str(p.relative_to(ROOT)),'data':d}
work=pathlib.Path(sys.argv[1]);(work/'all-literal-profile-data.json').write_text(json.dumps(all_data,ensure_ascii=False,indent=2),encoding='utf-8')
out=ROOT/'Codex/results/source-analysis/profile-extract.json';assert not out.exists();out.write_text(json.dumps({'parser':'nonexecuting literal-only lexer/parser; complete source consumption required','overview':overview,'selected':evidence},ensure_ascii=False,indent=2),encoding='utf-8')
print('PASS fully_consumed_literal_files=7; no_Lua_execution; data_file='+str(out));print('SCRATCH_DATA='+str(work/'all-literal-profile-data.json'))
