//
//  HomePageVC.swift
//  All Planned
//
//  Created by Lam Nguyen on 1/31/21.
//

import UIKit
import CoreData
import UserNotifications


var daysToDisplayOnCollection: [Day] = [
                                        Day(name: "", dayDate: "", clicked: false),
                                        Day(name: "", dayDate: "", clicked: false),
                                        Day(name: "", dayDate: "", clicked: false),
                                        Day(name: "", dayDate: "", clicked: false),
                                        Day(name: "", dayDate: "", clicked: false),
                                        Day(name: "", dayDate: "", clicked: false),
                                        Day(name: "", dayDate: "", clicked: false),
                                        Day(name: "General", dayDate: "-", clicked: false)]

var allTasks = [Tasks]()              //All the notes
var tasksToDisplay = [Tasks]()        //All the notes to display

class HomePageVC: UIViewController, passDataToVCDelegate, homeHeaderMessageDelegate {
    
    @IBOutlet var collection: UICollectionView!
    @IBOutlet var table: UITableView!
    @IBOutlet var addButton: UIButton!
    @IBOutlet var settingsButton: UIButton!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    
    //Delegate from the NewNotePage. adds a new entry into the allTasks array
    func passData(data: Tasks) {
        //Add to array
        allTasks.append(data)
    }
    
    func message() {
        if allTasks.count == 0{
            subtitleLabel.text = "No tasks this week!"
        }
        else{
            subtitleLabel.text = "Lets get some tasks done today!"
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Add a gradient to the home page
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1).cgColor, UIColor(red: 46/255, green: 46/255, blue: 46/255, alpha: 1).cgColor]
        gradient.locations = [0,1]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)
        gradient.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        self.view.layer.insertSublayer(gradient, at: 0)
        
        //Set up the table
        setupTable()
        
        //Set up the collection
        setupCollection()
        
        //Set up the add button
        setupAddButton()
        
        //Set up the settings button
        setupSettingButton()
        
        //Set up the title labels
        setupTitleLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Set up the array of day names
        fillInDayData()
        
        //Load up the data from core
        let fetchTasksRequest: NSFetchRequest<Tasks> = Tasks.fetchRequest()
        do{
            let fetchTasksData = try PersistenceService.context.fetch(fetchTasksRequest)
            //Fetch the data and delete old tasks
            allTasks = fetchTasksData
            deleteOldTasks()
            
        }
        catch{
            print("ERROR: Could not load saved data")
        }
        
        //Set up the subtitle label
        //If there are no notes, then display a message. Otherwise, display a different message
        if allTasks.count == 0{
            subtitleLabel.text = "No tasks this week!"
        }
        else{
            subtitleLabel.text = "Lets get some tasks done today!"
        }

    }
    
    //Delete old tasks
    fileprivate func deleteOldTasks(){
        //Delete any tasks from previous days
        if !allTasks.isEmpty{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy-"
            let todaysDate = Date().dayBefore         //Yesterday's date in Date type
            var i = 0
            
            for tasks in allTasks{

                if let dateOfTask = dateFormatter.date(from: String((tasks.dayDate?.prefix(10))!)) { //Date of task in Date type
                    //If a task has multiple days. Cherry pick out the first date in the encoding if the day has passed
                    
                    if tasks.dayDate!.count > 11 && dateOfTask < todaysDate {
                        
                        //Create a replacement entry
                        let replacementEntry: Tasks = Tasks(context: PersistenceService.context)
                        replacementEntry.day = tasks.day
                        replacementEntry.subject = tasks.subject
                        replacementEntry.dayDate = String(tasks.dayDate!.substring(from: 11))
                        
                        //Delete from model
                        let tasksToDelete = allTasks[i]

                        allTasks.remove(at: i)
                        allTasks.append(replacementEntry)
                        
                        //Delete from core data
                        PersistenceService.context.delete(tasksToDelete)
                        PersistenceService.saveContext()
                        
                    }
                    //If the date of the task is before today's date, delete it from core
                    else if dateOfTask < todaysDate{
                        //Delete from core
                        PersistenceService.context.delete(tasks)
                        PersistenceService.saveContext()
                        
                        //Delete from view
                        allTasks.remove(at: i)
                        i -= 1
                    }
                }
                
                i += 1
                
                
                
                
            }
            
        }
    }
    
    
    
    // MARK: segue or any data passing
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Connect the two view controller
        if segue.identifier == "showNewEntryPage"{
            let sendingVC: NewNotePageVC = segue.destination as! NewNotePageVC
            sendingVC.delegate1 = self
            sendingVC.delegate2 = self
        }
        
        //Initialize the titleText to be able to print the title in the next scene
        else if segue.identifier == "showNotes"{
            if let destination = segue.destination as? ShowNotesPageVC{
                let IndexPath = table.indexPathForSelectedRow!
                destination.titleText = tasksToDisplay[IndexPath.row].subject
            }
        }

    }
    
    @IBAction func unwindToHome( sender: UIStoryboardSegue){}

    
    // MARK: setting up the view functions
    //Fill in the daysToDisplayOnCollection array appropriately.
    //By appropriate, it means that the array will hold the names of the days of the week starting from Today.
    fileprivate func fillInDayData(){
        
        for i in 0...6{
            daysToDisplayOnCollection[i].name = getDayName(i)
            daysToDisplayOnCollection[i].dayDate = getDayValue(i)
        }
    
        
    }

    //Set up the title labels
    fileprivate func setupTitleLabel(){
        subtitleLabel.textColor = .white
        titleLabel.textColor = .white
    }
    
    //Set up the table
    fileprivate func setupTable(){
        table.delegate = self
        table.dataSource = self
        table.layer.cornerRadius = 30
        table.backgroundColor = UIColor(red: 80/255, green: 80/255, blue: 80/255, alpha: 0.7)
    }
    
    //Set up the setting button
    fileprivate func setupSettingButton(){
        settingsButton.imageView?.tintColor = .darkGray
        settingsButton.layer.cornerRadius = 27.5
        settingsButton.alpha = 0.8
        settingsButton.backgroundColor = UIColor(red: 162/255 , green: 151/255, blue: 151/255, alpha: 0.9)
    }
    
    //Set up the collection
    fileprivate func setupCollection(){
        collection.delegate = self
        collection.dataSource = self
        collection.showsHorizontalScrollIndicator = false
        collection.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        
        //Apply a dynamic top and height anchor to the collection view
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.topAnchor.constraint(equalTo: view.topAnchor, constant: UIScreen.main.bounds.height / 5.1).isActive = true
        collection.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height / 4.5).isActive = true
    }
    
    //Set up the add button
    fileprivate func setupAddButton(){
        addButton.imageView?.tintColor = .darkGray
        addButton.layer.cornerRadius = 27.5
        addButton.alpha = 0.8
        addButton.backgroundColor = UIColor(red: 162/255 , green: 151/255, blue: 151/255, alpha: 0.9)
    }
    

}


