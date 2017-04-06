//
//  CKAsset+UIImage.swift
//  EVReflection
//
//  Created by Edwin Vermeer on 9/2/15.
//  Copyright © 2017 evict. All rights reserved.
//

import CloudKit
import UIKit

public extension CKAsset {
    public func image() -> UIImage? {
        if let data = try? Data(contentsOf: self.fileURL) {
            return UIImage(data: data)
        }
        return nil
    }
}
