//
//  DetailsViewController.swift
//  realmToDoList-Swift
//
//  Created by Matheus on 18/07/17.
//  Copyright © 2017 Matheus Tavares. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class DetailsViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var prioritySelector: UISegmentedControl!

    var task = Task()
    var isEditingTask = false

    var parentView = ListViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        realm = try! Realm()
        
        self.nameTextField.delegate = self
        self.hideKeyboardWhenTappedAround()

        if(!isEditingTask) {
            self.title = "New Task"
        }else{
            self.nameTextField.text = task.name
            self.prioritySelector.selectedSegmentIndex = task.priority
        }
    }


    @IBAction func saveButton(_ sender: Any) {

        var name = ""

        if(nameTextField.text! == "") {
            name = "No name"
        } else {
            name = nameTextField.text!
        }

        saveTask(name: name, priority: prioritySelector.selectedSegmentIndex)

    }

    func saveTask(name: String, priority: Int) {

        if(isEditingTask) {
            
            try! realm.write {
                self.task.name = name
                self.task.priority = priority
                realm.create(Task.self,value:self.task,update:true)

            }

            parentView.message = "Task updated!"
        } else {

            try! realm.write {
                self.task.name = name
                self.task.priority = priority
                
                realm.create(Task.self,value:self.task)

            }
            parentView.message = "Task created!"
        }

        self.performSegueToReturnBack()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }


}

