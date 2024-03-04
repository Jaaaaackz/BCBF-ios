//
//  RegisterViewController.swift
//  BCBF
//
//  Created by user216835 on 4/21/22.
//
import AVFoundation
import UIKit
import AssetsLibrary
import FirebaseAuth
import CoreData
import Firebase

class RegisterViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate{
    var managedObjectContext: NSManagedObjectContext?
    @IBOutlet weak var nicknameTextfield: UITextField!
    @IBOutlet weak var usernameTextfield: UITextField!
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var sendSMSButton: UIButton!
    var takingPicture:UIImagePickerController!
    @IBOutlet weak var phoneNumberTextfield: UITextField!
    @IBOutlet weak var verficationCodeTextfield: UITextField!
    var imageList = [UIImage]()
    var imagePathList = [String]()
    
    
    @IBAction func swipeGesture(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    


    
    @IBAction func sendSMS(_ sender: Any) {
        if phoneNumberTextfield.text?.count==0{
            displayMessage(title: "Warming", message: "Please input a vaild phone number")
            return
        }
        guard let phoneNumber=phoneNumberTextfield.text else{
            displayMessage(title: "Warming", message: "Please input a vaild phone number")
            return
        }
        phoneAuthLogin(phoneNumber)
        countDown(60, btn: sendSMSButton)
    }
    
    @IBAction func FinishRegister(_ sender: Any) {
        /**
         Once finished register, save the avatar into coredata and goto the map page.
         */
        if phoneNumberTextfield.text?.count==0 || usernameTextfield.text?.count==0 || nicknameTextfield.text?.count==0{
            displayMessage(title: "Warming", message: "Please input all the information")
            return
        }
        else{
            let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
            guard let verificationID = verificationID else {return }
            guard let verificationCode=verficationCodeTextfield.text else{displayMessage(title: "Warming", message: "Please input the verfication code"); return}
            if verificationCode.count != 6{
                displayMessage(title: "Waring", message: "The verfication code should be 6 digits.")
                return
            }
            let credential = PhoneAuthProvider.provider().credential(
              withVerificationID: verificationID,
              verificationCode: verificationCode
            )
              Auth.auth().signIn(with: credential) { result, error in
                guard error == nil else { return self.displayError(error) }
                  //self.displayMessage(title: "Congraduation", message: "You have successfully login")
                  self.saveImage()
                  self.performSegue(withIdentifier: "successRegister", sender: sender)
              }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        managedObjectContext = appDelegate.persistentContainer?.viewContext
        //setup the image view of user's avatar
        self.userAvatar.layer.masksToBounds=true
        self.userAvatar.layer.borderWidth = 0;
        self.userAvatar.layer.borderColor = UIColor.white.cgColor;
        self.userAvatar.layer.cornerRadius = self.userAvatar.bounds.height / 2;
        //hide the navigation bar
        self.navigationItem.setLeftBarButton(nil, animated: false)
        self.navigationItem.hidesBackButton = true
        // Do any additional setup after loading the view.
    }
    
    @IBAction func changeAvatar() {
        /**
         setup an UIAlertController for user to select the way of changing avatar
         */
        let actionSheetController = UIAlertController()
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { (alertAction) -> Void in
            print("Tap Cancel Button")
        }
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let takingPicturesAction = UIAlertAction(title: "Take Photo", style: UIAlertAction.Style.default) { (alertAction) -> Void in
                self.getImageGo(type: 1)
            }
            actionSheetController.addAction(takingPicturesAction)
        }
        
        let photoAlbumAction = UIAlertAction(title: "Choose From Library", style: UIAlertAction.Style.default) { (alertAction) -> Void in
            self.getImageGo(type: 2)
        }
        
        actionSheetController.addAction(cancelAction)
        
        actionSheetController.addAction(photoAlbumAction)
        //Display
        self.present(actionSheetController, animated: true, completion: nil)
    }

    func getImageGo(type:Int){
        /**
         The Action of Alert Controller selection
         */
        takingPicture =  UIImagePickerController.init()
        if(type==1){
            takingPicture.sourceType = .camera
        }else if(type==2){
            takingPicture.sourceType = .photoLibrary
        }
        
        takingPicture.allowsEditing = true
        takingPicture.delegate = self
        present(takingPicture, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        takingPicture.dismiss(animated: true, completion: nil)
        if(takingPicture.allowsEditing == false){
            //original image
            userAvatar.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        }else{
            //image after edited
            userAvatar.image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        }
    }
    
    func saveImage(){
        /**
        Save the image into Coredata and rename it
         */
        guard let image = userAvatar.image else {
            displayMessage(title: "Error", message: "Cannot save until an image has been selected!")
            return
        }
        
        //rename
        let timestamp = UInt(Date().timeIntervalSince1970)
        let filename = "\(timestamp).jpg"
        
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            displayMessage(title: "Error", message: "Image data could not be compressed")
            return
        }
        let pathsList = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = pathsList[0]
        let imageFile = documentDirectory.appendingPathComponent(filename)
        
        do {
            try data.write(to: imageFile)
            let imageEntity = NSEntityDescription.insertNewObject(forEntityName: "AvatarImageData", into: managedObjectContext!) as! AvatarImageData
            
            imageEntity.filename = filename
            try managedObjectContext?.save()
            
            navigationController?.popViewController(animated: true)
        }
        catch {
            displayMessage(title: "Error", message: "\(error)")
        }

    }
    
    private func phoneAuthLogin(_ phoneNumber: String) {
      let phoneNumber = String(format: "+%@", phoneNumber)
      PhoneAuthProvider.provider()
        .verifyPhoneNumber(phoneNumber, uiDelegate: nil) {verificationID, error in
          guard error == nil else { return self.displayError(error) }
            guard let verificationID = verificationID else { return }
            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
        }
    }
    
    /*@objc func cancelInputAction() -> Void {
        birthdayTextfield.resignFirstResponder()
    }
    
    @objc func doneInputAction() -> Void {
        birthdayTextfield.resignFirstResponder()
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        birthdayTextfield.text = dateFormatter.string(from: datePicker.date)
    }
    */
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
