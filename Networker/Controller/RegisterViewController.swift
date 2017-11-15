//
//  RegisterViewController.swift
//  Networker
//
//  Created by Big Shark on 13/03/2017.
//  Copyright © 2017 shark. All rights reserved.
//

import UIKit
import MapKit

class RegisterViewController: BaseViewController {

    
    var profileImage : UIImage?
    var picker = UIImagePickerController()
    
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var address1: UITextField!
    
    @IBOutlet weak var postcode: UITextField!
    @IBOutlet weak var birthday: UITextField!
    
    @IBOutlet weak var aboutMe: UITextView!
    
    @IBOutlet weak var headerViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imvProfile: UIImageView!
    
    var user = UserModel()
    
    
    var addressPicker = UIPickerView()
    var filteredAddresses = [(String, String)]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        keyboardControl()
        addressPicker.delegate = self
        addressPicker.dataSource = self
        addressPicker.backgroundColor = .white
        addressPicker.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: screenSize.width, height: 220))
        self.view.addSubview(addressPicker)
        addressPicker.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func backButtonTapped(_ sender: UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }

    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func contentViewTapped(_ sender: Any) {
        self.view.endEditing(true)
    }
    @IBAction func registerButtonTapped(_ sender: Any) {
        
        let checkResult = checkValid()
        if checkResult == Constants.PROCESS_SUCCESS {
            showLoadingView()
            ApiFunctions.register(user, completion: {
                message in
                
                if message == Constants.PROCESS_SUCCESS {
                    self.user = currentUser!
                    if self.profileImage != nil {
                        let data = UIImageJPEGRepresentation(self.profileImage!, 0.5)
                        ApiFunctions.uploadImage(name: "profile_\(currentUser!.user_id).jpg", imageData: data!, completion: {
                            message, url in
                            if message == Constants.PROCESS_SUCCESS {
                                self.user.user_profileimageurl = url
                                ApiFunctions.updateProfile(profile: [Constants.KEY_USER_ID: self.user.user_id as AnyObject, Constants.KEY_USER_PROFILEIMAGEURL: url as AnyObject], completion: {
                                    message in
                                    if message == Constants.PROCESS_SUCCESS {
                                        self.navigationController?.showToastWithDuration(string: "Image uploaded successfully", duration: 3.0)
                                        self.gotoSkillVC()
                                    }
                                    else {
                                        self.hideLoadingView()
                                        self.showToastWithDuration(string: message, duration: 3.0)
                                    }
                                })
                            }
                            else{
                                self.hideLoadingView()
                                self.showToastWithDuration(string: message, duration: 3.0)
                            }
                        })
                    }
                    else {
                        self.hideLoadingView()
                        self.gotoSkillVC()
                    }
                }
                else {
                    self.hideLoadingView()
                    self.showToastWithDuration(string: message, duration: 3.0)
                }
            })
        }
        else  {
            self.showToastWithDuration(string: checkResult, duration: 3.0)
        }
    }
    
    func gotoSkillVC() {
        
        let skillVC = self.storyboard?.instantiateViewController(withIdentifier: "SkillsViewController") as! SkillsViewController
        skillVC.user = user
        self.navigationController?.viewControllers = [skillVC]
    }
    
    @IBAction func uploadImageButtonTapped(_ sender: Any) {
        if user.user_id > 0{
            if profileImage != nil {
                let data = UIImageJPEGRepresentation(profileImage!, 0.5)
                ApiFunctions.uploadImage(name: "profile_\(user.user_id)", imageData: data!, completion: {
                    message, url in
                    if message == Constants.PROCESS_SUCCESS {
                        self.user.user_profileimageurl = url
                        ApiFunctions.updateProfile(profile: [Constants.KEY_USER_ID: self.user.user_id as AnyObject, Constants.KEY_USER_PROFILEIMAGEURL: url as AnyObject], completion: {
                            message in
                            if message == Constants.PROCESS_SUCCESS {
                                self.showToastWithDuration(string: "Image uploaded successfully", duration: 3.0)
                            }
                            else {
                                self.showToastWithDuration(string: message, duration: 3.0)
                            }
                        })
                    }
                    else{
                        self.showToastWithDuration(string: message, duration: 3.0)
                    }
                })
            }
            else {
                self.showToastWithDuration(string: "Please select your photo to upload", duration: 3.0)
            }
        }
        else {
            showToastWithDuration(string: Constants.CHECK_PROFILE_IMAGE_UPLOAD, duration: 3.0)
        }
    }
    
    @IBAction func profileImageTapped(_ sender: UIButton) {
        selectImageSource()
        
        
    }
    
    func checkValid() -> String {
        user.user_firstname = firstName.text!
        user.user_lastname = lastName.text!
        user.user_email = email.text!
        user.user_password = password.text!
        user.user_address = address1.text!
        user.user_postcode = postcode.text!
        user.user_birthday = birthday.text!
        user.user_aboutme = aboutMe.text!
        if user.user_firstname.count == 0 {
            return Constants.CHECK_FIRSTNAME_EMPTY
        }
        if user.user_lastname.count == 0 {
            return Constants.CHECK_LASTNAME_EMPTY
        }
        if user.user_email.count == 0 {
            return Constants.CHECK_EMAIL_EMPTY
        }
        if !CommonUtils.isValidEmail(user.user_email) {
            return Constants.CHECK_EMAIL_INVALID
        }
        if user.user_birthday.count == 0 {
            return Constants.CHECK_BIRTHDAY_EMPTY
        }
        
        return Constants.PROCESS_SUCCESS
        
    
    }

    @IBAction func textFieldEditing(_ sender: UITextField) {
        
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.date
        
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        

    }
    func datePickerValueChanged(_ sender: UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        //dateFormatter.timeStyle = .none
        birthday.text = dateFormatter.string(from: sender.date)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        addressPicker.isHidden = true
    }
}

