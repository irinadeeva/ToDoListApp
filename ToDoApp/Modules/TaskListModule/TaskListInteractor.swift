//
//  TaskListInteractor.swift
//
//  Created by Irina Deeva on 29/11/24
//

import Foundation

protocol TaskListInteractorInput: AnyObject {
  func fetchTasks()
  func updateTaskItem(_ taskItem: TaskItem)
  func deleteTaskItem(_ taskItem: TaskItem)
}

protocol TaskListInteractorOutput: AnyObject {
  func didFetchTasks(_ tasks: [TaskItem])
  func didFetchTask(_ task: TaskItem)
  func didFetchId(_ taskId: UUID)
  func didFailToFetchTasks(with error: Error)
}

final class TaskListInteractor: TaskListInteractorInput {
  weak var output: TaskListInteractorOutput?

  func fetchTasks() {
    TaskService.shared.loadTaskItems { [weak self] result in
      switch result {
      case .success(let tasks):

        let sortedTasks = tasks.sorted { (task1, task2) -> Bool in
          if let date1 = task1.createdAt, let date2 = task2.createdAt {
            return date1 < date2
          }
          else if task1.createdAt == nil {
            return false
          } else {
            return true
          }
        }

        self?.output?.didFetchTasks(sortedTasks)
      case .failure(let error):
        self?.output?.didFailToFetchTasks(with: error)
      }
    }
  }

  func updateTaskItem(_ taskItem: TaskItem) {
    TaskService.shared.updateTaskItem(taskItem) { [weak self] result in
      switch result {
      case .success(let task):
        self?.output?.didFetchTask(task)
      case .failure(let error):
        self?.output?.didFailToFetchTasks(with: error)
      }
    }
  }

  func deleteTaskItem(_ taskItem: TaskItem) {
    TaskService.shared.deleteTaskItem(taskItem) { [weak self] result in
      switch result {
      case .success(let id):
        self?.output?.didFetchId(id)
      case .failure(let error):
        self?.output?.didFailToFetchTasks(with: error)
      }
    }
  }
}
