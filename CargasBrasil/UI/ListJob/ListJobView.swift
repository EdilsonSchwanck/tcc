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
    @State private var searchText: String = ""
    @EnvironmentObject var sessionService: SessionServiceImpl

    var filteredJobs: [Job] {
        if searchText.isEmpty {
            return viewModel.jobs
        } else {
            return viewModel.jobs.filter { job in
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
                // Renderiza o campo de texto somente para usuários que não são empresas
                if sessionService.userDetails?.isCompany == false {
                    CustomTextField(
                        sfIncon: "magnifyingglass",
                        hint: "Pesquise suas cargas por valor, destino ou coleta",
                        value: $searchText
                    )
                    .frame(width: 330)
                    .frame(height: 38)
                    .padding(5)
                    .overlay(content: {
                        RoundedRectangle(cornerRadius: 8).stroke(Color.goldBackground, lineWidth: 1)
                    })
                    .padding(2)
                    .foregroundStyle(Color.goldBackground)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .ignoresSafeArea(.keyboard)
                    .padding(.top, 15)
                }
                
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
    ListJobView().environmentObject(SessionServiceImpl())
}
