//
//  TaskCellModel.swift
//  realmToDoList-Swift
//
//  Created by Matheus on 18/07/17.
//  Copyright © 2017 Matheus Tavares. All rights reserved.
//

import Foundation
import UIKit
import SwipyCell
import RealmSwift

class TaskCell: SwipyCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priorityLabel: UILabel!
    
    var task = Task()
    
    override func awakeFromNib() {
        super.awakeFromNib()
//      self.task = Task()  
    }
    

    func bind(_ task: Task){
        
        self.task = task
        
        self.nameLabel.text = task.name
        
        switch self.task.priority{
        case 0:
            self.priorityLabel.text = "Low Priority"
            self.priorityLabel.textColor = greenColor
            break
        case 1:
            self.priorityLabel.text = "Medium Priority"
            self.priorityLabel.textColor = tangerineColor
            break
        case 2:
            self.priorityLabel.text = "High Priority"
            self.priorityLabel.textColor = redColor
            break
        default:
            break
        }
    }
    
}
