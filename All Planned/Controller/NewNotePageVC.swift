//
//  NewNotePageVC.swift
//  All Planned
//
//  Created by Lam Nguyen on 1/24/21.
//

import UIKit

protocol passDataToVCDelegate {
    func passData(data: Tasks)
}

protocol homeHeaderMessageDelegate {
    func message()
}

// MARK: set up the objects in the view
class NewNotePageVC: UIViewController {

    @IBOutlet var backView: UIView!                         //Background of the child view
    @IBOutlet var subjectTextField: UITextField!            //Subject Text Field
    @IBOutlet var table: UITableView!                       //Table on the child view
    @IBOutlet var saveButton: UIButton!                     //Save button
    
    var clicked = Array(repeating: false, count: 8)         //Keep track of the buttons pressed
    var delegate1: passDataToVCDelegate? = nil
    var delegate2: homeHeaderMessageDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)   //Make the background transparent
        
        //Set up the subject text field
        subjectTextField.backgroundColor = .gray
        subjectTextField.attributedPlaceholder = NSAttributedString(string: "Enter subject:", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        subjectTextField.textColor = .white
        
        //Set up the table
        table.delegate = self
        table.dataSource = self
        table.layer.cornerRadius = 25
        
        
        
        //Set up the save button
        saveButton.layer.cornerRadius = 12
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        backView.layer.cornerRadius = 25
        animateIn()
    }
    
    //Animate the modal view from the bottom
    fileprivate func animateIn(){
        backView.transform = CGAffineTransform(translationX: 0, y: 600)
        backView.alpha = 0
        UIView.animate(withDuration: 0.3, delay: 0.07) {
            self.backView.transform = .identity
            self.backView.alpha = 1
        }
    }
    
    //Animate the modal view out by exiting to the bottom
    fileprivate func animateOut(){
        view.alpha = 1
        subjectTextField.endEditing(true)               //Dismiss the keyboard
        UIView.animate(withDuration: 0.3, delay: 0.07) {
            self.backView.transform = CGAffineTransform(translationX: 0, y: 600)
            self.backView.alpha = 0
            
        } completion: { complete in
            if complete{
                self.dismiss(animated: false, completion: nil)
            }
        }
    }
    


}

// MARK: handle user input
extension NewNotePageVC{
    
    //Dismiss the keyboard if it is enabled
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if subjectTextField.isEditing{
            view.endEditing(true)
        }
    }
    
    //Dismiss the view out when the xmark is clicked
    @IBAction func xmarkClicked(_ sender: Any){
        animateOut()
    }
    
    //Save the text from the text field and the buttons pressed; store that data into core data
    @IBAction func savedClicked(_ sender: Any){
        //If the text field is empty, then change the placwholder in the text field
        let shiftTextField = pow(CGFloat(2), CGFloat(2))
        if subjectTextField.text == ""{
            let warningText = "Please enter a subject name:"
            subjectTextField.attributedPlaceholder = NSAttributedString(string: warningText, attributes: [NSAttributedString.Key.foregroundColor: UIColor.applyLightRedColor()])
            
            //Move the text field to get the users attention
            subjectTextField.transform = CGAffineTransform(translationX: shiftTextField, y: 0)
            UIView.animate(withDuration: 0.5, animations: {
                self.subjectTextField.transform = .identity
            })
            return
        }
        let shiftTable = pow(CGFloat(2.3), CGFloat(2.3))
        //If none of the days are clicked, then alert the user by "shaking" the table
        if !clicked.contains(true){
            
            //Shake the table
            table.transform = CGAffineTransform(translationX: shiftTable, y: 0)
            UIView.animate(withDuration: 0.5, animations: {
                self.table.transform = .identity
            })
            
            return
        }
        
        
        //Encode the days clicked into a single string
        var dayNameClicked = ""
        var dayDateClicked = ""
        for i in 0...clicked.count - 1 {
            if clicked[i]{
                //Take the first two letters of the day and add it to the daysClicked
                dayNameClicked += daysToDisplayOnCollection[i].name.prefix(2) + "-"
                dayDateClicked += daysToDisplayOnCollection[i].dayDate + "-"
            }
        }
        
        //Save the Task object into Core Data
        let newEntry: Tasks = Tasks(context: PersistenceService.context);
        let subjectEntry = subjectTextField.text
        
        newEntry.subject = subjectEntry
        newEntry.day = dayNameClicked
        newEntry.dayDate = dayDateClicked
        
        if delegate1 != nil && delegate2 != nil{
            delegate1?.passData(data: newEntry)
            delegate2?.message()
        }
        PersistenceService.saveContext()
        
        //Animate the view out
        animateOut()
        
        
    }
}

// MARK: set up the table
extension NewNotePageVC: UITableViewDelegate, UITableViewDataSource, changeStatusDelegate{
    
    //Set up the cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "datacell", for: indexPath) as? NewNoteTableCell
        
        //Configure the cell
        cell?.dayButton.setTitle(daysToDisplayOnCollection[indexPath.row].name, for: .normal)
        cell?.dayButton.setTitleColor(.white, for: .normal)
        cell?.backView.backgroundColor = .gray 
        cell?.statusImage.tintColor = .darkGray
        cell?.delegate = self
        
        //Change the status image depending on if the cell is clicked or not
        if clicked[indexPath.row] == false{
            cell?.statusImage.image = UIImage(systemName: "xmark.circle.fill")
        }
        else{
            cell?.statusImage.image = UIImage(systemName: "checkmark.circle.fill")
        }
        
        return cell!
    }
    
    //Return the number of cells/rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return daysToDisplayOnCollection.count
    }
    
    //Change the status image when the cell is clicked
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! NewNoteTableCell
        
        //When a cell is clicked, change the index of clicked array to the appropriate boolean type
        if clicked[indexPath.row] == false{
            cell.statusImage.image = UIImage(systemName: "checkmark.circle.fill")
            clicked[indexPath.row] = true
        }
        else{
            cell.statusImage.image = UIImage(systemName: "xmark.circle.fill")
            clicked[indexPath.row] = false
        }
    }
    
    //Similar to the function above, when the name of the day is clicked, the status image is appropriately changed.
    func changeStatus(cell: NewNoteTableCell) {
        let indexPath = table.indexPath(for: cell)
        if clicked[indexPath!.row] == false{
            cell.statusImage.image = UIImage(systemName: "checkmark.circle.fill")
            clicked[indexPath!.row] = true
        }
        else{
            cell.statusImage.image = UIImage(systemName: "xmark.circle.fill")
            clicked[indexPath!.row] = false
        }
    }
}
