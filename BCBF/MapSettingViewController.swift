//
//  MapSettingViewController.swift
//  BCBF
//
//  Created by user216835 on 5/16/22.
//

import UIKit
import MapKit

protocol mapSetDelegate:NSObjectProtocol{
    func setMap(mapType:mapSetting)
}

class MapSettingViewController: UIViewController {
    
    @IBOutlet weak var MomentShowSwitch: UISwitch!
    @IBOutlet weak var ScenicSpotShowSwitch: UISwitch!
    @IBOutlet weak var MapSettingSegment: UISegmentedControl!
    var mapType:MKMapType = .standard
    weak var delegate:mapSetDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        //let test = mapSetting.init(MomentShow: true, ScenicSpotShow: true, MapType: mapType)
        //delegate?.setMap(mapType: test)

        // Do any additional setup after loading the view.
    }
    
    @IBAction func swipeGesture(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func showScenicSpot(_ sender: Any) {
        /**
         Everytime one of the statu has been changed, the map setting will refresh.
         */
        switch MapSettingSegment.selectedSegmentIndex{
        case 0:
            mapType = .standard
        case 1:
            mapType = .satellite
        case 2:
            mapType = .hybrid
        default:
            mapType = .standard
        }
        let mapSet=mapSetting.init(MomentShow: MomentShowSwitch.isOn, ScenicSpotShow: ScenicSpotShowSwitch.isOn, MapType: mapType)
        self.delegate?.setMap(mapType: mapSet)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
   /* override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        let mapSet=mapSetting.init(MomentShow: MomentShowSwitch.isOn, ScenicSpotShow: ScenicSpotShowSwitch.isOn, MapType: mapType)
        self.delegate?.setMap(mapType: mapSet)
    }/*
    

      }*/*/
}
