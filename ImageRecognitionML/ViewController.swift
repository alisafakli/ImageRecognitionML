//
//  ViewController.swift
//  ImageRecognitionML
//
//  Created by Ali Safakli on 15.02.2018.
//  Copyright © 2018 Ali Safakli. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var imageViewObject: UIImageView!
    @IBOutlet weak var textViewObject: UITextView!
    @IBOutlet weak var buttonTakePhoto: UIButton!
    var imagePicker: UIImagePickerController!
    
    var spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    var loadingView: UIView = UIView()
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        textViewObject.text = "No image selected."
    }

    @IBAction func clearButtonTapped(_ sender: Any) {
        imageViewObject.image = #imageLiteral(resourceName: "Not_available.jpg")
        textViewObject.text = "No image selected."
    }
    
    
    @IBAction func takePictureTapped(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imageViewObject.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        imagePicker.dismiss(animated: true, completion: nil)
        photoIdentify(image: (info[UIImagePickerControllerOriginalImage] as? UIImage)!)
    }
    
    func photoIdentify(image: UIImage) {
        showActivityIndicator()
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else {
            fatalError("Model cannot loaded.")
        }
        
        let request = VNCoreMLRequest(model: model) {
            [weak self] request, error in
            guard let results = request.results as? [VNClassificationObservation],
                let firstResult = results.first else {
                    fatalError("cannot get result from VNCoreMLRequest")
            }
            
            DispatchQueue.main.async {
                self?.textViewObject.text = "Confidence = \(Int(firstResult.confidence * 100))%, \nIdentifier \((firstResult.identifier))"
                self?.hideActivityIndicator()
            }
            
        }
        
        guard let ciImage = CIImage(image: image) else {
            fatalError(" cannot conver to CIImage")
        }
        let imageHandler = VNImageRequestHandler(ciImage: ciImage)
        
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try imageHandler.perform([request])
            }catch {
                print("Error \(error)")
            }
            
        }
    }
    
    func showActivityIndicator() {
        DispatchQueue.main.async {
            self.loadingView = UIView()
            self.loadingView.frame = CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0)
            self.loadingView.center = self.view.center
            self.loadingView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            self.loadingView.alpha = 0.7
            self.loadingView.clipsToBounds = true
            self.loadingView.layer.cornerRadius = 10
            
            self.spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
            self.spinner.frame = CGRect(x: 0.0, y: 0.0, width: 80.0, height: 80.0)
            self.spinner.center = CGPoint(x:self.loadingView.bounds.size.width / 2, y:self.loadingView.bounds.size.height / 2)
            
            self.loadingView.addSubview(self.spinner)
            self.view.addSubview(self.loadingView)
            self.spinner.startAnimating()
        }
    }
    
    func hideActivityIndicator() {
        DispatchQueue.main.async {
            self.spinner.stopAnimating()
            self.loadingView.removeFromSuperview()
        }
    }
}

