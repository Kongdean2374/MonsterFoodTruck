import SwiftUI
import SpriteKit
import AVFoundation

enum TruckTheme {
    static let cream=Color(red:1,green:0.953,blue:0.839)
    static let cocoa=Color(red:0.231,green:0.169,blue:0.165)
    static let moss=Color(red:0.31,green:0.40,blue:0.24)
    static let teal=Color(red:0.20,green:0.40,blue:0.43)
}
struct TruckButtonStyle: ButtonStyle {
    var primary = false
    func makeBody(configuration:Configuration)->some View {
        configuration.label.font(.headline).frame(maxWidth:.infinity,minHeight:48)
            .padding(.horizontal,10)
            .foregroundStyle(primary ? TruckTheme.cream:TruckTheme.cocoa)
            .background(primary ? TruckTheme.moss:TruckTheme.cream,in:RoundedRectangle(cornerRadius:16))
            .overlay(RoundedRectangle(cornerRadius:16).stroke(TruckTheme.cocoa.opacity(0.15),lineWidth:1))
            .opacity(configuration.isPressed ? 0.72:1)
    }
}
struct GameRoot:View {
    @EnvironmentObject var model:AppModel
    @Environment(\.scenePhase) private var phase
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    private let timer=Timer.publish(every:0.05,on:.main,in:.common).autoconnect()
    var body:some View {
        Group {
            if let error=model.startupError {
                VStack(spacing:24){Text("無法載入餐車").font(.title);Text(error);Button("重新讀取"){model.load()}.buttonStyle(TruckButtonStyle(primary:true))}.padding()
            } else {
                switch model.screen {
                case .home:HomeScreen()
                case .levels:LevelScreen()
                case let .introduction(id):IntroductionScreen(levelID:id)
                case .game:PlayScreen()
                case .result:ResultScreen()
                case .complete:CompletionScreen()
                case .help:InformationScreen(about:false)
                case .about:InformationScreen(about:true)
                case .ended:
                    VStack(spacing:24){Image(systemName:"moon.stars").font(.system(size:48));Text("進度已儲存").font(.title.bold());Text("你可以使用 iPhone 的系統手勢或主畫面按鈕離開 App。").multilineTextAlignment(.center);Button("返回首頁"){model.screen = .home}.buttonStyle(TruckButtonStyle(primary:true))}.padding(28)
                }
            }
        }
        .foregroundStyle(model.document.settings.highContrast ? Color.black:TruckTheme.cocoa)
        .fontWeight(model.document.settings.highContrast ? .semibold:nil)
        .frame(maxWidth:.infinity,maxHeight:.infinity)
        .background(TruckTheme.cream)
        .environment(\.dynamicTypeSize,model.document.settings.largeText ? .xLarge:.large)
        .preferredColorScheme(model.screen == .home ? .dark:.light)
        .sheet(isPresented:$model.settingsPresented,onDismiss:{model.settingsDidDismiss()}){SettingsScreen()}
        .sheet(item:$model.confirmation){ConfirmationScreen(confirmation:$0)}
        .alert("餐車提醒",isPresented:Binding(get:{model.message != nil},set:{if !$0{model.message=nil}})) {Button("知道了"){model.message=nil}} message:{Text(model.message ?? "")}
        .onReceive(timer){_ in model.tick()}
        .onChange(of:phase){_,value in if value != .active{model.pause()}else if model.screen == .home{model.audio.startMusic()}}
        .onReceive(NotificationCenter.default.publisher(for:AVAudioSession.interruptionNotification)){_ in model.pause()}
        .onAppear{if systemReduceMotion{model.updateSettings{$0.reduceMotion=true}}}
    }
}
struct HomeScreen:View {
    @EnvironmentObject var model:AppModel
    var body:some View {
        ZStack {
            GeometryReader{background in
                ZStack{
                    if let image=ArtAtlas.background {Image(uiImage:image).resizable().scaledToFill().frame(width:background.size.width,height:background.size.height).clipped()}
                    LinearGradient(colors:[.black.opacity(0.22),.clear,TruckTheme.moss.opacity(0.96)],startPoint:.top,endPoint:.bottom)
                }
            }.ignoresSafeArea()
            GeometryReader{geo in
                VStack(spacing:8){
                    Text("黃昏森林・今日營業").font(.caption.weight(.semibold)).tracking(3)
                    Text("魔物餐車").font(.system(size:geo.size.height<650 ? 40:48,weight:.black,design:.rounded)).shadow(color:.black.opacity(0.2),radius:5,y:3)
                    Text("為森林裡的朋友，端上一點溫暖。").font(.subheadline)
                    Spacer(minLength:20)
                    VStack(spacing:10){
                        Button("開始遊戲"){model.startButton()}.buttonStyle(TruckButtonStyle(primary:true)).accessibilityIdentifier("start")
                        if model.session != nil{Button("繼續遊玩"){model.continueSession()}.buttonStyle(TruckButtonStyle())}
                        HStack(spacing:10){Button("關卡選擇"){model.screen = .levels};Button("設定"){model.openSettings()}}.buttonStyle(TruckButtonStyle())
                        HStack(spacing:10){Button("遊戲說明"){model.screen = .help};Button("關於"){model.screen = .about}}.buttonStyle(TruckButtonStyle())
                        Button("結束遊玩"){model.endPlay()}.font(.subheadline.bold()).frame(minHeight:44).foregroundStyle(TruckTheme.cream)
                    }.padding(16).background(TruckTheme.cocoa.opacity(0.18),in:RoundedRectangle(cornerRadius:24))
                }.foregroundStyle(TruckTheme.cream).padding(.horizontal,24).padding(.top,20).padding(.bottom,8)
            }
        }.onAppear{model.audio.startMusic()}
    }
}
struct ScreenHeading:View {
    @EnvironmentObject var model:AppModel
    var title:String
    var body:some View{HStack{Button{model.screen = .home}label:{Label("首頁",systemImage:"chevron.left").frame(minWidth:64,minHeight:44)};Spacer();Text(title).font(.title2.bold());Spacer();Color.clear.frame(width:64,height:44)}.foregroundStyle(TruckTheme.cocoa)}
}
struct LevelScreen:View {
    @EnvironmentObject var model:AppModel
    var body:some View {
        VStack(spacing:12){ScreenHeading(title:"森林小徑")
            if let content=model.content {
                ScrollView{
                    VStack(spacing:14){ForEach(Array(content.levels.enumerated()),id:\.element.id){index,level in
                        let unlocked=model.document.unlocked(index,content:content)
                        Button{model.screen = .introduction(level.id)}label:{
                            HStack(spacing:16){Text(String(format:"%02d",index+1)).font(.title.bold()).foregroundStyle(TruckTheme.moss).frame(width:42)
                                VStack(alignment:.leading,spacing:5){Text(level.name).font(.headline);Text(level.focus).font(.caption).multilineTextAlignment(.leading);Text(starsText(model.document.records[level.id]?.best ?? 0)).foregroundStyle(TruckTheme.teal)}
                                Spacer(minLength:0);Image(systemName:unlocked ? "chevron.right":"lock.fill")
                            }.padding(16).frame(maxWidth:.infinity,minHeight:104).background(.white.opacity(0.7),in:RoundedRectangle(cornerRadius:20))
                        }.disabled(!unlocked).opacity(unlocked ? 1:0.65).accessibilityIdentifier("level-\(level.id)").accessibilityLabel("第\(index+1)關，\(level.name)，\(unlocked ? "可玩":"鎖定")，最高\(model.document.records[level.id]?.best ?? 0)星")
                    }}.padding(.bottom,20)
                }
            }
        }.padding(.horizontal,20)
    }
}
func starsText(_ stars:Int)->String{String(repeating:"★",count:max(0,min(3,stars)))+String(repeating:"☆",count:max(0,3-stars))}

