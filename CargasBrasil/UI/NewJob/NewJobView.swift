//
//  NewJob.swift
//  CargasBrasil
//
//  Created by Edilson Borges on 12/08/24.
//

import SwiftUI
import MapKit
import CoreLocation

struct LocationCoordinate: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

struct NewJobView: View {
    @StateObject private var viewModel = NewJobViewModelImpl(service: NewJobServiceImpl())
    
    @State private var pickupCoordinate: LocationCoordinate?
    @State private var deliveryCoordinate: LocationCoordinate?
    @State private var showingPickupPicker = false
    @State private var showingDeliveryPicker = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    @State var destinoColeta: String = ""
    @State var destinoEntrega: String = ""
    @State var telefone: String = ""
    @State var tipodeCarga: String = ""
    @State var tipoDeCaminhao: String = ""
    @State var valor: String = ""

    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack {
                ScrollView {
                    VStack {
                        Text("Informe os dados para o Anúncio do frete")
                            .padding(.bottom, 20)
                            .padding(.top, 20)
                        
                        Group {
                            Button(action: {
                                showingPickupPicker = true
                            }) {
                                CustomTextField(sfIncon: "mappin.and.ellipse", hint: "Selecionar Local de Coleta", value: .constant(pickupCoordinate?.coordinate.formatted ?? "Selecionar Local de coleta"))
                            }
                            
                            Button(action: {
                                showingDeliveryPicker = true
                            }) {
                                CustomTextField(sfIncon: "mappin.and.ellipse", hint: "Selecionar Local de Entrega", value: .constant(deliveryCoordinate?.coordinate.formatted ?? "Selecionar Local de entrega"))
                            }
                            
                            CustomTextField(sfIncon: "lock", hint: "Destino de Coleta", value: $destinoColeta)
                            CustomTextField(sfIncon: "lock", hint: "Destino de Entrega", value: $destinoEntrega)
                            CustomTextField(sfIncon: "lock", hint: "Telefone", value: $telefone)
                            CustomTextField(sfIncon: "lock", hint: "Tipo de Carga", value: $tipodeCarga)
                            CustomTextField(sfIncon: "lock", hint: "Tipo de Caminhão", value: $tipoDeCaminhao)
                            CustomTextField(sfIncon: "lock", hint: "Valor", value: $valor)
                        }
                        .frame(width: 330)
                        .frame(height: 38)
                        .padding(5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8).stroke(Color.goldBackground, lineWidth: 1)
                        )
                        .padding(2)
                        .foregroundStyle(Color.goldBackground)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .ignoresSafeArea(.keyboard)
                    }
                    .padding(.horizontal, 15)
                }
                
                Button(action: registerJob) {
                    Text("Cadastrar")
                        .frame(width: 335)
                        .frame(height: 50)
                        .font(.system(size: 18, weight: .bold))
                        .background(Color.goldBackground)
                        .foregroundStyle(Color.colorLabelButton)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .ignoresSafeArea()
                }
                .padding(.bottom, 10)
            }
        }
        .sheet(isPresented: $showingPickupPicker) {
            MapPickerView(coordinate: $pickupCoordinate, title: "Selecione o Local de Coleta")
        }
        .sheet(isPresented: $showingDeliveryPicker) {
            MapPickerView(coordinate: $deliveryCoordinate, title: "Selecione o Local de Entrega")
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Sucesso!"), message: Text(alertMessage), dismissButton: .default(Text("OK"), action: resetFields))
        }
        .onChange(of: viewModel.state) { newState in
            switch newState {
            case .successfullyRegistered:
                alertMessage = "Anúncio cadastrado com sucesso!"
                showingAlert = true
            case .failed(let error):
                alertMessage = "Erro ao cadastrar: \(error.localizedDescription)"
                showingAlert = true
            default:
                break
            }
        }
    }

    private func registerJob() {
        if let pickup = pickupCoordinate?.coordinate, let delivery = deliveryCoordinate?.coordinate {
            viewModel.newJob = NewJobRequest(
                latitudeColeta: pickup.latitude,
                longitudeColeta: pickup.longitude,
                latitudeEntrega: delivery.latitude,
                longitudeEntrega: delivery.longitude,
                destinoColeta: destinoColeta,
                destinoEntrega: destinoEntrega,
                telefone: telefone,
                tipodeCarga: tipodeCarga,
                tipoDeCaminhao: tipoDeCaminhao,
                valor: valor
            )
            viewModel.create()
        }
    }

    private func resetFields() {
        destinoColeta = ""
        destinoEntrega = ""
        telefone = ""
        tipodeCarga = ""
        tipoDeCaminhao = ""
        valor = ""
        pickupCoordinate = nil
        deliveryCoordinate = nil
    }
}

extension CLLocationCoordinate2D {
    var formatted: String {
        return String(format: "%.4f, %.4f", latitude, longitude)
    }
}



#Preview {
    NewJobView()
}
