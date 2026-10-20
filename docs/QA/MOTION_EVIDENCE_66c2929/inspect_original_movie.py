#!/usr/bin/env python3
"""Read-only native MOV verification. Writes JSON/CSV, never images or assets."""
import csv
import hashlib
import json
from pathlib import Path
import statistics
import subprocess
import sys

movie=Path(sys.argv[1]);prefix=Path(sys.argv[2]);prefix.parent.mkdir(parents=True,exist_ok=True)
hash_value=hashlib.sha256()
with movie.open('rb') as stream:
    for chunk in iter(lambda:stream.read(1024*1024),b''):hash_value.update(chunk)
probe=json.loads(subprocess.check_output(['ffprobe','-v','error','-show_streams','-show_format','-of','json',str(movie)]))
frames=json.loads(subprocess.check_output(['ffprobe','-v','error','-select_streams','v:0','-show_frames','-show_entries','frame=pts_time','-of','json',str(movie)]))['frames']
times=[float(frame['pts_time']) for frame in frames]
assert times, 'Missing actual decoded frames'
reversals=[dict(decoded_frame_zero_based=i,previous_actual_seconds=times[i-1],actual_seconds=times[i]) for i in range(1,len(times)) if times[i]<times[i-1]]
decode=subprocess.run(['ffmpeg','-hide_banner','-v','error','-i',str(movie),'-map','0:v:0','-vf','setpts=N','-fps_mode','passthrough','-f','null','-'],capture_output=True,text=True)
assert decode.returncode==0 and not decode.stderr.strip(),decode.stderr
video=next(s for s in probe['streams'] if s['codec_type']=='video');gaps=[b-a for a,b in zip(times,times[1:])]
with prefix.with_suffix('.csv').open('w',newline='') as stream:
    writer=csv.writer(stream);writer.writerow(['decoded_frame_zero_based','actual_seconds']);writer.writerows(enumerate(times))
report=dict(file=movie.name,sha256=hash_value.hexdigest(),bytes=movie.stat().st_size,duration_seconds=float(probe['format']['duration']),width=video['width'],height=video['height'],audio_tracks=sum(s['codec_type']=='audio' for s in probe['streams']),decoded_frame_count=len(times),duplicate_pts_count=len(times)-len(set(times)),raw_pts_reversals=reversals,first_actual_seconds=times[0],last_actual_seconds=times[-1],max_actual_frame_gap_seconds=max(gaps,default=0),median_actual_frame_gap_seconds=statistics.median(gaps) if gaps else 0,full_decode_exit=decode.returncode,full_decode_errors=decode.stderr,decoder=subprocess.check_output(['ffmpeg','-version'],text=True).splitlines()[0],method='Read every decoded original MOV presentation timestamp with ffprobe frame pts_time and independently decode the complete video with ffmpeg into a discarded null sink. Only the discarded sink uses setpts=N to avoid muxer DTS rounding warnings; original MOV bytes and indexed raw PTS are untouched. Non-monotonic raw timestamps are recorded rather than sorted away. No requested seek time, nominal FPS, generated frames, PNG editing or source changes.',scope='Derived local read-only verification of the actual downloaded native recording. Original native probe/export failure remains recorded. Whole-movie gaps include static setup and shutdown; this is recorded-frame coverage, not gameplay or physical display FPS, joint approval or audible playback.')
prefix.with_suffix('.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({k:report[k] for k in ['file','sha256','duration_seconds','decoded_frame_count','audio_tracks','full_decode_exit']}))
