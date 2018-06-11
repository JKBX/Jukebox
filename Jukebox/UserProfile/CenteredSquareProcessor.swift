//
//  CenteredSquareProcessor.swift
//  Jukebox
//
//  Created by Philipp on 08.06.18.
//  Copyright © 2018 Jukebox. All rights reserved.
//

import Kingfisher

struct CenteredSquareProcessor: ImageProcessor {
    // `identifier` should be the same for processors with same properties/functionality
    // It will be used when storing and retrieving the image to/from cache.
    let identifier = "io.deap.csprocessor"
    
    // Convert input data/image to target image and return it.
    func process(item: ImageProcessItem, options: KingfisherOptionsInfo) -> Image? {
        switch item {
        case .image(let image):
            
            var imageHeight = image.size.height
            var imageWidth = image.size.width
            
            //Determine which way to crop
            if imageHeight > imageWidth {
                imageHeight = imageWidth
            }
            else {
                imageWidth = imageHeight
            }
            
            let size = CGSize(width: imageWidth, height: imageHeight)
            
            let refWidth : CGFloat = CGFloat(image.cgImage!.width)
            let refHeight : CGFloat = CGFloat(image.cgImage!.height)
            
            let x = (refWidth) / 2//(refWidth - size.width) / 2
            let y = (refHeight) / 2//(refHeight - size.height) / 2
            
            let cropRect = CGRect(x: x, y: y, width: size.height, height: size.width)
            if let imageRef = image.cgImage!.cropping(to: cropRect) {
                return UIImage(cgImage: imageRef, scale: 0, orientation: image.imageOrientation)
            }
            
            return nil
            
        case .data(_):
            return (DefaultImageProcessor.default >> self).process(item: item, options: options)
        }
        /*switch item {
        case .image(let image):
            print("already an image")
            return image
        case .data(let data):
            return WebpFramework.createImage(from: webpData)
        }*/
    }
}



/*
 public struct CenterCropImageProcessor: ImageProcessor {
 public let identifier: String
 
 /// Center point to crop to.
 public var centerPoint: CGFloat = 0.0
 
 /// Initialize a `CenterCropImageProcessor`
 ///
 /// - parameter centerPoint: The center point to crop to.
 ///
 /// - returns: An initialized `CenterCropImageProcessor`.
 public init(centerPoint: CGFloat? = nil) {
 if let center = centerPoint {
 self.centerPoint = center
 }
 self.identifier = "com.l4grange.CenterCropImageProcessor(\(centerPoint))"
 }
 
 public func process(item: ImageProcessItem, options: KingfisherOptionsInfo) -> Image? {
 switch item {
 case .image(let image):
 
 var imageHeight = image.size.height
 var imageWidth = image.size.width
 
 if imageHeight > imageWidth {
 imageHeight = imageWidth
 }
 else {
 imageWidth = imageHeight
 }
 
 let size = CGSize(width: imageWidth, height: imageHeight)
 
 let refWidth : CGFloat = CGFloat(image.cgImage!.width)
 let refHeight : CGFloat = CGFloat(image.cgImage!.height)
 
 let x = (refWidth - size.width) / 2
 let y = (refHeight - size.height) / 2
 
 let cropRect = CGRect(x: x, y: y, width: size.height, height: size.width)
 if let imageRef = image.cgImage!.cropping(to: cropRect) {
 return UIImage(cgImage: imageRef, scale: 0, orientation: image.imageOrientation)
 }
 
 return nil
 
 case .data(_):
 return (DefaultImageProcessor.default >> self).process(item: item, options: options)
 }
 }
 }
 
 
 */
