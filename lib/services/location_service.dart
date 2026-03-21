import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LocationService {
  static Future<bool> requestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }

    if (permission == LocationPermission.deniedForever) return false;

    return true;
  }

  /// Gets the current position and uploads it to Firestore under members/[uid]
  static Future<Position?> updateMyLocation() async {
    final hasPermission = await requestPermission();
    if (!hasPermission) return null;

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance.collection('members').doc(uid).update({
        'lat': position.latitude,
        'lng': position.longitude,
        'lastLocationUpdate': FieldValue.serverTimestamp(),
        'locationShared': true,
      });
    }

    return position;
  }

  /// Returns a stream of position updates
  static Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // update every 10 meters
      ),
    );
  }
}
