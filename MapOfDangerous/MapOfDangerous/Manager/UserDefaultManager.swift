//
//  UserDefaultManager.swift
//  MapOfDangerous
//
//  Created by 張文煥 on 2021/12/28.
//

import Foundation

class UserDefaultManager{
    
    private init() {}
    
    static let shared = UserDefaultManager()
    
    let userDefault = UserDefaults()
    
    func saveToken(token: String, key: String){
        userDefault.setValue(token, forKey: key)
    }
    
    func setViewCount(count: Int, key: String){
        userDefault.setValue(count, forKey: key)
        
    }
    
    func getViewCount(key: String) -> Int?{
        guard let count = userDefault.value(forKey: key) else { return 0 }
        print(count)
        return (count as! Int)
    }
    
    func saveNote(note: String, key: String){
        userDefault.setValue(note, forKey: key)
    }
    
    func getNote(key: String) -> String?{
        guard let noteInDefault = userDefault.value(forKey: key) else { return nil }
        return (noteInDefault as! String)
    }
    
    func removeData(key: String){
        userDefault.removeObject(forKey: key)
    }
    
    func saveNoteTime(time: String, key: String){
        userDefault.setValue(time, forKey: key)
    }
    
    func getNoteTime(key: String) -> String?{
        guard let time = userDefault.value(forKey: key) else { return nil }
        return (time as! String)
    }
    
    
}
