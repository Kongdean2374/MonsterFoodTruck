import SpriteKit
import UIKit

enum CharacterPose:String,CaseIterable{case waiting,expecting,worried,satisfied,disappointed}
@MainActor protocol CharacterAnimation:AnyObject {
    func display(order:OrderState,time:Double,reduceMotion:Bool)
    func receive(dish:UIImage?,reduced:Bool)
    func depart(disappointed:Bool,reduced:Bool)
    func preview(_ pose:CharacterPose)
    func warning(_ active:Bool,reduced:Bool)
    func stolenBite(reduced:Bool)
}
extension CharacterAnimation {
    func warning(_ active:Bool,reduced:Bool){}
    func stolenBite(reduced:Bool){}
}
@MainActor enum CharacterArt {
    static func make(_ monster:MonsterID)->(SKNode & CharacterAnimation)?{
        if monster == .emberDragon{return DragonRig.make()}
        return ForestRig.make(monster)
    }
    static func scale(_ monster:MonsterID,width:CGFloat,height:CGFloat=76)->CGFloat{
        let naturalHeight:CGFloat=monster == .mossDeer ? 119:monster == .nibbleImp ? 98:110
        return min(height/naturalHeight,width/(monster == .emberDragon ? 94:110))
    }
}

/// Independent head, torso, near limb and tail; actions never alter game truth.
final class ForestRig:SKNode,CharacterAnimation {
    private static var cachedTextures:[MonsterID:[String:SKTexture]]=[:]
    private let monster:MonsterID
    private let torso:SKSpriteNode,head:SKSpriteNode,arm:SKSpriteNode,tail:SKSpriteNode
    private let textures:[String:SKTexture]
    private var pose:CharacterPose = .waiting
    private var reduced:Bool?
    private var warningActive=false
    private var warningReduced:Bool?
    private var previousStage:FoodStage?
    private var lastDisplayedTime:Double=0
    private var reactionUntil:Double=0
    private var headBase:CGPoint{monster == .mossDeer ? CGPoint(x:-23,y:57):CGPoint(x:4,y:35)}
    static func make(_ monster:MonsterID)->ForestRig?{
        let parts=SpriteAtlas.parts(monster == .mossDeer ? "deer-layer-rig":"imp-layer-rig")
        guard parts.count==8 else{return nil}
        if cachedTextures[monster]==nil{cachedTextures[monster]=parts.mapValues{SKTexture(image:$0)}}
        return ForestRig(monster:monster,mapped:cachedTextures[monster] ?? [:])
    }
    private init(monster:MonsterID,mapped:[String:SKTexture]){
        self.monster=monster;textures=mapped
        torso=SKSpriteNode(texture:mapped["body"]);head=SKSpriteNode(texture:mapped["waiting"])
        arm=SKSpriteNode(texture:mapped["arm"]);tail=SKSpriteNode(texture:mapped["tail"])
        super.init()
        let deer=monster == .mossDeer
        torso.size=deer ? CGSize(width:72,height:65):CGSize(width:58,height:46)
        torso.anchorPoint=CGPoint(x:0.5,y:0);torso.zPosition=1
        head.size=deer ? CGSize(width:74,height:62):CGSize(width:94,height:60)
        head.anchorPoint=CGPoint(x:deer ? 0.5:0.65,y:0);head.position=deer ? CGPoint(x:-23,y:57):CGPoint(x:4,y:35);head.zPosition=4
        arm.size=deer ? CGSize(width:26,height:35):CGSize(width:23,height:22)
        arm.anchorPoint=CGPoint(x:deer ? 0.5:0.85,y:deer ? 1:0.9);arm.position=deer ? CGPoint(x:-15,y:35):CGPoint(x:18,y:32);arm.zPosition=3
        tail.size=deer ? CGSize(width:26,height:23):CGSize(width:42,height:34)
        tail.anchorPoint=CGPoint(x:deer ? 0.15:0.9,y:deer ? 0.3:0.4);tail.position=deer ? CGPoint(x:30,y:40):CGPoint(x:-18,y:17);tail.zPosition=0
        for part in [tail,torso,arm,head]{addChild(part)}
        if !deer{
            let farArm=SKSpriteNode(texture:textures["arm"]);farArm.size=arm.size;farArm.anchorPoint=arm.anchorPoint;farArm.xScale = -1;farArm.position=CGPoint(x:-19,y:32);farArm.zPosition=2;addChild(farArm)
        }
    }
    required init?(coder:NSCoder){return nil}
    func preview(_ next:CharacterPose){pose=next;head.texture=textures[next.rawValue];head.anchorPoint=SpriteAtlas.anchor(monster == .mossDeer ? "deer-layer-rig":"imp-layer-rig",next.rawValue)}
    func display(order:OrderState,time:Double,reduceMotion:Bool){
        lastDisplayedTime=time
        preview(time<reactionUntil ? .satisfied:order.deadline-time<=10 ? .worried:order.stage == .none || order.stage == .cooking ? .waiting:.expecting)
        if reduced != reduceMotion{
            reduced=reduceMotion
            for part in [torso,head,arm,tail]{part.removeAllActions();part.zRotation=0}
            torso.yScale=1;head.position=headBase
            if !reduceMotion{
                torso.run(.repeatForever(.sequence([.scaleY(to:1.02,duration:1.3),.scaleY(to:1,duration:1.3)])),withKey:"breathe")
                tail.run(.repeatForever(.sequence([.rotate(toAngle:0.08,duration:0.8),.rotate(toAngle:-0.05,duration:1.1)])),withKey:"tail")
                arm.run(.sequence([.rotate(toAngle:monster == .mossDeer ? 0.12:-0.2,duration:0.2),.rotate(toAngle:0,duration:0.3)]),withKey:"order")
            }
        }
        if !reduceMotion,monster == .mossDeer,order.stage == .topping,previousStage != .topping{
            head.run(.sequence([.move(to:CGPoint(x:headBase.x+2,y:headBase.y-2),duration:0.2),.rotate(toAngle:-0.04,duration:0.2),.rotate(toAngle:0,duration:0.2),.move(to:headBase,duration:0.2)]),withKey:"sniff")
        }
        previousStage=order.stage
    }
    func warning(_ active:Bool,reduced:Bool){
        guard monster == .nibbleImp,warningActive != active || warningReduced != reduced else{return};warningActive=active;warningReduced=reduced
        arm.removeAction(forKey:"reach")
        if reduced{arm.zRotation=active ? 0.7:0}
        else{arm.run(.rotate(toAngle:active ? 0.7:0,duration:0.25),withKey:"reach")}
    }
    func stolenBite(reduced:Bool){
        preview(.satisfied);reactionUntil=lastDisplayedTime+0.7;guard !reduced else{return}
        arm.run(.sequence([.rotate(toAngle:-0.7,duration:0.18),.rotate(toAngle:0,duration:0.3)]),withKey:"stolen-bite")
        head.run(.sequence([.rotate(toAngle:0.05,duration:0.15),.rotate(toAngle:0,duration:0.15)]),withKey:"chew")
    }
    func receive(dish:UIImage?,reduced:Bool){
        preview(.satisfied);guard !reduced else{return}
        arm.run(.sequence([.rotate(toAngle:monster == .mossDeer ? 0.18:-0.65,duration:0.25),.rotate(toAngle:0,duration:0.3)]),withKey:"receive")
        head.run(.sequence([.rotate(toAngle:0.05,duration:0.15),.rotate(toAngle:-0.03,duration:0.15),.rotate(toAngle:0,duration:0.15)]),withKey:"taste")
        if let dish{
            let plate=SKSpriteNode(texture:SKTexture(image:dish));plate.size=CGSize(width:20,height:16);plate.position=monster == .mossDeer ? CGPoint(x:-18,y:54):CGPoint(x:5,y:40);plate.zPosition=5;addChild(plate)
            plate.run(.sequence([.moveBy(x:0,y:5,duration:0.25),.wait(forDuration:0.15),.fadeOut(withDuration:0.25),.removeFromParent()]))
        }
    }
    func depart(disappointed:Bool,reduced:Bool){
        if disappointed{preview(.disappointed)}
        if reduced{removeFromParent()}else{run(.sequence([.wait(forDuration:0.8),.group([.moveBy(x:18,y:0,duration:0.35),.fadeOut(withDuration:0.35)]),.removeFromParent()]))}
    }
}

final class CompletionScene:SKScene {
    override init(size:CGSize){super.init(size:size);scaleMode = .resizeFill;backgroundColor = .clear;isUserInteractionEnabled=false}
    required init?(coder:NSCoder){return nil}
    func greet(width:CGFloat,reduced:Bool){
        size=CGSize(width:width,height:180);removeAllChildren()
        for (column,monster) in MonsterID.allCases.enumerated(){
            guard let rig=CharacterArt.make(monster) else{continue}
            rig.position=CGPoint(x:width*(CGFloat(column)+0.5)/3,y:25);rig.setScale(CharacterArt.scale(monster,width:width/3-12,height:118));addChild(rig)
            rig.preview(.satisfied);rig.receive(dish:nil,reduced:reduced)
        }
    }
}
