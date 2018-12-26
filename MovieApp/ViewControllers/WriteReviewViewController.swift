//
//  WriteReviewViewController.swift
//  MovieApp
//
//  Created by Lucas Longarini on 2018-12-23.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import UIKit

protocol WriteReviewDelegate {
    func reviewPosted(review:Review)
}

class WriteReviewViewController: UIViewController, UITextViewDelegate, StarViewDelegate {
    
    var reviewType:ReviewType!
    var mediaTitle:String!
    var mediaID:Int!
    var firstReview = false
    var delegate: WriteReviewDelegate?
    
    @IBOutlet weak var postButton: UIBarButtonItem!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollHeight: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var starView: StarRatingView!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var descriptionField: UITextView!
    
    var keyboardHeight: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionField.delegate = self
        titleField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        starView.delegate = self
        setupKeyboardObservers()
        setupView()
        checkIfPostable()
    }
    
    func setupView(){
        profilePicture.layer.cornerRadius = profilePicture.frame.height/2
        profilePicture.clipsToBounds = true
        profilePicture.layer.borderWidth = 1
        
        if let image = UserSingleton.shared.image{
            profilePicture.image = image
            profilePicture.layer.borderColor = UIColor.darkGray.cgColor
        }
        else{
           profilePicture.layer.borderColor = UIColor(rgb: 0xD8D8D8).cgColor
        }
        
        reSizeTextView(textView: descriptionField)
        descriptionField.text = "Your Description..."
        descriptionField.textColor = .lightGray
        descriptionField.selectedTextRange = descriptionField.textRange(from: descriptionField.beginningOfDocument, to: descriptionField.beginningOfDocument)
        titleLabel.text = mediaTitle
        
    }
    
    func reSizeTextView(textView:UITextView){
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        if estimatedSize.height != textView.frame.height{
            textView.constraints.forEach { (constraint) in
                if constraint.firstAttribute == .height{
                    constraint.constant = estimatedSize.height
                    self.view.layoutIfNeeded()
                }
            }

            if (self.view.frame.height-(keyboardHeight+8)) < self.descriptionField.frame.maxY{
                let diff = self.descriptionField.frame.maxY - (self.view.frame.height-(keyboardHeight+8))
                var increment: CGFloat
                if #available(iOS 11.0, *) {increment = self.descriptionField.frame.maxY - (self.contentView.frame.height + self.view.safeAreaInsets.bottom - (keyboardHeight+8))}
                else{increment = self.descriptionField.frame.maxY - (self.contentView.frame.height - (keyboardHeight+8))}
                scrollHeight.constant += increment
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
                    self.scrollView.contentOffset = CGPoint(x: 0, y: diff)
                }, completion: nil)
            }
        }
    }
    
    func setupKeyboardObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc func handleKeyboardWillShow(notification:NSNotification){
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue{
            let keyboardHeight = keyboardFrame.cgRectValue.height
            self.keyboardHeight = keyboardHeight
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
   
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Combine the textView text and the replacement text to
        // create the updated text string
        let currentText:String = textView.text
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)
        
        // If updated text view will be empty, add the placeholder
        // and set the cursor to the beginning of the text view
        if updatedText.isEmpty {
            
            textView.text = "Your Description..."
            textView.textColor = UIColor.lightGray
            checkIfPostable()
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        }
            
            // Else if the text view's placeholder is showing and the
            // length of the replacement string is greater than 0, set
            // the text color to black then set its text to the
            // replacement string
        else if textView.textColor == UIColor.lightGray && !text.isEmpty {
            textView.textColor = UIColor.darkGray
            textView.text = text
            checkIfPostable()
        }
            
            // For every other case, the text should change with the usual
            // behavior...
        else {
            return true
        }
        
        // ...otherwise return false since the updates have already
        // been made
        return false
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if self.view.window != nil {
            if textView.textColor == UIColor.lightGray {
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            }
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        reSizeTextView(textView: textView)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        checkIfPostable()
    }
    
    func starViewPressed() {
        checkIfPostable()
    }

    func checkIfPostable(){
        if starView.rating == 0 || titleField.text == "" || descriptionField.textColor == UIColor.lightGray{
            postButton.isEnabled = false
        }
        else{
            postButton.isEnabled = true
        }
    }

    @IBAction func postButtonPressed(_ sender: Any) {
        let review = Review(reviewType: reviewType, mediaID: mediaID, description: descriptionField.text, title: titleField.text!, score: starView.rating, time: Date(), reviewer: UserSingleton.shared.user!)
        DatabaseHelper.postReview(review: review) { (success) in
            if success{
                if !self.firstReview{
                    self.navigationController?.popViewController(animated: true)
                    if let del = self.delegate{
                        del.reviewPosted(review: review)
                    }
                }
                else{
                    guard var currentViewControllers = self.navigationController?.viewControllers else{return}
                    currentViewControllers.removeLast()
                    if let review = self.storyboard?.instantiateViewController(withIdentifier: "ReviewViewController") as? ReviewViewController{
                        review.reviewType = self.reviewType
                        review.mediaTitle = self.mediaTitle
                        review.mediaID = self.mediaID
                        currentViewControllers.append(review)
                    }
                    self.navigationController?.setViewControllers(currentViewControllers, animated: true)
                }
            }
            else{
                self.displayError(title: "Error", description: "Something went wrong. Please try again")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        ImageCache.shared.imageCache.removeAllObjects()
    }
    
}
