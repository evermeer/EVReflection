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
    func image() -> UIImage? {
        if let url = self.fileURL, let data = try? Data(contentsOf: url) {
            return UIImage(data: data)
        }
        return nil
    }
}
