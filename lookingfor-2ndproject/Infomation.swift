import RealmSwift

class Information: Object {
    
    static let realm: Realm? = try! Realm()
    
    dynamic private var id: Int = 0
    dynamic private var _image: UIImage? = nil
    dynamic var images: UIImage? {
        set {
            self._image = newValue
            if let value = newValue {
                self.imageData = UIImagePNGRepresentation(value)
            }
        }
        get {
            if let image = self._image {
                return image
            }
            if let data = self.imageData {
                self._image = UIImage(data: data)
                return self._image
            }
            return nil
        }
    }
    dynamic private var imageData: NSData? = nil
    dynamic var textmessages: String = ""
    dynamic var recordmessages: String = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["_image", "images"]
    }
    
    static func create(image: UIImage, text: String, messages: String) -> Information? {
        let info: Information = Information()
        info.id = self.lastId()
        info.images = self.resize(image, width: 300, height: 300)
        info.textmessages = text
        info.recordmessages = messages
        return info
    }
    
    static func lastId() -> Int {
        if let info = realm?.objects(Information).sorted("id", ascending: false).first {
            return info.id + 1
        }else {
            return 1
        }
    }
    
    static func resize(image: UIImage, width: Int, height: Int) -> UIImage? {
        guard let imageRef: CGImageRef = image.CGImage else { return nil}
        let sourceWidth: Int = CGImageGetWidth(imageRef)
        let sourceHeight: Int = CGImageGetHeight(imageRef)
        
        let size: CGSize = CGSize(width: width, height: height)
        UIGraphicsBeginImageContext(size)
        image.drawInRect(CGRectMake(0, 0, size.width, size.height))
        
        let resizeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizeImage
    }
}