//
//  ExpandedCardJobView.swift
//  CargasBrasil
//
//  Created by Edilson Borges on 09/08/24.
//

import SwiftUI
import MapKit

struct ExpandedCardJobView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -29.457171, longitude: -49.926963),
        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
    )
    
    @State private var directions: [MKRoute] = []
    
    let pickupLocation = CLLocationCoordinate2D(latitude: -29.457171, longitude: -49.926963)
    let deliveryLocation = CLLocationCoordinate2D(latitude: -29.335619, longitude: -49.737188)
    
    var body: some View {
        VStack(alignment: .leading) {
            MapView(region: $region, directions: directions)
                .frame(maxHeight: .infinity)
                .background(Color.gray.opacity(0.1))
                .onAppear {
                    fetchDirections()
                }
            
            VStack(alignment: .leading, spacing: 5) {
                Text("Destino de Coleta: São Paulo, SP")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Destino de Entrega: Rio de Janeiro, RJ")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Tipo de Caminhão: Truck")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Valor do Frete: R$ 2.500,00")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            .padding(.horizontal)
            
            Button(action: {
                // Ação do botão de chat
            }) {
                Text("Chat")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 10)
        }
        .edgesIgnoringSafeArea(.bottom)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
    
    private func fetchDirections() {
        let request = MKDirections.Request()
        let sourcePlacemark = MKPlacemark(coordinate: pickupLocation)
        let destinationPlacemark = MKPlacemark(coordinate: deliveryLocation)
        
        request.source = MKMapItem(placemark: sourcePlacemark)
        request.destination = MKMapItem(placemark: destinationPlacemark)
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            guard let response = response else {
                print("Error fetching directions: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            self.directions = response.routes
            self.updateRegion(for: response.routes)
        }
    }
    
    private func updateRegion(for routes: [MKRoute]) {
        guard let route = routes.first else { return }
        let routeRect = route.polyline.boundingMapRect
        let newRegion = MKCoordinateRegion(routeRect)
        region = newRegion
    }
}

struct MapViews: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    var directions: [MKRoute]
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeOverlays(uiView.overlays)
        
        for route in directions {
            uiView.addOverlay(route.polyline)
        }
        
        uiView.setRegion(region, animated: true)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let routeLine = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: routeLine)
                renderer.strokeColor = .blue
                renderer.lineWidth = 4.0
                return renderer
            }
            return MKOverlayRenderer()
        }
    }
}

#Preview {
    ExpandedCardJobView()
}
