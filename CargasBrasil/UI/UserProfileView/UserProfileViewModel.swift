//
//  UserProfileViewModel.swift
//  CargasBrasil
//
//  Created by Edilson Borges on 27/08/24.
//

import Foundation
import Combine

final class UserProfileViewModel: ObservableObject {
    @Published var assessments: [Assessment] = []
    @Published var averageRating: Double = 0.0
    
    
    private var cancellables = Set<AnyCancellable>()
    private let assessmentService: AssessmentService = AssessmentServiceImpl()

    func loadAssessments(for userId: String) {
        assessmentService.fetchAssessments(for: userId)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] assessments in
                self?.assessments = assessments
            })
            .store(in: &cancellables)
    }
    
    func calculateAverageRating(for userId: String) {
        assessmentService.calculateAverageRating(for: userId)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] averageRating in
                self?.averageRating = averageRating
            })
            .store(in: &cancellables)
    }

    func submitAssessment(request: AssessmentRequest) {
        assessmentService.saveAssessment(with: request, uid: request.nameUser ?? "")
            .sink(receiveCompletion: { _ in }, receiveValue: { })
            .store(in: &cancellables)
    }
}
