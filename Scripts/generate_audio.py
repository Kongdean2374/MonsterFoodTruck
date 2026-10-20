#!/usr/bin/env python3
"""Original score and short event tones. No samples, downloaded music, or runtime synthesis."""
import array
import json
import math
import wave
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'MonsterFoodTruck/Resources/Audio'
RATE=22050
TAU=2*math.pi

def frequency(midi): return 440*2**((midi-69)/12)
def tone(buffer,at,duration,midi,gain=0.1,kind='bell'):
    start=int(at*RATE);count=min(int(duration*RATE),len(buffer)-start)
    f=frequency(midi)
    for i in range(max(0,count)):
        t=i/RATE
        attack=min(1,t/0.012)
        release=min(1,(duration-t)/0.08)
        env=attack*max(0,release)*math.exp(-t*(3 if kind=='bell' else 1.3))
        sound=math.sin(TAU*f*t)+0.22*math.sin(TAU*2*f*t)+0.06*math.sin(TAU*3*f*t)
        buffer[start+i]+=gain*env*sound

def write(name,samples):
    peak=max(abs(x) for x in samples) or 1
    if peak>0.92: samples=[x*0.92/peak for x in samples]
    pcm=array.array('h',(int(max(-1,min(1,x))*32767) for x in samples))
    if __import__('sys').byteorder!='little':pcm.byteswap()
    with wave.open(str(OUT/(name+'.wav')),'wb') as file:
        file.setnchannels(1);file.setsampwidth(2);file.setframerate(RATE);file.writeframes(pcm.tobytes())
    rms=math.sqrt(sum(x*x for x in samples)/len(samples))
    return dict(file=name+'.wav',duration=round(len(samples)/RATE,3),peak=round(max(abs(x) for x in samples),4),rms=round(rms,4),clipped=any(abs(x)>=1 for x in samples),rate=RATE)

def main():
    OUT.mkdir(parents=True,exist_ok=True)
    report=[];beat=60/92;length=32*beat
    score=[0.0]*int(length*RATE)
    # Original eight-bar D-major lullaby; rests leave room for cooking warnings.
    melody=[(0,74),(1.5,78),(3,81),(4.5,78),(6,76),(7,74),(8,71),(9.5,74),(11,78),(13,76),(15,74),(16,72),(18,76),(19.5,79),(21,78),(23,76),(24,73),(26,76),(27,81),(29,78),(30,74)]
    for when,note in melody:tone(score,when*beat,1.2*beat,note,0.075)
    for bar,root in enumerate([50,50,47,47,48,48,45,50]):
        for offset,semitone in [(0,0),(1,7),(2,12),(3,7)]:tone(score,(bar*4+offset)*beat,1.4*beat,root+semitone,0.035,'wood')
    # Silent boundaries avoid discontinuities at the loop seam.
    for i in range(min(int(0.02*RATE),len(score))):score[i]*=i/(0.02*RATE);score[-1-i]*=i/(0.02*RATE)
    report.append(write('forest_evening',score))
    events={'select':[76],'prepStart':[62,67],'prepDone':[74,79],'cookStart':[55,62],'cookDone':[81,86,90],'scorched':[66,62],'plated':[72,79],'toppingStart':[79,83],'toppingDone':[83,86],'covered':[60,67],'uncovered':[67,60],'nibbleWarning':[89,77,89],'nibbled':[53,56],'tidyStart':[64,69],'tidyDone':[72,76],'served':[76,79],'preferred':[79,83,86],'left':[67,64],'arrival':[72,76],'win':[74,78,81,86],'lose':[71,67,62],'dragonReaction':[50,57,62],'impReaction':[84,81,88],'deerReaction':[76,81,79]}
    for name,notes in events.items():
        buffer=[0.0]*int((0.24+0.09*len(notes))*RATE)
        for i,note in enumerate(notes):tone(buffer,i*0.09,0.22,note,0.15 if name=='nibbleWarning' else 0.10)
        report.append(write(name,buffer))
    (OUT/'audio-analysis.json').write_text(json.dumps(report,indent=2)+'\n')
    print('Generated',len(report),'original audio files. Numeric analysis only; listening still requires review.')

if __name__=='__main__':main()
