//
//  ReminderDetails.swift
//  ManageMyReminders
//

import UIKit
import EventKit

class ReminderDetails: UIViewController {

    @IBOutlet var dateTextField: UITextField!
    
    var datePicker: UIDatePicker!
    var reminder: EKReminder!
    var eventStore: EKEventStore!

    @IBOutlet weak var reminderTextView: UITextView!

    @IBAction func saveReminder(sender: AnyObject) {
        self.reminder.title = reminderTextView.text
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let dueDateComponents = appDelegate.dateComponentFromNSDate(self.datePicker.date)
        reminder.dueDateComponents = dueDateComponents
        reminder.calendar = self.eventStore.defaultCalendarForNewReminders()
        
        do {
            try self.eventStore.saveReminder(reminder, commit: true)
            self.navigationController?.popToRootViewControllerAnimated(true)
        }catch{
            print("Error creating and saving new reminder : \(error)")
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.reminderTextView.text = self.reminder.title
        datePicker = UIDatePicker()
        datePicker.addTarget(self, action: "addDate", forControlEvents: UIControlEvents.ValueChanged)
        datePicker.datePickerMode = UIDatePickerMode.Date
        dateTextField.inputView = datePicker
        reminderTextView.becomeFirstResponder()
        
        let formatter:NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let dueDate = reminder.dueDateComponents?.date {
            dateTextField?.text = formatter.stringFromDate(dueDate)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addDate(){
        let formatter:NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        self.dateTextField.text = formatter.stringFromDate(self.datePicker.date)
    }
}
