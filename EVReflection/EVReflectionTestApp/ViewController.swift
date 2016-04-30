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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        usage = report_memory()
        curenMemoryUsage.text = "\(NSNumber(int: Int32(usage)).descriptionWithLocale(NSLocale.currentLocale()))"
        initialMemoryUsage.text = "\(NSNumber(int: Int32(usage)).descriptionWithLocale(NSLocale.currentLocale()))"
    }
    
    override func didReceiveMemoryWarning() {
        print("WARNING: didReceiveMemoryWarning")
        super.didReceiveMemoryWarning()
    }

    func report_memory() -> UInt {
        var info = task_basic_info()
        var count = mach_msg_type_number_t(sizeofValue(info))/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(&info) {
            
            task_info(mach_task_self_,
                      task_flavor_t(TASK_BASIC_INFO),
                      task_info_t($0),
                      &count)
            
        }
        
        if kerr == KERN_SUCCESS {
            print("Memory in use (in bytes): \(NSNumber(int: Int32(info.resident_size)).descriptionWithLocale(NSLocale.currentLocale()))")
            return UInt(info.resident_size)
        } else {
            print("Error with task_info(): " +
                (String.fromCString(mach_error_string(kerr)) ?? "unknown error"))
            return 0
        }
    }
    
    func doTest(test : ()-> ()) {
        let startTime = NSDate()
        let usageAtBegin = usage
    
        test()

        let endTime = NSDate()

        usage = report_memory()
        curenMemoryUsage.text = "\(NSNumber(int: Int32(usage)).descriptionWithLocale(NSLocale.currentLocale()))"

        let change: Int32 = (Int32(usage) - Int32(usageAtBegin))
        changedMemoryUsage.text = "\(NSNumber(int: change).descriptionWithLocale(NSLocale.currentLocale()))"

        testDuration.text = "\(endTime.timeIntervalSinceDate(startTime))"
    }
    
    // MARK: - Executing the tests
    
    @IBAction func test1(sender: AnyObject) {
        doTest {
            let a = TestObject1()
            for i in 1...1000 {
                a.ListObject2?.append(TestObject2(id: i))
            }
            let b = a.toJsonString()
            let c = TestObject1(json: b)
            assert(c.ListObject2?.count ?? 0 == 1000)
        }
    }

    @IBAction func test2(sender: AnyObject) {
        doTest {
            let test = ArrayDeserializationPerformanceTest()
            test.performanceTest1()
        }
    }


}


// MARK: - Objects used in the tests


class TestObject1: EVObject {
    var Name: String? = "Object1 Name"
    var ListObject2: [TestObject2]? = []
}

class TestObject2: EVObject {
    var Name: String? = "Object2 Name"

    init(id: Int) {
        super.init()
        Name = "Object2 Name \(id)"
    }
    //poep
    @available(*, deprecated=0.0.1, message="init isn't supported, use init(id:) instead")
    required init() {
        super.init()
    }
}
