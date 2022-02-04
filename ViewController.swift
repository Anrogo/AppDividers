//
//  ViewController.swift
//  Ej03
//
//  Created by user190722 on 1/30/22.
//

import UIKit
import UserNotifications

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var resultLabel: UILabel!
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    @IBOutlet weak var percentageLabel: UILabel!
    
    @IBOutlet weak var startBtn: UIButton!
    
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    @IBOutlet weak var loadingLabel: UILabel!
    
    //Array with all dividers
    var dividersArray = [Int]()
    
    //Number write by user
    var number = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Grant to show notifications
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            if granted {
                print("Permiso concedido")
            } else {
                print("Permiso denegado")
            }
        }
        
        //Text Field only numbers
        self.textField.keyboardType = .numberPad
        
        //custom button start
        customizeBtn()
        
        //Inicialise the progess bar with its percentage label
        self.progressBar.progress = 0
        self.percentageLabel.text = "0%"
        self.progressBar.isHidden = true
        self.percentageLabel.isHidden = true
        
        //Close keyboard when press "intro" (.default keyboard)
        //self.textField.delegate = self
        
        //Disabled label of the result and loader also
        self.resultLabel.isHidden = true
        self.loader.isHidden = true
        self.loadingLabel.isHidden = true
        self.loadingLabel.text = "Buscando divisores..."
        

    }

    @IBAction func start(_ sender: UIButton) {
        
        //Get value of text field
        number = Int(self.textField.text ?? "0") ?? 0
        if number == 0 { //If empty, the user is warned
            self.resultLabel.isHidden = false
            self.resultLabel.text = "Introduce un número mayor que 1, por favor"
        } else { //If not empty start searching
            //First of all, reset values for the new search
            newSearch()
            //Now searching
            findDivisors()
        }
    }
    
    func showNotification() {
        //Create and fill in the content to be displayed in the notification
        let content = UNMutableNotificationContent()
        content.title = "Finalizado"
        content.subtitle = "Divisores de \(self.number) encontrados (\(dividersArray.count))"
        content.body = "Vuelve a la app para revisar los resultados.."
        content.sound = .default
        content.badge = 1
        
        //Define trigger
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
        
        //Request for the launch
        let request = UNNotificationRequest(identifier: "notificationId", content: content, trigger: trigger)

        //Launch
        UNUserNotificationCenter.current().add(request) {
            (error) in print("")
        }
    }
    
    func findDivisors(){
        //If number is greater than 0 always enter
        if number > 0 {
            DispatchQueue.global().async {
                //Loop to loop through all possible divisors of the number
                for n in 1...self.number {
                
                    //If rest of division is 0, it will be a divisor
                    if self.number % n == 0 {
                        //And add one more in the counter and in the array
                        self.dividersArray.append(n)
                    }
                    
                    //Interval for each iteration
                    let interval = Float(n)/Float(self.number)
                    
                    //Calculate rounding of the number
                    let rounded = (interval*100).rounded()/100

                    //And display in the main thread the results of each update
                    DispatchQueue.main.async {
                        self.progressBar.setProgress(Float(rounded), animated: true)
                        self.percentageLabel.text = "\(Int(rounded*100))%"
                    }
                }
                //Call to display the notification with result
                self.showNotification()
                DispatchQueue.main.async {
                    
                    //Disable loading text and loader
                    self.loader.isHidden = true
                    self.loadingLabel.isHidden = true

                    //And show the result in the screen
                    self.showResult()
                    
                }
            }
        }
    }
    
    //Method to close keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    //Custom styles for start button
    func customizeBtn(){
        startBtn.layer.backgroundColor =  #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        startBtn.layer.cornerRadius = 12
        startBtn.layer.borderWidth = 2
        startBtn.layer.borderColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        startBtn.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
    }
    
    //Method to make a new search of divisors
    func newSearch(){
        
        //Enable progress bar and percentage
        self.progressBar.isHidden = false
        self.percentageLabel.isHidden = false
        
        //Origin progress bar
        self.progressBar.progress = 0
        
        //Close keyboard when finish writing
        self.textField.endEditing(true)
        
        //Disabled label of the result
        self.resultLabel.isHidden = true
        
        //Enable loader
        self.loader.isHidden = false
        self.loadingLabel.isHidden = false
        
        //Remove data of dividers array
        self.dividersArray.removeAll()
    }
    
    //Method to finally display the divisors found and stored in the array
    func showResult(){
        self.resultLabel.isHidden = false
        var strResult = "El número \(self.number) tiene \(dividersArray.count) divisores ("
            
        for i in 0...dividersArray.count-1 {
            if i == 0 {
                strResult += "\(dividersArray[i])"
            } else if i < dividersArray.count-1 {
                strResult += ", \(dividersArray[i])"
            } else if i == dividersArray.count-1 {
                strResult += " y \(dividersArray[i])"
            }
        }
        strResult += ")"
        //After concatenating all divisors,it display in the label
        self.resultLabel.text = strResult
    }
}

