import SwiftUI
import MapKit

struct CardJobView: View {
    var job: Job
    @State private var region: MKCoordinateRegion

    @State private var directions: [MKRoute] = []
    var isExpanded: Bool

    init(job: Job, isExpanded: Bool) {
        self.job = job
        self.isExpanded = isExpanded
        self._region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: job.latitudeColeta, longitude: job.longitudeColeta),
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        ))
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
               
            VStack(alignment: .leading) {
                MapView(region: $region, directions: directions)
                    .frame(height: isExpanded ? 300 : 150)
                    .cornerRadius(10)
                    .padding(.bottom, 10)
                    .onAppear {
                        fetchDirections(from: CLLocationCoordinate2D(latitude: job.latitudeColeta, longitude: job.longitudeColeta), to: CLLocationCoordinate2D(latitude: job.latitudeEntrega, longitude: job.longitudeEntrega))
                    }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Destino de Coleta: \(job.destinoColeta)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Destino de Entrega: \(job.destinoEntrega)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Telefone: \(job.telefone)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Tipo de carga: \(job.tipodeCarga)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Tipo de Caminhão: \(job.tipoDeCaminhao)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Valor do Frete: R$ \(job.valor)")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                .padding(.horizontal)
                
                if isExpanded {
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
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(15)
            .shadow(radius: 5)
            .padding(.horizontal)
            .padding(.bottom, 5)
        }
    }

    private func fetchDirections(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: source))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            if let response = response, let route = response.routes.first {
                self.directions = [route]
                self.updateRegion(for: route)
            } else {
                print("Error fetching directions: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    private func updateRegion(for route: MKRoute) {
        region = MKCoordinateRegion(route.polyline.boundingMapRect)
    }
}


struct MapView: UIViewRepresentable {
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

extension Job {
    static var example: Job {
        return Job(
            id: "1",
            destinoColeta: "São Paulo, SP",
            destinoEntrega: "Rio de Janeiro, RJ",
            telefone: "51 9 9654 8812",
            tipodeCarga: "Carga de arroz",
            tipoDeCaminhao: "Truck",
            valor: "2.500",
            latitudeColeta: -23.55052,
            longitudeColeta: -46.6333,
            latitudeEntrega: -22.9068,
            longitudeEntrega: -43.1729
        )
    }
}


#Preview {
    CardJobView(job: Job.example, isExpanded: true)
}
