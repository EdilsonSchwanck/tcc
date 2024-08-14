//
//  ListJob.swift
//  CargasBrasil
//
//  Created by Edilson Borges on 09/08/24.
//
import SwiftUI

struct ListJobView: View {
    @StateObject private var viewModel = JobViewModel()
    @State private var selectedJobID: String?

    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.jobs) { job in
                        CardJobView(job: job, isExpanded: selectedJobID == job.id)
                            .onTapGesture {
                                withAnimation {
                                    selectedJobID = selectedJobID == job.id ? nil : job.id
                                }
                            }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
        }
        .onAppear {
            viewModel.fetchJobs()
        }
    }
}

#Preview {
    ListJobView()
}


