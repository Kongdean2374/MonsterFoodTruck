import SwiftUI
import SpriteKit

struct PlayScreen:View {
    @EnvironmentObject var model:AppModel
    var body:some View{
        ZStack {
            VStack(spacing:6){
                if let label=model.debugScenarioLabel{Text(label).font(.caption2.bold()).foregroundStyle(TruckTheme.teal)}
                if let session=model.session,let content=model.content{
                    HStack{VStack(alignment:.leading,spacing:2){Text(session.level(content).name).font(.headline);Text("已服務 \(session.served)／\(session.level(content).orders.count) ・\(session.mode.rawValue)").font(.caption)
                        if session.waitingForSlot{Label("下一位客人在等候入場",systemImage:"figure.stand.line.dotted.figure.stand").font(.caption2.bold())}
                        else if let next=session.nextAdmissionAt,next-session.time<=GameRules.arrivalNotice{Text("下一位 \(Int(ceil(max(0,next-session.time)))) 秒後入場").font(.caption2.bold())}
                    };Spacer();Button{model.pause()}label:{Label("暫停",systemImage:"pause.fill").frame(minWidth:72,minHeight:44)}.accessibilityIdentifier("pause")}
                    KitchenCanvas().frame(minHeight:324,maxHeight:.infinity)
                    CommandPanel()
                }
            }.padding(.horizontal,12).padding(.vertical,6)
                .disabled(model.session?.isPaused == true)
                .accessibilityHidden(model.session?.isPaused == true)
            if model.session?.isPaused == true && model.lesson == nil {
                Color.black.opacity(0.28).ignoresSafeArea()
                VStack(spacing:12){
                    Text("餐車暫停中").font(.title2.bold())
                    Text("所有工序、耐心與熱度都已暫停。").font(.caption)
                    if model.resultSession != nil{Button("重試儲存結算"){model.retrySettlement()}.buttonStyle(TruckButtonStyle(primary:true))}
                    else{Button("繼續營業"){model.resume()}.buttonStyle(TruckButtonStyle(primary:true))}
                    Button("設定"){model.openSettings()}.buttonStyle(TruckButtonStyle())
                    Button("重新開始本關"){model.confirmation = .restart}.buttonStyle(TruckButtonStyle())
                    Button("保存並回首頁"){model.homeSaving()}.buttonStyle(TruckButtonStyle())
                    Button("放棄本局"){model.confirmation = .abandon}.frame(minHeight:44)
                }.padding(24).background(TruckTheme.cream,in:RoundedRectangle(cornerRadius:24)).padding(24)
            }
            if let lesson=model.lesson {
                Color.black.opacity(0.35).ignoresSafeArea()
                VStack(spacing:18){Text("餐車小筆記").font(.title2.bold());Text(lesson).fixedSize(horizontal:false,vertical:true);Button("知道了，繼續"){model.dismissLesson()}.buttonStyle(TruckButtonStyle(primary:true));Button("略過教學"){model.dismissLesson(skip:true)}.frame(minHeight:44)}.padding(24).background(TruckTheme.cream,in:RoundedRectangle(cornerRadius:24)).padding(24)
            }
            if model.isSettling{Color.black.opacity(0.35).ignoresSafeArea();ProgressView("正在儲存結算…").padding(28).background(TruckTheme.cream,in:RoundedRectangle(cornerRadius:20))}
        }
    }
}
struct KitchenCanvas:View {
    @EnvironmentObject var model:AppModel
    var body:some View{
        GeometryReader{geo in
            ZStack(alignment:.top){
                RoundedRectangle(cornerRadius:24).fill(TruckTheme.moss.opacity(0.11))
                if KitchenArt.enabled{
                    if let body=KitchenArt.image("body"){Image(uiImage:body).resizable(capInsets:EdgeInsets(top:32,leading:22,bottom:20,trailing:22)).frame(width:geo.size.width,height:geo.size.height).clipShape(RoundedRectangle(cornerRadius:24)).accessibilityHidden(true)}
                    if let forest=KitchenArt.image("forest"){Image(uiImage:forest).resizable().scaledToFill().frame(width:geo.size.width,height:80).clipped().clipShape(UnevenRoundedRectangle(topLeadingRadius:24,topTrailingRadius:24)).accessibilityHidden(true)}
                }
                SpriteView(scene:model.kitchen,options:[.allowsTransparency]).allowsHitTesting(false).accessibilityHidden(true)
                if let session=model.session,let content=model.content{
                    VStack(spacing:0){
                        HStack(spacing:4){
                            ForEach(0..<3,id:\.self){slot in
                                if slot<session.activeOrders.count{
                                    let order=session.activeOrders[slot]
                                    Button{model.select(order.id)}label:{
                                        VStack(spacing:2){Spacer(minLength:80);Text(content.recipe(order.recipe).name).font(.caption.bold()).lineLimit(1)
                                            HStack(spacing:2){Image(systemName:order.monster == .emberDragon ? "thermometer.sun.fill":order.monster == .mossDeer ? "leaf.fill":"star.fill");Text(content.monster(order.monster).preference).lineLimit(1)}.font(.system(size:model.document.settings.largeText ? 13:11,weight:.semibold))
                                            HStack(spacing:3){Image(systemName:order.deadline-session.time<=10 ? "exclamationmark.triangle.fill":"hourglass");ProgressView(value:max(0,order.deadline-session.time),total:content.monster(order.monster).patience*session.mode.multiplier).tint(TruckTheme.teal);Text("\(Int(ceil(max(0,order.deadline-session.time))))").monospacedDigit()}.font(.caption2)
                                        }.frame(maxWidth:.infinity).padding(.horizontal,8).padding(.bottom,5)
                                            .background(RoundedRectangle(cornerRadius:16).stroke(model.selectedOrder==order.id ? TruckTheme.moss:.clear,lineWidth:3))
                                    }.buttonStyle(.plain).accessibilityIdentifier("customer-\(order.id)").accessibilityLabel("\(content.monster(order.monster).name)，\(content.recipe(order.recipe).name)，偏好\(content.monster(order.monster).preference)，耐心剩\(Int(max(0,order.deadline-session.time)))秒")
                                }else{VStack(spacing:4){Image(systemName:"leaf");Text(session.waitingForSlot ? "等候入場":arrivalText(session))}.font(.caption).foregroundStyle(TruckTheme.cocoa.opacity(0.65)).frame(maxWidth:.infinity,maxHeight:.infinity).accessibilityElement(children:.combine)}
                            }
                        }.frame(height:132).background(alignment:.bottom){if KitchenArt.enabled{TruckTheme.cream.frame(height:52)}}
                        ForEach([Station.plate,.stove,.prep],id:\.self){station in
                            HStack(spacing:6){Text(station == .plate ? "成品":station == .stove ? "爐台":"備料").font(.caption.bold()).frame(width:30)
                                ForEach(0..<2,id:\.self){slot in
                                    StationControl(station:station,slot:slot,order:session.activeOrders.first{$0.station==station && $0.slot==slot})
                                }
                            }.frame(height:(geo.size.height-132)/3).padding(.horizontal,6)
                                .background{if KitchenArt.enabled{KitchenPiece(name:"counter").padding(.leading,32).padding(.horizontal,3)}}
                        }
                    }
                    if let target=session.nibbleTarget,let plate=session.orders.first(where:{$0.id==target})?.slot,
                       let actor=session.activeOrders.firstIndex(where:{$0.id==session.nibbleActor}){
                        WarningConnector(actor:actor,plate:plate).allowsHitTesting(false).accessibilityHidden(true)
                    }
                }
            }
        }
    }
    func arrivalText(_ session:GameSession)->String{
        if let next=session.nextAdmissionAt, next-session.time<=GameRules.arrivalNotice{return "下位 \(Int(ceil(max(0,next-session.time))))秒"}
        return "森林小徑"
    }
}
struct StationControl:View {
    @EnvironmentObject var model:AppModel
    var station:Station;var slot:Int;var order:OrderState?
    var isTarget:Bool{order != nil && model.session?.nibbleTarget==order?.id}
    var body:some View{
        Button{
            guard let order else{return};model.select(order.id)
            if order.stage == .prepared{model.command(.cook(order.id))}
            else if order.stage == .ready{model.command(.plate(order.id))}
        }label:{
            HStack(spacing:3){
                if let order,let content=model.content,let session=model.session{
                    ZStack{
                        if KitchenArt.enabled{KitchenPiece(name:KitchenArt.workSurface(station)).frame(width:62,height:48).saturation(station == .stove && order.stage != .cooking ? 0.25:1)}
                        DishImage(column:content.recipe(order.recipe).atlasColumn)
                        if order.isCovered{ClocheView()}
                        if order.needsTidy{Image(systemName:order.everNibbled ? "hand.raised.fill":"exclamationmark.triangle.fill").font(.caption).foregroundStyle(TruckTheme.cocoa).padding(4).background(TruckTheme.cream,in:Circle()).offset(x:16,y:-12)}
                        if let topping=order.topping{Image(systemName:topping == .herb ? "leaf.fill":"star.fill").font(.caption.bold()).foregroundStyle(topping == .herb ? TruckTheme.moss:Color.orange).offset(y:-8)}
                        if isTarget{Image(systemName:"hand.point.down.fill").font(.system(size:16,weight:.bold)).foregroundStyle(TruckTheme.plum).padding(3).background(TruckTheme.cream,in:Circle()).offset(x:16,y:-14)}
                    }.frame(width:50,height:50)
                    VStack(alignment:.leading,spacing:2){
                        Text(status(order,session:session)).font(.system(size:model.document.settings.largeText ? 14:12,weight:.bold)).lineLimit(2)
                        if let end=order.workEnds{Text("\(max(0,end-session.time),specifier:"%.1f") 秒").font(.caption).monospacedDigit()}
                        else if order.station == .stove,let cooked=order.cookedAt,!order.everScorched{
                            let remaining=cooked+content.recipe(order.recipe).grace*session.mode.multiplier-session.time
                            Text("\(remaining<=GameRules.scorchNotice ? "快起鍋":"寬限") \(Int(ceil(max(0,remaining))))秒").font(.caption2).bold()
                        }
                        if order.monster == .emberDragon,let cooked=order.cookedAt{Text("熱度 \(Int(ceil(max(0,cooked+GameRules.heatWindow*session.mode.multiplier-session.time))))秒").font(.caption2).bold()}
                        if order.isCovered,let remaining=order.warningRemaining{Text("預告暫停 \(Int(ceil(remaining)))秒").font(.caption2).bold()}
                    }
                }else{
                    if KitchenArt.enabled{KitchenPiece(name:KitchenArt.workSurface(station)).frame(width:58,height:46).saturation(station == .stove ? 0.1:1)}
                    else{Image(systemName:station == .stove ? "flame":station == .prep ? "carrot":"circle.dashed")}
                    Text("空位 \(slot+1)").font(.caption)
                }
            }.frame(maxWidth:.infinity,minHeight:48,maxHeight:.infinity)
                .padding(.horizontal,3)
                .background(TruckTheme.cream,in:RoundedRectangle(cornerRadius:13))
                .overlay(RoundedRectangle(cornerRadius:13).stroke(isTarget ? TruckTheme.plum:model.selectedOrder==order?.id && order != nil ? TruckTheme.moss:TruckTheme.cocoa.opacity(0.18),lineWidth:isTarget ? 3:model.selectedOrder==order?.id && order != nil ? 2.5:1))
        }.buttonStyle(.plain).disabled(order==nil).padding(.vertical,3)
            .accessibilityLabel(accessibilityText)
    }
    var accessibilityText:String{
        guard let order,let content=model.content,let session=model.session else{return "\(station == .prep ? "備料槽":station == .stove ? "爐位":"成品位")空位\(slot+1)"}
        return "\(content.recipe(order.recipe).name)，\(content.monster(order.monster).name)的餐點，\(status(order,session:session))"
    }
    func status(_ o:OrderState,session:GameSession)->String{
        if session.nibbleTarget==o.id{return "爪子目標 \(Int(ceil(o.warningRemaining ?? 0)))秒"}
        if o.isCovered{return "餐蓋保護"}
        if o.needsTidy && o.stage != .tidying{return o.station == .stove ? "焦邊・先裝盤":o.everNibbled ? "被偷嚐・待整理":"焦邊・待整理"}
        switch o.stage{case .prepping:return "備料中";case .prepared:return "備妥・可下鍋";case .cooking:return "烹調中";case .ready:return "完成・可裝盤";case .topping:return "配料中";case .tidying:return "整理中";case .plated:return o.topping?.rawValue ?? "可出餐";case .none:return "等待備料"}
    }
}
struct WarningConnector:View{
    var actor:Int;var plate:Int
    var body:some View{
        GeometryReader{geometry in
            let width=geometry.size.width
            let start=CGPoint(x:width*(CGFloat(actor)+0.5)/3+12,y:58)
            let side:CGFloat=actor==0 ? 3:width-3
            let destination=CGPoint(x:plate==0 ? width/4+28.5:width*0.75+7.5,y:153)
            Canvas{context,_ in
                var path=Path();path.move(to:start);path.addLines([CGPoint(x:side,y:73),CGPoint(x:side,y:142),CGPoint(x:destination.x,y:142),destination])
                context.stroke(path,with:.color(TruckTheme.cream.opacity(0.9)),style:StrokeStyle(lineWidth:5,lineCap:.round,lineJoin:.round))
                context.stroke(path,with:.color(TruckTheme.plum),style:StrokeStyle(lineWidth:2.5,lineCap:.round,lineJoin:.round,dash:[5,3]))
                var arrow=Path();arrow.move(to:CGPoint(x:destination.x-5,y:destination.y-4));arrow.addLine(to:CGPoint(x:destination.x+5,y:destination.y-4));arrow.addLine(to:CGPoint(x:destination.x,y:destination.y+3));arrow.closeSubpath()
                context.fill(arrow,with:.color(TruckTheme.plum))
            }
        }
    }
}
struct ClocheView:View {
    var body:some View{ZStack(alignment:.bottom){Ellipse().fill(TruckTheme.cocoa.opacity(0.18)).frame(height:8);UnevenRoundedRectangle(topLeadingRadius:26,topTrailingRadius:26).fill(LinearGradient(colors:[.white,Color(red:0.74,green:0.75,blue:0.67)],startPoint:.topLeading,endPoint:.bottomTrailing)).overlay(UnevenRoundedRectangle(topLeadingRadius:26,topTrailingRadius:26).stroke(TruckTheme.cocoa,lineWidth:1.5)).frame(height:32);Capsule().fill(TruckTheme.cream).overlay(Capsule().stroke(TruckTheme.cocoa,lineWidth:1.5)).frame(height:5);Circle().fill(TruckTheme.cocoa).frame(width:7,height:7).offset(y:-31)}.frame(height:40)}
}
struct CommandPanel:View {
    @EnvironmentObject var model:AppModel
    var body:some View{
        VStack(spacing:6){
            if let hint=model.commandHint{Text(hint).font(.caption.bold()).foregroundStyle(TruckTheme.cocoa).frame(maxWidth:.infinity,alignment:.leading).accessibilityLabel("操作提醒：\(hint)")}
            if let session=model.session,let content=model.content{
                HStack(spacing:6){ForEach(session.activeOrders){order in
                    Button{model.select(order.id)}label:{VStack(spacing:2){Text(content.monster(order.monster).name).font(.system(size:11,weight:.medium));Text(content.recipe(order.recipe).name).font(.system(size:model.document.settings.largeText ? 16:14,weight:.bold))}.lineLimit(1).frame(maxWidth:.infinity,minHeight:44).background(model.selectedOrder==order.id ? TruckTheme.moss:TruckTheme.cream,in:RoundedRectangle(cornerRadius:12)).foregroundStyle(model.selectedOrder==order.id ? TruckTheme.cream:TruckTheme.cocoa)}.accessibilityIdentifier("quick-\(order.id)").accessibilityLabel("選取\(content.monster(order.monster).name)的\(content.recipe(order.recipe).name)")
                }}
            }
            if let order=model.selected {
                HStack(spacing:8){
                    if model.document.settings.leftHanded{primary(order);cover(order)}else{cover(order);primary(order)}
                }
                if order.stage == .plated && !order.needsTidy && !order.isCovered{
                    HStack(spacing:8){ForEach(Topping.allCases,id:\.self){topping in Button(topping.rawValue){model.command(.garnish(order.id,topping))}.buttonStyle(TruckButtonStyle())}}
                }else if order.stage == .topping{
                    Button("取消配料，保留未加料料理"){model.command(.cancelGarnish(order.id))}.buttonStyle(TruckButtonStyle())
                }else{Text("兩爐功能相同，工作站會自動完成計時。").font(.caption).frame(minHeight:44)}
            }else{Text("下一位客人正在森林小徑上。").font(.subheadline).frame(maxWidth:.infinity,minHeight:96)}
        }
        .padding(8).background(TruckTheme.cocoa.opacity(model.document.settings.highContrast ? 0.12:0.05),in:RoundedRectangle(cornerRadius:18))
    }
    func primary(_ order:OrderState)->some View{
        let action=action(order)
        return Button(action.0){if let command=action.1{model.command(command)}}.buttonStyle(TruckButtonStyle(primary:true)).disabled(action.1==nil).opacity(action.1==nil ? 0.65:1).accessibilityIdentifier("primaryCommand")
    }
    @ViewBuilder func cover(_ order:OrderState)->some View{
        if order.station == .plate {
            Button(order.isCovered ? "取下":"蓋上"){model.command(order.isCovered ? .uncover(order.id):.cover(order.id))}.buttonStyle(TruckButtonStyle()).frame(width:74).disabled(order.stage != .plated)
        }
    }
    func action(_ o:OrderState)->(String,GameCommand?){
        let active=model.session?.activeOrders ?? []
        switch o.stage{
        case .none:return active.filter{$0.station == .prep}.count<2 ? ("備料",.prepare(o.id)):("備料槽已滿",nil)
        case .prepared:return active.filter{$0.station == .stove}.count<2 ? ("下鍋",.cook(o.id)):("爐位已滿",nil)
        case .ready:return active.filter{$0.station == .plate}.count<2 ? ("裝盤",.plate(o.id)):("成品位已滿",nil)
        case .plated:return o.needsTidy ? ("整理 3 秒",.tidy(o.id)):("出餐",.serve(o.id))
        case .prepping:return("備料中…",nil);case .cooking:return("烹調中…",nil);case .topping:return("配料中…",nil);case .tidying:return("整理中…",nil)
        }
    }
}
