//
//  LoginViewController.swift
//  BCBF
//
//  Created by user216835 on 4/20/22.
//

import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn
import FBSDKLoginKit

class LoginViewController: UIViewController,DatabaseListener {
    var phoneNumber:String?
    var listenerType: ListenerType = .user
    
    func onUserChange(change: DatabaseChange, userNightLocation: [NightLocation]) {
        return 
    }
    
    func onNightLocationChange(change: DatabaseChange, userNightLocation: [NightLocation]) {
        return
    }
    

    @IBOutlet weak var VerifyCodeTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var sendSMSbutton: UIButton!
    @IBOutlet weak var googleSignInButton: UIButton!
    
    //checkbox setup.x,y are the location of checkbox.
    let checkbox=CheckboxButton(frame: CGRect(x: 105, y:715, width: 30, height: 30))
    
    @IBAction func LoginBySMS(_ sender: Any){
        /**
        Sign in by SMS through Firebase
        Include error checking
        Once successfully sign in, turn to next page
         */
        if phoneNumberTextField.text?.count==0{
            displayMessage(title: "Warming", message: "Please input a vaild phone number")
            return
        }
        if checkbox.getIsCheck()==false{displayMessage(title: "Warming", message: "Please agree with term and condition"); return}
        let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
        guard let verificationID = verificationID else {return }
        guard let verificationCode=VerifyCodeTextField.text else{displayMessage(title: "Warming", message: "Please input the verfication code"); return}
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
              self.performSegue(withIdentifier: "successLoginSegue", sender: sender)
          }
        //self.displayMessage(title: "Congraduation", message: "You have successfully login")
    }
    
    @IBAction func googleSignin(_ sender: Any) {
        performGoogleSignInFlow()
    }
    
    
    @IBAction func sendSMS(_ sender: Any) {
        if phoneNumberTextField.text?.count==0{
            displayMessage(title: "Warming", message: "Please input a vaild phone number")
            return 
        }
        guard let phoneNumber=phoneNumberTextField.text else{
            displayMessage(title: "Warming", message: "Please input a vaild phone number")
            return
        }
        phoneAuthLogin(phoneNumber)
        /*PhoneAuthProvider.provider()
            .verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
              if let error = error {
                  self.displayMessage(title: "Phone Error", message: error.localizedDescription)
                return
              }
              // Sign in using the verificationID and the code sent to the user
              // ...
          }*/
        countDown(10, btn: sendSMSbutton)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        googleSignInButton.imageView?.layer.transform = CATransform3DMakeScale(0.2, 0.2, 0.2)
        // Do any additional setup after loading the view.
        view.addSubview(checkbox)
        let gesture=UITapGestureRecognizer(target: self, action: #selector(didTapCheckbox))
        checkbox.addGestureRecognizer(gesture)
        guard case phoneNumberTextField.text=phoneNumber else{
            return
        }
        
    }
    
    
    
    @objc func didTapCheckbox(){
        checkbox.toggle()
    }
    
    
    
    private func phoneAuthLogin(_ phoneNumber: String) {
        //get the SMS
        
        let phoneNumber = String(format: "+%@", phoneNumber)
        PhoneAuthProvider.provider()
            .verifyPhoneNumber(phoneNumber, uiDelegate: nil) {verificationID, error in
                guard error == nil else { return self.displayError(error) }
                guard let verificationID = verificationID else { return }
                UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
            }
    }
  
    
    private func performGoogleSignInFlow() {
      guard let clientID = FirebaseApp.app()?.options.clientID else { return }
      // Create Google Sign In configuration object.
      let config = GIDConfiguration(clientID: clientID)

      // Start the sign in flow
      GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in

        guard error == nil else { return displayError(error) }

        guard
          let authentication = user?.authentication,
          let idToken = authentication.idToken
        else {
          let error = NSError(
            domain: "GIDSignInError",
            code: -1,
            userInfo: [
              NSLocalizedDescriptionKey: "Unexpected sign in result: required authentication data is missing.",
            ]
          )
            return displayError(error)
        }

        let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                       accessToken: authentication.accessToken)

        Auth.auth().signIn(with: credential) { result, error in
          guard error == nil else { return self.displayError(error) }
          // At this point, user is signed in
    
          //self.transitionToRegisterViewController()
        }
      }
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
