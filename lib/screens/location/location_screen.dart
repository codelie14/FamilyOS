
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/theme.dart';
import '../../widgets/common_widgets.dart';
import '../../services/firestore_service.dart';
import '../../services/location_service.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final FirestoreService _db = FirestoreService();
  final MapController _mapController = MapController();
  LatLng _myPosition = const LatLng(48.8566, 2.3522); // Paris fallback

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    final position = await LocationService.updateMyLocation();
    if (position != null && mounted) {
      setState(() {
        _myPosition = LatLng(position.latitude, position.longitude);
      });
      _mapController.move(_myPosition, 13.0);
    }
  }

  LinearGradient _getGrad(int index) {
    const list = [
      LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [kPink, kPurple]),
      LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [kCyan, kBlue]),
      LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [kGreen, kCyan]),
      LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [kOrange, kPink]),
      LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [kPurple, kBlue]),
    ];
    return list[index % list.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg2,
      body: Column(
        children: [
          const SafeArea(bottom: false, child: SizedBox.shrink()),
          // Top bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: kSurface,
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: Colors.white.withAlpha(15), width: 1),
                    ),
                    child: const Icon(Icons.chevron_left, color: kTextMuted, size: 22),
                  ),
                ),
                const SizedBox(width: 14),
                const Text('Localisation', style: TextStyle(fontFamily: 'Sora', fontSize: 20, fontWeight: FontWeight.w700, color: kText)),
                const Spacer(),
                AppIconButton(icon: const Icon(Icons.share_location, color: kTextMuted, size: 18), showDot: true),
              ],
            ),
          ),
          
          // Radar View
          // Map View
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: _db.getMembersStream(),
                builder: (context, snapshot) {
                  final docs = snapshot.data?.docs ?? [];
                  
                  return FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _myPosition,
                      initialZoom: 13.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.familyos.app',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _myPosition,
                            width: 60,
                            height: 60,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: kGradMain,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withAlpha(40), width: 3),
                                boxShadow: [BoxShadow(color: kPurple.withAlpha(100), blurRadius: 15, spreadRadius: 2)],
                              ),
                              child: const Icon(Icons.my_location, color: Colors.white, size: 22),
                            ),
                          ),
                          if (snapshot.hasData)
                            ...docs.where((doc) {
                              final d = doc.data() as Map<String, dynamic>;
                              return d['lat'] != null && d['lng'] != null;
                            }).map((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              final initial = data['initial'] ?? '?';
                              final grad = _getGrad(data['colorIndex'] ?? 0);
                              final lat = (data['lat'] as num).toDouble();
                              final lng = (data['lng'] as num).toDouble();
                              return Marker(
                                point: LatLng(lat, lng),
                                width: 40,
                                height: 40,
                                child: _buildMapPin(initial, grad),
                              );
                            }),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          // Bottom Sheet / List
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: kSurface,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                border: Border.all(color: Colors.white.withAlpha(10), width: 1),
                boxShadow: [BoxShadow(color: Colors.black.withAlpha(40), blurRadius: 20, offset: const Offset(0, -5))],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white.withAlpha(20), borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 20),
                  
                  // Active sharing status
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         const Text('Position partagée', style: TextStyle(fontFamily: 'Sora', fontSize: 16, fontWeight: FontWeight.w700, color: kText)),
                         Container(
                           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                           decoration: BoxDecoration(color: kGreen.withAlpha(30), borderRadius: BorderRadius.circular(10)),
                           child: const Row(
                             children: [
                               Icon(Icons.circle, color: kGreen, size: 8),
                               SizedBox(width: 6),
                               Text('En direct', style: TextStyle(fontFamily: 'Nunito', fontSize: 11, fontWeight: FontWeight.w800, color: kGreen)),
                             ],
                           ),
                         ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // List of members
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _db.getMembersStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(color: kPurple));
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text("Aucun membre", style: TextStyle(color: kTextMuted, fontFamily: 'Nunito')));
                        }
                        
                        final docs = snapshot.data!.docs;
                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: docs.length,
                          itemBuilder: (ctx, i) {
                            final data = docs[i].data() as Map<String, dynamic>;
                            final name = data['name'] ?? 'Inconnu';
                            final initial = data['initial'] ?? '?';
                            final grad = _getGrad(data['colorIndex'] ?? i);
                            final hasLocation = data['lat'] != null && data['lng'] != null;
                            final locationText = hasLocation
                              ? 'Position connue'
                              : 'Position inconnue';

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: GestureDetector(
                                onTap: hasLocation ? () {
                                  final lat = (data['lat'] as num).toDouble();
                                  final lng = (data['lng'] as num).toDouble();
                                  _mapController.move(LatLng(lat, lng), 15);
                                } : null,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: kBg2,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.white.withAlpha(10), width: 1),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 46,
                                        height: 46,
                                        decoration: BoxDecoration(gradient: grad, borderRadius: BorderRadius.circular(14)),
                                        alignment: Alignment.center,
                                        child: Text(initial, style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white)),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(name, style: const TextStyle(fontFamily: 'Nunito', fontSize: 15, fontWeight: FontWeight.w800, color: kText)),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(hasLocation ? Icons.location_on : Icons.location_off, color: hasLocation ? kGreen : kTextDim, size: 12),
                                                const SizedBox(width: 4),
                                                Text(locationText, style: const TextStyle(fontFamily: 'Nunito', fontSize: 12, fontWeight: FontWeight.w600, color: kTextMuted)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (hasLocation)
                                        AppIconButton(icon: const Icon(Icons.navigation_outlined, color: kCyan, size: 18)),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildMapPin(String initial, LinearGradient grad) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: grad,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [BoxShadow(color: Colors.black.withAlpha(60), blurRadius: 8, offset: const Offset(0, 4))],
          ),
          alignment: Alignment.center,
          child: Text(initial, style: const TextStyle(fontFamily: 'Nunito', fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
        ),
        const SizedBox(height: 2),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black.withAlpha(40), blurRadius: 4)],
          ),
        ),
      ],
    );
  }
}
