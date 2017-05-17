//
//  ApiFunctions.swift
//  Networker
//
//  Created by Big Shark on 13/03/2017.
//  Copyright © 2017 shark. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class ApiFunctions{
    
    
    //static let SERVER_BASE_URL          = "http://35.166.129.141"
    
    static let SERVER_BASE_URL          = "http://192.168.1.120:2000/Networker"
    static let SERVER_URL               = SERVER_BASE_URL + "/index.php/Api/"
    
    static let REQ_GET_ALLCATEGORY      = SERVER_URL + "getAllCategory"
    static let REQ_REGISTER             = SERVER_URL + "register"
    
    
    static func login(email: String, password: String, completion: @escaping (String) -> () ){
        currentUser = ParseHelper.parseUser(JSON(TestJson.getMe()))
        completion(Constants.PROCESS_SUCCESS)
    }
    
    static func register(_ user: UserModel, completion: @escaping (String, UserModel) -> ()){
        
    }
    
    static func loginWithFacebook(){
        
    }
    
    static func loginWithLinkedIn(){
        
    }
    
    static func passwordChangeRequest(email: String){
        
    }
    
    static func getUsers(available: Bool) {
        
    }
    
    static func advancedSearch(){
        
    }
    
    static func getSkillsArray(completion : @escaping (String, [SkillModel]) -> ()){
        Alamofire.request(REQ_GET_ALLCATEGORY, method: .post, parameters: nil).responseJSON { response in
            if response.result.isFailure{
                completion("Connection failed", [])
            }
            else
            {
                let json = JSON(response.result.value!)
                NSLog("\(response.result.value!)")
                let categories = json[Constants.KEY_CATEGORYS].arrayValue
                if categories.count > 0 {
                    
                    var skills : [SkillModel] = []
                    for category in categories{
                    let skillsData = category[Constants.KEY_CATEGORY_SKILLS].arrayValue
                        for skillData in skillsData{
                            skills.append(ParseHelper.parseSkill(skillData))
                        }

                    }
                    completion(Constants.PROCESS_SUCCESS, skills)
                }
                else{
                    completion("No category", [])
                }
            }
        }
        
        
    }
    
    static func getTagsArray(completion : @escaping (String, [TagModel]) -> ()){
        let tagsData = JSON(TestJson.getTagsJson()).arrayValue
        var tags : [TagModel] = []
        for tagData in tagsData{
            tags.append(ParseHelper.parseTag(tagData))
        }
        completion(Constants.PROCESS_SUCCESS, tags)
    }
    
    static func getHomeData(completion : @escaping (String, [UserModel]) -> ()){
        let usersData = JSON(TestJson.nearMeUsers()).arrayValue
        var users: [UserModel] = []
        for userData in usersData {
            users.append(ParseHelper.parseUser(userData))
        }
        completion(Constants.PROCESS_SUCCESS, users)
    }
    
    static func getNameMatchedUsers(keyword: String, from preDefinedUsers: [UserModel], completion : @escaping (String, [UserModel]) -> ()){
        
        var users : [UserModel] = []
        if keyword.characters.count > 0{
            for user in preDefinedUsers {
                if(user.user_firstname + " " + user.user_lastname).lowercased().contains(keyword.lowercased()){
                    users.append(user)
                }
            }
        }
        else{
            users = preDefinedUsers
        }
        completion(Constants.PROCESS_SUCCESS, users)
    }
    
    static func getSkillMatchedUsers(skillId: Int64, completion: @escaping(String, [UserModel]) -> ()){
        var result : [UserModel] = []
        getHomeData(completion : {
            message, users in
            if message == Constants.PROCESS_SUCCESS {
                for user in users {
                    for skill in user.user_skills{
                        if skill.skill_id == skillId
                        {
                            result.append(user)
                            break
                        }
                    }
                    completion(Constants.PROCESS_SUCCESS, result)
                }
            }
        })
    }
    
    static func uploadImage(name: String, file: Data, completion: @escaping (String, String) -> ()) {
        
    }
    
    static func downloadImage(url: String, completion: @escaping (String, String) -> ()) {
        
    }
    
    //file download function
    /*
     All files has its own name and they will not be same, so all files are saved as a name based files.
     And database be 
     */
    static func downloadFile(urlString: String,completion: @escaping (URL, String) -> ()){
        
        let filenames = urlString.components(separatedBy: "/")
        let filename = filenames[filenames.count - 1]
        var savedFilePath = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])"  + "/" + filename
        
        
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: savedFilePath) {
            savedFilePath = "file:" + savedFilePath
            let localURL = URL(string: savedFilePath)!
            completion(localURL, Constants.PROCESS_SUCCESS)
            return
        } else {
            NSLog("FILE NOT AVAILABLE - downloading \(urlString)")
        }
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            documentsURL.appendPathComponent(filename)
            return (documentsURL, [.removePreviousFile])
        }
        
        Alamofire.download(urlString, to: destination).responseData { response in
            if let destinationUrl = response.destinationURL {
                
                completion(destinationUrl, Constants.PROCESS_SUCCESS)
            }
        }
    }
    
    static func loginWithFacebook(user: UserModel, completion: @escaping (String) -> ()) {
        
    }
    
    
}

