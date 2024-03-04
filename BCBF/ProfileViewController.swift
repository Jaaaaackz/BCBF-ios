//
//  ProfileViewController.swift
//  BCBF
//
//  Created by user216835 on 6/9/22.
//

import AVFoundation
import UIKit
import AssetsLibrary
import CoreData
import FirebaseAuth

class ProfileViewController: UIViewController {

    var managedObjectContext: NSManagedObjectContext?
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var birthday: UITextField!
    @IBOutlet weak var friendsNumber: UITextField!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    var imageList = [UIImage]()
    var imagePathList = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //set the text of button align to left
        signOutButton.contentHorizontalAlignment = .left
        
        managedObjectContext = appDelegate.persistentContainer?.viewContext
        self.navigationItem.setLeftBarButton(nil, animated: false)
        self.navigationItem.hidesBackButton = true
        cancelButton.imageView?.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Get the user's avatar which stored in CoreData and display it.
        do {
            let imageDataList = try managedObjectContext!.fetch(AvatarImageData.fetchRequest()) as [AvatarImageData]
            for data in imageDataList {
                let filename = data.filename!
                if imagePathList.contains(filename) {
                    print("Image Already Loaded. Skipping Image")
                    continue
                }
                if let image = loadImageData(filename: filename) {
                    imageList.append(image)
                    imagePathList.append(filename)
                    avatar.image=image
                }
            }
        } catch {
            print("Unable to fetch images")
        }
    }
    
    func loadImageData(filename: String) -> UIImage? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let imageURL = documentsDirectory.appendingPathComponent(filename)
        let image = UIImage(contentsOfFile: imageURL.path)
        return image
    }
    
    @IBAction func signOut(_ sender: Any) {
        let firebaseAuth=Auth.auth()
        do{
            try firebaseAuth.signOut()
        }catch let signOutError as NSError{
            print("Error Signout: %@",signOutError)
        }
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func cancel(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
