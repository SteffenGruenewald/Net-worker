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
    
    static func login(email: String, password: String, completion: @escaping (String) -> () ){
        currentUser = ParseHelper.parseUser(JSON(TestJson.getMe()))
        completion(Constants.PROCESS_SUCCESS)
    }
    
    static func register(){
        
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
        let skillsData = JSON(TestJson.getSkillsJson()).arrayValue
        var skills : [SkillModel] = []
        for skillData in skillsData{
            skills.append(ParseHelper.parseSkill(skillData))
        }
        completion(Constants.PROCESS_SUCCESS, skills)
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
    
    
}
