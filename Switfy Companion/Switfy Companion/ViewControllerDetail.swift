//
//  ViewControllerDetail.swift
//  Switfy Companion
//
//  Created by Said Chebbal on 14/02/2019.
//  Copyright © 2019 Said Chebbal. All rights reserved.
//


import UIKit


class ViewControllerDetail: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
   var login:String! = ""
    var data: Data?
    
    @IBOutlet weak var nomComplet: UILabel!
    @IBOutlet weak var login_profile: UILabel!
    @IBOutlet weak var mail_profile: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var correction_point: UILabel!
    @IBOutlet weak var wallet: UILabel!
    @IBOutlet weak var photo_profile: UIImageView!
    @IBOutlet weak var phone: UILabel!
    @IBOutlet weak var niveau: UILabel!
    @IBOutlet weak var mySegmentedControl: UISegmentedControl!
    @IBOutlet weak var myTableView: UITableView!
    
    @IBOutlet weak var myActivityIndicator: UIActivityIndicatorView!
    var token = String()
    var tokenType = String()
    
    var retrunValue: Int! = 0
    
    var projets: NSMutableArray = []
    var competences: NSMutableArray = []
    var skills: NSArray = []
    var cursus: NSArray = []
    var achievements: NSMutableArray = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        myTableView.backgroundColor = UIColor.darkGray
        myTableView.separatorColor = UIColor.green
        loadData()
    }
    
    func loadData()
    {
        self.myActivityIndicator.startAnimating()
        // Convert server json response to NSDictionary
        do {
                let json = try JSONSerialization.jsonObject(with: self.data!, options: .mutableContainers) as? NSDictionary
                self.projets = json!.object(forKey: "projects_users") as! NSMutableArray
                self.achievements = json?["achievements"] as! NSMutableArray
                self.competences = json?["cursus_users"] as! NSMutableArray
            
                self.cursus = ((self.competences.value(forKey: "cursus") as AnyObject).value(forKey: "name")) as! NSArray
                for cursuss in cursus {
                    if (String(describing: cursuss) == "Formation Pole Emploi") {
                        let index = cursus.index(of: "Formation Pole Emploi")
                        self.skills = (self.competences[index] as AnyObject).value(forKey: "skills") as! NSArray
                        let niv = (self.competences.value(forKey: "level") as? NSArray)!
                        self.niveau.isHidden = false
                        self.niveau.text = String("niveau: \(niv[index]) %")
                    } else if (String(describing: cursuss) == "42") {
                        let index = cursus.index(of: "42")
                        self.skills = (self.competences[index] as AnyObject).value(forKey: "skills") as! NSArray
                        let niv = (self.competences.value(forKey: "level") as? NSArray)!
                        self.niveau.isHidden = false
                        self.niveau.text = String("niveau: \(niv[index]) %")
                    }
                }
            
                if let parseJSON = json {
                    //print(parseJSON)
                    let strUrl = parseJSON["image_url"] as? String
                    if let url = NSURL(string: strUrl!) {
                        if let data = NSData(contentsOf: url as URL) {
                            self.photo_profile.image  = UIImage(data: data as Data)
                        }
                    }
                    
                    self.login_profile.text = parseJSON["login"] as? String
                    self.mail_profile.text = parseJSON["email"] as? String
                    self.mail_profile.isHidden = false
                    self.phone.text = parseJSON["phone"] as? String
                    self.nomComplet.text = parseJSON["displayname"] as? String
                    
                    let points: Int = (parseJSON["correction_point"] as? Int)!
                    self.correction_point.text = String("points: \(points)")
                    
                    let wallets: Int = (parseJSON["wallet"] as? Int)!
                    self.wallet.text = String("wallet: \(wallets)")
                    
                    self.location.text = parseJSON["location"] as? String
                }
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        self.myActivityIndicator.stopAnimating()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        retrunValue = 0
        switch(mySegmentedControl.selectedSegmentIndex) {
        case 0:
            retrunValue = (projets.count)
            print("Nbre projects: \(projets.count)")
            break
        case 1:
            retrunValue = (skills.count)
            print("Nbre skills: \(skills.count)")
            break
        case 2:
            retrunValue = (achievements.count)
            print("Nbre achievements: \(achievements.count)")
            break
        default:
            break
        }
 
        return retrunValue

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "lineTableViewCell"
        //let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? lineTableViewCell else {
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        cell.textLabel?.font = UIFont.systemFont(ofSize: 12.0)
        cell.champ1.font = UIFont.systemFont(ofSize: 12.0)
        cell.champ2.font = UIFont.systemFont(ofSize: 12.0)
        cell.champ3.font = UIFont.systemFont(ofSize: 12.0)
        switch(mySegmentedControl.selectedSegmentIndex) {
        case 0:
            
            if (self.projets.count > 0) {
                let str = self.projets[indexPath.row] as? NSDictionary
                let str1 = str?.object(forKey: "project")
                var str2 = str?["final_mark"] ?? 0
                str2 = String(describing: str2) != "<null>" ? str2 : 0
                cell.champ1.text = ((str1 as AnyObject).object(forKey: "slug") as? String)!
                cell.champ2.text = "\(str2) % "
                cell.champ3.text = (str?.object(forKey: "status") as? String)!
            }
            break
        case 1:
            let str = self.skills[indexPath.row] as? NSDictionary
            cell.champ1.text = (str?["name"] as? String)!
            cell.champ3.text = "\(str?["level"] ?? 0) %"
            cell.champ2.text = " "
            break
        case 2:
            let str = self.achievements[indexPath.row] as? NSDictionary
            cell.champ3.text = (str?.object(forKey: "name") as? String)!
            cell.champ2.text = " "
            cell.champ1.text = (str?.object(forKey: "description") as? String)!
            break
        default:
            break
        }
        return cell

    }

    @IBAction func segmentedControlActionChanged(_ sender: Any) {
        myTableView.reloadData()
    }
}
