//
//  MyPostJobs.swift
//  CargasBrasil
//
//  Created by Edilson Borges on 22/10/24.
//

import SwiftUI

struct MyPostJobsView: View {
    @StateObject private var viewModel = JobViewModel()
    @State private var selectedJobID: String?
    @State private var searchText: String = ""
    @EnvironmentObject var sessionService: SessionServiceImpl

    var filteredJobs: [Job] {
        // Filtra apenas os jobs postados pelo usuário logado
        let userJobs = viewModel.jobs.filter { $0.userId == sessionService.userDetails?.id }
        
        if searchText.isEmpty {
            return userJobs
        } else {
            return userJobs.filter { job in
                job.valor.contains(searchText) ||
                job.destinoColeta.lowercased().contains(searchText.lowercased()) ||
                job.destinoEntrega.lowercased().contains(searchText.lowercased())
            }
        }
    }

    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()

            VStack {
                CustomTextField(
                    sfIncon: "magnifyingglass",
                    hint: "Pesquise seus jobs por valor, destino, coleta",
                    value: $searchText
                )
                .frame(width: 330)
                .frame(height: 38)
                .padding(5)
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.goldBackground, lineWidth: 1)
                }
                .padding(2)
                .foregroundStyle(Color.goldBackground)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .ignoresSafeArea(.keyboard)
                .padding(.top, 15)

                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredJobs) { job in
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
        }
        .onAppear {
            viewModel.fetchJobs()
        }
    }
}

#Preview {
    MyPostJobsView()
        .environmentObject(SessionServiceImpl())
}
