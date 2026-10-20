#if DEBUG
import SwiftUI
import SpriteKit

/// Explicit visual inspection, never counted as a gameplay completion.
struct ArtReviewScreen:View {
    @EnvironmentObject var model:AppModel
    var dark:Bool
    @State private var scene=ArtReviewScene(size:CGSize(width:351,height:480))
    var body:some View{
        VStack(spacing:8){
            Text("\(dark ? "深":"淺")底・三角色五表情・72×76pt").font(.caption.bold())
            GeometryReader{geo in
                SpriteView(scene:scene).accessibilityHidden(true)
                    .onAppear{scene.configure(width:geo.size.width,dark:dark)}
                    .onChange(of:geo.size.width){_,width in scene.configure(width:width,dark:dark)}
            }.frame(height:480)
            Button("播放部件動作"){scene.playDemo(reduced:model.reducesMotion)}.buttonStyle(TruckButtonStyle(primary:true))
            Button("返回首頁"){model.screen = .home}.frame(minHeight:44)
        }.padding(12)
    }
}

final class ArtReviewScene:SKScene {
    private var firstRow:[(MonsterID,SKNode & CharacterAnimation)]=[]
    override init(size:CGSize){super.init(size:size);scaleMode = .resizeFill;isUserInteractionEnabled=false}
    required init?(coder:NSCoder){return nil}
    func configure(width:CGFloat,dark:Bool){
        size=CGSize(width:width,height:480);removeAllChildren();removeAllActions();firstRow=[]
        backgroundColor=dark ? UIColor(red:0.231,green:0.169,blue:0.165,alpha:1):UIColor(red:1,green:0.953,blue:0.839,alpha:1)
        let names=["待機","期待","低耐心","滿意","離開／失望"]
        for (row,pose) in CharacterPose.allCases.enumerated(){
            for (column,monster) in MonsterID.allCases.enumerated(){
                guard let rig=CharacterArt.make(monster) else{continue}
                rig.setScale(CharacterArt.scale(monster,width:72));rig.position=CGPoint(x:width*(CGFloat(column)+0.5)/3,y:396-CGFloat(row)*96)
                rig.preview(pose);addChild(rig)
                if row==0{firstRow.append((monster,rig))}
                let title=SKLabelNode(fontNamed:"PingFangTC-Semibold");title.text=names[row];title.fontSize=11;title.fontColor=dark ? .white:.black;title.position=CGPoint(x:rig.position.x,y:rig.position.y-17);addChild(title)
            }
        }
    }
    func playDemo(reduced:Bool){
        guard !reduced else{for (_,rig) in firstRow{rig.preview(.satisfied)};return}
        removeAction(forKey:"sample")
        for (monster,rig) in firstRow{
            let order=OrderState(id:"art-review",monster:monster,recipe:.starSoup,admittedAt:0,deadline:44)
            rig.display(order:order,time:0,reduceMotion:false);rig.warning(true,reduced:false)
        }
        run(.sequence([
            .wait(forDuration:0.8),.run{[weak self] in for (_,rig) in self?.firstRow ?? []{rig.receive(dish:FoodArt.image(.starSoup,"finished"),reduced:false)}},
            .wait(forDuration:0.8),.run{[weak self] in for (_,rig) in self?.firstRow ?? []{rig.stolenBite(reduced:false)}},
            .wait(forDuration:0.8),.run{[weak self] in for (_,rig) in self?.firstRow ?? []{rig.warning(false,reduced:false);rig.preview(.waiting)}}
        ]),withKey:"sample")
    }
}
#endif
