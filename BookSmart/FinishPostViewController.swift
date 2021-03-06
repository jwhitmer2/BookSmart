//
//  FinishPostViewController.swift
//  BookSmart
//
//  Created by Alec Brownlie on 4/26/16.
//  Copyright © 2016 Alec Brownlie. All rights reserved.
//

import UIKit
import Parse

class FinishPostViewController: UIViewController
{
    var post : Post?
    var book : Book?
    var ISBN : String?
    var bookFromDS : BookLookup?
    var bookDS : BookLookupDataSource?
    
    @IBOutlet weak var bookTitleTextField: UITextField!
    @IBOutlet weak var authorTextField: UITextField!
    @IBOutlet weak var pagesTextField: UITextField!
    
    @IBOutlet weak var bookDescriptionTextView: UITextView!
    @IBOutlet weak var bookStockImageView: UIImageView!
    
    var bookYear : String!
    var pages : Int!
    @IBAction func nextButtonToUpload(sender: AnyObject)
    {
        if checkTextFields() == true
        {
            print("The value of pages is \(pages)")
            book = Book(title: bookTitleTextField.text, isbn: ISBN, pageNum: pages, desc: bookDescriptionTextView.text, author: authorTextField.text, image: bookStockImageView, year: bookYear)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("The post being used is: \(post)")
        
        
        // if user entered ISBN, lookup book using Google Books API and autofill
        if let isbn = ISBN
        {
            if isbn != ""{
                let urlString = "https://www.googleapis.com/books/v1/volumes?q=isbn:" + isbn
                if let url = NSURL(string: urlString) {
                    NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: {data, _, error -> Void in
                        if let error = error {
                            print(error.localizedDescription)
                        } else {
                            if let data = data,
                                jsonResult = try? NSJSONSerialization.JSONObjectWithData(data, options: []),
                                arrayOfTitles = jsonResult.valueForKeyPath("items.volumeInfo") as? [AnyObject] {
                                    let titles = arrayOfTitles
                                    print(titles)
                                    self.bookDS = BookLookupDataSource(dataSource: titles)
                                    self.autoFillTextFields(self.bookDS!.titleAt(0))
                                    
                            } else {
                                print("ERROR")
                            }
                        }
                    }).resume()
                }
            }
        }
    }
    
    func autoFillTextFields(book: BookLookup)
    {
        dispatch_async(dispatch_get_main_queue()){
            /* Do UI work here */
            
            if let title = book.bookTitle()
            {
                print("title: \(title)")
                self.bookTitleTextField.text = title
            }
            if let author = book.bookAuthors()
            {
                print("authors: \(author)")
                self.authorTextField.text = author[0]
            }
            if let d = book.bookDescription()
            {
                print("descriptions: \(d)")
                self.bookDescriptionTextView.text = d
            }
            if let pageNum = book.bookPages()
            {
                print("pages: \(pageNum)")
                self.pages = pageNum
                self.pagesTextField.text = "\(pageNum) pages"
            }
            if let stock = book.bookStockImageURL()
            {
                self.bookStockImageView.image = stock
                
            }
            if let year = book.bookYearPublished()
            {
                self.bookYear = year
            }
        }
    }
    
    func checkTextFields() -> Bool
    {
        if (!bookTitleTextField.text!.isEmpty && !authorTextField.text!.isEmpty)
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    func postToUploadWithISBN(post: Post, isbn : String)
    {
        self.post = post
        self.ISBN = isbn
        //self.bookLookupDownloadAssistant = BookLookupDownload(withISBN: isbn)
    }
    
    func postToUpload(post: Post)
    {
        self.post = post
        self.ISBN = nil
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        // update price and condition before segue
        
        if segue.identifier == "uploadPost"
        {
            if let p = post, b = book{
                let detailedVC = segue.destinationViewController as! UploadPostViewController
                detailedVC.postToUpload(p, book: b)
            }
        }
    }
    
    
}
