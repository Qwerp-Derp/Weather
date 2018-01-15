//
//  ViewController.swift
//  Weather
//
//  Created by Hanyuan Li on 14/1/18.
//  Copyright © 2018 Qwerp-Derp. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreData

protocol UpdatePlacesDelegate {
    func updatePlaces(_ name: String, _ country: String)
}

class ViewController: UITableViewController, UISearchBarDelegate, UpdatePlacesDelegate {
    var places = [NSManagedObject]()
    var searchController = UISearchController()

    private func initPlaces() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Place")

        do {
            self.reminders = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }

    private func initSearchBar() {
        let resultController = self.storyboard!.instantiateViewController(withIdentifier: "resultController") as! ResultController
        resultController.updatePlacesDelegate = self

        self.searchController = UISearchController(searchResultsController: resultController)
        self.searchController.dimsBackgroundDuringPresentation = true
        self.searchController.searchResultsUpdater = resultController

        self.searchController.searchBar.placeholder = "Enter place name here..."
        self.searchController.searchBar.sizeToFit()
        self.searchController.searchBar.delegate = self

        self.definesPresentationContext = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem

        initPlaces()
        initSearchBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UISearchBarDelegate
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.tableView.tableHeaderView = nil
        self.navigationController?.isNavigationBarHidden = false
    }

    // MARK: UpdatePlacesDelegate

    private func addPlace(_ name: String, _ country: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Reminder", in: managedContext)!

        let place = NSManagedObject(entity: entity, insertInto: managedContext)
        place.setValue(name, forKey: "name")
        place.setValue(country, forKey: "country")

        do {
            try managedContext.save()
            self.places.append(place)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }

    func updatePlaces(_ name: String, _ country: String) {
        self.addPlace(name, country)
        self.tableView.reloadData()

        self.searchController.searchBar.text = nil

        self.tableView.tableHeaderView = nil
        self.navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: Actions

    @IBAction func startSearchBar(_ sender: UIBarButtonItem) {
        self.tableView.tableHeaderView = self.searchController.searchBar
        self.navigationController?.isNavigationBarHidden = true
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.places.count
    }

    private func fetchTemperature(_ name: String, completion: @escaping (String?) -> Void) {
        let key = "3b91deabdf62449b737fe65edaf5e0d2"
        let url = "https://api.openweathermap.org/data/2.5/weather?q=\(name)&units=metric&appid=\(key)"

        Alamofire.request(url).responseJSON { response in
            switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    let temperature = json["main"]["temp"].float!
                    completion(String(format: "%.1f°C", temperature))
                case .failure(let error):
                    print("Error while fetching temperature: \(error)")
                    completion(nil)
                }
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "weatherCell", for: indexPath) as? WeatherCell else {
            fatalError("Dequeued cell is not a WeatherCell")
        }

        let place = self.places[indexPath.row]
        let name = place.value(forKeyPath("name")) as? String
        let country = place.value(forKeyPath("country")) as? String

        cell.placeLabel.text = name
        cell.tempLabel.text = nil

        fetchTemperature("\(name),\(country)") { result in
            if let updatedCell = self.tableView.cellForRow(at: indexPath) as? WeatherCell {
                updatedCell.tempLabel.text = result
                updatedCell.setNeedsLayout()
            }
        }

        return cell
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            self.places.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
}
