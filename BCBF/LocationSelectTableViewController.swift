//
//  LocationSelectTableViewController.swift
//  BCBF
//
//  Created by user216835 on 5/21/22.
//

import UIKit
import MapKit

protocol locationSearchDelegate:NSObjectProtocol{
    func getLocation(loca:String)
}

class LocationSelectTableViewController: UITableViewController, UISearchResultsUpdating, MKLocalSearchCompleterDelegate {
    weak var delegate:locationSearchDelegate?
    
    var filteredLocation: [searchLocation] = []
    private let completer = MKLocalSearchCompleter()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        completer.delegate=self
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search the location"
        navigationItem.searchController = searchController
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        // This view controller decides how the search controller is presented
        definesPresentationContext = true
        
    }

    func updateSearchResults(for searchController: UISearchController) {
        //if input a new value while searching, cancel the old searching first
        guard let searchText = searchController.searchBar.text?.lowercased() else {
            if completer.isSearching{
                completer.cancel()
            }
            return
        }
        if searchText.count > 0 {
            completer.queryFragment=searchText
        } else {
            filteredLocation = []
            tableView.reloadData()
        }
        
        //print(filteredLocation.count)
        //print(filteredLocation)
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        /**
         The method for searching locations
         
         Note: The result of completer include choice to further search some special type of location, so the if condition is for ignoring it.
         */
        filteredLocation = []
        if completer.results.count>1{
            for i in 0...completer.results.count-1{
                if(completer.results[i].subtitle=="Search Nearby"){
                }
                else{
                    filteredLocation.append(searchLocation.init(name: completer.results[i].title, city: completer.results[i].subtitle))
                }
            }
        }
        else if completer.results.count==1{
            if(completer.results[0].subtitle=="Search Nearby"){
            }
            else{
                filteredLocation.append(searchLocation.init(name: completer.results[0].title, city: completer.results[0].subtitle))
            }
        }
        else{
            filteredLocation.append(searchLocation.init(name: "No Place Found", city: ""))
        }
        //print(completer.results[0].title)
        //print("CITY:"+completer.results[0].subtitle)
        //print(filteredLocation.count)
        //print(filteredLocation)
        tableView.reloadData()
        
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Error suggesting a location: \(error.localizedDescription)")
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return filteredLocation.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        let location = filteredLocation[indexPath.row]
        content.text = location.name
        content.secondaryText = location.city
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //send the details of selected location to the previous controller.
        if !filteredLocation.isEmpty{
            let loca=filteredLocation[indexPath.row]
            let location=loca.name+","+loca.city
            self.delegate?.getLocation(loca: location)
            print(location)
            navigationController?.popViewController(animated: true)
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
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
