//
//  BaseViewController.swift
//  Networker
//
//  Created by Big Shark on 13/03/2017.
//  Copyright © 2017 shark. All rights reserved.
//

import UIKit
import Toast_Swift
import KYDrawerController

class BaseViewController: UIViewController {

    var drawerController : KYDrawerController?
    //var drawerOpened : Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        drawerController = self.navigationController?.parent as? KYDrawerController
        if drawerController != nil {
            drawerController?.drawerDirection = .right
            //drawerOpened = false
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func viewWillAppear(_ animated : Bool) {
        
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    
    func showToastWithDuration(string: String!, duration: Double) {
        self.view.makeToast(string, duration: duration, position: .bottom)
    }
    
    func showLoadingView()
    {
        self.view.makeToastActivity(.center)
        self.view.isUserInteractionEnabled = false
    }
    
    func hideLoadingView()
    {
        self.view.hideToastActivity()
        self.view.isUserInteractionEnabled = true
    }

    func gotoMainScene(){
        let storyboard = getStoryboard(id: Constants.STORYBOARD_MAIN)

        let mainTab = storyboard.instantiateViewController(withIdentifier: "MainTab") as! UITabBarController
        
        //setNavigationRoots()
        present(mainTab, animated: true, completion: nil)
        
    }
    
    func getStoryboard(id: Int) -> UIStoryboard{
        switch id {
        case Constants.STORYBOARD_MAIN:
            return UIStoryboard(name: "Main", bundle: nil)
        case Constants.STORYBOARD_HOME:
            return UIStoryboard(name: "Home", bundle: nil)
        case Constants.STORYBOARD_SEARCH:
            return UIStoryboard(name: "Search", bundle: nil)
        case Constants.STORYBOARD_SCHEDULE:
            return UIStoryboard(name: "Schedule", bundle: nil)
        case Constants.STORYBOARD_FAVORITE:
            return UIStoryboard(name: "Favorite", bundle: nil)
        case Constants.STORYBOARD_CHATTING:
            return UIStoryboard(name: "Chatting", bundle: nil)
        default:
            return UIStoryboard(name: "Main", bundle: nil)
        }
    }
    
}
