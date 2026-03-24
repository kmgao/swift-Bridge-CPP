//
//  Person.swift
//  MobileApp
//
//  Created by kmgao on 2026/3/18.
//

import Foundation


class Person:NSObject{
    
    private var name:String
    private var index:Int 
    
    public override init(){
        self.name = ""
        self.index = 1
    }
    
    public class func getObjCounter() -> Int{
        
        return 100
    }
    
    public func doRun(){
        
    }
    
    public func doExcute(_ name:String?, andType typeIndex:Int){
        
    }
    
}
