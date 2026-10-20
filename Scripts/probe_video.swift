import AVFoundation
import Foundation
import AppKit

let asset=AVURLAsset(url:URL(fileURLWithPath:CommandLine.arguments[1]))
let duration=CMTimeGetSeconds(asset.duration)
guard duration.isFinite,duration>0,let track=asset.tracks(withMediaType:.video).first,
      track.naturalSize.width>0,track.naturalSize.height>0 else{
    fputs("Actual recording has no valid video track or duration\n",stderr);exit(1)
}
var report:[String:Any]=["duration_seconds":duration,"width":track.naturalSize.width,"height":track.naturalSize.height,"capture_nominal_fps":track.nominalFrameRate,"audio_tracks":asset.tracks(withMediaType:.audio).count,"scope":"Capture metadata and optional original-dimension frame samples; nominal capture rate does not prove game FPS, image correctness, or audible playback."]
if CommandLine.arguments.count>2{
    let directory=URL(fileURLWithPath:CommandLine.arguments[2],isDirectory:true)
    try FileManager.default.createDirectory(at:directory,withIntermediateDirectories:true)
    let generator=AVAssetImageGenerator(asset:asset)
    generator.appliesPreferredTrackTransform=true
    generator.requestedTimeToleranceBefore = .zero;generator.requestedTimeToleranceAfter = .zero
    var frames:[[String:Any]]=[],errors:[String]=[]
    let margin=min(0.05,duration/4)
    for index in 0..<36{
        let seconds=margin+(duration-2*margin)*Double(index)/35
        let requested=CMTime(seconds:seconds,preferredTimescale:600)
        var actual=CMTime.invalid
        do{
            let cg=try generator.copyCGImage(at:requested,actualTime:&actual)
            let actualSeconds=CMTimeGetSeconds(actual)
            guard actualSeconds.isFinite else{throw CocoaError(.fileReadCorruptFile)}
            guard let png=NSBitmapImageRep(cgImage:cg).representation(using:.png,properties:[:]) else{throw CocoaError(.fileWriteUnknown)}
            let name=String(format:"actual-recording-frame-%02d.png",index)
            try png.write(to:directory.appendingPathComponent(name),options:.atomic)
            frames.append(["file":name,"requested_seconds":seconds,"actual_seconds":actualSeconds,"width":cg.width,"height":cg.height])
        }catch{errors.append("Sample \(index): \(error.localizedDescription)")}
    }
    report["frame_sample_method"]="Read-only decoding of the original recording at its original dimensions; no rescaling, overlays, alpha edits or replacement images. The complete original MOV is retained. These are timestamped samples, not a claim that every animation was reviewed."
    report["frame_samples"]=frames;report["frame_sample_errors"]=errors
}
let data=try JSONSerialization.data(withJSONObject:report,options:[.prettyPrinted,.sortedKeys])
print(String(decoding:data,as:UTF8.self))
