//
//  MemeDetailViewController.swift
//  MemeMe
//
//  Created by Jerod Merritt on 3/10/16.
//  Copyright © 2016 Jerod. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {
    @IBOutlet weak var memeImageView: UIImageView!
    
    var selectedMeme: Meme!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        memeImageView.contentMode = .ScaleAspectFit
        memeImageView!.image = selectedMeme.memedImage
        
    }
    
    @IBAction func editCurrentMeme(sender: AnyObject) {
        let memeEditor = storyboard!.instantiateViewControllerWithIdentifier("MemeEditor") as! MemeEditorViewController
        
        memeEditor.importedImage = selectedMeme.originalImage
        memeEditor.importedTopText = selectedMeme.textTop
        memeEditor.importedBottomText = selectedMeme.textBottom
        
        presentViewController(memeEditor, animated: true, completion: nil)
        
        navigationController?.popToRootViewControllerAnimated(true)
    }
}
