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
    
    static let SERVER_BASE_URL          = "http://35.167.68.193"
    
    //static let SERVER_BASE_URL          = "http://192.168.1.120/NetWorker"
    static let SERVER_URL                = SERVER_BASE_URL + "/index.php/Api/"
    
    static let REQ_GET_ALLSKILLS        = SERVER_URL + "getSkills"
    static let REQ_REGISTER             = SERVER_URL + "registerUser"
    static let REQ_UPLOADIMAGE          = SERVER_URL + "uploadImage"
    static let REQ_UPDATEUSER           = SERVER_URL + "updateUser"
    static let REQ_ADDUSERSKILL         = SERVER_URL + "addUserSkill"
    static let REQ_LOGIN                = SERVER_URL + "login"
    static let REQ_GETSKILLVERSION      = SERVER_URL + "getSkillVersion"
    static let REQ_UPLOADPOSITION       = SERVER_URL + "uploadPosition"
    static let REQ_GETUSERSCHEDULE      = SERVER_URL + "getUserSchedule"
    static let REQ_SAVESCHEDULES        = SERVER_URL + "saveUserSchedules"
    static let REQ_SEARCHUSERS          = SERVER_URL + "searchMatchedUsers"
    static let REQ_GETNEARBYWORKERS     = SERVER_URL + "getNearByWorkers"
    static let REQ_GETWORKERREVIEWS     = SERVER_URL + "getWorkerReviews"
    static let REQ_GETCLIENTREVIEWS     = SERVER_URL + "getClientReviews"
    static let REQ_SENDREQUESTTOWORKER  = SERVER_URL + "sendRequestToWorker"
    static let REQ_GETPROCESSINGJOBS    = SERVER_URL + "getProcessingJobs"
    static let REQ_REJECTREQUEST        = SERVER_URL + "rejectRequest"
    
    
    
    static func login(email: String, password: String, completion: @escaping (String) -> () ){
        var token = ""
        if let tokenObject = UserDefaults.standard.value(forKey: Constants.KEY_USER_TOKEN) {
            token = tokenObject as! String
        }
        
        //currentUser = ParseHelper.parseUser(JSON(TestJson.getMe()))
        let params = [Constants.KEY_USER_EMAIL: email,
                      Constants.KEY_USER_PASSWORD: password,
                      Constants.KEY_USER_TOKEN : token]
        Alamofire.request(REQ_LOGIN, method: .post, parameters: params).responseJSON { response in
            if response.result.isFailure{
                completion(Constants.CHECK_NETWORK_ERROR)
            }
            else
            {
                let json = JSON(response.result.value!)
                let message = json[Constants.RES_MESSAGE].stringValue
                if message == Constants.PROCESS_SUCCESS {
                    currentUser = ParseHelper.parseUser(json[Constants.RES_USER_INFO])
                    for scheduleObject in json[Constants.KEY_USER_SCHEDULES].arrayValue {
                        currentUser?.user_schedules.append(ParseHelper.parseSchedule(scheduleObject))
                    }
                    
                    UIApplication.shared.applicationIconBadgeNumber = 0
                    for dealObject in json["jobs"].arrayValue {
                        if dealObject["isclient"].intValue == 1 {
                            pendingMyDeals.append(ParseHelper.parseDeal(dealObject))
                        }
                        else {
                            pendingWorkingDeals.append(ParseHelper.parseDeal(dealObject))
                        }
                    }
                    completion(Constants.PROCESS_SUCCESS)
                }
                else {
                    completion(message)
                }
            }
        }
    }
    
    static func register(_ user: UserModel, completion: @escaping (String) -> ()){
        let userObject = user.getUserObject()
        Alamofire.request(REQ_REGISTER, method: .post, parameters: userObject).responseJSON { response in
            if response.result.isFailure{
                completion(Constants.CHECK_NETWORK_ERROR)
            }
            else
            {
                let json = JSON(response.result.value!)
                let message = json[Constants.RES_MESSAGE].stringValue
                if message == Constants.PROCESS_SUCCESS {
                    user.user_id = json[Constants.KEY_USER_ID].int64Value
                    currentUser = user
                    completion(Constants.PROCESS_SUCCESS)
                }
                else {
                    completion(message)
                }
            }
        }
    }
    
    static func passwordChangeRequest(email: String){
        
    }
    
    static func getUsers(available: Bool) {
        
    }
    
    static func advancedSearch(){
        
    }
    
    static func getSkillsArray(completion : @escaping (String) -> ()){
        
        getSkillVersion(completion: {
            message, version in
            if message == Constants.PROCESS_SUCCESS {
                if let skill_version = UserDefaults.standard.value(forKey: "skill_version"){
                    if (skill_version as! Int) < version {
                        
                        getSkills(version, completion: {
                            message in
                            completion(message)
                        })
                    }
                    else {
                        completion(Constants.PROCESS_SUCCESS)
                    }
                    
                }
                else {
                    getSkills(version, completion: {
                        message in
                        completion(message)
                    })
                }
                
                
                
            }
            else {
                completion(message)
            }
        })
        
        
        
    }
    
    static func getSkills(_ version: Int, completion: @escaping (String) -> ()) {
        
        Alamofire.request(REQ_GET_ALLSKILLS, method: .post, parameters: nil).responseJSON { response in
            if response.result.isFailure{
                completion(Constants.CHECK_NETWORK_ERROR)
            }
            else
            {
                var json = JSON(response.result.value!)
                let message = json["message"].stringValue
                if message == Constants.PROCESS_SUCCESS {
                    json = json["result"]
                    fmdbManager.emptyTables()
                    fmdbManager.createTables()
                    let localDataSet = FMDBManagerSetData()
                    let categoryObject = json["category"].arrayValue
                    localDataSet.saveCategories(categoryObject)
                    let skillObject = json["skill"].arrayValue
                    localDataSet.saveSkills(skillObject)
                    let skillTagObject = json["skill_tag"].arrayValue
                    localDataSet.saveSkill_Tags(skillTagObject)
                    let tagObject = json["tag"].arrayValue
                    localDataSet.saveTags(tagObject)
                    
                    UserDefaults.standard.set(version, forKey: "skill_version")
                    completion(Constants.PROCESS_SUCCESS)
                }
                else {
                    completion(message)
                }
                
            }
        }
    }
    
    static func getSkillVersion(completion: @escaping (String, Int) -> ()){
        Alamofire.request(REQ_GETSKILLVERSION).responseJSON { response in
            if response.result.isFailure{
                completion(Constants.CHECK_NETWORK_ERROR, 0)
            }
            else
            {
                var json = JSON(response.result.value!)
                let message = json["message"].stringValue
                if message == Constants.PROCESS_SUCCESS {
                    let skill_version = json["result"].intValue
                    completion(Constants.PROCESS_SUCCESS, skill_version)
                }
                else {
                    completion(message, 0)
                }
                
            }
        }
    }
    
    static func getNameMatchedUsers(keyword: String, from preDefinedUsers: [UserModel], completion : @escaping (String, [UserModel]) -> ()){
        
        var users : [UserModel] = []
        if keyword.count > 0{
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
    
    
    static func uploadImage(name: String, imageData: Data, completion: @escaping (String, String) -> ()) {
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(imageData, withName: "image", fileName: "test.jpg", mimeType: "image/jpg")                //multipartFormData.boundary
                multipartFormData.append(name.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "image_name")
        },
            to: REQ_UPLOADIMAGE,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        
                        switch response.result {
                            
                        case .success(_):
                            let json = JSON(response.result.value!)
                            let message = json[Constants.RES_MESSAGE].stringValue
                            if message == Constants.PROCESS_SUCCESS {
                                let imageurl = json[Constants.KEY_IMAGEURL].stringValue
                                //CommonUtils.saveImageToLocal(name, data: imageData)
                                completion(message, imageurl)
                            }
                            else {
                                completion(message, "")
                            }
                            
                        case .failure(_):
                            
                            completion(Constants.CHECK_NETWORK_ERROR, "")
                            
                        }
                    }
                    
                case .failure(_):
                    completion(Constants.CHECK_ENCODING_ERROR, "")
                }
        })
    }
    
    //MARK -- File Download function
    static func downloadFile(urlString: String,completion: @escaping (String, URL?) -> ()){
        
        let filenames = urlString.components(separatedBy: "/")
        let filename = filenames[filenames.count - 1]
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            documentsURL.appendPathComponent(filename)
            return (documentsURL, [.removePreviousFile])
        }
        
        Alamofire.download(urlString, to: destination).responseData { response in
            if let destinationUrl = response.destinationURL {
                
                completion(Constants.PROCESS_SUCCESS, destinationUrl)
            }
            else {
                completion(Constants.PROCESS_FAIL, nil)
            }
        }
    }
    
    static func loginWithFacebook(user: UserModel, completion: @escaping (String) -> ()) {
        
    }
    
    static func updateProfile(profile: [String: AnyObject], completion: @escaping (String) -> ()) {
        
        Alamofire.request(REQ_UPDATEUSER, method: .post, parameters: profile).responseJSON { response in
            if response.result.isFailure{
                completion(Constants.CHECK_NETWORK_ERROR)
            }
            else
            {
                let json = JSON(response.result.value!)
                let message = json[Constants.RES_MESSAGE].stringValue
                completion(message)
            }
        }
    }
    
    static func uploadPosition(completion: @escaping (String) -> ()) {
        let params = ["user_latitude" : currentLatitude as AnyObject,
                      "user_longitude" : currentLongitude as AnyObject,
                      "user_id" : currentUser!.user_id as AnyObject,
                      "user_available" : currentUser!.user_available as AnyObject]
        Alamofire.request(REQ_UPLOADPOSITION, method: .post, parameters: params).responseJSON { response in
            if response.result.isFailure{
                completion(Constants.CHECK_NETWORK_ERROR)
            }
            else
            {
                let json = JSON(response.result.value!)
                let message = json[Constants.RES_MESSAGE].stringValue
                completion(message)
            }
        }
    }
    
    static func saveChangedUserSchedule(_ schedules: [DayScheduleModel], completion: @escaping (String) -> ()) {
        var scheduleArray = [String: AnyObject]()
        var objects = [AnyObject]()
        for schedule in schedules {
            objects.append(schedule.getObject() as AnyObject)
        }
        scheduleArray["schedules"] = objects as AnyObject
        scheduleArray["user_id"] = currentUser!.user_id as AnyObject
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: scheduleArray, options: .prettyPrinted)
            var request = URLRequest(url: URL(string: REQ_SAVESCHEDULES)!)
            request.httpBody = jsonData
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            Alamofire.request(request).responseJSON { response in
                if response.result.isFailure{
                    completion(Constants.CHECK_NETWORK_ERROR)
                }
                else
                {
                    let json = JSON(response.result.value!)
                    let message = json[Constants.RES_MESSAGE].stringValue
                    if message == Constants.PROCESS_SUCCESS {
                        var schedules = [DayScheduleModel]()
                        for scheduleObject in json[Constants.KEY_USER_SCHEDULES].arrayValue {
                            schedules.append(ParseHelper.parseSchedule(scheduleObject))
                        }
                        currentUser?.user_schedules = schedules
                        completion(message)
                    }
                    else {
                        completion(message)
                    }
                    
                }
            }
        }
        catch {
            completion(Constants.PROCESS_FAIL)
        }
    }
    
    static func getSkillMatchedUsers(deal: DealModel, completion: @escaping (String, [UserModel]) -> ()) {
        let params = [Constants.KEY_SKILL_ID: deal.deal_skill.skill_id as AnyObject,
                      "startday": deal.deal_startday as AnyObject,
                      "endday": deal.deal_endday as AnyObject,
                      "starttime" : deal.deal_starttime as AnyObject,
                      "endtime" : deal.deal_endtime as AnyObject,
                      "latitude" : currentLatitude as AnyObject,
                      "longitude" : currentLongitude as AnyObject,
                      "distance" : deal.deal_distance as AnyObject,
                      "time" : (Int64(1 << (deal.deal_endtime - deal.deal_starttime) - 1) << Int64(deal.deal_starttime - 1)) as AnyObject,
                      Constants.KEY_USER_ID : deal.deal_client.user_id as  AnyObject
        ]
        Alamofire.request(REQ_SEARCHUSERS, method: .post, parameters: params).responseJSON { response in
            if response.result.isFailure{
                completion(Constants.CHECK_NETWORK_ERROR, [])
            }
            else
            {
                let json = JSON(response.result.value!)
                let message = json[Constants.RES_MESSAGE].stringValue
                let userObjects = json["users"].arrayValue
                var users = [UserModel]()
                for object in userObjects {
                    users.append(ParseHelper.parseUser(object))
                }
                completion(message, users)
            }
        }
    }
    
    static func getNearByWorkers(completion: @escaping (String, [UserModel]) -> ()) {
        let params = [
            Constants.KEY_USER_ID : currentUser?.user_id as AnyObject,
            "distance" : currentUser?.user_rangedistance as AnyObject,
            "latitude" : currentLatitude as AnyObject,
            "longitude" : currentLongitude as AnyObject
        ]
        Alamofire.request(REQ_GETNEARBYWORKERS, method: .post, parameters: params).responseJSON { response in
            if response.result.isFailure{
                completion(Constants.CHECK_NETWORK_ERROR, [])
            }
            else
            {
                let json = JSON(response.result.value!)
                let message = json[Constants.RES_MESSAGE].stringValue
                let userObjects = json["users"].arrayValue
                var users = [UserModel]()
                for object in userObjects {
                    users.append(ParseHelper.parseUser(object))
                }
                completion(message, users)
            }
        }
    }
    
    static func getUserSchedule(_ userId: Int64, completion: @escaping (String, [DayScheduleModel]) -> ())
    {
        Alamofire.request(REQ_GETUSERSCHEDULE, method: .post, parameters: [Constants.KEY_USER_ID : userId]).responseJSON { response in
            if response.result.isFailure{
                completion(Constants.CHECK_NETWORK_ERROR, [])
            }
            else
            {
                let json = JSON(response.result.value!)
                let message = json[Constants.RES_MESSAGE].stringValue
                let userObjects = json[Constants.KEY_USER_SCHEDULES].arrayValue
                var schedules = [DayScheduleModel]()
                for object in userObjects {
                    schedules.append(ParseHelper.parseSchedule(object))
                }
                completion(message, schedules)
            }
        }
    }
    
    static func getWorkerReviews(_ userId: Int64, completion: @escaping (String, Float,  [RatingModel], [Int: Float]) -> ())
    {
        Alamofire.request(REQ_GETWORKERREVIEWS, method: .post, parameters: [Constants.KEY_USER_ID : userId]).responseJSON { response in
            if response.result.isFailure{
                completion(Constants.CHECK_NETWORK_ERROR, 0, [], [:])
            }
            else
            {
                let json = JSON(response.result.value!)
                let message = json[Constants.RES_MESSAGE].stringValue
                let userObjects = json[Constants.KEY_USER_RATINGS].arrayValue
                var ratings = [RatingModel]()
                for object in userObjects {
                    ratings.append(ParseHelper.parseRating(object))
                }
                var skill_marks = [Int: Float]()
                
                let value = json["user_skill_marks"]
                //.dictionaryObject as! [String: String]
                if let dict = value.dictionaryObject {
                    let objects = dict as! [String: String]
                    for key in objects.keys {
                        skill_marks[Int(key)!] = Float(objects[key]!)!
                    }
                }
                completion(message, json["avg_marks"].floatValue, ratings, skill_marks)
            }
        }
    }
    static func getClientReviews(_ userId: Int64, completion: @escaping (String, Float, [RatingModel]) -> ())
    {
        Alamofire.request(REQ_GETCLIENTREVIEWS, method: .post, parameters: [Constants.KEY_USER_ID : userId]).responseJSON { response in
            if response.result.isFailure{
                completion(Constants.CHECK_NETWORK_ERROR,0, [])
            }
            else
            {
                let json = JSON(response.result.value!)
                let message = json[Constants.RES_MESSAGE].stringValue
                let userObjects = json[Constants.KEY_USER_RATINGS].arrayValue
                var ratings = [RatingModel]()
                for object in userObjects {
                    ratings.append(ParseHelper.parseRating(object))
                }
                
                completion(message, json[Constants.KEY_USER_AVGRATING].floatValue, ratings)
            }
        }
    }
    
    static func sendRequestToWorker(deal: DealModel, completion: @escaping (String, DealModel?) -> ()) {
        Alamofire.request(REQ_SENDREQUESTTOWORKER, method: .post, parameters: deal.getObject()).responseJSON { response in
            if response.result.isFailure{
                completion(Constants.CHECK_NETWORK_ERROR, nil)
            }
            else
            {
                let json = JSON(response.result.value!)
                let message = json[Constants.RES_MESSAGE].stringValue
                let deal = ParseHelper.parseDeal(json["deal"])
                completion(message, deal)
            }
        }
    }
    
    static func cancelJob() {
        
    }
    
    static func confirmJob() {
        
    }
    
    static func rejectRequest(_ requestId: Int64, completion : @escaping (String) -> ()) {
        Alamofire.request(REQ_REJECTREQUEST, method: .post, parameters: ["request_id": requestId, "user_id": currentUser!.user_id]).responseJSON { response in
            if response.result.isFailure{
                completion(Constants.CHECK_NETWORK_ERROR)
            }
            else
            {
                let json = JSON(response.result.value!)
                let message = json[Constants.RES_MESSAGE].stringValue
                completion(message)
            }
        }
    }
    
    static func getProcessingJobs(completion: @escaping (String) -> ()) {
        Alamofire.request(REQ_GETPROCESSINGJOBS, method: .post, parameters: ["user_id" : currentUser!.user_id]).responseJSON { response in
            if response.result.isFailure{
                completion(Constants.CHECK_NETWORK_ERROR)
            }
            else
            {
                let json = JSON(response.result.value!)
                let message = json[Constants.RES_MESSAGE].stringValue
                
                if message == Constants.PROCESS_SUCCESS {
                    pendingMyDeals = [DealModel]()
                    pendingWorkingDeals = [DealModel]()
                    for dealObject in json["deals"].arrayValue {
                        if dealObject["isclient"].intValue == 1 {
                            pendingMyDeals.append(ParseHelper.parseDeal(dealObject))
                        }
                        else {
                            pendingWorkingDeals.append(ParseHelper.parseDeal(dealObject))
                        }
                    }
                }
                completion(message)
            }
        }
    }
    
    
    
}



