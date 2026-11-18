import hashlib,json,pathlib,zipfile,stat,sys,tempfile,collections,os
root=pathlib.Path(r'D:\Projects\Project_WF')
scratch=pathlib.Path(tempfile.mkdtemp(prefix='source-analysis-',dir=root/'work'))
acq=json.loads((root/'Codex/results/source-analysis/acquisition.json').read_text(encoding='utf-8-sig'))
records=[]
for a in acq:
    original=pathlib.Path(a['archive_path'])
    digest=hashlib.sha256(original.read_bytes()).hexdigest().upper()
    assert original.stat().st_size==a['size'] and digest==a['sha256'], 'acquisition mismatch'
    with zipfile.ZipFile(original) as z:
        infos=z.infolist(); seen={}; unsafe=[]
        total=sum(i.file_size for i in infos)
        assert total<2*1024**3 and max((i.file_size for i in infos),default=0)<128*1024**2,'size bound exceeded'
        entries=[]
        for i in infos:
            name=i.filename.replace('\\','/'); p=pathlib.PurePosixPath(name)
            mode=i.external_attr>>16
            reason=[]
            if p.is_absolute() or '..' in p.parts or ':' in name or '\x00' in name:reason.append('unsafe_path')
            if stat.S_ISLNK(mode):reason.append('symlink')
            key=str(p).rstrip('/').casefold()
            if key in seen and not(i.is_dir() and seen[key].is_dir()):reason.append('duplicate_or_case_collision')
            seen[key]=i
            if reason:unsafe.append({'name':i.filename,'reason':reason})
            entries.append({'path':i.filename,'is_dir':i.is_dir(),'size':i.file_size,'compressed':i.compress_size,'crc32':f'{i.CRC:08X}','utf8_name':bool(i.flag_bits&0x800)})
        assert not unsafe, json.dumps(unsafe,ensure_ascii=False)
        bad=z.testzip(); assert bad is None, 'CRC error '+str(bad)
        target=root/'SourceArchive/2022-11-19/extracted'/original.stem
        assert not target.exists(), 'target already exists'
        target.mkdir(parents=True)
        for i,e in zip(infos,entries):
            dst=target.joinpath(*pathlib.PurePosixPath(i.filename.replace('\\','/')).parts)
            assert os.path.commonpath([str(target.resolve()),str(dst.resolve())])==str(target.resolve()),'escape'
            if i.is_dir():dst.mkdir(parents=True,exist_ok=True)
            else:
                dst.parent.mkdir(parents=True,exist_ok=True)
                data=z.read(i); dst.write_bytes(data)
                e['sha256']=hashlib.sha256(data).hexdigest().upper()
                assert hashlib.sha256(dst.read_bytes()).hexdigest().upper()==e['sha256'],'extract mismatch'
        suffixes=collections.Counter(pathlib.PurePosixPath(e['path']).suffix.lower() for e in entries if not e['is_dir'])
        tocs=[]
        for e in entries:
            if pathlib.PurePosixPath(e['path']).suffix.lower()=='.toc':
                raw=target.joinpath(*pathlib.PurePosixPath(e['path']).parts).read_bytes()
                for enc in ('utf-8-sig','cp949','cp1252'):
                    try:txt=raw.decode(enc);break
                    except UnicodeDecodeError:continue
                tags={}
                for line in txt.splitlines():
                    if line.startswith('## ') and ':' in line: k,v=line[3:].split(':',1);tags[k.strip()]=v.strip()
                tocs.append({'path':e['path'],'encoding':enc,'tags':tags,'line_count':len(txt.splitlines())})
        rec={'archive':original.name,'size':a['size'],'sha256':digest,'entry_count':len(infos),'file_count':sum(not i.is_dir() for i in infos),'directory_count':sum(i.is_dir() for i in infos),'uncompressed_bytes':total,'unsafe_count':len(unsafe),'crc_bad_member':bad,'extracted_file_hash_match_count':sum(not i.is_dir() for i in infos),'extracted_root':str(target),'suffix_counts':dict(sorted(suffixes.items())),'toc_files':tocs,'entries':entries}
        records.append(rec)
        print(json.dumps({k:rec[k] for k in ('archive','entry_count','file_count','uncompressed_bytes','unsafe_count','crc_bad_member','suffix_counts')},ensure_ascii=False))
        print('TOP_LEVEL',sorted({tuple(pathlib.PurePosixPath(e['path']).parts[:3]) for e in entries if not e['is_dir']}))
        print('SPECIAL',[e['path'] for e in entries if any(s in e['path'].casefold() for s in ('devil','fanfix','profile','default','license','readme','wtf','savedvariables'))][:200])
        print('TOC_CORE',[t for t in tocs if any(s in t['path'].casefold() for s in ('devil','dominos','pitbull','quartz','sexymap','chocolate','masque'))])
out=root/'Codex/results/source-analysis/archive-inventory.json'
assert not out.exists();out.write_text(json.dumps({'schema':'source-archive-inventory/1','python':sys.version,'records':records},ensure_ascii=False,indent=2),encoding='utf-8')
(scratch/'inspection-summary.txt').write_text('archive inventory created with full CRC, safe paths and per-file extracted hash checks\n',encoding='utf-8')
print('PASS archives=2; byte_pins=2/2; CRC_errors=0; unsafe_paths=0; extraction_hashes_all_matched; inventory='+str(out));print('SCRATCH='+str(scratch))
