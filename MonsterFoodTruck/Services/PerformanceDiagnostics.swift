#if DEBUG
import UIKit
import SpriteKit
import Darwin

/// Opt-in measurements of the running app, never a replacement game clock.
/// SpriteKit update cadence is a simulator diagnostic, not physical display FPS.
@MainActor final class PerformanceDiagnostics {
    static let shared=PerformanceDiagnostics()
    static let enabled=ProcessInfo.processInfo.environment["MFT_PERFORMANCE"]=="1"
    private struct Window:Codable {
        var entry:Int;var nodeCount:Int;var allocatedAudioPlayers:Int
        var frameIntervals:[Double]=[]
        var handlerToNextSceneUpdateMS:[Double]=[]
        var footprintBytes:UInt64?;var residentBytes:UInt64?
    }
    private var windows:[Window]=[]
    private var previousFrame:Double?
    private var pendingHandlers:[Double]=[]
    private var lastMemorySample:Double=0
    private(set) var reportError:String?
    var entryCount:Int{windows.count}
    func enter(scene:SKScene,audioPlayers:Int){
        guard Self.enabled else{return}
        windows.append(Window(entry:windows.count+1,nodeCount:scene.children.count,allocatedAudioPlayers:audioPlayers))
        previousFrame=nil;pendingHandlers=[];sampleMemory()
    }
    func handledInput(){guard Self.enabled else{return};pendingHandlers.append(ProcessInfo.processInfo.systemUptime)}
    func frame(){
        guard Self.enabled,!windows.isEmpty else{return}
        let now=ProcessInfo.processInfo.systemUptime,index=windows.count-1
        if let previousFrame{windows[index].frameIntervals.append(now-previousFrame)}
        self.previousFrame=now
        windows[index].handlerToNextSceneUpdateMS.append(contentsOf:pendingHandlers.map{(now-$0)*1000})
        pendingHandlers=[]
        if now-lastMemorySample>=1{sampleMemory();lastMemorySample=now}
    }
    private func sampleMemory(){
        guard !windows.isEmpty else{return}
        var info=task_vm_info_data_t()
        var count=mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.size/MemoryLayout<integer_t>.size)
        let status=withUnsafeMutablePointer(to:&info){pointer in
            pointer.withMemoryRebound(to:integer_t.self,capacity:Int(count)){
                task_info(mach_task_self_,task_flavor_t(TASK_VM_INFO),$0,&count)
            }
        }
        if status==KERN_SUCCESS{
            let i=windows.count-1
            windows[i].footprintBytes=max(windows[i].footprintBytes ?? 0,info.phys_footprint)
            windows[i].residentBytes=max(windows[i].residentBytes ?? 0,info.resident_size)
        }else{reportError="task_info failed: \(status)"}
    }
    func endActiveInterval(){previousFrame=nil;pendingHandlers=[]}
    func pauseAndExport(){
        guard Self.enabled else{return}
        endActiveInterval();sampleMemory()
        do{
            let data=try JSONEncoder().encode(windows)
            let rows=try JSONSerialization.jsonObject(with:data)
            let report:[String:Any]=[
                "scope":"Actual DEBUG simulator app. SpriteKit scene update cadence; not physical screen FPS or iPhone 17 Pro performance. Handler-to-next-scene-update is a scheduling proxy, not touch-to-photon latency. Paused intervals excluded by explicit pause/resume boundaries; active long frames retained. Memory is sampled once per second and at scene entry/pause; maxima are sampled observations, not continuous profiler peaks.",
                "os":UIDevice.current.systemVersion,"device":UIDevice.current.model,
                "bundle_id":Bundle.main.bundleIdentifier ?? "missing",
                "build":Bundle.main.object(forInfoDictionaryKey:"CFBundleVersion") ?? "missing",
                "windows":rows,"measurement_error":(reportError as Any?) ?? NSNull()
            ]
            let directory=try SaveStore.applicationDirectory().appendingPathComponent("Diagnostics",isDirectory:true)
            try FileManager.default.createDirectory(at:directory,withIntermediateDirectories:true)
            try JSONSerialization.data(withJSONObject:report,options:[.prettyPrinted,.sortedKeys]).write(to:directory.appendingPathComponent("PERFORMANCE.json"),options:.atomic)
        }catch{reportError=error.localizedDescription}
    }
}
#endif
