import AVFoundation
import Foundation

let asset=AVURLAsset(url:URL(fileURLWithPath:CommandLine.arguments[1]))
let duration=CMTimeGetSeconds(asset.duration)
guard duration.isFinite,duration>0,let track=asset.tracks(withMediaType:.video).first,
      track.naturalSize.width>0,track.naturalSize.height>0 else{
    fputs("Actual recording has no valid video track or duration\n",stderr);exit(1)
}
let report:[String:Any]=["duration_seconds":duration,"width":track.naturalSize.width,"height":track.naturalSize.height,"capture_nominal_fps":track.nominalFrameRate,"audio_tracks":asset.tracks(withMediaType:.audio).count,"scope":"Capture metadata only; nominal capture rate does not prove game FPS, image correctness, or audible playback."]
let data=try JSONSerialization.data(withJSONObject:report,options:[.prettyPrinted,.sortedKeys])
print(String(decoding:data,as:UTF8.self))
