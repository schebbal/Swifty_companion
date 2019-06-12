//
//  ViewController.swift
//  Switfy Companion
//
//  Created by Said Chebbal on 14/02/2019.
//  Copyright © 2019 Said Chebbal. All rights reserved.
//

import UIKit


let myUID = "6ee9c10135b4e78f2339e940bc5d4bbf61a37e54a91f71b8ae024b1191bc7e86"
let mySECRET = "55705501e0e4814fb0377807f9143c849f44098530b3a356ca82712e39d84d5c"

/*
 curl -X POST --data "grant_type=client_credentials&client_id=6ee9c10135b4e78f2339e940bc5d4bbf61a37e54a91f71b8ae024b1191bc7e86&client_secret=55705501e0e4814fb0377807f9143c849f44098530b3a356ca82712e39d84d5c" https://api.intra.42.fr/oauth/token
 {"access_token":"e1b34f06d935d6fbd420aaf4c4f0093d3ef2ecc0d8403f0324d78157dd23f525","token_type":"bearer","expires_in":7200,"scope":"public","created_at":1549273748}
 200 : succès de la requête ;
 301 et 302 : redirection, respectivement permanente et temporaire ;
 401 : utilisateur non authentifié ;
 403 : accès refusé ;
 404 : page non trouvée ;
 500 et 503 : erreur serveur ;
 504 : le serveur n'a pas répondu.
 */

class ViewController: UIViewController {

    @IBOutlet weak var login_profile: UITextField!
    @IBOutlet weak var button_go: UIButton!
    @IBOutlet weak var myActivityIndicatorView: UIActivityIndicatorView!
    
    var login:String! = ""
    var dataJson: Data?
    var sLogin = ""
    var token:String! = ""
    var tokenType = String()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func actionValid(_ sender: Any) {
        sLogin = login_profile.text!
        
            if (sLogin == "") {
                alert(title: "Erreur", message: "Veuillez saisir un login 42.")
                return
            } else {
                self.login = self.login_profile.text
                self.checkToken()
            }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            if (self.sLogin == "") {
                return
            }else {
                self.performSegue(withIdentifier: "Segue", sender: self)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let DestController: ViewControllerDetail = segue.destination as? ViewControllerDetail {
            DestController.login = self.login
            DestController.data = self.dataJson
        }
       
    }

    
    //Ouvre une popup
    func alert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    //Cache le clavier lorsque l'utilisateur touche l'écran
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func getUser() {
        print("********************* getUser() ***********************")
        let url = URL(string: "https://api.intra.42.fr/v2/users/"+login)
        let tokenString =  "Bearer " + self.token
        print ("tokenString : \(tokenString)")
        let request = NSMutableURLRequest(url: url! as URL)
        request.setValue(tokenString, forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        //self.myActivityIndicatorView.startAnimating()
        // Excute HTTP Request
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            DispatchQueue.main.async {
            // Check for error
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    self.sLogin = ""
                    //self.myActivityIndicatorView.stopAnimating()
                    print("2-statusCode should be 200, but is \(httpStatus.statusCode)")
                    self.alert(title: "Error", message: "Login inexistant!")
                    return
            } else {
                self.dataJson = data
            }
            }
            return
        }
        task.resume()
    }
    
    func getToken() {
        
        print("********************* getToken() ***********************")
        let getUrl = URL(string: "https://api.intra.42.fr/oauth/token?grant_type=client_credentials&client_id=\(myUID)&client_secret=\(mySECRET)")
        var request = URLRequest(url: getUrl! as URL)
        request.timeoutInterval = 30
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "POST"
        print("request : \(request)")
        let task = URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            if error == nil {
                let json = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                if let parseJSON = json {
                    self.token = (parseJSON?["access_token"] as? String)!
                    self.tokenType = (parseJSON?["token_type"] as? String)!
                    let defaults = UserDefaults.standard
                    defaults.set(self.token, forKey: "tokenSave")
                    print("New token : \(self.token)")
                    self.getUser()
                }
            }
        }
        task.resume()
    }
    
    func checkToken() {
        
        print("********************* checkToken() ***********************")
        let myUrl = URL(string: "https://api.intra.42.fr/oauth/token/info")
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "tokenSave") != nil {
            let tokenSave = defaults.object(forKey: "tokenSave") as! String
            print("tokenSave : \(String(describing: tokenSave))")
            self.token = tokenSave
        }
        print("Check token: \(self.token)")
        let tokenStr = "Bearer " + self.token
        let request = NSMutableURLRequest(url: myUrl! as URL)
        request.setValue(tokenStr, forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        print ("tokenStr: \(String(describing: tokenStr))")
        URLSession.shared.dataTask(with: request as URLRequest) { (dataJson, URLResponse, Error) in
            if let httpStatus = URLResponse as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("1-statusCode should be 200, but is \(httpStatus.statusCode)")
                if (httpStatus.statusCode == 401) {
                    self.getToken()
                } else {
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                }
            } else {
                self.getUser()
            }
            return
        }.resume()
    }
}

