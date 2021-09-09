//
//  SettingsPageVC.swift
//  All Planned
//
//  Created by Lam Nguyen on 1/31/21.
//

import UIKit
//import SafariServices
import MessageUI

class SettingsPageVC: UIViewController {

    @IBOutlet var backView: UIView!                      //Background of the child view
    @IBOutlet weak var bugsButton: UIButton!             //IBOutlet for report bugs button
    @IBOutlet weak var contactButton: UIButton!          //IBOutlet for contact
    @IBOutlet var instructionsLabel: UILabel!
    
    // MARK: initial setup of the page
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)   //Make the background transparent
        
        //Set up the backview
        backView.layer.cornerRadius = 30

        //Open the links when the appropriate link is pressed
        bugsButton.addTarget(self, action: #selector(openBugsLink), for: .touchUpInside)
        
        //Open up email to contact
        contactButton.addTarget(self, action: #selector(openEmail), for: .touchUpInside)
        
        //Set ip the instructions text
        instructionsLabel.text = "* Add a task using the add button and save\n* Click on a day of the week to view tasks and write a note\n* Swipe on a tasks to delete it"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        backView.layer.cornerRadius = 25
        animateIn()
    }
    
    // MARK: animations of the page
    fileprivate func animateIn(){
        backView.transform = CGAffineTransform(translationX: 0, y: 600)
        backView.alpha = 0
        UIView.animate(withDuration: 0.3, delay: 0.07) {
            self.backView.transform = .identity
            self.backView.alpha = 1
        }
    }
    
    fileprivate func animateOut(){
        view.alpha = 1
        UIView.animate(withDuration: 0.35, delay: 0.07) {
            self.backView.transform = CGAffineTransform(translationX: 0, y: 600)
            self.backView.alpha = 0
            
        } completion: { complete in
            if complete{
                self.dismiss(animated: false, completion: nil)
            }
        }
    }

}

// User interaction
extension SettingsPageVC: MFMailComposeViewControllerDelegate{
    // MARK: IBActions
    //Dismiss the view out when the xmark is clicked
    @IBAction func xmarkClicked(_ sender: Any){
        animateOut()
    }
    
    //Open up the email
    @objc fileprivate func openEmail(){
        //Check to see if email can be sent and show an alert if fail
        guard MFMailComposeViewController.canSendMail() else{
            let alertController = UIAlertController(title: "Error", message: "Please set up mail on device", preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            
            present(alertController, animated: true, completion: nil)
            return
        }
        let mailcntr = MFMailComposeViewController()
        mailcntr.mailComposeDelegate = self
        mailcntr.setSubject("Contact")                                      //Email Subject
        mailcntr.setToRecipients(["lance66nguyen@gmail.com"])                        //Email Recipients
        
        present(mailcntr, animated: true)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    //Open up the safari to a site
    @objc private func openBugsLink(){
        if let urlToOpen  = URL(string: "https://google.com"){             //Open Report Bugs Link
            UIApplication.shared.open(urlToOpen, options: [:], completionHandler: nil)
        }
    }
}
