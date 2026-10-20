import AVFoundation
import CoreMedia
import CoreVideo
import Foundation

// Read every actual decoded frame PTS. No seek tolerance or requested sample
// times are substituted for the frame that was actually returned.
let video=URL(fileURLWithPath:CommandLine.arguments[1])
let output=URL(fileURLWithPath:CommandLine.arguments[2])
let asset=AVURLAsset(url:video)
guard let track=asset.tracks(withMediaType:.video).first else{fatalError("Missing actual video track")}
let reader=try AVAssetReader(asset:asset)
let samples=AVAssetReaderTrackOutput(track:track,outputSettings:[kCVPixelBufferPixelFormatTypeKey as String:kCVPixelFormatType_32BGRA])
samples.alwaysCopiesSampleData=false
reader.add(samples)
guard reader.startReading() else{fatalError("Could not read actual video")}
var times:[Double]=[]
while let sample=samples.copyNextSampleBuffer(){
    let seconds=CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(sample))
    guard seconds.isFinite,CMSampleBufferGetImageBuffer(sample) != nil else{fatalError("Invalid decoded frame")}
    times.append(seconds)
}
guard reader.status == .completed,!times.isEmpty else{fatalError("Video decode incomplete: \(String(describing:reader.error))")}
times.sort()
let gaps=zip(times,times.dropFirst()).map{$0.1-$0.0}.sorted()
let duration=CMTimeGetSeconds(asset.duration)
guard duration.isFinite,duration>0 else{fatalError("Invalid actual duration")}
struct VideoReport:Encodable {
    let file:String
    let duration_seconds:Double
    let width:Double,height:Double
    let audio_tracks:Int,decoded_frame_count:Int
    let first_actual_seconds:Double,last_actual_seconds:Double
    let max_actual_frame_gap_seconds:Double,p95_actual_frame_gap_seconds:Double
    let scope:String
}
let report=VideoReport(file:video.lastPathComponent,duration_seconds:duration,width:Double(track.naturalSize.width),height:Double(track.naturalSize.height),audio_tracks:asset.tracks(withMediaType:.audio).count,decoded_frame_count:times.count,first_actual_seconds:times.first!,last_actual_seconds:times.last!,max_actual_frame_gap_seconds:gaps.last ?? 0,p95_actual_frame_gap_seconds:gaps.isEmpty ? 0:gaps[max(0,Int(ceil(Double(gaps.count)*0.95))-1)],scope:"Continuous native simulator recording; all decoded presentation timestamps retained. This measures recorded frame coverage, not physical display FPS, artistic acceptance or audio playback. No requested times or generated replacement frames.")
let encoder=JSONEncoder();encoder.outputFormatting=[.prettyPrinted,.sortedKeys]
let reportData=try encoder.encode(report)
try reportData.write(to:output.appendingPathExtension("json"))
try ("decoded_frame,actual_seconds\n"+times.enumerated().map{"\($0.offset),\($0.element)"}.joined(separator:"\n")+"\n").write(to:output.appendingPathExtension("csv"),atomically:true,encoding:.utf8)
print(String(data:reportData,encoding:.utf8)!)
