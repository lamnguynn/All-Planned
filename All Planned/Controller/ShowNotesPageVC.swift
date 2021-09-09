//
//  ShowNotesPageVC.swift
//  All Planned
//
//  Created by Lam Nguyen on 1/31/21.
//

import UIKit
import CoreData

class ShowNotesPageVC: UIViewController {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var textView: UITextView!
    @IBOutlet var backView: UIView!
    @IBOutlet var clearButton: UIButton!
    
    var titleText: String!
    var savedNote = [Note]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Change color to the theme
        view.backgroundColor = .black
        textView.backgroundColor = .black
        textView.textColor = .white
        
        //Set up the title label
        titleLabel.text = titleText
        
        //Set up the head back view
        backView.backgroundColor = UIColor.applyPurpleColor()
        backView.layer.cornerRadius = 70
        
        //Set up the clear button
        clearButton.layer.cornerRadius = 30
        clearButton.backgroundColor = UIColor.applyPowderRedColor()
        
        //Set up the text view
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        do{
            let fetchedNotesData = try PersistenceService.context.fetch(fetchRequest)
            savedNote = fetchedNotesData
            
            //find the appropriate note that correlates with the title
            if !savedNote.isEmpty{
                for i in savedNote{
                    if titleText == i.taskName{
                        textView.text = i.noteText
                    }
                }
            }
        }
        catch{
            print("ERROR: Could not load saved data")
        }
    }
    
    //Perform the segue animation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "unwindFromShowNotes"{
            //Set up unwind segue animation
            let xmarkButton = sender as! UIButton
            (segue as? PageSegueAnimation)?.circleOrigin = xmarkButton.center
            
            //Hide keyboard if up
            view.endEditing(true)
        }
    }
    
    //Dismiss the keyboard when clicking on the view
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    //Once the view controller is dismissed, save the notes to core data
    override func viewWillDisappear(_ animated: Bool) {
        if isBeingDismissed && textView.text != ""{
            //Delete the previous entry
            if !savedNote.isEmpty{
                let notePreviousToDelete = savedNote[0]
                PersistenceService.context.delete(notePreviousToDelete)
                PersistenceService.saveContext()
            }
            
            //Add the new entry
            let notesEntry = Note(context: PersistenceService.context)
            notesEntry.noteText = textView.text
            notesEntry.taskName = titleText
            
            PersistenceService.saveContext()
        }
        //Handle case where user deletes the entire text manually
        else if isBeingDismissed && textView.text == ""{
            if !savedNote.isEmpty{
                let notePreviousToDelete = savedNote[0]
                PersistenceService.context.delete(notePreviousToDelete)
                savedNote.remove(at: 0)
                PersistenceService.saveContext()
            }
        }
    }
    
    //Clear the text when button is clicked
    @IBAction func clearClicked(_ sender: Any){
        
        //Clear the text visually
        textView.text = nil
        
        //Clear the text from core data
        if !savedNote.isEmpty{
            let noteToDelete = savedNote[0]
            PersistenceService.context.delete(noteToDelete)
            savedNote.remove(at: 0)
            PersistenceService.saveContext()
        }
        
    }


}
