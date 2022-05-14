//
//  CalendarViewController.swift
//  CalendarApp
//
//  Created by Arun on 13/05/22.
//

import UIKit
import FSCalendar

final class CalendarViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FSCalendarDataSource, FSCalendarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    private var notificationDetails = [String: [String]]()
    private var array = (10...60).map { $0 }
    private var dateToolBar = UIToolbar()
    private var datePicker  = UIDatePicker()
    private var toolBar = UIToolbar()
    private var picker  = UIPickerView()
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let alert = UIAlertController(title: "Event", message: "Time", preferredStyle: .alert)
    private var selectedDate = ""
    private var minutes = 0
    private var eventName = ""
    private var selectedTime = ""
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.calendar.select(Date())
        self.calendar.scope = .month
        self.calendar.accessibilityIdentifier = "calendar"
        picker = UIPickerView.init()
        picker.delegate = self
        picker.dataSource = self
        picker.backgroundColor = UIColor.white
        picker.setValue(UIColor.black, forKey: "textColor")
        picker.autoresizingMask = .flexibleWidth
        picker.contentMode = .center
        picker.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 300)
        toolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 50))
        toolBar.barStyle = .default
        toolBar.items = [UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(onDoneButtonTapped))]
        
        datePicker = UIDatePicker.init()
        datePicker.backgroundColor = UIColor.white
        datePicker.autoresizingMask = .flexibleWidth
        datePicker.datePickerMode = .time
        
        dateFormatter.dateFormat = "hh:mm a"
        datePicker.addTarget(self, action: #selector(self.dateChanged(_:)), for: .valueChanged)
        datePicker.frame = CGRect(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 300)
        
        dateToolBar = UIToolbar(frame: CGRect(x: 0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 50))
        dateToolBar.items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.dateToolBaronDoneButtonClick))]
        dateToolBar.sizeToFit()
        
        alert.addTextField { (textField) in
            textField.placeholder = "Event name"
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Remainder time"
            textField.inputView = self.picker
            textField.inputAccessoryView = self.toolBar
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Time"
            textField.inputView = self.datePicker
            textField.inputAccessoryView = self.dateToolBar
        }
        
        alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { [weak alert] (_) in
            if let textField = alert?.textFields?[0], let userText = textField.text , self.minutes != 0 , self.selectedTime != "", self.selectedDate != "" {
                self.eventName = userText
                let dateString = self.selectedDate + " " + self.selectedTime
                self.dateFormatter.dateFormat = "yyyy/MM/dd hh:mm a"
                let date = self.dateFormatter.date(from: dateString)
                let remainderDate = date?.minus(minutes: self.minutes)
                let identifier = UUID()
                
                var notificationValues = [String]()
                let eventString  = "Event name : \(self.eventName)  Time: \(self.selectedTime)"
                if let value = self.notificationDetails[self.selectedDate] {
                    notificationValues = value
                    notificationValues.append(eventString)
                    print("notificationValues",notificationValues.count)
                    self.notificationDetails[self.selectedDate] = notificationValues
                } else {
                    self.notificationDetails[self.selectedDate] = [eventString]
                }
                
                self.tableView.reloadData()
                self.appDelegate.scheduleNotification(at: remainderDate ?? Date(), title: "Remainder", body: "Your have \(self.eventName) event", id: identifier.uuidString)
            } else {
                // Create the alert controller
                let alertController = UIAlertController(title: "Alert", message: "Please enter all details", preferredStyle: .alert)
                
                // Create the actions
                let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                    UIAlertAction in
                }
                
                // Add the actions
                alertController.addAction(okAction)
                
                // Present the controller
                self.present(alertController, animated: true, completion: nil)
            }
            
        }))
        
        // Create the actions
        let okAction = UIAlertAction(title: "Close", style: UIAlertAction.Style.default) {
            UIAlertAction in
        }
        
        // Add the actions
        alert.addAction(okAction)
    }
    
    deinit {
        print("\(#function)")
    }
    
    @objc func dateChanged(_ sender: UIDatePicker?) {
        dateFormatter.dateFormat = "hh:mm a"
        if let date = sender?.date {
            alert.textFields?[2].text = dateFormatter.string(from: date)
            selectedTime = dateFormatter.string(from: date)
        }
    }
    
    @objc func dateToolBaronDoneButtonClick()
    {
        alert.textFields?[2].resignFirstResponder()
    }
    
    @objc func onDoneButtonTapped()
    {
        alert.textFields?[1].resignFirstResponder()
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendarHeightConstraint.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        dateFormatter.dateFormat = "yyyy/MM/dd"
        let dateString = self.dateFormatter.string(from: date)
        selectedDate = dateString
        if monthPosition == .next || monthPosition == .previous {
            calendar.setCurrentPage(date, animated: true)
        }
        alert.textFields?[0].text = ""
        alert.textFields?[1].text = ""
        alert.textFields?[2].text = ""
        minutes = 0
        selectedTime = ""
        eventName = ""
        tableView.reloadData()
        self.present(alert, animated: true, completion: nil)
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        print("\(self.dateFormatter.string(from: calendar.currentPage))")
    }
    
    // MARK:- UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return notificationDetails[selectedDate]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"NotificationTableViewCell") as! NotificationTableViewCell
        cell.title.text = notificationDetails[selectedDate]?[indexPath.row] ?? ""
        return cell
    }
    
    // MARK:- UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    // MARK:- Target actions
}

extension CalendarViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return array.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(array[row]) Mins"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        alert.textFields?[1].text = "\(array[row]) Mins"
        minutes = array[row]
    }
}
