//  Copyright © 2017 RigaDevDays. All rights reserved.

import UIKit
import Firebase
import MapKit
import Kingfisher

class VenueViewController: UITableViewController {

    @IBOutlet weak var venueTitle: UILabel!
    @IBOutlet weak var venueMap: MKMapView!
    @IBOutlet weak var venueAddress: UILabel!
    @IBOutlet weak var venueDescription: UILabel!
    @IBOutlet weak var venueURL: UILabel!
    @IBOutlet weak var venueImage: UIImageView!

    @IBOutlet weak var firstSeparatorLineHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var secondSeparatorLineHeightConstraint: NSLayoutConstraint!

    var venue: Venue?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension

        firstSeparatorLineHeightConstraint?.constant = 0.5
        secondSeparatorLineHeightConstraint?.constant = 0.5

        venueMap?.layer.cornerRadius = 10.0
        venueMap?.layer.masksToBounds = true

        venueImage?.layer.cornerRadius = 10.0
        venueImage?.layer.masksToBounds = true

        presentVenue(venue!)
    }

    func presentVenue(_ venue: Venue) {
        title = venue.name
        venueTitle.text = venue.title
        if let coordinates = venue.coordinates?.components(separatedBy: ","),
            let latitude = Double(coordinates[0]),
            let longitude = Double(coordinates[1]) {

            let venueCoordinate = CLLocationCoordinate2D.init(latitude: latitude, longitude: longitude)
            let region = venueMap.regionThatFits(MKCoordinateRegionMakeWithDistance(venueCoordinate, 200, 200))
            venueMap.setRegion(region, animated: true)

            let point = MKPointAnnotation.init()
            point.coordinate = venueCoordinate
            point.title = venue.name
            point.subtitle = venue.title
            venueMap.addAnnotation(point)
        }

        if let photoURL = venue.imageUrl, photoURL.contains("http"), let imageURL = URL(string: photoURL) {
            venueImage?.kf.indicatorType = .activity
            venueImage?.kf.setImage(with: imageURL, options: [.transition(.fade(0.2))])
        } else if let url = URL(string: Config.sharedInstance.baseURLPrefix + venue.imageUrl!) {
            venueImage?.kf.indicatorType = .activity
            venueImage?.kf.setImage(with: url, options: [.transition(.fade(0.2))])
        }

        venueAddress.text = venue.address
        venueDescription.setHTMLFromString(htmlText: venue.description!)
        venueURL.text = venue.web
    }

    // MARK: - UITableViewDelegate -

    // do not remove this; table view cannot calculate proper height
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            if let url = URL.init(string: (venue?.web)!) {
                UIApplication.shared.openURL(url)
            }
        }
    }
}

extension VenueViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        let annotationView = MKPinAnnotationView.init(annotation: annotation, reuseIdentifier: "loc")
        annotationView.canShowCallout = true
        annotationView.rightCalloutAccessoryView = UIButton.init(type: .detailDisclosure)
        return annotationView
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let coordinates = self.venue?.coordinates?.components(separatedBy: ","),
            let latitude = Double(coordinates[0]),
            let longitude = Double(coordinates[1]) {
            let regionDistance:CLLocationDistance = 200
            let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
            let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
            ]
            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = self.venue?.name
            mapItem.openInMaps(launchOptions: options)
        }
    }
}
