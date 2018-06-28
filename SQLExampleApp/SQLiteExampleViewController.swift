//
//  SQLiteExampleViewController.swift
//  KpOli
//
//  Created by Mac on 6/28/18.
//  Copyright © 2018 ShiranTech. All rights reserved.
//

import UIKit
import SQLite3

class SQLiteExampleViewController: UIViewController {
    
    private final let TAG = "SQLiteExampleViewController"
    
    var db: OpaquePointer?
    
    
    //Mark outlets
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var powerRankTextField: UITextField!
    
    
    @IBOutlet weak var outputTextView: UITextView!
    
    
    @IBOutlet weak var deleteIdTextField: UITextField!
   
    @IBOutlet weak var updateIdTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //the database file
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("RecenDatabase.sqlite")
        
        //opening the database
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        
        //creating table
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Heroes (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, name TEXT, powerrank INTEGER)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
        
        getOutput()
        
    }
    
    func insert() {
        var insertStatement: OpaquePointer? = nil
         let insertStatementString = "INSERT INTO Heroes (name, powerrank) VALUES (?, ?);"
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {

            AppLog.showLog(tag: "", message: "Name is: \(nameTextField.text!) & power Rank is: \(powerRankTextField.text)")
            sqlite3_bind_text(insertStatement, 1, (nameTextField.text! as NSString).utf8String, -1, nil)
            
            sqlite3_bind_int64(insertStatement, 2, sqlite3_int64(powerRankTextField.text!)!)
            
            // 4
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted row.")
            } else {
                print("Could not insert row.")
            }
        } else {
            print("INSERT statement could not be prepared.")
        }
        // 5
        sqlite3_finalize(insertStatement)
        getOutput()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func getOutput() {
        var queryStatement: OpaquePointer? = nil
        let getList = "SELECT * FROM Heroes"
        outputTextView.text = ""
        if sqlite3_prepare_v2(db, getList, -1, &queryStatement, nil) == SQLITE_OK {
            // 2
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                let id = sqlite3_column_int(queryStatement, 0)
                
                let queryResultCol2 = sqlite3_column_int(queryStatement, 2)
                let name = String(cString: sqlite3_column_text(queryStatement, 1))
                // 5
                print("Query Result:")
                print("\(id) | \(name) | \(queryResultCol2)")
                outputTextView.text.append(String(id)+"->"+name+"->"+String(queryResultCol2)+"\n")
                }
            } else {
                print("Query returned no results")
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
    }
    
    func update() {
        let updateStatementString = "UPDATE Heroes SET name = "+"'"+nameTextField.text!+"'"+" , powerrank = "+powerRankTextField.text!+" WHERE id = "+updateIdTextField.text!+";"
        AppLog.showLog(tag: TAG, message: "\(updateStatementString)")
        
        var updateStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                print("Successfully updated row.")
            } else {
                print("Could not update row.")
            }
        } else {
            print("UPDATE statement could not be prepared")
        }
        sqlite3_finalize(updateStatement)
        getOutput()
    }
    
    func delete() {
        let deleteStatementString = "DELETE FROM Heroes where id = "+deleteIdTextField.text!+";"
        var deleteStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, deleteStatementString, -1, &deleteStatement, nil) == SQLITE_OK {
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Successfully deleted row.")
            } else {
                print("Could not delete row.")
            }
        } else {
            print("DELETE statement could not be prepared")
        }
        sqlite3_finalize(deleteStatement)
        getOutput()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //Mark Actions
    @IBAction func insertButton(_ sender: UIButton) {
        
        var cancel = false
        if (nameTextField.text?.isEmpty)! {
            cancel = true
            AppUtil.showAlert(title: "", message: "Name is empty.", in: self)
            
        } else if (powerRankTextField.text?.isEmpty)! {
            AppUtil.showAlert(title: "", message: "Power Rank is empty", in: self)
            cancel = true
        }
        
        if !cancel {
            insert()
        }
        
        
    }
    
    @IBAction func deleteButton(_ sender: UIButton) {
        if (deleteIdTextField.text?.isEmpty)! {
            AppUtil.showAlert(title: "", message: "Delete ID is empty.", in: self)
        } else {
            delete()
        }
    }
    
    @IBAction func updateButton(_ sender: UIButton) {
        var cancel = false
        if (updateIdTextField.text?.isEmpty)! {
            cancel = true
            AppUtil.showAlert(title: "", message: "ID is empty.", in: self)

        } else if (nameTextField.text?.isEmpty)! {
            cancel = true
            AppUtil.showAlert(title: "", message: "Name is Empty", in: self)
        }
        else if (powerRankTextField.text?.isEmpty)! {
            cancel = true
            AppUtil.showAlert(title: "", message: "Rank is empty.", in: self)
            
        }
        
        if !cancel {
            update()
        }
    }
    
    
    
    
}
