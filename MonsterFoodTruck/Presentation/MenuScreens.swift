import SwiftUI
import SpriteKit

struct SettingsScreen:View {
    @EnvironmentObject var model:AppModel
    func setting<T>(_ keyPath:WritableKeyPath<GameSettings,T>)->Binding<T>{Binding(get:{model.document.settings[keyPath:keyPath]},set:{value in model.updateSettings{$0[keyPath:keyPath]=value}})}
    func switchRow(_ title:String,_ key:WritableKeyPath<GameSettings,Bool>)->some View{
        let value=setting(key)
        return Toggle(isOn:value){
            Text(title).frame(maxWidth:.infinity,minHeight:44,alignment:.leading).contentShape(Rectangle())
                .onTapGesture{value.wrappedValue.toggle()}.accessibilityHidden(true)
        }.accessibilityLabel(title)
    }
    var body:some View{
        NavigationStack{
            Form{
                if let message=model.message{Section("尚未儲存"){Text(message).foregroundStyle(TruckTheme.cocoa)}}
                Section("聲音與回饋"){
                    VStack(alignment:.leading){Text("音樂音量 \(Int(model.document.settings.music*100))%");Slider(value:setting(\.music),in:0...1).accessibilityLabel("音樂音量")}
                    VStack(alignment:.leading){Text("音效音量 \(Int(model.document.settings.effects*100))%");Slider(value:setting(\.effects),in:0...1).accessibilityLabel("音效音量")}
                    Button("試聽配樂與完成提示"){model.audio.preview()}.frame(minHeight:44)
                    switchRow("觸覺回饋",\.haptics)
                }
                Section("下一局模式"){
                    Picker("模式",selection:setting(\.nextMode)){ForEach(PlayMode.allCases,id:\.self){mode in Text(mode.rawValue).tag(mode)}}.pickerStyle(.segmented)
                    Text("舒緩：耐心、起鍋寬限與熱食期限延長 50%，偷嚐預告延長至五秒。兩模式都能解鎖與獲得三星。").font(.caption)
                    if let session=model.session{Text("目前這局固定為「\(session.mode.rawValue)」；更改僅套用下一局。").font(.caption.bold())}
                }
                Section("閱讀與操作"){
                    switchRow("高對比資訊",\.highContrast)
                    switchRow("大字介面",\.largeText)
                    switchRow("減少動態效果",\.reduceMotion)
                    if model.systemReducedMotion{Text("iPhone 系統已啟用減少動態，餐車也會遵循；此處保留你自己的額外設定。").font(.caption)}
                    switchRow("左手單手配置",\.leftHanded)
                    Text("左手配置將主要命令放到左側；兩爐、兩備料槽與兩成品位置的規則相同。").font(.caption)
                }
                Section("教學與資料"){
                    Button("重新查看操作教學"){model.closeSettingsToHelp()}.frame(minHeight:44)
                    Button("恢復預設設定"){model.closeSettingsFor(.resetSettings)}.frame(minHeight:44)
                    Button("清除遊戲進度",role:.destructive){model.closeSettingsFor(.resetProgress)}.frame(minHeight:44)
                }
            }.disabled(model.isClosingSettings).navigationTitle("餐車設定").toolbar{ToolbarItem(placement:.confirmationAction){Button("完成"){model.closeSettings()}.frame(minHeight:44).disabled(model.isClosingSettings)}}
        }.preferredColorScheme(.light)
            .interactiveDismissDisabled(model.isClosingSettings)
    }
}
struct ConfirmationScreen:View {
    @EnvironmentObject var model:AppModel
    @Environment(\.dismiss) private var dismiss
    var confirmation:AppModel.Confirmation
    @State private var secondConfirmation=false
    var body:some View{
        VStack(spacing:20){
            Image(systemName:"questionmark.circle").font(.system(size:40)).foregroundStyle(TruckTheme.moss)
            Text(title).font(.title2.bold()).multilineTextAlignment(.center)
            Text(detail).multilineTextAlignment(.center)
            if case .replace = confirmation{Button("返回繼續目前這局"){dismiss();model.confirmation=nil;model.continueSession()}.buttonStyle(TruckButtonStyle(primary:true))}
            Button(actionTitle){
                if case .resetProgress=confirmation,!secondConfirmation{secondConfirmation=true}
                else{dismiss();model.confirmed(confirmation)}
            }.buttonStyle(TruckButtonStyle(primary:true))
            Button("取消"){dismiss();model.confirmation=nil}.frame(minHeight:44)
        }.padding(28).foregroundStyle(TruckTheme.cocoa).presentationDetents([.medium,.large]).presentationDragIndicator(.visible).preferredColorScheme(.light)
    }
    var title:String{switch confirmation{case .replace:return "要開始新的一局嗎？";case .restart:return "重新開始本關？";case .abandon:return "放棄目前這局？";case .resetSettings:return "恢復預設設定？";case .resetProgress:return secondConfirmation ? "再次確認：清除所有進度？":"清除遊戲進度？"}}
    var detail:String{switch confirmation{case .replace,.restart,.abandon:return "目前這局的工序與訂單會清除，已獲得的星數及解鎖會保留。";case .resetSettings:return "只還原音量、模式與介面設定，不清除星數及解鎖。";case .resetProgress:return "將清除六關星數、解鎖、教學紀錄與進行中的局。音量與介面設定會保留；取消不會刪除任何資料。"}}
    var actionTitle:String{switch confirmation{case .replace:return "放棄目前這局並開始";case .restart:return "確認重新開始";case .abandon:return "確認放棄本局";case .resetSettings:return "還原設定";case .resetProgress:return secondConfirmation ? "確認清除全部遊戲進度":"繼續確認"}}
}
struct ResultScreen:View {
    @EnvironmentObject var model:AppModel
    var body:some View{
        ScrollView{VStack(spacing:18){
            if let session=model.resultSession,let content=model.content{
                let stars=session.stars(content:content)
                Text(stars>0 ? "今晚的森林很滿足":"再試一次自己的節奏").font(.title.bold()).multilineTextAlignment(.center)
                Text(session.level(content).name).font(.headline)
                Text(starsText(stars)).font(.system(size:46)).foregroundStyle(TruckTheme.teal).accessibilityLabel("\(stars)星")
                Text(session.isPractice ? "教學重看・不更新正式紀錄":stars>0 ? "通過・紀錄已儲存":"未通過").font(.headline)
                VStack(spacing:10){stat("成功訂單",session.served);stat("偏好達成",session.preferences);stat("失單",session.lost);stat("料理過熟",session.scorchCount);stat("被偷嚐",session.nibbleCount)}.padding(20).background(.white.opacity(0.7),in:RoundedRectangle(cornerRadius:20))
                ForEach(session.hints,id:\.self){Text($0).font(.subheadline).frame(maxWidth:.infinity,alignment:.leading)}
                if stars>0,!session.isPractice,let index=content.levels.firstIndex(where:{$0.id==session.levelID}){
                    if index<5{Button("下一關"){model.screen = .introduction(content.levels[index+1].id)}.buttonStyle(TruckButtonStyle(primary:true))}
                    else{Button("六關完成，收店囉"){model.screen = .complete}.buttonStyle(TruckButtonStyle(primary:true))}
                }
                if session.isPractice{
                    Button("正式開始第一關"){model.begin("level_01")}.buttonStyle(TruckButtonStyle(primary:true))
                    Button("再看一次教學"){model.begin("level_01",practice:true)}.buttonStyle(TruckButtonStyle())
                }else{Button("再玩一次"){model.begin(session.levelID)}.buttonStyle(TruckButtonStyle())}
                Button("關卡選擇"){model.screen = .levels}.buttonStyle(TruckButtonStyle())
                Button("回首頁"){model.screen = .home}.frame(minHeight:44)
            }
        }.padding(24)}
    }
    func stat(_ label:String,_ value:Int)->some View{HStack{Text(label);Spacer();Text("\(value)").bold().monospacedDigit()}}
}
struct CompletionScreen:View {
    @EnvironmentObject var model:AppModel
    @State private var scene=CompletionScene(size:CGSize(width:351,height:180))
    var body:some View{
        VStack(spacing:24){
            Spacer()
            GeometryReader{geo in
                SpriteView(scene:scene,options:[.allowsTransparency]).accessibilityHidden(true)
                    .onAppear{scene.greet(width:geo.size.width,reduced:model.reducesMotion)}
                    .onChange(of:geo.size.width){_,width in scene.greet(width:width,reduced:model.reducesMotion)}
            }.frame(height:180)
            Text("謝謝款待，森林朋友們！").font(.title.bold()).multilineTextAlignment(.center)
            Text("六關已完成，可返回挑戰三星。").font(.headline)
            Text("最高星數合計 \(model.document.totalStars)／18").font(.title2.bold()).foregroundStyle(TruckTheme.moss)
            Spacer()
            Button("返回挑戰三星"){model.screen = .levels}.buttonStyle(TruckButtonStyle(primary:true))
            Button("略過動畫，回首頁"){model.screen = .home}.frame(minHeight:44)
        }.padding(24)
    }
}
struct InformationScreen:View {
    @EnvironmentObject var model:AppModel
    var about:Bool
    var body:some View{
        VStack{ScreenHeading(title:about ? "關於餐車":"餐車小手冊")
            ScrollView{VStack(alignment:.leading,spacing:22){
                if about{
                    Text("魔物餐車").font(.largeTitle.bold())
                    Text("版本 \(Bundle.main.object(forInfoDictionaryKey:"CFBundleShortVersionString") as? String ?? "—")（\(Bundle.main.object(forInfoDictionaryKey:"CFBundleVersion") as? String ?? "—")）")
                    Text("單人、完整離線的森林料理遊戲。三位森林朋友、三道暖心料理、六個黃昏夜晚。")
                    Text("美術為本專案原創生成與程式整理；配樂、事件音由本專案原創合成，未使用外部歌曲或音訊樣本。字型為系統字型，介面符號使用 Apple SF Symbols。")
                    Text("素材來源與製作紀錄隨原始碼提供：github.com/Kongdean2374/MonsterFoodTruck 的 docs/ASSET_MANIFEST.md。此說明可離線閱讀，遊玩不需帳號或網路。")
                    Text("原創內容未指定額外再利用授權。")
                }else{
                    Text("忙碌來自安排，不用重複連點。").font(.title2.bold())
                    ForEach(Array([("1・選訂單","點客人或底部訂單卡，料理會綁定原來的客人。"),("2・備料","點備料，等工序自動完成。"),("3・下鍋","點備妥食材或底部下鍋，會進第一個空爐。"),("4・裝盤","料理完成後移至空成品位；兩格都滿時，先送出一盤。"),("5・配料或整理","香草芽與星脆片各需兩秒，可以不加。焦邊或偷嚐後，先整理三秒；偏好資格不會恢復。"),("6・出餐","明確按出餐，會送到原客人；蓋著也能直接送。")].enumerated()),id:\.offset){_,step in VStack(alignment:.leading,spacing:6){Text(step.0).font(.headline);Text(step.1)}}
                    Divider()
                    Text("焰尾龍喜歡熱食，熱度從烹調完成起算九秒；苔角鹿喜歡香草芽；饞嘴小鬼喜歡星脆片，也會偷嚐別人的成品。")
                    Text("看到爪子目標與倒數時，可蓋住那盤、先出餐，或服務伸手的小鬼。唯一餐蓋只暫停偷嚐，不延長熱度，也不重置暴露或預告進度。")
                    Text("暫停、設定、離開 App 時，所有遊戲時間停止；回來後需自行按繼續營業。舒緩模式可延長反應時間，不影響可得星數。")
                    if model.session != nil{Button("返回暫停的這一局"){model.screen = .game}.buttonStyle(TruckButtonStyle(primary:true))}
                    else{Button("重看第一關教學"){model.screen = .practiceIntroduction}.buttonStyle(TruckButtonStyle(primary:true))}
                }
            }.padding(.vertical,20)}
        }.padding(.horizontal,24)
    }
}