extension RegisterViewController : UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return filteredAddresses.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return filteredAddresses[row].0
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.address1.text = filteredAddresses[row].0
        self.postcode.text = filteredAddresses[row].1
        
    }
}


extension RegisterViewController:  UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        profileImage = info[UIImagePickerControllerEditedImage] as? UIImage
        imvProfile.image = profileImage
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelgeate
    // open gallery
    func openGallery() {
        
        picker.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum
        picker.allowsEditing = true
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    
    // open camera
    func openCamera() {
        
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
            
            picker.sourceType = .camera
            picker.allowsEditing = true
            picker.cameraCaptureMode = .photo
            picker.modalPresentationStyle = .fullScreen
            picker.delegate = self
            self.present(picker, animated: true, completion: nil)
        }
    }
    
    func selectImageSource()
    {
        
        self.view.endEditing(true)
        
        let alertController = UIAlertController(title: "Select Image Source", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let selectGalleryAction = UIAlertAction(title: "Gallery", style: .default, handler: { action in
            self.openGallery()
            
        })
        let selectCameraAction = UIAlertAction(title: "Camera",				 style: .default, handler: { action in
            
            self.openCamera()
            
        })
        let selectCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
        })
        alertController.addAction(selectGalleryAction)
        alertController.addAction(selectCameraAction)
        alertController.addAction(selectCancel)
        
        
        self.navigationController?.present(alertController, animated: true, completion: nil)
        
        
    }
    
}


// MARK: - @extension SinglePostVC
extension RegisterViewController {
    
    func keyboardControl() {
        /**
         Keyboard notifications
         */
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardDidShow(_:)), name: .UIKeyboardDidShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardDidHide(_:)), name: .UIKeyboardDidHide, object: nil)
    }
    
    func keyboardWillShow(_ notification: Notification)
    {
        self.keyboardControl(notification, isShowing: true)
    }
    
    func keyboardDidShow(_ notification: Notification)
    {
        
    }
    func keyboardWillHide(_ notification: Notification)
    {
        self.keyboardControl(notification, isShowing: false)
    }
    func keyboardDidHide(_ notification: Notification)
    {
        
    }
    
    func keyboardControl(_ notification: Notification, isShowing: Bool)
    {
        var userInfo = notification.userInfo!
        let keyboardRect = (userInfo[UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue
        let curve = (userInfo[UIKeyboardAnimationCurveUserInfoKey]! as AnyObject).uint32Value
        
        let convertedFrame = self.view.convert(keyboardRect!, from: nil)
        let heightOffset = self.view.bounds.size.height - convertedFrame.origin.y
        let options = UIViewAnimationOptions(rawValue: UInt(curve!) << 16 | UIViewAnimationOptions.beginFromCurrentState.rawValue)
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey]! as AnyObject).doubleValue
        
        
        UIView.animate(
            withDuration: duration!,
            delay: 0,
            options: options,
            animations: {
                if isShowing && self.headerViewHeightConstraint.constant == 0{
                    if (self.screenSize.height - heightOffset - 500) < 0 {                    self.view.frame.origin.y = (self.screenSize.height - heightOffset - 500)
                    }
                }
                else
                {
                    self.view.frame.origin.y = 0
                    
                }
        },
            completion: { bool in
                if isShowing {
                    self.view.frame.origin.y = 0
                    if (self.screenSize.height - heightOffset - 500) < 0 {
                        self.headerViewHeightConstraint.constant = self.screenSize.height - heightOffset - 500
                    }
                    
                }
                else {
                    self.headerViewHeightConstraint.constant = 0
                }
                
                
        })
    }
    
}


extension RegisterViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == firstName{
            lastName.becomeFirstResponder()
        }
        else if textField == lastName {
            email.becomeFirstResponder()
        }
            
        else if textField == email {
            password.becomeFirstResponder()
        }
            
        else if textField == password {
            address1.becomeFirstResponder()
        }
        else if textField == address1 {
            birthday.becomeFirstResponder()
        }
            
        else if textField == postcode {
            birthday.becomeFirstResponder()
        }
            
        else {
            self.view.endEditing(true)
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == address1 {
            self.addressPicker.isHidden = true
        }
    }
    
}


