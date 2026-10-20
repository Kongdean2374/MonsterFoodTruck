#!/usr/bin/env python3
import json
import math
import struct
import wave
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
RES=ROOT/'MonsterFoodTruck/Resources'
c=json.loads((RES/'Content.json').read_text())
assert c['version']==1
assert len(c['recipes'])==3 and len(c['monsters'])==3 and len(c['levels'])==6
recipe_ids={r['id'] for r in c['recipes']};monster_ids={m['id'] for m in c['monsters']}
assert len(recipe_ids)==3 and len(monster_ids)==3
assert [len(level['orders']) for level in c['levels']]==[3,4,5,6,7,9]
for recipe in c['recipes']:
 assert all(math.isfinite(recipe[key]) and recipe[key]>0 for key in ['prep','cook','grace'])
 assert recipe['atlasColumn'] in range(3)
for monster in c['monsters']:
 assert monster['patience']>0 and monster['atlasColumn'] in range(3)
for level in c['levels']:
 assert len({o['id'] for o in level['orders']})==len(level['orders'])
 times=[o['scheduledAt'] for o in level['orders']]
 assert times==sorted(times) and times[0]==0 and all(t>=0 for t in times)
 assert all(o['monster'] in monster_ids and o['recipe'] in recipe_ids for o in level['orders'])

def png_info(path):
 data=path.read_bytes()
 assert data[:8]==b'\x89PNG\r\n\x1a\n'
 return struct.unpack('>IIBB',data[16:26])
assert png_info(RES/'Art/characters-and-dishes.png')[:2]==(1536,1024)
assert png_info(RES/'Art/characters-and-dishes.png')[3]==6
assert png_info(ROOT/'MonsterFoodTruck/Assets.xcassets/AppIcon.appiconset/Icon.png')[:2]==(1024,1024)
assert png_info(ROOT/'MonsterFoodTruck/Assets.xcassets/AppIcon.appiconset/Icon.png')[3]==2
audio=json.loads((RES/'Audio/audio-analysis.json').read_text())
assert len(audio)==25
for record in audio:
 assert not record['clipped'] and record['peak']<1
 with wave.open(str(RES/'Audio'/record['file'])) as file:
  assert file.getnchannels()==1 and file.getsampwidth()==2 and file.getframerate()==22050 and file.getnframes()>0
names=[p.name for p in RES.rglob('*') if p.is_file()]
assert len(names)==len(set(names)), 'Flat resource names must be unique'
print('Static validation: 3 recipes, 3 monsters, 6 scripts, alpha atlas, RGB icon, 25 PCM audio files; not visual or listening acceptance.')
