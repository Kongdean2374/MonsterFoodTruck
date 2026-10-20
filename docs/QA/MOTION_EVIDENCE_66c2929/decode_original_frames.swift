import AVFoundation
import CoreImage
import CoreMedia
import CoreVideo
import Foundation
import ImageIO
import UniformTypeIdentifiers

// Read-only native movie decoding, not PNG/atlas editing. Preserve reader order
// and actual sample PTS, even if timestamps repeat or move backwards.
let movie=URL(fileURLWithPath:CommandLine.arguments[1])
let output=URL(fileURLWithPath:CommandLine.arguments[2],isDirectory:true)
let first=Int(CommandLine.arguments[3])!,last=Int(CommandLine.arguments[4])!
try FileManager.default.createDirectory(at:output,withIntermediateDirectories:true)
let asset=AVURLAsset(url:movie)
guard let track=asset.tracks(withMediaType:.video).first else{fatalError("No video")}
let reader=try AVAssetReader(asset:asset)
let samples=AVAssetReaderTrackOutput(track:track,outputSettings:[kCVPixelBufferPixelFormatTypeKey as String:kCVPixelFormatType_32BGRA])
samples.alwaysCopiesSampleData=false;reader.add(samples)
guard reader.startReading() else{fatalError("Cannot start actual decode")}
let context=CIContext(options:[.useSoftwareRenderer:false])
struct Frame:Encodable {let decoded_frame_zero_based:Int;let actual_seconds:Double;let png:String?}
struct Report:Encodable {
    let file:String,width:Double,height:Double,audio_tracks:Int
    let frames:[Frame],scope:String
}
var frames:[Frame]=[]
while let sample=samples.copyNextSampleBuffer(){
    try autoreleasepool {
        let index=frames.count,seconds=CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(sample))
        guard seconds.isFinite,let buffer=CMSampleBufferGetImageBuffer(sample) else{fatalError("Invalid actual sample")}
        var filename:String?
        if index>=first && index<=last {
            let ci=CIImage(cvPixelBuffer:buffer)
            guard let image=context.createCGImage(ci,from:ci.extent) else{fatalError("Native image decode failed")}
            let name=String(format:"decoded-frame-%05d.png",index)
            guard let destination=CGImageDestinationCreateWithURL(output.appendingPathComponent(name) as CFURL,UTType.png.identifier as CFString,1,nil) else{fatalError("Cannot preserve decoded frame")}
            CGImageDestinationAddImage(destination,image,nil)
            guard CGImageDestinationFinalize(destination) else{fatalError("PNG export failed")}
            filename=name
        }
        frames.append(Frame(decoded_frame_zero_based:index,actual_seconds:seconds,png:filename))
    }
}
guard reader.status == .completed,!frames.isEmpty else{fatalError("Incomplete native decode")}
if first>=0 {guard frames.filter({$0.png != nil}).count==last-first+1 else{fatalError("Missing dense frames")}}
let report=Report(file:movie.lastPathComponent,width:Double(track.naturalSize.width),height:Double(track.naturalSize.height),audio_tracks:asset.tracks(withMediaType:.audio).count,frames:frames,scope:"Actual AVAssetReader decoded frames in returned sequence and actual sample presentation timestamps, never requested seek times. Selected contiguous frames exported at original dimensions using CoreImage/ImageIO, without resizing, crops, overlays, alpha cleanup or generated artwork. Original MOVs and original capture failures remain preserved; no timing, motion quality or art acceptance is inferred.")
let encoder=JSONEncoder();encoder.outputFormatting=[.prettyPrinted,.sortedKeys]
try encoder.encode(report).write(to:output.appendingPathComponent("NATIVE_DECODE.json"))
let csv="decoded_frame_zero_based,actual_seconds,png\n"+frames.map{"\($0.decoded_frame_zero_based),\($0.actual_seconds),\($0.png ?? "")"}.joined(separator:"\n")+"\n"
try csv.write(to:output.appendingPathComponent("NATIVE_DECODE.csv"),atomically:true,encoding:.utf8)
print("Native decoded \(frames.count) frames; preserved \(frames.filter{$0.png != nil}.count) original-size frames for \(movie.lastPathComponent)")
