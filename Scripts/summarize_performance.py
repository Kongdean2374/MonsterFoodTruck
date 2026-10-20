#!/usr/bin/env python3
"""Summarize actual on-device diagnostics; never synthesize missing observations."""
import json,math,sys
from pathlib import Path

report=json.loads(Path(sys.argv[1]).read_text())
assert report.get('node_inventory_version')==2,'Missing actual complete SpriteKit subtree observations; legacy direct-child counts cannot be promoted to full-tree evidence'
windows=report['windows']
def p95(values):
    return sorted(values)[max(0,math.ceil(len(values)*0.95)-1)] if values else None
rows=[]
for item in windows:
    frames=item['frameIntervals'];latency=item['handlerToNextSceneUpdateMS']
    rows.append(dict(entry=item['entry'],nodes=item['nodeCount'],root_nodes_at_entry=item['nodeCount'],descendant_nodes_at_entry=item['descendantNodesAtEntry'],root_nodes_at_pause=item.get('nodeCountAtPause'),descendant_nodes_at_pause=item.get('descendantNodesAtPause'),update_sampled_peak_root_nodes=item['peakNodeCount'],update_sampled_peak_descendant_nodes=item['peakDescendantNodes'],audio_players=item['allocatedAudioPlayers'],scene_updates=len(frames),active_seconds=sum(frames),scene_update_hz=len(frames)/sum(frames) if sum(frames)>0 else None,p95_frame_gap_ms=p95([x*1000 for x in frames]),max_frame_gap_ms=max(frames)*1000 if frames else None,handler_samples=len(latency),p95_handler_to_scene_update_ms=p95(latency),footprint_mb=item.get('footprintBytes',0)/1024**2,resident_mb=item.get('residentBytes',0)/1024**2))
summary=dict(scope=report['scope'],os=report['os'],device=report['device'],build=report['build'],node_inventory_version=report.get('node_inventory_version'),windows=rows,measurement_error=report['measurement_error'])
Path(sys.argv[2]).write_text(json.dumps(summary,ensure_ascii=False,indent=2)+'\n')
assert report['measurement_error'] is None,report['measurement_error']
assert len(rows)==20,f'Expected twenty actual entries, found {len(rows)}'
assert all(r['scene_updates']>0 and r['handler_samples']>0 for r in rows),'Missing actual scene/handler observations'
assert all(r['nodes']==1 for r in rows),'Unexpected retained nodes after fresh single-customer scene entry'
assert all(r['descendant_nodes_at_entry']>r['root_nodes_at_entry'] for r in rows),'Character child parts are missing from the recursive inventory'
assert len({r['descendant_nodes_at_entry'] for r in rows})==1,'Complete character subtree grew across scene entry'
assert all(r['root_nodes_at_pause']==r['root_nodes_at_entry'] and r['descendant_nodes_at_pause']==r['descendant_nodes_at_entry'] for r in rows),'Complete subtree changed after the same first-customer preparation flow'
assert all(r['update_sampled_peak_root_nodes']>=r['root_nodes_at_entry'] and r['update_sampled_peak_descendant_nodes']>=r['descendant_nodes_at_entry'] for r in rows),'Invalid sampled node maxima'
assert len({r['audio_players'] for r in rows})==1,'Allocated audio players grew'
