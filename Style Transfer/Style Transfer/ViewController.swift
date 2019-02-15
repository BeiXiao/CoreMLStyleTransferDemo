//
//  ViewController.swift
//  Style Transfer Demo
//
//  Created by majx on 2/12/19.
//  Copyright © 2019 M. All rights reserved.
//

import UIKit
import CoreML

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    let imagePicker = UIImagePickerController()
    var currentImage = UIImage(named: "GoldFluid")
    let styleArray = ["Flitter", "GoldFluid", "Pigment", "VanGogh", "Ukiyoe"]
    var styleIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.view.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        imagePicker.delegate = self
        imageView.layer.masksToBounds = true
        addStyleItems()
    }

    func addStyleItems() {
        for (i, style) in styleArray.enumerated() {
            let styleButton = UIButton(type: .custom)
            styleButton.frame = CGRect(x: 20 + i * 136, y: 0, width: 120, height: 148)
            let styleImage = UIImage(named: "style_\(style)")
            styleButton.setImage(styleImage, for: .normal)
            styleButton.tag = i
            styleButton.addTarget(self, action: #selector(changeStyle), for: .touchUpInside)
            self.scrollView.addSubview(styleButton)
        }
        self.scrollView.clipsToBounds = false
        self.scrollView.contentSize = CGSize(width: 20 + styleArray.count * 136, height: 148)
    }
    
    // 选择图片
    @IBAction func chooseImage(_ sender: Any) {
        // 选择图片
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    // 切换风格
    @objc func changeStyle(_ sender: Any) {
        guard let button: UIButton = sender as? UIButton else {
            return
        }
        for (i, view) in self.scrollView.subviews.enumerated() {
            guard let styleButton = view as? UIButton else { continue }
            UIView.animate(withDuration: 0.1) {
                styleButton.transform = .identity
            }
        }
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 10, initialSpringVelocity: 0.8, options: .curveEaseIn, animations: {
            button.transform = CGAffineTransform(translationX: 0, y: -12)
        }) { (isFinish) in

        }
        let tag = button.tag
        styleIndex = tag
        transformImage(button)
    }
    
    // 风格迁移
    @IBAction func transformImage(_ sender: Any) {
        DispatchQueue.global().async { [weak self]  in
            guard let sself = self else { return }
            let model = MyStyleTransfer()
            let numStyles = sself.styleArray.count
            
            let styleArray = try? MLMultiArray(shape: [numStyles] as [NSNumber], dataType: .double)
            for i in 0...((styleArray?.count)!-1) {
                styleArray?[i] = 0.0
            }
            
            styleArray?[sself.styleIndex] = 1.0
            guard let image = sself.currentImage else { return }
            guard let imageBuffer = sself.pixelBuffer(from: image) else { return }
            
            do {
                let predictionOutput = try model.prediction(image: imageBuffer, index: styleArray!)
                let ciImage = CIImage(cvPixelBuffer: predictionOutput.stylizedImage)
                let tempContext = CIContext(options: nil)
                let tempImage = tempContext.createCGImage(ciImage, from: CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(predictionOutput.stylizedImage), height: CVPixelBufferGetHeight(predictionOutput.stylizedImage)))
                DispatchQueue.main.async { [weak self]  in
                    guard let sself = self else { return }
                    sself.imageView.image = UIImage(cgImage: tempImage!)
                }
            } catch let error as NSError {
                print("CoreML Model Error: \(error)")
            }
        }
    }
    
    func pixelBuffer(from image: UIImage) -> CVPixelBuffer? {
        // 1
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 600, height: 600), true, 2.0)
        image.draw(in: CGRect(x: 0, y: 0, width: 600, height: 600))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        // 2
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, 600, 600, kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return nil
        }

        // 3
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)

        // 4
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: 600, height: 600, bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

        // 5
        context?.translateBy(x: 0, y: 600)
        context?.scaleBy(x: 1.0, y: -1.0)

        // 6
        UIGraphicsPushContext(context!)
        image.draw(in: CGRect(x: 0, y: 0, width: 600, height: 600))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        return pixelBuffer
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        if let pickedImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
            imageView.image = pickedImage
            currentImage = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
