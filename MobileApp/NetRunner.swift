//
//  NetRunner.swift
//  MobileApp
//
//  Created by kmgao on 2026/3/17.
//

import Foundation
import UIKit

 


class DataRevicer:NSObject{
    
    var index:Int = 1
    let name:String = "Swift"
  
    public override init(){}
 
    
}

//test struct immutable value

 
class UserInfo:NSObject{
    
    public init(height:Double, name:String?, age:Int){
        self.height = height
        self.name = name
        self.age = age
    }
    var height:Double
    var name:String?
    var age:Int
}




@objcMembers
class NetRunner:NSObject
{
    
    private var thread:Thread
    
    private let data:DataRevicer = DataRevicer()
    
    private let userinfo = UserInfo(height: 12.1, name: "swift", age: 18)
  
    private var calculatorRef: MathCalculatorRef?
 
    private var personRef:PersonRef?
    
    private var person_name:String?
 
    enum MathError: Error {
        case invalidState
        case invalidArgument(String)
        case unknownError(code: Int)
    }
    
    
    private func setSwiftName(_ name:String)->Void{
        person_name = name
    }
    
    public override init(){
        data.index = 11
//        userinfo.age = 20   //Immutable value 'self.userinfo' may only be initialized once
        self.thread = Thread()
        
        //使用示例 call C Language Interface
        calculatorRef = createMathCalculator(12.1)
        
        personRef = createPerson()
        setPersonName(personRef,String("Swift String").cString(using: String.Encoding.utf8))
        
        let swiftName = String(cString: getName(personRef));
        self.person_name = swiftName
        
        guard personRef != nil  else{
            print("aaaa")
            return
        }
         
        guard let optPointer = personRef else{
            return
        }
        
        if let person = personRef{
            person.pointee.age = 1
            person.pointee.height = 10
            setPersonName(personRef, "Swift")
        }
        
        
        setPersonName(optPointer,"Swift_name")
        
        print("code excuting...")
    }
    
    
    
    
    deinit{
        if let ref = calculatorRef {
            deleteMathCalculator(ref)
        }
        
        guard personRef != nil else{
            return
        }
        deletePerson(personRef)
        
    }
    
   
    
    @objc open func power(_ exponent: Double) throws -> Void {
        guard let ref = calculatorRef else {
            throw MathError.invalidState
        }
        var result: Double = 0
        let errorCode = mathCalculatorPower(ref, exponent, &result)

        switch errorCode {
        case 0:
            return
        case -2:
            throw MathError.invalidArgument("Exponent not supported for negative base.")
        default:
            throw MathError.unknownError(code: Int(errorCode))
        }
    }

    static func getVersion() -> String {
        if let versionCString = mathLibGetVersion() {
            return String(cString: versionCString)
        }
        return "Unknown"
    }
    
    
    @objc private func timerFire(){
        print("timer start run repeat")
    }
    
   
    
    @objc func startThread(){
        
        let loop = RunLoop.current
        let port = Port()
        
        loop.add(port, forMode: RunLoop.Mode.default)
        let timer = Timer(timeInterval: 2, target: self, selector: #selector(timerFire), userInfo: nil, repeats: true)
        
//        let timer = Timer(timeInterval: 1, repeats: true) { timer in
//            print("timer start run repeat")
//        }
        
        loop.add(timer, forMode: RunLoop.Mode.default)
        loop.run()
        
       
        
        
    }
    
    @objc open func startRun(){
        
        //        public convenience init(target: Any, selector: Selector, object argument: Any?)
        thread = .init(target: self, selector: #selector(startThread), object: nil)
        thread.start()
        
    }
    
    
    open class func getRunner()->NetRunner{
        let runner = NetRunner()
        return runner
    }
    
    
    @MainActor public func callOCFun()->Void{
        
        var name = "Swift String"
        
        let vc = ViewController();
        print("the index: %d",vc.selectIndex)
    }
    

    
    
    private func changeStringValue(_ name:String?)->Void{
         
        var newString = name;
        
        newString = "new Swift String"
        
        return  ;
    }
    
    
    private func callBack(_ block:((String?)->Void)?){
        if(block != nil){
            block!("swift")
        }
       
    }
    
    @objc open func doAction()->String{
         
        self.callBack(nil)
        
//        self.callBack { (name) in
//            print("the name is: %s",name!) 
//        }
        
        
         
        var swiftName = "ABC" + "EFG";
        
        swiftName += "aasdsaf"
        
        
        
        self.changeStringValue(swiftName)
        
        var p = Person()
        p.doRun()
        
        var pName = String("Swift String")
         
        
        if(self.thread.isExecuting){
            let info = UserInfo(height: 0.06,name: "Swift string",age: 10)
            self.perform(#selector(excuteInNewThread(userInfo:)), on: self.thread, with:info, waitUntilDone: true)
            
            NSLog("the age: %d", info.age)
            
        }
        
        if(self.thread.isExecuting){
            self.perform(#selector(NoMainThreadRun(_:name:params:)), on: self.thread, with: nil, waitUntilDone:true)
        }
         
       
        
        
        return "sucessfulll";
    }
    
    
    @objc  private func excuteInNewThread(userInfo:UserInfo?){
         
//      userInfo = UserInfo(height:12.82, name:"Swift", age:11)
    userInfo?.age = 15
        
        
        
        print("excuteInNewThread run....")
    }
    @objc  private func NoMainThreadRun(_ index:Int,name:String?,params:Dictionary< String, Any>?){
//    @objc internal func NoMainThreadRun(index:Int,name:String?, params:Dictionary< String, Any>?){
        NSLog("objc String print")
        print("swift String print")
        
    }
    
    
}
