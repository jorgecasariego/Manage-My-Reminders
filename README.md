# Manage-My-Reminders
Event Kit framework is designed to grant developers access to data generated by both Calendar and Reminders system apps. The framework provides a set of API to manipulate the Calendar database, that same database which store all Calendar/Reminders informations of our iOS devices.

![alt text](https://github.com/jorgecasariego/Manage-My-Reminders/blob/master/screenshots/eventkit.jpg "EventKit")


The power side of Event Kit is that it allows, not only to read your reminders and events data from within your app, but also it grants you access to manage such data, whether by deleting, adding, or editing Calendar and Reminders app informations.

**Request Access to Reminder**

```swift
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
           
```

![alt text](https://github.com/jorgecasariego/Manage-My-Reminders/blob/master/screenshots/screen1.png "EventKit")

**Save Data**

```swift
    // Guardamos el nuevo recordatorio al calendario
    // 1: This will create a new EKReminder instance with the event store property you previously passed to the view controller. Then it will set the title, dueDateComponents and calendar properties of the reminder with the relevant values. Note that you used a helper method called dateComponentFromNSDate to convert the UIDatePicker NSDate content to an NSDateComponents object and assign it to the dueDateComponents property.
    
    // 2: Every Calendar database operation is done by the event store. Here, you just used the saveReminder API with the EKReminder object in argument. The API will try to save the reminder and if it succeeds, the screen will be dismissed to reveal the root view with all the current and new reminders in the table view.
    @IBAction func saveNewReminder(sender: AnyObject) {
        
        // 1.
        let reminder = EKReminder(eventStore: self.eventStore)
        reminder.title = reminderTextView.text
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let dueDateComponents = appDelegate.dateComponentFromNSDate(self.datePicker.date)
        reminder.dueDateComponents = dueDateComponents
        reminder.calendar = self.eventStore.defaultCalendarForNewReminders()
        
        
        // 2.
        do {
            try self.eventStore.saveReminder(reminder, commit: true)
            dismissViewControllerAnimated(true, completion: nil)
        } catch {
            print("Error creating and saving new reminder : \(error)")
        }
    }
```

![alt text](https://github.com/jorgecasariego/Manage-My-Reminders/blob/master/screenshots/screen2.png "EventKit")

![alt text](https://github.com/jorgecasariego/Manage-My-Reminders/blob/master/screenshots/screen3.png "EventKit")

**Delete reminder**

```swift
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
```

![alt text](https://github.com/jorgecasariego/Manage-My-Reminders/blob/master/screenshots/screen4.png "EventKit")

![alt text](https://github.com/jorgecasariego/Manage-My-Reminders/blob/master/screenshots/screen6.png "EventKit")
