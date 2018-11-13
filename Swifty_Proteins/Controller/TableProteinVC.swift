//
//  TableProteinVC.swift
//  Swifty_Proteins
//
//  Created by Ivan SELETSKYI on 10/25/18.
//  Copyright © 2018 Ivan SELETSKYI. All rights reserved.
//

import UIKit

class TableProteinVC: UIViewController {
    
    let read = Reader()
    
    var filterArr: [String] = []
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar! {
        willSet {
            UITextField.appearance(whenContainedInInstancesOf: [type(of: newValue)]).tintColor = UIColor(red:0.24, green:0.06, blue:0.26, alpha:1.0)
            UITextField.appearance(whenContainedInInstancesOf: [type(of: newValue)]).textColor = UIColor(red:0.24, green:0.06, blue:0.26, alpha:1.0)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        read.getProteinsArr()
        filterArr = Ligands.ligands

        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
    }
    
    @IBOutlet weak var button: UIButton!
    
    @IBAction func buttonAction(_ sender: Any) {
        performSegue(withIdentifier: "segueFormTableToModel", sender: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func performSelector(inBackground aSelector: Selector, with arg: Any?) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "modelViewController" {
            let cell = sender as! ProteinTableViewCell
            let tpvc = segue.destination as! ModelViewController
            tpvc.title = cell.nameLabel.text!
        }
        if segue.identifier == "seguePopupFromTable" {
            let vc = segue.destination as! PopupViewController
            vc.data = sender as! [String]
        }
    }
}

// MARK: - TableView Delegate DataSearse

extension TableProteinVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellProtein", for: indexPath) as? ProteinTableViewCell
        cell?.nameLabel.text = filterArr[indexPath.row]
        cell?.cellActivity.stopAnimating()
        return cell!
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if UIApplication.shared.isNetworkActivityIndicatorVisible == false {
            let cell = tableView.cellForRow(at: indexPath) as! ProteinTableViewCell
            cell.cellActivity.startAnimating()
            let name = cell.nameLabel.text!
            let qos = DispatchQoS.background.qosClass
            let queue = DispatchQueue.global(qos: qos)
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            queue.async {
                if Ligands.LigandsGeom.count != 0 {
                    Ligands.LigandsGeom.removeAll()
                }
                if Ligands.boundsGeom.count != 0 {
                    Ligands.boundsGeom.removeAll()
                }
                let result = self.read.getModel(name: name)
                DispatchQueue.main.async {
                    cell.cellActivity.stopAnimating()
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    if (result){
                        self.performSegue(withIdentifier: "modelViewController", sender: cell)
                    } else {
                        let data = ["Error", "Something wrong with that file"]
                        self.performSegue(withIdentifier: "seguePopupFromTable", sender: data)
                    }
                }
            }
        }
        return indexPath
    }
}

// MARK: - searchBar UISearchBarDelegate

extension TableProteinVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let text = searchBar.text!.lowercased()
        searchTextInBar(text)
    }
    
    func searchTextInBar(_ str: String) {
        var i = 0
        
        if (str != "") {
            filterArr = []
            while (i < Ligands.ligands.count) {
                if (Ligands.ligands[i].lowercased().contains(str)) {
                    self.filterArr.append(Ligands.ligands[i])
                }
                i += 1
            }
            filterArr = filterArr.sorted()
        } else {
            filterArr = Ligands.ligands
        }
        tableView.reloadData()
    }
}









