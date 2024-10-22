//
//  PerfilView.swift
//  CargasBrasil
//
//  Created by Edilson Borges on 08/08/24.
//



import SwiftUI

struct PerfilView: View {
    @EnvironmentObject var sessionService: SessionServiceImpl
    @StateObject private var viewModel = UserProfileViewModel()
    @State private var assessments: [Assessment] = []
    @State private var isLoading = true // Controla o estado de carregamento
    @State private var isLoggedOut = false // Controla o redirecionamento para a tela de login
    @State private var showLogoutConfirmation = false // Controla o alerta de confirmação

    var body: some View {
        if isLoggedOut {
            LoginView()
        } else {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                VStack(spacing: 20) {
                    profileHeader

                    Divider()
                        .padding(.horizontal)

                    Text("Avaliações")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.top)

                    if isLoading {
                        ProgressView()
                            .scaleEffect(1.8) // Aumenta o tamanho do círculo
                            .padding(.top, 50)
                    } else {
                        assessmentsScrollView
                    }

                    Spacer()

                    logoutButton
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            }
            .onAppear {
                loadUserDetails()
            }
            .onReceive(viewModel.$assessments) { assessments in
                self.assessments = assessments
                self.isLoading = false // Oculta o ProgressView ao concluir o carregamento
            }
            .alert(isPresented: $showLogoutConfirmation) {
                Alert(
                    title: Text("Sair do aplicativo"),
                    message: Text("Tem certeza que deseja sair?"),
                    primaryButton: .destructive(Text("Sim")) {
                        handleLogout()
                    },
                    secondaryButton: .cancel(Text("Não"))
                )
            }
        }
    }

    private var profileHeader: some View {
        VStack {
            Text(sessionService.userDetails?.isCompany == true
                 ? sessionService.userDetails?.nameCompany ?? "Empresa"
                 : sessionService.userDetails?.nameUser ?? "Usuário")
                .font(.title)
                .fontWeight(.bold)

            if sessionService.userDetails?.isCompany == true {
                Text(sessionService.userDetails?.cnpj ?? "CNPJ")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            } else {
                VStack {
                    Text("Placa: \(sessionService.userDetails?.plateVheicle ?? "N/A")")
                        .font(.headline)
                    Text("Veículo: \(sessionService.userDetails?.typeVheicle ?? "N/A")")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
        }
    }

    private var assessmentsScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(assessments) { assessment in
                    CardAssessmentProfile(
                        profileImageURL: assessment.imageURL,
                        userName: assessment.nameUserAssessmet,
                        reviewText: assessment.textAssessment,
                        starRating: assessment.nota
                    )
                    .frame(width: 250, height: 150) // Definir largura e altura fixas para os cards
                }
            }
            .padding(.horizontal)
        }
        .frame(height: 170)
    }

    private var logoutButton: some View {
        Button(action: {
            showLogoutConfirmation = true // Exibe o alerta de confirmação
        }) {
            Text("Sair")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(LinearGradient(
                    gradient: Gradient(colors: [Color.red, Color.orange]),
                    startPoint: .leading,
                    endPoint: .trailing
                ))
                .cornerRadius(10)
                .padding(.horizontal)
        }
    }

    private func loadUserDetails() {
        isLoading = true // Ativa o ProgressView durante o carregamento
        if let userDetails = sessionService.userDetails {
            let userId = userDetails.isCompany ? userDetails.nameCompany : userDetails.nameUser
            viewModel.loadAssessments(for: userId)
        }
    }

    private func handleLogout() {
        sessionService.logout()
        clearState()
        isLoggedOut = true // Redireciona para a tela de login
    }

    private func clearState() {
        assessments = []
        viewModel.assessments = []
    }
}

#Preview {
    PerfilView().environmentObject(SessionServiceImpl())
}
