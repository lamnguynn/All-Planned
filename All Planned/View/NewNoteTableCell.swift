//
//  NewNoteTableCell.swift
//  All Planned
//
//  Created by Lam Nguyen on 1/31/21.
//

import UIKit

protocol changeStatusDelegate: AnyObject {
    func changeStatus(cell: NewNoteTableCell)
}

class NewNoteTableCell: UITableViewCell {
    
    weak var delegate: changeStatusDelegate?
    
    @IBOutlet var dayButton: UIButton!
    @IBOutlet var statusImage: UIImageView!
    @IBOutlet var backView: UIView!
    
    @IBAction func dayButtonClicked(_ sender: Any){
        delegate?.changeStatus(cell: self)
    }
    
    
}
