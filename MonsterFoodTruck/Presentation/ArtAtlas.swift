import UIKit
import SpriteKit

/// Runtime subtextures of the selected master; source files remain unmodified.
enum ArtAtlas {
    static let master: UIImage? = image("characters-and-dishes")
    static let background: UIImage? = image("forest-food-truck")
    static let characters: [UIImage] = (0..<3).compactMap { tile(column:$0,food:false) }
    static let dishes: [UIImage] = (0..<3).compactMap { tile(column:$0,food:true) }
    private static func image(_ name: String) -> UIImage? {
        guard let url=Bundle.main.url(forResource:name,withExtension:"png") else{return nil}
        guard let original=UIImage(contentsOfFile:url.path) else{return nil}
        return original.preparingForDisplay() ?? original
    }
    static func preload() throws {
        guard master != nil,background != nil,characters.count==3,dishes.count==3 else{throw GameError.invalid("餐車或料理素材無法讀取，請重新載入。")}
    }
    private static func tile(column:Int,food:Bool)->UIImage? {
        guard let cg=master?.cgImage else{return nil}
        let sx=CGFloat(cg.width)/1536,sy=CGFloat(cg.height)/1024
        let rect=CGRect(x:CGFloat(column)*512*sx,y:(food ? 540:0)*sy,width:512*sx,height:(food ? 484:540)*sy)
        guard let crop=cg.cropping(to:rect) else{return nil}
        return UIImage(cgImage:crop,scale:2,orientation:.up)
    }
    static func character(_ column:Int)->UIImage? {characters.indices.contains(column) ? characters[column]:nil}
    static func dish(_ column:Int)->UIImage? {dishes.indices.contains(column) ? dishes[column]:nil}
}

final class KitchenScene: SKScene {
    private var monsters: [String:SKNode] = [:]
    private var state: GameSession?
    private var content: GameContent?
    private var reduced = false
    private var previewDragonRig:Bool{
        #if DEBUG
        return ProcessInfo.processInfo.environment["MFT_DRAGON_RIG"]=="1"
        #else
        return false
        #endif
    }
    override init(size:CGSize) {super.init(size:size);scaleMode = .resizeFill;backgroundColor = .clear;isUserInteractionEnabled=false}
    override convenience init(){self.init(size:CGSize(width:390,height:330))}
    required init?(coder:NSCoder){super.init(coder:coder)}
    override func didChangeSize(_ oldSize:CGSize){
        if let state,let content{display(session:state,content:content,selected:nil,reduceMotion:reduced)}
        else{layoutCharacters()}
    }
    func display(session:GameSession,content:GameContent,selected:String?,reduceMotion:Bool) {
        if let old=state,old.id != session.id || old.levelID != session.levelID || session.time<old.time{
            removeAllChildren();monsters.removeAll()
        }
        state=session;self.content=content;reduced=reduceMotion
        let live=Set(session.activeOrders.map(\.id))
        for key in Array(monsters.keys) where !live.contains(key) {
            if let rig=monsters[key] as? DragonRig,let order=session.orders.first(where:{$0.id==key}){
                if order.status == .served{rig.receive(dish:ArtAtlas.dish(content.recipe(order.recipe).atlasColumn),reduced:reduceMotion)}
                rig.depart(disappointed:order.status == .left,reduced:reduceMotion)
            }else{monsters[key]?.removeFromParent()}
            monsters[key]=nil
        }
        for order in session.activeOrders {
            if monsters[order.id] == nil,let image=ArtAtlas.character(content.monster(order.monster).atlasColumn) {
                let node:SKNode
                if previewDragonRig,order.monster == .emberDragon,let rig=DragonRig.make(){node=rig}
                else{let sprite=SKSpriteNode(texture:SKTexture(image:image));sprite.anchorPoint=CGPoint(x:0.5,y:0.1);node=sprite}
                node.name=order.id;node.zPosition=2;addChild(node);monsters[order.id]=node
            }
            if let node=monsters[order.id] {
                node.alpha=1
                if let rig=node as? DragonRig{rig.display(order:order,time:session.time,reduceMotion:reduceMotion)}
                else if reduceMotion {node.removeAllActions();node.zRotation=0}
                else if node.action(forKey:"idle")==nil {
                    let breath=SKAction.sequence([.rotate(toAngle:0.025,duration:1.1),.rotate(toAngle:-0.025,duration:1.1)])
                    node.run(.repeatForever(breath),withKey:"idle")
                }
            }
        }
        layoutCharacters()
        isPaused=session.isPaused || reduceMotion
    }
    private func layoutCharacters(){
        guard let state else{return}
        for (i,order) in state.activeOrders.enumerated(){
            guard let node=monsters[order.id] else{continue}
            let width=min(72,size.width/3-16)
            if let sprite=node as? SKSpriteNode{
                sprite.position=CGPoint(x:size.width*(CGFloat(i)+0.5)/3,y:size.height-70)
                sprite.size=CGSize(width:width,height:width*540/512)
            }else{
                node.position=CGPoint(x:size.width*(CGFloat(i)+0.5)/3-4,y:size.height-78)
                node.setScale(min(76/110,width/94))
            }
        }
    }
}
