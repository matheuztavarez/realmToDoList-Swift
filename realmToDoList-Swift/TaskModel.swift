//
//  TaskModel.swift
//  realmToDoList-Swift
//
//  Created by Matheus on 18/07/17.
//  Copyright © 2017 Matheus Tavares. All rights reserved.
//
import RealmSwift

// Task model
class Task: Object {
    dynamic var id = NSUUID().uuidString
    dynamic var name = ""
    dynamic var priority = 0 //0=Low / 1=Medium / 2=High
    dynamic var created_at = Date()
    dynamic var completed = false
    dynamic var completed_at = Date()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

