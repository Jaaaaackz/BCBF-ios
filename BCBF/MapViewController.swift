//
//  MapViewController.swift
//  BCBF
//
//  Created by user216835 on 5/1/22.
//

import UIKit
import MapKit
import CoreLocation
import AssetsLibrary
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate,DatabaseListener,NewLocationDelegate, mapSetDelegate{
    
    ///- Parameters mapType: The setting of the map display, include if turning on shown of the Moment and Scenic Spot, and also the display mode of map.
    func setMap(mapType: mapSetting) {
        /**
         Get the setting from MapSettingViewController
         */
        maptype?.MapType=mapType.MapType
        maptype?.MomentShow=mapType.MomentShow
        maptype?.ScenicSpotShow=mapType.ScenicSpotShow
        mapView.mapType=mapType.MapType
        if mapType.ScenicSpotShow==true{
            getScenicSpots(lon: mapView.userLocation.coordinate.longitude, lat: mapView.userLocation.coordinate.latitude)

        }
        if mapType.MomentShow==true{
            print("show moment")
        }
    }
    
    var maptype:mapSetting?
    var listenerType = ListenerType.nightLocation
    weak var databaseController: DatabaseProtocol?
    weak var delegate:NewLocationDelegate?
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationBarButtonItem: UIButton!
    @IBOutlet weak var MapSettingButton: UIButton!
    @IBOutlet weak var AccountDetailButton: UIButton!
    @IBOutlet weak var FriendListButton: UIButton!
    var locationList = [LocationAnnotation]()
    var allNightLocation:[NightLocation]=[]
    let locationManager = CLLocationManager()
    var managedObjectContext: NSManagedObjectContext?
    
    func annotationAdded(annotation: LocationAnnotation) {
        locationList.append(annotation)
    }
    
    func onUserChange(change: DatabaseChange, userNightLocation: [NightLocation]) {
        
    }
    
    func onNightLocationChange(change: DatabaseChange, userNightLocation: [NightLocation]) {
        allNightLocation=userNightLocation
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        managedObjectContext = appDelegate!.persistentContainer?.viewContext
        // Do any additional setup after loading the view.
        FriendListButton.imageView?.layer.transform = CATransform3DMakeScale(0.5, 0.5, 0.5)
        AccountDetailButton.imageView?.layer.transform = CATransform3DMakeScale(0.2, 0.2, 0.2)
        MapSettingButton.imageView?.layer.transform = CATransform3DMakeScale(0.2, 0.2, 0.2)
        locationManager.delegate = self
        mapView.delegate = self
        
        mapView.mapType = .standard
        
        // Ensure the navgation bar is not transparent.
        navigationController?.navigationBar.scrollEdgeAppearance = UINavigationBarAppearance()

        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        mapView.showsUserLocation = !mapView.showsUserLocation
        
    }
    @IBAction func setMap(_ sender: Any) {
        performSegue(withIdentifier: "mapSettingSegue", sender: sender)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        //Initial view position
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    // MARK: - Action methods

    @IBAction func showFriendList(_ sender: Any) {
        //getNightLocation()
        print("Current Not working yet")
    }
    

    
    @IBAction func toggleLocationTracking(_ sender: Any) {
        //locate to user's location
        mapView.showsUserLocation = !mapView.showsUserLocation
        let buttonImageName = (mapView.showsUserLocation) ? "location.circle.fill" : "location.circle"
        locationBarButtonItem.setImage(UIImage(systemName: buttonImageName), for: .normal)
    }
   
    func getScenicSpots(lon:Double,lat:Double){
        /**
         Parameter: lon, lat are the current longitude and latitude of user's  location
         
         Resolve the Scenic Spot information through the API and store them as a MapKit annotation
         */
        Task {
            do {
                // Create the URL for the request
                guard let jsonURL = URL(string:"https://api.geoapify.com/v2/places?categories=tourism&bias=proximity:"+String(lon)+","+String(lat)+"&limit=20&apiKey=bdb2b05bbc904ea18be58c5f0fe4df19") else {
                    throw DownloadError.invalidUrl
                }
                // Perform the request
                let (data, response) = try await URLSession.shared.data(from: jsonURL)
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw DownloadError.invalidServerResponse
                }
                // Do something with the data.
                let decoder = JSONDecoder()
                let feature = try decoder.decode(feature.self, from: data)
                //ScenicSpotList.removeAll()
                //print(feature.features)
                await MainActor.run {
                    let length=feature.features.count
                    var scenicSpotList:[ScenicSpot]=[]
                    for i in 0...length-1{
                        let name=feature.features[i].properties.name
                        let lon=feature.features[i].properties.lon
                        let lat=feature.features[i].properties.lat
                        
                        scenicSpotList.append(ScenicSpot(name: name ?? "None", lon: lon, lat: lat))
                    }
                    for i in 0...scenicSpotList.count-1{
                        let name=scenicSpotList[i].name
                        let lon=scenicSpotList[i].lon
                        let lat=scenicSpotList[i].lat
                        //self.delegate?.annotationAdded(annotation:  LocationAnnotation.init(title: name, subtitle: "Scenic Spot", lat: lat, long: lon))
                        annotationAdded(annotation: LocationAnnotation.init(title: name, subtitle: "Scenic Spot", lat: lat, long: lon))
                    }
                    mapView.addAnnotations(locationList)
                    print("done")
                }
            }
            catch {
                print(error.localizedDescription)
            }
        }
    }
    
    @IBAction func MakeAppointment(_ sender: Any) {
        performSegue(withIdentifier: "MakeAppointmentSegue", sender: sender)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let ScenicSpotIdentifier = "Scenic Spot"
        let UserIdentifier="User"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: ScenicSpotIdentifier)
        if annotationView == nil&&annotation.subtitle=="Scenic Spot" {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: ScenicSpotIdentifier)
            annotationView?.annotation = annotation
            annotationView?.image = self.resizeImage(image: UIImage(named: "Scenic spot")!, targetSize: CGSize(width: 25.0, height: 25.0)) // set the image of annotation
            annotationView?.centerOffset = CGPoint(x: 0, y: 0)
            annotationView?.canShowCallout = true// set the box
            annotationView?.calloutOffset = CGPoint(x: 0, y: 0)
            annotationView?.setSelected(true, animated: true)
            self.mapView.showAnnotations(locationList, animated: true)
        }
        else if annotationView==nil&&annotation is MKUserLocation{
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: UserIdentifier)
            annotationView?.annotation = annotation
            annotationView?.image = self.resizeImage(image: getUserAvatar(), targetSize: CGSize(width: 30.0, height: 30.0))
            annotationView?.centerOffset = CGPoint(x: 0, y: 0)
            annotationView?.canShowCallout = true
            annotationView?.calloutOffset = CGPoint(x: 0, y: 0)
            annotationView?.zPriority = .max
        }
        
        return annotationView
    }
    
    func getUserAvatar()->UIImage{
        var imageList = [UIImage]()
        var imagePathList = [String]()
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
                    return image
                }
            }
        } catch {
            print("Unable to fetch images")
        }
        return UIImage(named: "account")!
    }
    
    func loadImageData(filename: String) -> UIImage? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let imageURL = documentsDirectory.appendingPathComponent(filename)
        let image = UIImage(contentsOfFile: imageURL.path)
        return image
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        // Pan to new user location when updated
        var mapRegion = MKCoordinateRegion()
        mapRegion.center = userLocation.coordinate
        mapRegion.span = mapView.region.span; // Use current 'zoom'
        mapView.setRegion(mapRegion, animated: true)
    }
    
    func getNightLocation(){
        print(allNightLocation)
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
    //source:https://stackoverflow.com/questions/31314412/how-to-resize-image-in-swift
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(origin: .zero, size: newSize)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
        
    
    // MARK: - CLLocationManagerDelegate methods

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // Only show user location in MapView if user has authorized location tracking
        let isAUthorised = (status == .authorizedWhenInUse)
        locationBarButtonItem.isEnabled = isAUthorised
        
        // If the user has disabled authorisation, ensure we are not showing location.
        if (isAUthorised == false && mapView.showsUserLocation) {
            mapView.showsUserLocation = false
        }
    }
    
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier=="mapSettingSegue"{
            let controller = segue.destination as! MapSettingViewController
            controller.delegate = self
        }
        else if segue.identifier=="MakeAppointmentSegue"{
            let controller = segue.destination as! AppointmentViewController
            
            controller.coordinate=CLLocationCoordinate2D(latitude: mapView.userLocation.coordinate.latitude, longitude: mapView.userLocation.coordinate.longitude)
        }
    }
    
}
