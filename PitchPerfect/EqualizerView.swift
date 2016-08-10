//
//  EqualizerView.swift
//  PitchPerfect
//
//  Created by Yan Zverev on 6/15/16.
//  Copyright © 2016 Yan Zverev. All rights reserved.
//

import UIKit

class EqualizerView: UIView {
    
    
    @IBOutlet weak var rightStackView: UIStackView!
    @IBOutlet weak var leftStackView: UIStackView!
    
    var leftChannelDB: Float! = -160.0 {
        didSet {
            updateUI()
        }
    }

    var rightChannelDB: Float! = -160.0 {
        didSet {
            updateUI()
        }
    }

   
    lazy var currentLeftChannelDB: Int? = 15
    lazy var currentRightChannelDB: Int? = 15
    
    
    lazy var leftChannelImageViews : [UIView]! = [UIView]()
    lazy var rightChannelImageViews: [UIView]! = [UIView]()
    
    enum Channel {
        case Right, Left
    }
    
    override func awakeFromNib() {
        //the function is called when the UIView is coming out from the
        //storyboard and the outlets are set and ready to be initialized
        print("awake from nib")
        super.awakeFromNib()
        initViews()
    }
   override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func turnOnLightsForChannel(channel: Channel, range: NSRange)
    {
         //the volume is increasing
        for index in 0...range.length {
            if channel == .Left{
                if range.location-index == 0 {
                    //animation while changing the background color to give it a little fluidity
                    UIView.animateWithDuration(0.2, animations: {
                        self.leftChannelImageViews?[range.location-index].backgroundColor = UIColor.init(red: 255.0/255, green: 0.0/255, blue: 0.0/255, alpha: 1.0)
                    })
                } else {
                    UIView.animateWithDuration(0.2, animations: {
                        self.leftChannelImageViews?[range.location-index].backgroundColor = UIColor.init(red: 135.0/255, green: 206.0/255, blue: 250.0/255, alpha: 1.0)
                    })
                }
            } else if channel == .Right{
                if range.location-index == 0 {
                    UIView.animateWithDuration(0.2, animations: {
                        self.rightChannelImageViews?[range.location-index].backgroundColor = UIColor.init(red: 255.0/255, green: 0.0/255, blue: 0.0/255, alpha: 1.0)
                    })
                } else {
                    UIView.animateWithDuration(0.2, animations: {
                        self.rightChannelImageViews?[range.location-index].backgroundColor = UIColor.init(red: 135.0/255, green: 206.0/255, blue: 250.0/255, alpha: 1.0)
                    })
                }
            }
        }
    }
    
    func turnOffLightsForChannel(channel: Channel, range: NSRange)
    {
        //the volume is decreasing
        
        for index in 0...range.length {
            if channel == .Left{
                if range.location+index == 0 {
                    UIView.animateWithDuration(0.2, animations: {
                        self.leftChannelImageViews?[range.location+index].backgroundColor = UIColor.init(red: 139.0/255, green: 0.0/255, blue: 0.0/255, alpha: 1.0)
                    })
                    
                } else {
                    UIView.animateWithDuration(0.1, animations: {
                         self.leftChannelImageViews?[range.location+index].backgroundColor = UIColor.init(red: 65.0/255, green: 105.0/255, blue: 225.0/255, alpha: 1.0)
                    })
                }
            } else if channel == .Right{
                if range.location+index == 0 {
                    UIView.animateWithDuration(0.2, animations: {
                        self.rightChannelImageViews?[range.location+index].backgroundColor = UIColor.init(red: 139.0/255, green: 0.0/255, blue: 0.0/255, alpha: 1.0)
                    })
                } else {
                    UIView.animateWithDuration(0.2, animations: {
                        self.rightChannelImageViews?[range.location+index].backgroundColor = UIColor.init(red: 65.0/255, green: 105.0/255, blue: 225.0/255, alpha: 1.0)
                    })
                }
            }
        }
    }
    
