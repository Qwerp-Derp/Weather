//
//  ResultController.swift
//  Weather
//
//  Created by Hanyuan Li on 15/1/18.
//  Copyright © 2018 Qwerp-Derp. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreData

class ResultController: UITableViewController, UISearchResultsUpdating {
    var results = [(name: String, country: String)]()
    var updatePlacesDelegate: UpdatePlacesDelegate? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.results.count
    }

    // MARK: UISearchResultsUpdating

    private func parseResults(_ json: JSON) -> [(String, String)] {
        var names = [(name: String, country: String)]()

        if let list = json["list"].array {
            for result in list {
                let name = result["name"].string!
                let country = result["sys"]["country"].string!

                names.append((name: name, country: country))
            }
        }

        return names
    }

    private func fetchSearchResults(_ name: String, completion: @escaping ([(String, String)]?) -> Void) {
        let key = "3b91deabdf62449b737fe65edaf5e0d2"
        let url = "https://api.openweathermap.org/data/2.5/find?q=\(name)&type=like&appid=\(key)"

        Alamofire.request(url).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                completion(self.parseResults(json))
            case .failure(let error):
                print("Error while fetching results: \(error)")
                completion(nil)
            }
        }
    }

    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text!

        fetchSearchResults(text) { results in
            if results != nil {
                self.results = results!
                self.tableView.reloadData()
            }
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath) as? ResultCell else {
            fatalError("Dequeued cell is not a ResultCell")
        }

        let result = results[indexPath.row]
        cell.resultLabel.text = "\(result.name), \(result.country)"

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let result = results[indexPath.row]
        self.updatePlacesDelegate?.updatePlaces(result.name, result.country)

        self.results = []
        self.tableView.reloadData()
        self.dismiss(animated: false, completion: nil)
    }

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
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
