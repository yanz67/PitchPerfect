//
//  ViewController.swift
//  PitchPerfect
//
//  Created by Yan Zverev on 6/14/16.
//  Copyright © 2016 Yan Zverev. All rights reserved.
//

import UIKit
import AVFoundation


class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var recordTimeLabel: UILabel!
    @IBOutlet weak var equalizerView: EqualizerView!
    @IBOutlet weak var leftLevelLabel: UILabel!
    @IBOutlet weak var rightLevelLabel: UILabel!
    
    var audioRecorder:AVAudioRecorder!
    var myTimer:NSTimer!
    
    lazy var elapsedRecordingTime: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        //reset all the to the original state
        super.viewWillAppear(animated)
        stopButton.enabled = false
        recordButton.enabled = true
        equalizerView.resetEqualizer()
        recordTimeLabel.text = "Tap To Record"
        leftLevelLabel.text = "Left: 0"
        rightLevelLabel.text = "Right: 0"
    }



    func setupRecorder()
    {
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        print(filePath)
        
        let session = AVAudioSession.sharedInstance()
        
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord) // check device if it can record and play back
        
        
        try! audioRecorder = AVAudioRecorder(URL: filePath!, settings: [:])
        
        audioRecorder.meteringEnabled = true;
        audioRecorder.delegate = self

    }
    
    @IBAction func recordAudio(sender: UIButton)
    {
        print("Record")
        recordButton.enabled = false
        stopButton.enabled = true
        
        if (audioRecorder == nil) {
            setupRecorder()
        }
        audioRecorder.prepareToRecord()
        audioRecorder.record()
        
        //setup a time to invoke showlevels method every second
        myTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector:#selector(self.showLevels), userInfo: nil, repeats: true)
    }
    
    @IBAction func stopRecording(sender: UIButton) {
        print("Stop Recording is pressed")
        audioRecorder.stop()
        myTimer.invalidate()
        
    }
    
    func recordingTimeToString() -> String
    {
        //create and return a string if elapsed recording in time in HH:MM:SS format
        return String(format:"%02d:%02d:%02d", elapsedRecordingTime/3600,((elapsedRecordingTime/60)%60),(elapsedRecordingTime%60))
    }
    
    func showLevels()
    {
        //this method is being invoked by the timer every second
        //will update the meter levels, labels and recording time
        audioRecorder.updateMeters()
        self.leftLevelLabel.text = "Left: \(self.audioRecorder.averagePowerForChannel(0))"
        self.rightLevelLabel.text = "Right:\(self.audioRecorder.averagePowerForChannel(1))"
        equalizerView.leftChannelDB = self.audioRecorder.averagePowerForChannel(0)
        equalizerView.rightChannelDB = self.audioRecorder.averagePowerForChannel(1)
        recordTimeLabel.text = "Recording Time: \(recordingTimeToString())"
        elapsedRecordingTime+=1
    }
    
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        print("recording finished")
        if (flag){
            self.performSegueWithIdentifier("playSoundSegue", sender: audioRecorder.url)
        }else{
            print("Saving recording failed")
            let alert = UIAlertController(title: "Error", message: "Error Saving Audio", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Dissmiss Alert", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "playSoundSegue") {
            let playSoundsVC = segue.destinationViewController as! PlaySoundsUIViewController
            playSoundsVC.recordedAudioURL = audioRecorder.url
        }
    }
    
    
}

