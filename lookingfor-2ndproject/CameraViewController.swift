import UIKit
import AVFoundation
import RealmSwift
import SwiftFilePath

class CameraViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet var cameraView : UIImageView!
    @IBOutlet var takepicture : UIButton!
    @IBOutlet var savepicture : UIButton!
    
    let fileManager = NSFileManager()
    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    var messageURL: String!
    var pictureURL: NSURL!
    
    //NSUserDefaults
    let allinformations: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var stopButton: UIButton!
    
    @IBOutlet var textforthing: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupAudioRecorder()
        textforthing.delegate = self
    }
    
    //text
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textforthing.resignFirstResponder()
        return true
    }
    
    // カメラの撮影開始
    @IBAction func cameraStart(sender : AnyObject) {
        let sourceType:UIImagePickerControllerSourceType = UIImagePickerControllerSourceType.PhotoLibrary
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary){
            let cameraPicker = UIImagePickerController()
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            self.presentViewController(cameraPicker, animated: true, completion: nil)
        }
    }
    
    //　撮影が完了した時に呼ばれる
    func imagePickerController(imagePicker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            cameraView.contentMode = .ScaleAspectFit
            cameraView.image = pickedImage
        }
        
        //閉じる処理
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // 撮影がキャンセルされた時に呼ばれる
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // すべてを保存
    @IBAction func savePic(sender : AnyObject) {
        
        guard let image: UIImage = cameraView.image else { return }
        guard let text: String = textforthing.text else { return }
        
        guard let info: Information = Information.create(image, text: text, messages: messageURL) else { return }
        
        let realm = try! Realm()
        
        try! realm.write {
            realm.add(info)
        }
    }
    
    // 録音ボタンを押した時の挙動
    @IBAction func pushRecordButton(sender: AnyObject) {
        audioRecorder?.record()
        let alert = UIAlertController(title: "録音", message: "録音中", preferredStyle: .Alert)
        alert.addAction(
            UIAlertAction(
                title: "完了",
                style: UIAlertActionStyle.Default,
                handler: {action in
                    self.audioRecorder?.stop()
                }
            )
        )
        
        presentViewController(alert, animated: true, completion: nil)

    }
    
//    @IBAction func pushStopButton(sender: AnyObject) {
//        audioRecorder?.stop()
//    }
    
    // 録音するために必要な設定を行う
    // viewDidLoad時に行う
    func setupAudioRecorder() {
        // 再生と録音機能をアクティブにする
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        try! session.setActive(true)
        let recordSetting : [String : AnyObject] = [
            AVEncoderAudioQualityKey : AVAudioQuality.Min.rawValue,
            AVEncoderBitRateKey : 16,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey: 44100.0
        ]
        let uuid = NSUUID().UUIDString
        let recordPath = Path.documentsDir["\(uuid).caf"].asString
        messageURL = "\(uuid).caf"
        do {
            try audioRecorder = AVAudioRecorder(URL: NSURL(string: recordPath)!, settings: recordSetting)
        } catch {
            print("初期設定でerror出たよ(-_-;)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}