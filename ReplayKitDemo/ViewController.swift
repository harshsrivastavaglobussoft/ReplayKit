//
//  ViewController.swift
//  ReplayKitDemo
//
//  Created by Sumit Ghosh on 04/07/18.
//  Copyright © 2018 Sumit Ghosh. All rights reserved.
//

import UIKit
import ReplayKit

class ViewController: UIViewController,RPPreviewViewControllerDelegate {

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var boxView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var segmentController: UISegmentedControl!
    @IBOutlet weak var toggleSwitch: UISwitch!
    
    let recorder = RPScreenRecorder.shared()
    private var isRecording = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    //MARK: View reset 
    func viewReset() -> Void {
        self.toggleSwitch.isEnabled = true
        self.statusLabel.text = "Ready to Record"
        self.statusLabel.textColor = UIColor.black
        self.recordButton.isSelected = false
    }
    
    //MARK: segment action
    @IBAction func segmentAction(_ sender: UISegmentedControl) {
       //0-red 1-blue 2-orange 3-green
        switch sender.selectedSegmentIndex {
        case 0:
            boxView.backgroundColor = UIColor.red
            break;
        case 1:
            boxView.backgroundColor = UIColor.blue
            break;
        case 2:
            boxView.backgroundColor = UIColor.orange
            break;
        default:
            boxView.backgroundColor = UIColor.green
            break;
        }
    }
    
    //MARK: recordButton Action
    @IBAction func recordButtonAction(_ sender: Any) {
        if isRecording == true {
          recordButton.isSelected = false
          self.stopRecording()
        }else{
          recordButton.isSelected = true
          self.startRecording()
        }
    }
    
    //MARK: Start Recording
    func startRecording() -> Void {
        print("recording start")
        guard recorder.isAvailable else {
            print("Recording is not available at this time.")
            return
        }
        
        if self.toggleSwitch.isOn {
            recorder.isMicrophoneEnabled = true
            
        } else {
            recorder.isMicrophoneEnabled = false
        }
        
        recorder.startRecording{ [unowned self] (error) in
            
            guard error == nil else {
                print("There was an error starting the recording.")
                return
            }
            
            print("Started Recording Successfully")
            self.toggleSwitch.isEnabled = false
            self.recordButton.isSelected = true
            self.statusLabel.text = "Recording..."
            self.statusLabel.textColor = UIColor.red
            self.isRecording = true
        }

    }
    
    //MARK: Stop Recording
    func stopRecording() -> Void {
        recorder.stopRecording{[unowned self] (preview, error)in
            print("Stopped recording")
            guard preview != nil else {
                print("Preview controller is not available")
                return
            }
            
            let  alert = UIAlertController.init(title: "Recording Finished", message: "Would you like to edit or delete your recording?", preferredStyle: .alert)
            
            let deleteAction = UIAlertAction.init(title: "Delete", style: .destructive, handler: { (action:UIAlertAction) in
                self.recorder.discardRecording(handler: {
                    print("Recording Successfully deleted")
                })
            })
            
            let editAction = UIAlertAction.init(title: "Edit", style: .default, handler: { (action:UIAlertAction) in
                preview?.previewControllerDelegate = self as? RPPreviewViewControllerDelegate
                self.present(preview!, animated: true, completion: nil)
            })
            
            alert.addAction(editAction)
            alert.addAction(deleteAction)
            self.present(alert, animated: true, completion: nil)
            
            self.isRecording = false
            self.viewReset()
            
        }
    }
    
    //MARK: RPPreviewViewControllerDelegate
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