struct IntroductionScreen:View {
    @EnvironmentObject var model:AppModel
    var levelID:String
    var body:some View{
        VStack(spacing:20){ScreenHeading(title:"準備開張")
            if let content=model.content,let level=content.levels.first(where:{$0.id==levelID}){
                Spacer(minLength:0)
                Text(level.name).font(.largeTitle.bold()).multilineTextAlignment(.center)
                HStack{ForEach(Array(Set(level.orders.map(\.recipe))).sorted(by:{$0.rawValue<$1.rawValue}),id:\.self){id in
                    VStack{DishImage(column:content.recipe(id).atlasColumn).frame(height:80);Text(content.recipe(id).name).font(.caption)}
                }}
                Text(level.focus).font(.headline).multilineTextAlignment(.center)
                VStack(alignment:.leading,spacing:12){Text("共 \(level.orders.count) 筆訂單・成功 \(level.passCount) 筆通關");Text("全部服務，並達成 \(level.preferenceCount) 筆偏好可得三星");Text("下一局模式：\(model.document.settings.nextMode.rawValue)");Text("\(Set(level.orders.map{content.monster($0.monster).name}).sorted().joined(separator:"、"))")}.font(.subheadline).padding(20).background(.white.opacity(0.7),in:RoundedRectangle(cornerRadius:20))
                Spacer(minLength:0)
                Button("開始營業"){model.requestBegin(levelID)}.buttonStyle(TruckButtonStyle(primary:true)).accessibilityIdentifier("beginLevel")
                Button("返回選關"){model.screen = .levels}.frame(minHeight:44)
            }
        }.padding(.horizontal,24).padding(.bottom,12)
    }
}
struct DishImage:View{var column:Int;var body:some View{Group{if let image=ArtAtlas.dish(column){Image(uiImage:image).resizable().scaledToFit()}}.accessibilityHidden(true)}}
