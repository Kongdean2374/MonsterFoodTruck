import SwiftUI

/// Original truck-interior parts, shared by gameplay and explicit visual review.
enum KitchenArt {
    static let enabled=true
    private struct Atlas:Decodable{var rects:[String:[Int]]}
    private static let parts:[String:UIImage]={
        guard let imageURL=Bundle.main.url(forResource:"kitchen-layers",withExtension:"png"),
              let metaURL=Bundle.main.url(forResource:"kitchen-layers",withExtension:"json"),
              let cg=UIImage(contentsOfFile:imageURL.path)?.cgImage,
              let data=try? Data(contentsOf:metaURL),let atlas=try? JSONDecoder().decode(Atlas.self,from:data) else{return [:]}
        var result:[String:UIImage]=[:]
        for (name,r) in atlas.rects where r.count==4{
            if let piece=cg.cropping(to:CGRect(x:CGFloat(r[0]),y:CGFloat(r[1]),width:CGFloat(r[2]),height:CGFloat(r[3]))){
                let image=UIImage(cgImage:piece,scale:2,orientation:.up)
                result[name]=image.preparingForDisplay() ?? image
            }
        }
        return result
    }()
    static func image(_ name:String)->UIImage?{parts[name]}
    static func preload() throws{guard parts.count==7 else{throw GameError.invalid("餐車分層素材無法讀取。")}}
    static func workSurface(_ station:Station)->String{station == .stove ? "stove":station == .prep ? "prep":"serving"}
}

struct KitchenPiece:View{
    var name:String
    var body:some View{Group{if let image=KitchenArt.image(name){Image(uiImage:image).resizable().scaledToFit()}}.allowsHitTesting(false).accessibilityHidden(true)}
}
