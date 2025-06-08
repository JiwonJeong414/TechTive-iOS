//
//  ImagePicker.swift
//  TechTive
//
//  Created by jiwon jeong on 12/3/24.
//
import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var authViewModel: AuthViewModel
    var onUploadComplete: ((Bool) -> Void)? = nil

    func makeUIViewController(context: Context) -> UIImagePickerController {
        print("📸 ImagePicker: Creating UIImagePickerController")
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }

    func updateUIViewController(_: UIImagePickerController, context _: Context) {
        print("📸 ImagePicker: Updating UIImagePickerController")
    }

    func makeCoordinator() -> Coordinator {
        print("📸 ImagePicker: Creating Coordinator")
        return Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            print("📸 Coordinator: Initializing")
            self.parent = parent
        }

        func imagePickerController(
            _: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any])
        {
            if let image = info[.originalImage] as? UIImage {
                if let imageData = image.pngData() { // Changed to pngData()
                    print("📸 Coordinator: Image size: \(imageData.count / 1024)KB")
                }

                self.parent.selectedImage = image

                Task { @MainActor in
                    do {
                        print("📸 Coordinator: Attempting to upload image")
                        let success = try await parent.authViewModel.uploadProfilePicture(image: image)
                        print("📸 Coordinator: Upload completed with success: \(success)")
                        self.parent.onUploadComplete?(success)
                    } catch {
                        print("❌ Coordinator: Error uploading image: \(error)")
                        print("❌ Coordinator: Error details: \(error.localizedDescription)")
                        self.parent.onUploadComplete?(false)
                    }
                }
            } else {
                print("❌ Coordinator: Failed to get image from picker")
            }

            print("📸 Coordinator: Dismissing picker")
            self.parent.dismiss()
        }

        func imagePickerControllerDidCancel(_: UIImagePickerController) {
            print("📸 Coordinator: User cancelled picker")
            self.parent.dismiss()
        }
    }
}
