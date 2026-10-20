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
        return UIImage(contentsOfFile:url.path)
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
    private var monsters: [String:SKSpriteNode] = [:]
    private var state: GameSession?
    private var content: GameContent?
    private var reduced = false
    private let warning=SKShapeNode()
    override init(size:CGSize) {super.init(size:size);scaleMode = .resizeFill;backgroundColor = .clear;isUserInteractionEnabled=false}
    override convenience init(){self.init(size:CGSize(width:390,height:330))}
    required init?(coder:NSCoder){super.init(coder:coder)}
    override func didChangeSize(_ oldSize:CGSize){
        if let state,let content{display(session:state,content:content,selected:nil,reduceMotion:reduced)}
        else{layoutCharacters()}
    }
    func display(session:GameSession,content:GameContent,selected:String?,reduceMotion:Bool) {
        state=session;self.content=content;reduced=reduceMotion
        let live=Set(session.activeOrders.map(\.id))
        for key in Array(monsters.keys) where !live.contains(key) {
            monsters[key]?.removeFromParent();monsters[key]=nil
        }
        for order in session.activeOrders {
            if monsters[order.id] == nil,let image=ArtAtlas.character(content.monster(order.monster).atlasColumn) {
                let node=SKSpriteNode(texture:SKTexture(image:image));node.name=order.id
                node.zPosition=2;node.anchorPoint=CGPoint(x:0.5,y:0.1);addChild(node);monsters[order.id]=node
            }
            if let node=monsters[order.id] {
                node.alpha=1
                if reduceMotion {node.removeAllActions();node.zRotation=0}
                else if node.action(forKey:"idle")==nil {
                    let breath=SKAction.sequence([.rotate(toAngle:0.025,duration:1.1),.rotate(toAngle:-0.025,duration:1.1)])
                    node.run(.repeatForever(breath),withKey:"idle")
                }
            }
        }
        layoutCharacters()
        warning.removeFromParent()
        if let target=session.nibbleTarget,let order=session.orders.first(where:{$0.id==target}),let slot=order.slot,
           let actor=session.nibbleActor,let actorNode=monsters[actor] {
            let path=CGMutablePath();path.move(to:actorNode.position);path.addLine(to:CGPoint(x:size.width*(slot==0 ? 0.28:0.74),y:size.height-162))
            warning.path=path;warning.strokeColor=UIColor(red:0.45,green:0.23,blue:0.57,alpha:1);warning.lineWidth=3;warning.zPosition=4
            addChild(warning)
        }
        isPaused=session.isPaused || reduceMotion
    }
    private func layoutCharacters(){
        guard let state else{return}
        for (i,order) in state.activeOrders.enumerated(){
            guard let node=monsters[order.id] else{continue}
            node.position=CGPoint(x:size.width*(CGFloat(i)+0.5)/3,y:size.height-70)
            let width=min(72,size.width/3-16);node.size=CGSize(width:width,height:width*540/512)
        }
    }
}
