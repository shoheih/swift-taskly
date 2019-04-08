//
//  TaskStore.swift
//  Taskly
//
//  Created by 林将平 on 2019/04/07.
//  Copyright © 2019 Shohei Hayashi. All rights reserved.
//

import Foundation

class TaskStore {
    
    var tasks = [[Task](), [Task]()]
    
    func add(_ task: Task, at index: Int, isDone: Bool = false) {
        
        let section = isDone ? 1 : 0
        
        tasks[section].insert(task, at: index)
    }
    
    @discardableResult func removeTask(at index: Int, isDone: Bool = false) -> Task {
        
        let section = isDone ? 1 : 0
        
        return tasks[section].remove(at: index)
    }
}
