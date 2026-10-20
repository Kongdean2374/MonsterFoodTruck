import UIKit

/// Original generated pixels, cropped only into runtime textures by saved metadata.
enum SpriteAtlas {
    private struct Metadata:Decodable{var width:Int;var height:Int;var rects:[String:[Int]];var anchors:[String:[Double]]?}
    private static var cache:[String:[String:UIImage]]=[:]
    private static var anchors:[String:[String:[Double]]]=[:]
    static func parts(_ name:String)->[String:UIImage]{
        if let cached=cache[name]{return cached}
        guard let imageURL=Bundle.main.url(forResource:name,withExtension:"png"),
              let metaURL=Bundle.main.url(forResource:name,withExtension:"json"),
              let cg=UIImage(contentsOfFile:imageURL.path)?.cgImage,
              let bytes=try? Data(contentsOf:metaURL),let metadata=try? JSONDecoder().decode(Metadata.self,from:bytes),
              cg.width==metadata.width,cg.height==metadata.height else{return [:]}
        var result:[String:UIImage]=[:]
        for (key,r) in metadata.rects{
            guard r.count==4,r[0]>=0,r[1]>=0,r[2]>0,r[3]>0,r[0]+r[2]<=cg.width,r[1]+r[3]<=cg.height,
                  let piece=cg.cropping(to:CGRect(x:CGFloat(r[0]),y:CGFloat(r[1]),width:CGFloat(r[2]),height:CGFloat(r[3]))) else{return [:]}
            let image=UIImage(cgImage:piece,scale:2,orientation:.up)
            result[key]=image.preparingForDisplay() ?? image
        }
        cache[name]=result;anchors[name]=metadata.anchors ?? [:];return result
    }
    static func image(_ atlas:String,_ part:String)->UIImage?{parts(atlas)[part]}
    static func anchor(_ atlas:String,_ part:String)->CGPoint{
        guard let p=anchors[atlas]?[part],p.count==2 else{return CGPoint(x:0.5,y:0)}
        return CGPoint(x:p[0],y:p[1])
    }
    static func preload() throws{
        for (name,count) in [("imp-layer-rig",8),("deer-layer-rig",8),("soup-states",9),("crisp-states",9),("stew-states",9),("kitchen-props",6)]{
            guard parts(name).count==count else{throw GameError.invalid("分層素材無法讀取：\(name)")}
        }
    }
}

enum FoodArt {
    static func atlas(_ recipe:RecipeID)->String{recipe == .starSoup ? "soup-states":recipe == .moonCrisp ? "crisp-states":"stew-states"}
    static func image(_ recipe:RecipeID,_ state:String)->UIImage?{SpriteAtlas.image(atlas(recipe),state)}
    static func state(_ order:OrderState)->String{
        switch order.stage{
        case .none,.prepping:return "raw"
        case .prepared:return "prepared"
        case .cooking:return "cooking"
        default:
            if order.needsTidy{return order.everNibbled ? "nibbled":"scorched"}
            if order.everNibbled{return "repairedNibble"}
            if order.everScorched{return "repairedScorch"}
            return "finished"
        }
    }
}
