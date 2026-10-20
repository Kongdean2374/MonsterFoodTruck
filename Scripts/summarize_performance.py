#!/usr/bin/env python3
"""Summarize actual on-device diagnostics; never synthesize missing observations."""
import json,math,sys
from pathlib import Path

report=json.loads(Path(sys.argv[1]).read_text())
windows=report['windows']
def p95(values):
    return sorted(values)[max(0,math.ceil(len(values)*0.95)-1)] if values else None
rows=[]
for item in windows:
    frames=item['frameIntervals'];latency=item['handlerToNextSceneUpdateMS']
    rows.append(dict(entry=item['entry'],nodes=item['nodeCount'],audio_players=item['allocatedAudioPlayers'],scene_updates=len(frames),active_seconds=sum(frames),scene_update_hz=len(frames)/sum(frames) if sum(frames)>0 else None,p95_frame_gap_ms=p95([x*1000 for x in frames]),max_frame_gap_ms=max(frames)*1000 if frames else None,handler_samples=len(latency),p95_handler_to_scene_update_ms=p95(latency),footprint_mb=item.get('footprintBytes',0)/1024**2,resident_mb=item.get('residentBytes',0)/1024**2))
summary=dict(scope=report['scope'],os=report['os'],device=report['device'],build=report['build'],windows=rows,measurement_error=report['measurement_error'])
Path(sys.argv[2]).write_text(json.dumps(summary,ensure_ascii=False,indent=2)+'\n')
assert report['measurement_error'] is None,report['measurement_error']
assert len(rows)==20,f'Expected twenty actual entries, found {len(rows)}'
assert all(r['scene_updates']>0 and r['handler_samples']>0 for r in rows),'Missing actual scene/handler observations'
assert all(r['nodes']==1 for r in rows),'Unexpected retained nodes after fresh single-customer scene entry'
assert len({r['audio_players'] for r in rows})==1,'Allocated audio players grew'
