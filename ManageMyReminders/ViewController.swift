//
//  ViewController.swift
//  ManageMyReminders
//

import UIKit
import EventKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    @IBOutlet var tableView: UITableView!
    
    // 1. Propiedad que representa una referencia a la BD del calendario
    var eventStore: EKEventStore!
    
    // 2. Array en el que almacenaremos todos los recordatorios consultados antes de poblarlos en el tableView
    var reminders: [EKReminder]!

    // 6. Propieda que almacenara el recordario seleccionado
    var selectedReminder: EKReminder!
    
    override func viewWillAppear(animated: Bool) {
        
        // 3. Obtenemos todos los recordatorios almacenados en la BD de nuestro calendario
        self.eventStore = EKEventStore()
        self.reminders = [EKReminder]()
        
        // 4: Before you access the reminders in the event store, you need to get the user permission. The requestAccessToEntityType API will run asynchronously and call the completion block when the request is completed. The block will pass two arguments, the first to check whether the user has given permission to the app to access the reminders, and the second will store an error object for a backtrace if something went wrong during the operation.
        self.eventStore.requestAccessToEntityType(EKEntityType.Reminder) { (granted: Bool, error: NSError?) -> Void in
            
            if granted {
                // 5: Once permission is granted to the app, it will fetch all reminders asynchronously and return the results in a completion block as well. At that time, you assign the reminders objects to the array property and reload the table view to populate the data.
                let predicate = self.eventStore.predicateForRemindersInCalendars(nil)
                self.eventStore.fetchRemindersMatchingPredicate(predicate, completion: { (reminders: [EKReminder]?) -> Void in
                    self.reminders = reminders
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.tableView.reloadData()
                    })
                })
            } else {
                print("The app is not permitted to access reminders, make sure to grant permission in the settings and try again")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }

    @IBAction func editTable(sender: AnyObject) {
        tableView.editing = !tableView.editing
        
        if tableView.editing {
            tableView.setEditing(true, animated: true)
        } else {
            tableView.setEditing(false, animated: true)
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Agregar un nuevo recordatorio
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ShowReminderDetails" {
            let reminderDetailsVC = segue.destinationViewController as! ReminderDetails
            reminderDetailsVC.reminder = self.selectedReminder
            reminderDetailsVC.eventStore = eventStore
        } else {
            let newReminderVC = segue.destinationViewController as! NewReminder
            newReminderVC.eventStore = eventStore

        }
    }
    
    // MARK: - TableView
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.reminders.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell! = tableView.dequeueReusableCellWithIdentifier("reminderCell")
        
        let reminder:EKReminder! = self.reminders![indexPath.row]
        
        cell.textLabel?.text = reminder.title
        
        let formatter:NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        if let dueDate = reminder.dueDateComponents?.date {
            cell.detailTextLabel?.text = formatter.stringFromDate(dueDate)
        } else {
            cell.detailTextLabel?.text = "N/A"
        }
        
        return cell
    }
    
    // Borrar un recordatorio
    // 1. first get the EKReminder object in the selected row
    // 2. then try to remove it from the event store (and hence from the Calendar database).
    // 3. If the reminder is removed successfully and the data are synchronized with the Calendar database, you then remove the EKReminder object from the table view and its data source array.
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        
        let reminder: EKReminder = reminders[indexPath.row]
        
        do{
            try eventStore.removeReminder(reminder, commit: true)
            self.reminders.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        } catch {
            print("An error occurred while removing the reminder from the Calendar database: \(error)")
        }
    }
    
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        self.selectedReminder = self.reminders[indexPath.row]
        self.performSegueWithIdentifier("ShowReminderDetails", sender: self)
    }
    
    
}