    func mapDB(db: Int, lowFrom: Int, hiFrom: Int, lowTo: Int, highTo: Int) -> Int
    {
        print("db:\(db) ")
        let mapDB = lowTo + (db - lowFrom) * (highTo - lowTo) / (hiFrom - lowFrom)
        // remaping the decibals to make the equalizer react better
        // could be improved
        
        /*if db >= 15 {return 15}
        if db > 12 {return 14}
        if db > 10 {return 13}
        if db > 8 {return 12}
        if db > 7 {return 11}*/
        if mapDB > 6 {return 15}
        if mapDB > 5 {return 13}
        if mapDB > 4 {return 10}
        if mapDB >= 3 {return 8}
        if mapDB >= 2 {return 6}
        if mapDB >= 1 {return 4}
        if mapDB > -1 {return 0}

        return mapDB
    }
    
    func updateUI()
    {
        //calculate how many views needs to color and update them accordingly
        print("leftChDB \(leftChannelDB)")
        
        let leftChannelNum = mapDB(Int(abs(leftChannelDB)), lowFrom: 0, hiFrom: 160, lowTo: 0, highTo: 15)
        
        if leftChannelNum < currentLeftChannelDB {
            //create a range of where the current level is and how many views need to be updated.
            //this way i don't have to itterate through every view in the array
            let changeRange = NSRange(location: currentLeftChannelDB!, length: (currentLeftChannelDB! - leftChannelNum))
            turnOnLightsForChannel(.Left, range: changeRange)
            currentLeftChannelDB = leftChannelNum
        } else if leftChannelNum > currentLeftChannelDB {
            let changeRange = NSRange(location: currentLeftChannelDB!, length: (leftChannelNum - currentLeftChannelDB!))
            turnOffLightsForChannel(.Left, range: changeRange)
            currentLeftChannelDB = leftChannelNum
        }
        
        
        let rightChannelNum = mapDB(Int(abs(rightChannelDB)), lowFrom: 0, hiFrom: 160, lowTo: 0, highTo: 15)

        if rightChannelNum < currentRightChannelDB {
            let changeRange = NSRange(location: currentRightChannelDB!, length: (currentRightChannelDB! - rightChannelNum))
            turnOnLightsForChannel(.Right, range: changeRange)
            currentRightChannelDB = rightChannelNum
        } else if rightChannelNum > currentRightChannelDB {
            let changeRange = NSRange(location: currentRightChannelDB!, length: (rightChannelNum - currentRightChannelDB!))
            turnOffLightsForChannel(.Right, range: changeRange)
            currentRightChannelDB = rightChannelNum
        }
        
        
    }
    
    func initViews()
    {
        //init view and adding 16 UIView's to stack view for each stop in the equalizer
        
        print("Initilizing views")

        for index in 0...15{
            let eViewLeft = UIView()
            eViewLeft.tag = index
            eViewLeft.backgroundColor = UIColor.init(red: 65.0/255, green: 105.0/255, blue: 225.0/255, alpha: 1.0)
        
            leftChannelImageViews.append(eViewLeft)
            leftStackView.addArrangedSubview(eViewLeft)
            
            let eViewRight = UIView()
            eViewRight.tag = index
            eViewRight.backgroundColor = UIColor.init(red: 65.0/255, green: 105.0/255, blue: 225.0/255, alpha: 1.0)
            rightStackView.addArrangedSubview(eViewRight)
            rightChannelImageViews.append(eViewRight)
        }
        // set the top view to red
        leftChannelImageViews.first?.backgroundColor = UIColor.init(red: 139.0/255, green: 0.0/255, blue: 0.0/255, alpha: 1.0)
        rightChannelImageViews.first?.backgroundColor = UIColor.init(red: 139.0/255, green: 0.0/255, blue: 0.0/255, alpha: 1.0)
    }
    
    func resetEqualizer()
    {
        leftChannelDB = -160.0
        rightChannelDB = -160.0
    }

}
