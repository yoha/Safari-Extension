//
//  ActionViewController.swift
//  Action Extension
//
//  Created by Yohannes Wijaya on 9/17/15.
//  Copyright © 2015 Yohannes Wijaya. All rights reserved.
//

import UIKit
import MobileCoreServices

class ActionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "done")
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "adjustForKeyboard:", name: UIKeyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: "adjustForKeyboard:", name: UIKeyboardWillChangeFrameNotification, object: nil)
    
        if let inputItem = self.extensionContext!.inputItems.first as? NSExtensionItem {
            if let itemProvider = inputItem.attachments?.first as? NSItemProvider {
                itemProvider.loadItemForTypeIdentifier(kUTTypePropertyList as String, options: nil, completionHandler: { [unowned self] (dict, error) -> Void in
                    let itemDictionary = dict as! NSDictionary
                    let javaScriptValues = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as! NSDictionary
                    self.pageTitle = javaScriptValues["title"] as! String
                    self.pageURL = javaScriptValues["URL"] as! String
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.title = self.pageTitle
                    })
                })
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Stored Properties
    
    var pageTitle = ""
    var pageURL = ""
    
    // MARK: - IBOutlet Properties
    
    @IBOutlet weak var scriptTextView: UITextView!
    
    // MARK: - IBOutlet Actions

    @IBAction func done() {
        let extensionItem = NSExtensionItem()
        let webDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: ["customJavaScript": scriptTextView.text]]
        let customJavaScript = NSItemProvider(item: webDictionary, typeIdentifier: kUTTypePropertyList as String)
        extensionItem.attachments = [customJavaScript]
        
        self.extensionContext!.completeRequestReturningItems([extensionItem], completionHandler: nil)
    }
    
    // MARK: - Local Methods
    
    func adjustForKeyboard(notification: NSNotification) {
        
        let keyboardScreenEndFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let keyboardViewEndFrame = self.view.convertRect(keyboardScreenEndFrame, fromView: self.view.window!)
        
        if notification.name == UIKeyboardWillHideNotification { self.scriptTextView.contentInset = UIEdgeInsetsZero }
        else { scriptTextView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardViewEndFrame.height, right: 0.0) }
        
        self.scriptTextView.scrollIndicatorInsets = self.scriptTextView.contentInset
        
        let selectedRange = self.scriptTextView.selectedRange
        self.scriptTextView.scrollRangeToVisible(selectedRange)
    }

}
