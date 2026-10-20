import SpriteKit
import UIKit

/// One-character art prototype. DEBUG preview only until actual-size visual review.
final class DragonRig:SKNode {
    enum Pose:String {case waiting,expecting,worried,satisfied,disappointed}
    private struct Atlas:Decodable{var rects:[String:[Int]]}
    private static let textures:[String:SKTexture]={
        guard let imageURL=Bundle.main.url(forResource:"dragon-layer-rig",withExtension:"png"),
              let metaURL=Bundle.main.url(forResource:"dragon-layer-rig",withExtension:"json"),
              let cg=UIImage(contentsOfFile:imageURL.path)?.cgImage,
              let data=try? Data(contentsOf:metaURL),let atlas=try? JSONDecoder().decode(Atlas.self,from:data) else{return [:]}
        var result:[String:SKTexture]=[:]
        for (name,r) in atlas.rects where r.count==4{
            if let piece=cg.cropping(to:CGRect(x:CGFloat(r[0]),y:CGFloat(r[1]),width:CGFloat(r[2]),height:CGFloat(r[3]))){result[name]=SKTexture(cgImage:piece)}
        }
        return result
    }()
    static func make()->DragonRig?{textures.count==8 ? DragonRig(textures:textures):nil}
    private let torso:SKSpriteNode
    private let head:SKSpriteNode
    private let arm:SKSpriteNode
    private let tail:SKSpriteNode
    private var pose:Pose = .waiting
    private var motionReduced:Bool?
    private init(textures:[String:SKTexture]){
        torso=SKSpriteNode(texture:textures["body"]);head=SKSpriteNode(texture:textures["waiting"])
        arm=SKSpriteNode(texture:textures["arm"]);tail=SKSpriteNode(texture:textures["tail"])
        super.init()
        torso.size=CGSize(width:66,height:54);torso.anchorPoint=CGPoint(x:0.5,y:0);torso.zPosition=1
        tail.size=CGSize(width:40,height:45);tail.anchorPoint=CGPoint(x:0.08,y:0.5);tail.position=CGPoint(x:18,y:21);tail.zPosition=0
        head.size=CGSize(width:74,height:66);head.anchorPoint=CGPoint(x:0.5,y:0);head.position=CGPoint(x:-3,y:44);head.zPosition=3
        arm.size=CGSize(width:25,height:31);arm.anchorPoint=CGPoint(x:0.85,y:0.9);arm.position=CGPoint(x:14,y:37);arm.zPosition=2
        for node in [tail,torso,arm,head]{addChild(node)}
    }
    required init?(coder:NSCoder){return nil}
    func display(order:OrderState,time:Double,reduceMotion:Bool){
        let next:Pose=order.deadline-time<=10 ? .worried:order.stage == .none || order.stage == .cooking ? .waiting:.expecting
        setPose(next)
        if motionReduced != reduceMotion{
            motionReduced=reduceMotion
            for part in [torso,head,arm,tail]{part.removeAllActions();part.zRotation=0}
            torso.yScale=1
            if !reduceMotion{
                torso.run(.repeatForever(.sequence([.scaleY(to:1.025,duration:1.2),.scaleY(to:1,duration:1.2)])),withKey:"breathe")
                head.run(.repeatForever(.sequence([.rotate(toAngle:0.018,duration:1.2),.rotate(toAngle:-0.018,duration:1.2)])),withKey:"look")
                tail.run(.repeatForever(.sequence([.rotate(toAngle:0.05,duration:0.7),.rotate(toAngle:-0.04,duration:0.9)])),withKey:"tail-flame")
                arm.run(.sequence([.rotate(toAngle:-0.18,duration:0.2),.rotate(toAngle:0,duration:0.4)]),withKey:"order")
            }
        }
    }
    private func setPose(_ next:Pose){guard pose != next else{return};pose=next;head.texture=Self.textures[next.rawValue]}
    func receive(dish:UIImage?,reduced:Bool){
        setPose(.satisfied)
        guard !reduced else{return}
        arm.run(.sequence([.rotate(toAngle:-0.65,duration:0.25),.wait(forDuration:0.2),.rotate(toAngle:0,duration:0.3)]),withKey:"eat")
        head.run(.sequence([.rotate(toAngle:0.07,duration:0.16),.rotate(toAngle:-0.03,duration:0.18),.rotate(toAngle:0,duration:0.16)]),withKey:"taste")
        if let dish{
            let plate=SKSpriteNode(texture:SKTexture(image:dish));plate.size=CGSize(width:20,height:18);plate.position=CGPoint(x:8,y:51);plate.zPosition=5;addChild(plate)
            plate.run(.sequence([.moveBy(x:0,y:9,duration:0.3),.wait(forDuration:0.15),.fadeOut(withDuration:0.25),.removeFromParent()]))
        }
    }
    func depart(disappointed:Bool,reduced:Bool){
        if disappointed{setPose(.disappointed)}
        if reduced{removeFromParent()}
        else{run(.sequence([.wait(forDuration:0.8),.group([.moveBy(x:18,y:0,duration:0.35),.fadeOut(withDuration:0.35)]),.removeFromParent()]))}
    }
}
