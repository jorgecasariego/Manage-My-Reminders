//
//  NewReminder.swift
//  ManageMyReminders
//
import UIKit
import EventKit

class NewReminder: UIViewController {

    @IBOutlet weak var reminderTextView: UITextView!
    @IBOutlet var dateTextField: UITextField!
    
    var eventStore: EKEventStore!
    var datePicker: UIDatePicker!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Cargamos un datePicker cuando clickeamos sobre el text field
        datePicker = UIDatePicker()
        // 2. Cada vez que la fecha es cambiada en el datePicker vamos a llamar a la funcion addDate()
        datePicker.addTarget(self, action: "addDate", forControlEvents: UIControlEvents.ValueChanged)
        datePicker.datePickerMode = UIDatePickerMode.DateAndTime
        dateTextField.inputView = datePicker
        reminderTextView.becomeFirstResponder()
    }
    
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Este metodo va a estar atado al boton Cancel a la izquierda del navigation bar
    @IBAction func dismiss(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addDate() {
        let formatter:NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        // Asignamos la fecha del date picker al text field
        self.dateTextField.text = formatter.stringFromDate(self.datePicker.date)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
