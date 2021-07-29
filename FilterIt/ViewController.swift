//
//  ViewController.swift
//  FilterIt
//
//  Created by Atin Agnihotri on 28/07/21.
//

import CoreImage
import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var intensity: UISlider!
    
    var context: CIContext!
    var currentFilter: CIFilter!
    
    var currentImage: UIImage!
    
    let filters = ["CIBumpDistortion", "CIGaussianBlur", "CIPixellate", "CISepiaTone", "CITwirlDistortion", "CIUnsharpMask", "CIVignette"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupCoreImage()
    }
    
    func setupNavigationBar() {
        title = "FilterIt"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addImage))
    }
    
    func setupCoreImage() {
        context = CIContext()
        currentFilter = CIFilter(name: "CISepiaTone")
    }
    
    
    
    @objc func addImage() {
        let ac = UIAlertController(title: "Get image from . . .", message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let camera = UIAlertAction(title: "Camera", style: .default) { [weak self] _ in
                self?.importImage(with: .camera)
            }
            ac.addAction(camera)
        }
        
        let library = UIAlertAction(title: "Photo Library", style: .default) { [weak self] _ in
            self?.importImage(with: .photoLibrary)
        }
        ac.addAction(library)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        ac.addAction(cancel)
        
        present(ac, animated: true)
    }
    
    func importImage(with sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        dismiss(animated: true)
        currentImage = image
        
        setupForProcessing()
    }
    
    func setupForProcessing() {
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
    }

    
    func applyProcessing() {
        let inputKeys = currentFilter.inputKeys
        print(currentFilter)
        print(inputKeys)
        
        if inputKeys.contains(kCIInputIntensityKey) {
            currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey)
        }
        
        if inputKeys.contains(kCIInputRadiusKey) {
            currentFilter.setValue(intensity.value * 200, forKey: kCIInputRadiusKey)
        }
        
        if inputKeys.contains(kCIInputScaleKey) {
            currentFilter.setValue(intensity.value * 10, forKey: kCIInputScaleKey)
        }
        
        if inputKeys.contains(kCIInputCenterKey) {
            let halfWidth = currentImage.size.width / 2
            let halfHeight = currentImage.size.height / 2
            currentFilter.setValue(CIVector(x: halfWidth, y: halfHeight), forKey: kCIInputCenterKey)
        }
        
        guard let outputImage = currentFilter.outputImage else { return }
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return }
        
        let processedImage = UIImage(cgImage: cgImage)
        imageView.image = processedImage
    }
    
    
    @IBAction func changeFilter(_ sender: UIButton) {
        let ac = UIAlertController(title: "Choose filter", message: nil, preferredStyle: .actionSheet)
        
        for filter in filters {
            let action = UIAlertAction(title: filter, style: .default, handler: setFilter)
            ac.addAction(action)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        ac.addAction(cancel)
        
        if let popoverController = ac.popoverPresentationController {
            popoverController.sourceView = sender
        }
        present(ac, animated: true)
    }
    
    func setFilter(_ action: UIAlertAction) {
        guard currentImage != nil else { return }
        guard let filter = action.title else { return }
        currentFilter = CIFilter(name: filter)
        setupForProcessing()
//        let beginImage = CIImage(image: currentImage)
//        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
//        applyProcessing()
//        setupForProcessing()
        print(filter)
    }
    
    @IBAction func save(_ sender: UIButton) {
        
    }
    
    @IBAction func intensityChanged(_ sender: UISlider) {
        applyProcessing()
    }
    
}

