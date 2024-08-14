//
//  MapPickerView.swift
//  CargasBrasil
//
//  Created by Edilson Borges on 12/08/24.
//
// MapPickerView.swift
import SwiftUI
import MapKit

struct MapPickerView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var coordinate: LocationCoordinate?
    
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -23.55052, longitude: -46.6333), // Posição inicial (São Paulo, SP)
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @State private var address: String = ""
    @State private var showingAlert = false
    @State private var selectedCoordinate: CoordinateAnnotation?
    
    var title: String
    
    var body: some View {
        NavigationView {
            VStack {
                // Barra de pesquisa com design melhorado
                HStack {
                    TextField("Digite o endereço", text: $address, onCommit: {
                        fetchCoordinates(from: address)
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    
                    Button(action: {
                        self.address = ""
                        self.selectedCoordinate = nil
                        self.coordinate = nil
                        self.mapRegion = MKCoordinateRegion(
                            center: CLLocationCoordinate2D(latitude: -23.55052, longitude: -46.6333),
                            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                        )
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .padding(.trailing)
                    }
                }
                
                // Mapa interativo
                Map(coordinateRegion: $mapRegion, annotationItems: selectedCoordinate != nil ? [selectedCoordinate!] : []) { coordinate in
                    MapPin(coordinate: coordinate.coordinate, tint: .blue)
                }
                .onTapGesture { location in
                    let coordinate = self.mapRegion.center
                    self.selectedCoordinate = CoordinateAnnotation(coordinate: coordinate)
                    self.coordinate = LocationCoordinate(coordinate: coordinate)
                }
                .edgesIgnoringSafeArea(.all)
                
                Button("Confirmar") {
                    if let _ = coordinate {
                        presentationMode.wrappedValue.dismiss()
                    } else {
                        showingAlert = true
                    }
                }
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Erro"), message: Text("Selecione um local válido"), dismissButton: .default(Text("OK")))
                }
            }
            .navigationBarTitle(title, displayMode: .inline)
            .navigationBarItems(trailing: Button("Fechar") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func fetchCoordinates(from address: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                return
            }
            
            if let placemark = placemarks?.first,
               let location = placemark.location {
                self.coordinate = LocationCoordinate(coordinate: location.coordinate)
                self.selectedCoordinate = CoordinateAnnotation(coordinate: location.coordinate)
                self.mapRegion = MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
                // Atualiza o campo de texto com o endereço
                self.address = "\(placemark.thoroughfare ?? "") \(placemark.locality ?? ""), \(placemark.administrativeArea ?? "") \(placemark.postalCode ?? "")"
            } else {
                showingAlert = true
            }
        }
    }
}

// Estrutura para coordenada anotada
struct CoordinateAnnotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    
    var locationCoordinate: CLLocationCoordinate2D {
        return coordinate
    }
}

// Estrutura para localização com coordenadas


#Preview {
    MapPickerView(coordinate: .constant(nil), title: "Selecione o Local de Coleta")
}
