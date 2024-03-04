//
//  AppointmentViewController.swift
//  BCBF
//
//  Created by user216835 on 5/16/22.
//

import UIKit
import EventKit
import MapKit

class AppointmentViewController: UIViewController, MKLocalSearchCompleterDelegate,locationSearchDelegate{
    func getLocation(loca: String) {
        SearchedLocation=loca
        locationTextField.text=SearchedLocation!
    }
    

    @IBOutlet weak var inviteeTextField: UITextField!
    @IBOutlet weak var noteTextField: UITextField!
    @IBOutlet weak var themeTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    var SearchedLocation:String?
    
    var searchResults = [MKLocalSearchCompletion]()
    var coordinate:CLLocationCoordinate2D?
    
    @IBAction func swipeGesture(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    static let NOTIFICATION_IDENTIFIER = "BCBF"

    lazy var appDelegate = {
       return UIApplication.shared.delegate as! AppDelegate
    }()
    
    @IBAction func LocationTextFieldChanged(_ sender: Any) {
        //completer.queryFragment = locationTextField.text!
        performSegue(withIdentifier: "locationSelectSegue", sender: sender)
     }
     
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.date=Date.init(timeIntervalSinceNow: 3600)
        datePicker.minimumDate=Date.init(timeIntervalSinceNow: 900)
        datePicker.locale=NSLocale.current
        datePicker.timeZone=NSTimeZone.local
        locationTextField.placeholder="Please input a location"
        // Do any additional setup after loading the view.
        if let response = UserDefaults.standard.string(forKey: "response") {
            print("There was a stored response: \(response)")
        }
        else {
            print("No stored response")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if locationTextField.text?.count==0{
            //setup the default locationTextField as user's current location
            getCurrentLocation(coordinate: self.coordinate!)
        }
    }
    
    
    @IBAction func addToCalendar(_ sender: Any) {
        /**
         Add the event to Calendar app
         */
        if inviteeTextField.text?.count==0||noteTextField.text?.count==0||themeTextField.text?.count==0||locationTextField.text?.count==0{
            displayMessage(title: "Warming", message: "Please fill in all the information")
        }
        else{
            guard let title=themeTextField.text,let notes=noteTextField.text,let loca=locationTextField.text else {
                print("error while get input")
                return
            }
            addCalendar(title: title, notes: notes,location:loca , date: datePicker.date)
        }
    }
    
    
    @IBAction func makeAppointment(_ sender: Any) {
        /**
         Check if all the input is vaild then start to create the notification with the information.
         */
        guard appDelegate.notificationsEnabled == true else {
            print("Notifications are disabled")
            return
        }
        if inviteeTextField.text?.count==0||noteTextField.text?.count==0||themeTextField.text?.count==0||locationTextField.text?.count==0{
            displayMessage(title: "Warming", message: "Please fill in all the information")
        }
        else{
            guard let title=themeTextField.text,let notes=noteTextField.text,let loca=locationTextField.text else {
                print("error while get input")
                return
            }
            let time=Int(datePicker.date.timeIntervalSinceNow)/60
            createNotification(title:"Your Appointment is close,"+String(time)+" mins left", body: "Theme:"+title+"\nLocation:"+loca)
            navigationController?.popViewController(animated: true)
        }
    }
    
    func addCalendar(title:String,notes:String,location:String,date:Date){
        //source:https://www.jianshu.com/p/ef999c482e5f
        //create object
        let eventDB: EKEventStore=EKEventStore()
        //apply for premission
        eventDB .requestAccess(to: .event){success,error in
            if success{
                DispatchQueue.main.async {
                    let calevent:EKEvent=EKEvent.init(eventStore: eventDB)
                    calevent.title=title
                    calevent.notes=notes
                    calevent.location=location
                    calevent.startDate=date
                    calevent.endDate=date
                    calevent.addAlarm(EKAlarm.init(absoluteDate: date))
                    calevent.calendar=eventDB.defaultCalendarForNewEvents
                    try? eventDB.save(calevent,span:.thisEvent)
                }
            }else{
                print("Fail to get the premission",error)
            }
        }
    }
    
    func createNotification(title:String,body:String){
        /**
         Setup the notification, and alert when 10 mins left.
         
         Note: If the time remind is less than 10 mins, then will directly push the notification
         */
        let content = UNMutableNotificationContent()
        
        content.title = title
        content.body = body
        
        var interval=TimeInterval.init()
        
        if datePicker.date.addingTimeInterval(-600)<Date.now{
            interval = datePicker.date.timeIntervalSinceNow
        }
        else{
            interval=(datePicker.date.addingTimeInterval(-600)).timeIntervalSinceNow
        }
        print(datePicker.date.addingTimeInterval(-600).timeIntervalSinceNow)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        
        let request = UNNotificationRequest(identifier: AppointmentViewController.NOTIFICATION_IDENTIFIER, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        print("Notification scheduled.")
    }
    
    func getCurrentLocation(coordinate:CLLocationCoordinate2D){
        /**
         Get the detail of current location through coordinate
         Use CLGeocoder to search, select the best fit one, then set up the text in location Text Field.
         */
        let lat=coordinate.latitude
        let lon=coordinate.longitude
        
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: lat, longitude:lon)
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            // Location name
            if placeMark != nil{
                if let locationName = placeMark.name{
                    //print(locationName)
                    self.locationTextField.text=locationName+","
                }
                
                // City
                if let city = placeMark.locality {
                    //print(city)
                    self.locationTextField.text!+=city+","
                }
                
                // Country
                if let country = placeMark.country{
                    //print(country)
                    self.locationTextField.text!+=country
                }
            }
        })
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier=="locationSelectSegue"{
            let controller=segue.destination as! LocationSelectTableViewController
            controller.delegate = self
        }
    }


}

