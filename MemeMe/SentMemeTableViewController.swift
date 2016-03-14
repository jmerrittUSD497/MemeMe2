//
//  SentMemeTableViewController.swift
//  MemeMe
//
//  Created by Jerod Merritt on 3/9/16.
//  Copyright © 2016 Jerod. All rights reserved.
//

import UIKit

class SentMemeTableViewController: UITableViewController {
    var memes: [Meme]! {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).memes
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView!.reloadData()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MemeCell", forIndexPath: indexPath)
        let meme = memes[indexPath.item]
        cell.imageView!.image = meme.memedImage
        cell.textLabel?.text = meme.textTop + "..." + meme.textBottom
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let memeDetailView = self.storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! MemeDetailViewController
        memeDetailView.selectedMeme = memes[indexPath.item]
        navigationController!.pushViewController(memeDetailView, animated: true)
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let memeDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            memeDelegate.memes.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
}