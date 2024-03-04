//
//  showmessage.swift
//  BCBF
//
//  Created by user216835 on 4/22/22.
//

import UIKit

extension UIViewController{
    //The three structs are for decode the Scenic Spot information from API
    struct feature:Codable{
        var features:[properties]
        private enum CodingKeys: String, CodingKey{
            case features
        }
    }
    struct properties:Codable {
        //var type:String
        var properties:ScenicSpotDetails
        private enum CodingKeys: String, CodingKey{
            case properties
        }
    }
    struct ScenicSpotDetails:Codable{
        var name:String?
        var lon:Double
        var lat:Double
        private enum CodingKeys:String, CodingKey{
            case name
            case lon
            case lat
        }
    }

    
    enum DownloadError: Error {
        case invalidUrl
        case invalidServerResponse
    }


    func displayMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    public func displayError(_ error: Error?, from function: StaticString = #function) {
        guard let error = error else { return }
        print("ⓧ Error in \(function): \(error.localizedDescription)")
        let message = "\(error.localizedDescription)\n\n Ocurred in \(function)"
        let errorAlertController = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        errorAlertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(errorAlertController, animated: true, completion: nil)
    }
    
    func countDown(_ timeOut: Int, btn: UIButton){
        //source:https://blog.csdn.net/weixin_46681371/article/details/121791450
               var timeout = timeOut
               let queue:DispatchQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.default)
               let _timer:DispatchSource = DispatchSource.makeTimerSource(flags: [], queue: queue) as! DispatchSource
        _timer.schedule(wallDeadline: DispatchWallTime.now(), repeating: .seconds(1))
               _timer.setEventHandler(handler: { () -> Void in
                   if(timeout<=0){
                       _timer.cancel();
                       DispatchQueue.main.sync(execute: { () -> Void in
                           btn.setTitle("Resend", for: .normal)
                           btn.isEnabled = true
                           btn.layer.backgroundColor = UIColor.systemBlue.cgColor.copy(alpha: 0.5)
                       })
                   }else{
                       let seconds = timeout
                       DispatchQueue.main.sync(execute: { () -> Void in
                           let str = String(describing: seconds)
                           btn.setTitle("\(str)s CD", for: .normal)
                           btn.isEnabled = false
                           btn.layer.backgroundColor = UIColor.gray.cgColor
                       })
                       timeout -= 1;
                   }
               })
               _timer.resume()
           }
}
