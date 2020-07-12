//
//  ViewController.swift
//  ObjectDetector
//
//  Created by Ashan Anuruddika on 7/12/20.
//  Copyright © 2020 Ashan. All rights reserved.
//

import UIKit

import CoreML

import Vision

class ViewController: UIViewController,UINavigationControllerDelegate {

    @IBOutlet weak var objectImageView: UIImageView!
    
    @IBOutlet weak var resultLablel: UILabel!
    
    @IBOutlet weak var findImageButton: UIButton!
    
    @IBOutlet weak var takePhotoButton: UIButton!
    
    private let imagePicker = UIImagePickerController()
    
    private lazy var request : VNCoreMLRequest = {
        
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else {
            
            fatalError("can't load model.")
            
        }
        
        let request = VNCoreMLRequest(model: model) { [weak self](request, error) in
            
            guard let strongSelf = self else { return}
            
            if let requestError = error {
                
                print(requestError.localizedDescription)
                
            }
            
            strongSelf.process(request)
            
        }
        
        return request
        
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        findImageButton.layer.cornerRadius = findImageButton.frame.height / 2
        
        takePhotoButton.layer.cornerRadius = takePhotoButton.frame.height / 2
        
        findImageButton.layer.borderColor = UIColor.black.cgColor
        
        findImageButton.layer.borderWidth = 2
        
        takePhotoButton.layer.borderColor = UIColor.black.cgColor
        
        takePhotoButton.layer.borderWidth = 2
        
        resultLablel.text = ""
    }
    
    
    private func process( _ request : VNRequest){
        
        guard let results = request.results as? [VNClassificationObservation],let dominantResult = results.first else {
            
            fatalError("Error getting the dominant result.")
            
        }
        
        DispatchQueue.main.async {
            
            self.resultLablel.text = "\(Int(dominantResult.confidence * 100))% \(dominantResult.identifier)"
            
        }
        
    }
    
    private func detectingImage(_ image : UIImage) {
        
        resultLablel.text = ""
        
        guard let ciImage = CIImage(image: image) else {
            
            print("unable to create CIImage.")
            
            return
            
        }
        
        resultLablel.text = "Detecting..."
        
        let handler = VNImageRequestHandler(ciImage: ciImage)
        
        DispatchQueue.global(qos: .userInteractive).async {
            
            do {
                
                try handler.perform([self.request])
                
            } catch {
                
                print(error)
                
            }
        }
        
    }


    @IBAction func findImageButtonDidTouch(_ sender: Any) {
        
        imagePicker.sourceType = .photoLibrary
        
        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    @IBAction func takePhotoDidTouch(_ sender: Any) {
        
        imagePicker.sourceType = .camera
        
        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)
        
    }
}

extension ViewController : UIImagePickerControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            objectImageView.image = pickedImage
            
            detectingImage(pickedImage)
            
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
}
