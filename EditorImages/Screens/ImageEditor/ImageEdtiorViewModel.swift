//
//  ImageEdtiorViewModel.swift
//  EditorImages
//
//  Created by Кирилл Зубков on 14.04.2024.
//

import Combine
import UIKit

final class ImageEdtiorViewModel: ObservableObject {
    
    // MARK: - Input
    
    var drawingImage: UIImage?
    @Published var imageAddingTapped = false
    @Published var saveButtonTapped = false
    @Published var finishAlerOKTapped = false
    
    
    // MARK: - Output
    
    @Published var editableImage: UIImage?
    @Published var shouldShowImagePicker = false
    @Published var shouldShowFinishAlert = false
    
    
    
    // MARK: - Propeties
    
    private var subscriptions = Set<AnyCancellable>()
    
    
    // MARK: - Init
    
    init() {
        binding()
    }
    
    
    // MARK: - Private Methods
    
    private func binding() {
        $imageAddingTapped
            .sink { [weak self] isTapped in
                if isTapped {
                    self?.imageAddingTapped = false
                    self?.shouldShowImagePicker = true
                }
            }
            .store(in: &subscriptions)
        
        $saveButtonTapped
            .sink { [weak self] isTapped in
                if isTapped {
                    self?.saveButtonTapped = false
                    self?.save()
                }
            }
            .store(in: &subscriptions)
        
        $finishAlerOKTapped
            .sink { [weak self] isTapped in
                if isTapped {
                    self?.finishAlerOKTapped = false
                    self?.reset()
                }
            }
            .store(in: &subscriptions)
    }
    
    private func save() {
        guard let drawingImage else { return }
        UIImageWriteToSavedPhotosAlbum(drawingImage, nil, nil, nil)
        shouldShowFinishAlert = true
    }
    
    private func reset() {
        drawingImage = nil
        editableImage = nil
    }
    
}
