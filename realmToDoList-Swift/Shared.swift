//
//  Shared.swift
//  realmToDoList-Swift
//
//  Created by Matheus on 18/07/17.
//  Copyright © 2017 Matheus Tavares. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import Toaster

public let lightBlueColor = UIColor(red: 0, green: 187/255, blue: 204/255, alpha: 1.0)

var realm = try! Realm()

var taskList = [Results<Task>]()
var searchedTasks = [Results<Task>]()

let greenColor = UIColor(red: 0, green: 128/255, blue: 0, alpha: 1)
let tangerineColor = UIColor(red: 255/255, green: 128/255, blue: 0, alpha: 1)
let redColor = UIColor(red: 255/255, green: 0, blue: 0, alpha: 1)

func objectForIndexPath(indexPath: IndexPath,selectedScope:Int,filtered:Bool) -> Task? {
    if(filtered){
        return searchedTasks[selectedScope][indexPath.row]
    }
    return taskList[selectedScope][indexPath.row]
}

func presentYesNoAlert(title: String, message: String, view: UIViewController, yesHandler: ((UIAlertAction) -> Void)?, noHandler: ((UIAlertAction) -> Void)?) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
    let yesAction = UIAlertAction(title: "Yes", style: .destructive, handler: yesHandler)
    
    let noAction = UIAlertAction(title: "No", style: .cancel, handler: noHandler)
    
    alertController.addAction(yesAction)
    
    alertController.addAction(noAction)
    
    view.present(alertController, animated: true, completion: nil)
}

func viewWithImageName(_ imageName: String) -> UIView {
    let image = UIImage(named: imageName)
    let imageView = UIImageView(image: image)
    imageView.contentMode = .center
    return imageView
}

extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func performSegueToReturnBack() {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

public func showToast(_ show: String) {
    Toast(text: show, duration: Delay.short).show()
}
