//
//  ImageEditorViewController.swift
//  EditorImages
//
//  Created by Кирилл Зубков on 14.04.2024.
//

import UIKit
import SnapKit
import Combine
import PencilKit
import Photos
import PhotosUI

final class ImageEditorViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel = ImageEdtiorViewModel()
    private var subscriptions = Set<AnyCancellable>()
    private var transformHelper: ViewTransformGestureHelper?
    
    private lazy var pickerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Загрузить изображение", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(self,
                         action: #selector(didTapPickerButton),
                         for: .touchUpInside)
        return button
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Сохранить", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(self,
                         action: #selector(didTapSaveButton),
                         for: .touchUpInside)
        return button
    }()
    
    private var drawing: PKDrawing = {
        let drawing = PKDrawing()
        return drawing
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var canvasView: PKCanvasView = {
        let canvasView = PKCanvasView()
        canvasView.drawing = drawing
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        return canvasView
    }()
    
    private lazy var toolPicker: PKToolPicker = {
        let picker = PKToolPicker()
        picker.addObserver(canvasView)
        picker.setVisible(true, forFirstResponder: canvasView)
        canvasView.becomeFirstResponder()
        return picker
    }()
    
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(customView: saveButton),
            UIBarButtonItem(customView: pickerButton)
        ]
        addViews()
        addConstraints()
        binding()
        
        transformHelper = ViewTransformGestureHelper(gestureView: view,
                                                     transformView: canvasView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateLayout(for: toolPicker)
    }
    
    
    // MARK: - Private Methods
    
    private func addViews() {
        view.addSubview(canvasView)
        canvasView.subviews.first?.insertSubview(imageView, at: 0)
    }
    
    private func addConstraints() {
        canvasView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func binding() {
        viewModel.$shouldShowImagePicker
            .sink { [weak self] shouldShow in
                if shouldShow {
                    self?.viewModel.shouldShowImagePicker = false
                    self?.showPickerSelectionAlert()
                }
            }
            .store(in: &subscriptions)
        
        viewModel.$editableImage
            .sink { [weak self] image in
                self?.imageView.image = image
            }
            .store(in: &subscriptions)
        
        viewModel.$shouldShowFinishAlert
            .sink { [weak self] shouldShow in
                if shouldShow {
                    self?.viewModel.shouldShowFinishAlert = false
                    self?.showFinishAlert()
                }
            }
            .store(in: &subscriptions)
    }
    
    private func showPickerSelectionAlert() {
        let alertController = UIAlertController(title: nil,
                                                message: nil,
                                                preferredStyle: .actionSheet)
        
        alertController.popoverPresentationController?.sourceView = pickerButton
        alertController.popoverPresentationController?.sourceRect = pickerButton.frame
        
        let galleryAction = UIAlertAction(title: "Фото",
                                          style: .default) { [weak self] _ in
            self?.showImagePicker()
        }
        
        let cameraAction = UIAlertAction(title: "Камера",
                                         style: .default) { [weak self] _ in
            self?.showCameraPicker()
            
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        alertController.addAction(galleryAction)
        alertController.addAction(cameraAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    private func showImagePicker() {
        var phPickerConfig = PHPickerConfiguration(photoLibrary: .shared())
        phPickerConfig.selectionLimit = 1
        phPickerConfig.filter = .images
        let phPickerVC = PHPickerViewController(configuration: phPickerConfig)
        phPickerVC.delegate = self
        present(phPickerVC, animated: true)
    }
    
    private func showCameraPicker() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        imagePickerController.sourceType = .camera
        present(imagePickerController, animated: true)
    }
    
    private func showFinishAlert() {
        let alertController = UIAlertController(title: "Успешно сохранено",
                                                message: nil,
                                                preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK",
                                     style: .default) { [weak self] _ in
            self?.viewModel.finishAlerOKTapped = true
        }
        
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
    
    private func updateLayout(for toolPicker: PKToolPicker) {
        let obscuredFrame = toolPicker.frameObscured(in: view)
        if obscuredFrame.isNull {
            canvasView.contentInset = .zero
            navigationItem.leftBarButtonItems = []
        }
        canvasView.scrollIndicatorInsets = canvasView.contentInset
    }
    
    // MARK: - User Actions
    
    @objc
    private func didTapPickerButton() {
        viewModel.imageAddingTapped = true
    }
    
    @objc
    private func didTapSaveButton() {
        let renderer = UIGraphicsImageRenderer(bounds: canvasView.bounds)
        let drawingImage = renderer.image { rendererContext in
            canvasView.layer.render(in: rendererContext.cgContext)
        }
        viewModel.drawingImage = drawingImage
        viewModel.saveButtonTapped = true
        
        canvasView.drawing = PKDrawing()
        transformHelper?.reset()
    }
    
}

extension ImageEditorViewController: PHPickerViewControllerDelegate {
    
    // MARK: - PHPickerViewControllerDelegate
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        results.first?.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
            DispatchQueue.main.async { [weak self] in
                self?.viewModel.editableImage = image as? UIImage
            }
        }
        picker.dismiss(animated: true)
    }
    
}

extension ImageEditorViewController: UIImagePickerControllerDelegate,
                                     UINavigationControllerDelegate {
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        viewModel.editableImage = image
        picker.dismiss(animated: true)
        canvasView.becomeFirstResponder()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        canvasView.becomeFirstResponder()
    }
    
}
