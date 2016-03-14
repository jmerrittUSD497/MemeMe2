//
//  ViewController.swift
//  MemeMe
//
//  Created by Jerod Merritt on 2/17/16.
//  Copyright © 2016 Jerod. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    //Meme variables that need to be created so the editor can be called to edit an existing meme
    var importedImage: UIImage!
    var importedTopText: String!
    var importedBottomText: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        topTextField.delegate = self
        bottomTextField.delegate = self
        
        prepareMeme()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //Disable the cameraButton if no camera is available
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        self.subscribeToKeyboardNotifications()
        self.subscribeToKeyboardWillHide()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeFromKeyboardNotifications()
    }
    
//MARK: - Keyboard functions
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        //Shift the view frame up, if bottomTextField is the first responder
        if self.bottomTextField.isFirstResponder() {
            self.view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func subscribeToKeyboardWillHide() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        //Shift the view frame back to the original starting position
        self.view.frame.origin.y = 0.0
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }

//MARK: - Textfield functions
    func setTextFieldAttributes(textField: UITextField) {
        //Set text field attributes and alignment
        let memeTextAttributes = [
            NSStrokeColorAttributeName : UIColor.blackColor(),
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName : -3.0
        ]
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = NSTextAlignment.Center
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        self.subscribeToKeyboardWillHide()
    }
    
//MARK: - Image picking functions
    @IBAction func pickAnImageFromAlbum(sender: AnyObject) {
        //Present photo album and return the selected image to imagePickerView
        pickAnImage(UIImagePickerControllerSourceType.PhotoLibrary)
    }
    
    @IBAction func pickAnImageFromCamera(sender: AnyObject) {
        //Present the camera to acquire an image
        pickAnImage(UIImagePickerControllerSourceType.Camera)
    }
    
    func pickAnImage(source: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = source
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.imagePickerView.image = image
            shareButton.enabled = true
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }

//MARK: - Meme functions
    func prepareMeme() {
        //Check to see if variables have been set for image editing, if not display a blank meme
        if let currentImage = importedImage as UIImage? {
            imagePickerView.image = currentImage
        }
        
        if let currentTopText = importedTopText as String? {
            topTextField.text = currentTopText
        }
        
        if let currentBottomText = importedBottomText as String? {
            bottomTextField.text = currentBottomText
        }
        
        setTextFieldAttributes(topTextField)
        setTextFieldAttributes(bottomTextField)
    }
    
    @IBAction func shareMeme(sender: AnyObject) {
        //Share the meme and save it
        let memedImage = generateMemedImage()
        let myController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        myController.completionWithItemsHandler = {activity, success, items, error in
            if success {
                self.save()
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        presentViewController(myController, animated: true, completion: nil)
    }
    
    func save() {
        //Create the meme
        let meme = Meme(textTop: topTextField.text!, textBottom: bottomTextField.text!, originalImage: imagePickerView.image!, memedImage: generateMemedImage())
        //Add it to the memes array
        (UIApplication.sharedApplication().delegate as! AppDelegate).memes.append(meme)
    }
    
    func generateMemedImage() ->UIImage {
        //Hide toolbar and navbar
        toolBar.hidden = true
        navigationBar.hidden = true
        
        //Render view to an image
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawViewHierarchyInRect(view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //Show toolbar and navbar
        toolBar.hidden = false
        navigationBar.hidden = false
        
        return memedImage
    }
    
    @IBAction func cancelMeme(sender: AnyObject) {
        //Clear the imagePickerView, disable the shareButton and set the textFields back to placeholder values
        self.imagePickerView.image = nil
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        if (shareButton.enabled) {
            shareButton.enabled = false
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
}

