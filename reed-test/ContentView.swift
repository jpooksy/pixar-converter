//
//  ContentView.swift
//  reed-test
//
//  Created by J Parker Rogers on 11/18/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = PixarConverterViewModel()
    @State private var showImagePicker = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        Text("Pixar Style Converter")
                            .font(.title)
                            .bold()
                        Text("Transform your photos into Pixar-style art")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)

                    // Selected Image
                    if let selectedImage = viewModel.selectedImage {
                        VStack(spacing: 12) {
                            Text("Original Image")
                                .font(.headline)
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 300)
                                .cornerRadius(12)
                                .shadow(radius: 4)
                        }
                    }

                    // Select Image Button
                    Button(action: {
                        showImagePicker = true
                    }) {
                        Label("Select Image from Library", systemImage: "photo.on.rectangle")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .disabled(viewModel.isProcessing)

                    // Convert Button
                    if viewModel.selectedImage != nil {
                        Button(action: {
                            Task {
                                await viewModel.convertToPixarStyle()
                            }
                        }) {
                            if viewModel.isProcessing {
                                HStack {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    Text(viewModel.currentStep.description)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            } else {
                                Label("Convert to Pixar Style", systemImage: "wand.and.stars")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                        }
                        .disabled(viewModel.isProcessing)
                    }

                    // Error Message
                    if let errorMessage = viewModel.errorMessage {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text(errorMessage)
                                .font(.subheadline)
                                .foregroundColor(.red)
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                    }

                    // Pixar Result Image
                    if let pixarImage = viewModel.pixarImage {
                        VStack(spacing: 12) {
                            Text("Pixar Style Result")
                                .font(.headline)
                            Image(uiImage: pixarImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 300)
                                .cornerRadius(12)
                                .shadow(radius: 4)

                            // Save Button
                            Button(action: {
                                viewModel.savePixarImage()
                            }) {
                                Label("Save to Photos", systemImage: "square.and.arrow.down")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.purple)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }

                            // Reset Button
                            Button(action: {
                                viewModel.reset()
                            }) {
                                Label("Start New Conversion", systemImage: "arrow.clockwise")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.gray)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: Binding(
                get: { viewModel.selectedImage },
                set: { image in
                    if let image = image {
                        viewModel.selectImage(image)
                    }
                }
            ))
        }
    }
}

#Preview {
    ContentView()
}
