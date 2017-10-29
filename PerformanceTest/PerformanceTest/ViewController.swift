//
//  ViewController.swift
//  EVReflectionTestApp
//
//  Created by Edwin Vermeer on 4/9/16.
//  Copyright © 2016 evict. All rights reserved.
//

import UIKit
import EVReflection


class ViewController: UIViewController {
    
    // MARK: - General test setup and functions
    
    @IBOutlet weak var initialMemoryUsage: UILabel!
    @IBOutlet weak var testDuration: UILabel!
    @IBOutlet weak var curenMemoryUsage: UILabel!
    @IBOutlet weak var changedMemoryUsage: UILabel!
    
    var usage: UInt = 0
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        usage = report_memory()
        curenMemoryUsage.text = "\(NSNumber(value: Int32(usage)).description(withLocale: NSLocale.current))"
        initialMemoryUsage.text = "\(NSNumber(value: Int32(usage)).description(withLocale: NSLocale.current))"
        
        testIssue213()
    }
    
    override func didReceiveMemoryWarning() {
        print("WARNING: didReceiveMemoryWarning")
        super.didReceiveMemoryWarning()
    }
    
    func report_memory() -> UInt {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                          task_flavor_t(MACH_TASK_BASIC_INFO),
                          $0,
                          &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            print("Memory in use (in bytes): \(info.resident_size)")
            return UInt(info.resident_size)
        } else {
            print("Error with task_info(): " +
                (String(cString: mach_error_string(kerr), encoding: String.Encoding.ascii) ?? "unknown error"))
            return 0
        }
    }
    
    
    
    func doTest(test : ()-> ()) {
        let startTime = NSDate()
        let usageAtBegin = usage
    
        test()

        let endTime = NSDate()

        usage = report_memory()
        curenMemoryUsage.text = "\(NSNumber(value: Int32(usage)).description(withLocale: NSLocale.current))"

        let change: Int32 = (Int32(usage) - Int32(usageAtBegin))
        changedMemoryUsage.text = "\(NSNumber(value: change).description(withLocale: NSLocale.current))"

        testDuration.text = "\(endTime.timeIntervalSince(startTime as Date))"
    }
    
    // MARK: - Executing the tests
    
    @IBAction func test1(sender: AnyObject) {
        doTest {
            let a = TestObject1()
            for i in 1...1000 {
                a.listObject2?.append(TestObject2(id: i))
            }
            let b = a.toJsonString()
            let c = TestObject1(json: b)
            assert(c.listObject2?.count ?? 0 == 1000)
        }
    }

    @IBAction func test2(sender: AnyObject) {
        doTest {
            let test = ArrayDeserializationPerformanceTest()
            test.performanceTest1()
        }
    }

    @IBAction func test3(sender: AnyObject) {
        doTest {
            let a = TestObject1()
            a.listObject2?.append(TestObject2(id: 1))
            let b = a.toJsonString()
            let c = TestObject1(json: b)
            assert(c.listObject2?.count ?? 0 == 1)
        }
    }

    func testIssue213() {
        let path: String = Bundle(for: type(of: self)).path(forResource: "test", ofType: "json") ?? ""
        let content = try! String(contentsOfFile: path)
        let data = ResultArrayWrapper<Spot>(json: content)
        print("\(data)")
    }
    
}


// MARK: - Objects used in the tests


class TestObject1: EVObject {
    var name1: String? = "Object1 Name1"
    var name2: String? = "Object1 Name2"
    var name3: String? = "Object1 Name3"
    var name4: String? = "Object1 Name4"
    var name5: String? = "Object1 Name5"
    var name6: String? = "Object1 Name6"
    var name7: String? = "Object1 Name7"
    var name8: String? = "Object1 Name8"
    var name9: String? = "Object1 Name9"
    var name10: String? = "Object1 Name10"
    var name11: String? = "Object1 Name11"
    var name12: String? = "Object1 Name12"
    var name13: String? = "Object1 Name13"
    var name14: String? = "Object1 Name14"
    var name15: String? = "Object1 Name15"
    var name16: String? = "Object1 Name16"
    var name17: String? = "Object1 Name17"
    var name18: String? = "Object1 Name18"
    var name19: String? = "Object1 Name19"
    var name20: String? = "Object1 Name20"
    var name21: String? = "Object1 Name21"
    var name22: String? = "Object1 Name22"
    var name23: String? = "Object1 Name23"
    var name24: String? = "Object1 Name24"
    var name25: String? = "Object1 Name25"
    var name26: String? = "Object1 Name26"
    var name27: String? = "Object1 Name27"
    var name28: String? = "Object1 Name28"
    var name29: String? = "Object1 Name29"
    var name30: String? = "Object1 Name30"
    var listObject2: [TestObject2]? = []
}

class TestObject2: EVObject {
    var name: String? = "Object2 Name"

    init(id: Int) {
        super.init()
        name = "Object2 Name \(id)"
    }
    //workaround
    @available(*, deprecated: 0.0.1, message: "init isn't supported, use init(id:) instead")
    required init() {
        super.init()
    }
}











    



class ResultArrayWrapper<T: Model>: EVObject, EVGenericsKVC {
    required init() {
        super.init()
    }
    var data: [T]?
    
    func setGenericValue(_ value: AnyObject!, forUndefinedKey key: String) {
        switch key {
        case "data":
            data = value as? [T]
            break;
        case "meta":
            
            break;
            
        default:
            print("---> setValue '\(value)' for key '\(key)' should be handled.")
        }
    }
    
    func getGenericType() -> NSObject {
        return T() as NSObject
    }
}

class XMeta<T: Model>: Model, EVGenericsKVC {
    required init() {
        super.init()
    }
    
    var cursor: String?
    
    internal func setGenericValue(_ value: AnyObject!, forUndefinedKey key: String) {
        if(key == "data") {
            //data = value  as? [T]
        }
    }
    
    internal func getGenericType() -> NSObject {
        return T() as NSObject
    }
}

class Model: EVObject {
    
}

class Spot: Model {
    var id: String?
    var firstName: String?
    var lastName: String?
    var username: String?
    var email: String?
    var phone: String?
    var sex: String?
    var canBook: Bool = false
    var contractable: Bool = false
    
    var profile = ResultArrayWrapper<Profile>()
    
    override func setValue(_ value: Any!, forUndefinedKey key: String) {
        if key == "profile" {
            if let value = value as? ResultArrayWrapper<Profile> {
                self.profile = value
                return
            }
        }
        print("setValue forUndefinedKey \(key)")
    }
}

class Profile: Model {
    var about: String?
    var avatarUrl: String?
    var coverUrl: String?
}