// MARK: helper functions for date
extension HomePageVC{
    //Get the date string currently
    func getDate() -> String{
        let date = Date()
        let formatter = DateFormatter()
        formatter.timeZone = .autoupdatingCurrent
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: date)
    }
    
    //Get the next date based on the value incremented
    func getNextDate(_ increment: Int) -> Date{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let myDate = dateFormatter.date(from: getDate())!
        let tomorrow = Calendar.current.date(byAdding: .day, value: increment, to: myDate)
        
        return tomorrow!
    }
    
    //Get the date string based on the day of reference
    func getDayValue(_ increment: Int) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let somedateString = dateFormatter.string(from: getNextDate(increment))
        return somedateString
    }
    
    //Get the date name based on the day of reference
    func getDayName(_ increment: Int) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let dayInWeek = dateFormatter.string(from: getNextDate(increment))
        
        if increment == 0{
            return "Today"
        }
        return dayInWeek
    }
}

// MARK: set up the collection view
extension HomePageVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    //Set up the cells
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "datacell", for: indexPath) as! HomePageCollectionCell
        
        //Keep the changes when being loaded in
        if daysToDisplayOnCollection[indexPath.row].clicked == true{
            cell.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            cell.backView.backgroundColor = UIColor.applyDarkGray()
        }
        else{
            cell.transform = .identity
            cell.backView.backgroundColor = UIColor.applyPurpleColor()
        }
        
        //Configure the cell
        cell.dayLabel.text = daysToDisplayOnCollection[indexPath.row].name
        cell.dateLabel.text = indexPath.row != 7 ? daysToDisplayOnCollection[indexPath.row].dayDate : ""
        cell.dayLabel.textColor = .darkGray
        cell.dateLabel.textColor = .darkGray
        cell.layer.cornerRadius = 20
        
        /*
        //Change the status image of the cell if there is a task
        for notes in allTasks{
            print("-" + (cell.dayLabel.text?.prefix(2))! + "-")
            print(notes.day!)
            if notes.day!.contains((cell.dayLabel.text?.prefix(2))! + "-"){

                cell.statusImage.image = UIImage(systemName: "exclamationmark")
            }
            
        }
        */
        return cell
    }
    
    //Return the number of cells/items
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return daysToDisplayOnCollection.count
    }
    
    //Change the size of the cell in relation to the cpllection views size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let dim = collection.bounds.height / 1.3
        return CGSize(width: dim, height: dim)
    }
    
    //Change the color of the cell when clicked to indicate being clicked
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! HomePageCollectionCell
        
        if daysToDisplayOnCollection[indexPath.row].clicked == false{
            daysToDisplayOnCollection[indexPath.row].clicked = true
            cell.backView.backgroundColor = UIColor.applyDarkGray()
            
            //Change size and color
            UIView.animate(withDuration: 0.4, delay: 0.07, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn) {
                cell.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }
            
            //Filter the notes to only print the right one
            if !allTasks.isEmpty{
                filterNotes(status: daysToDisplayOnCollection[indexPath.row].clicked, day: daysToDisplayOnCollection[indexPath.row].dayDate)
            }
            
        }
        else{
            cell.backView.backgroundColor = UIColor.applyPurpleColor()
            daysToDisplayOnCollection[indexPath.row].clicked = false
            
            //Return size and color to normal
            UIView.animate(withDuration: 0.4, delay: 0.07, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn) {
                cell.transform = .identity
            }
            if !allTasks.isEmpty{
                filterNotes(status: daysToDisplayOnCollection[indexPath.row].clicked, day: daysToDisplayOnCollection[indexPath.row].dayDate)
            }
        }
    }
    
    func filterNotes(status s: Bool, day d: String){
        //Update the table by adding if cell is selected
        if s {
            for tasks in allTasks{
                if tasks.subject != nil{
                    //Check if it is the right date and is not a duplicate of already added tasks
                    if tasks.dayDate!.contains(d + "-") && !tasksToDisplay.contains(tasks){
                        //Update the view and the model on main thread
                        DispatchQueue.main.async {
                            tasksToDisplay.append(tasks)
                            let indexPath = IndexPath(row: tasksToDisplay.count - 1, section: 0)
                            self.table.insertRows(at: [indexPath], with: .fade)
                        }
                    }
                }


            }

        }
        //Update the table by deleting if cell is selected
        else{
            var i = 0
            //var timesFound = 0
            for tasks in tasksToDisplay{
                if tasks.dayDate!.contains(d + "-"){
                    //Remove from model
                    tasksToDisplay.remove(at: i)
                    
                    //Remove from view
                    let indexPath = IndexPath(row: i, section: 0)
                    table.deleteRows(at: [indexPath], with: .fade)
                    i -= 1
                }
                //If a task has more than one day selected, then remove it from view if all the days associated with the task are unclicked
                /*
                if tasks.day!.count > 3{
                    print("hi")
                    for days in daysToDisplayOnCollection{
                        if !days.clicked && tasks.day!.contains(days.name.prefix(2) + "-"){
                            timesFound += 1
                            if timesFound > 1{
                                tasksToDisplay.remove(at: i)
                                
                                //Remove from view
                                let indexPath = IndexPath(row: i, section: 0)
                                table.deleteRows(at: [indexPath], with: .fade)
                                
                                //Once the deletion operation is done, update i and leave the loop
                                i -= 1
                                break
                            }
                        }
                    }
                }
                */

                i += 1
            }
        }
         
    }
}

// MARK: set up the table view
extension HomePageVC: UITableViewDelegate, UITableViewDataSource{
    
    //Set up the cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "datacell", for: indexPath)
        
        cell.textLabel?.text = tasksToDisplay[indexPath.row].subject
        cell.textLabel?.textColor = .white
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor(red: 80/255, green: 80/255, blue: 80/255, alpha: 0.7)
        
        return cell
    }
    
    //Return the number of cells/rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasksToDisplay.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    //Add a swipe action so when the user swipes, it allows them to delete the cells
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        //Create the action
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { (action, view, complete) in
            //Delete from core data
            let itemToDelete = tasksToDisplay[indexPath.row]
            PersistenceService.context.delete(itemToDelete)
            PersistenceService.saveContext()
            
            //Delete from view
            tasksToDisplay.remove(at: indexPath.row)
            allTasks.remove(at: indexPath.row)
            self.table.deleteRows(at: [indexPath], with: .fade)
            
            complete(true)
        }
        
        //Customize the action
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .red
        
        let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeConfig
    }
}
