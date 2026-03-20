import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme.dart';
import '../../widgets/common_widgets.dart';
import '../../services/firestore_service.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> with SingleTickerProviderStateMixin {
  final FirestoreService _db = FirestoreService();
  late AnimationController _radarController;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
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

  String _getMockLocation(int index) {
    const locs = ['À la maison', 'Au travail', 'École primaire', 'En déplacement', 'Salle de sport'];
    return locs[index % locs.length];
  }

  String _getMockDistance(int index) {
    const dists = ['0 km', '12 km', '2 km', '150 km', '5 km'];
    return dists[index % dists.length];
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
          Expanded(
            flex: 3,
            child: StreamBuilder<QuerySnapshot>(
              stream: _db.getMembersStream(),
              builder: (context, snapshot) {
                final docs = snapshot.data?.docs ?? [];
                
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Concentric circles
                    _buildRadarCircle(280, 0.05),
                    _buildRadarCircle(200, 0.1),
                    _buildRadarCircle(120, 0.15),
                    
                    // Radar sweep animation
                    AnimatedBuilder(
                      animation: _radarController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _radarController.value * 2 * pi,
                          child: Container(
                            width: 280,
                            height: 280,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: SweepGradient(
                                colors: [
                                  kCyan.withAlpha(0),
                                  kCyan.withAlpha(20),
                                  kCyan.withAlpha(80),
                                ],
                                stops: const [0.0, 0.8, 1.0],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // Central pin (Home/Me)
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: kGradMain,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withAlpha(40), width: 3),
                        boxShadow: [BoxShadow(color: kPurple.withAlpha(100), blurRadius: 15, spreadRadius: 2)],
                      ),
                      child: const Icon(Icons.home_rounded, color: Colors.white, size: 22),
                    ),

                    // Family members positioned randomly on radar
                    if (snapshot.hasData)
                      ...List.generate(docs.length, (i) {
                        final data = docs[i].data() as Map<String, dynamic>;
                        final initial = data['initial'] ?? '?';
                        final grad = _getGrad(data['colorIndex'] ?? i);
                        
                        // Pseudo-random position based on index purely for UI mockup
                        final angle = (i * 1.5) + 0.5;
                        final radius = 60.0 + (i * 30.0 % 80.0);
                        
                        return Positioned(
                          left: (MediaQuery.of(context).size.width / 2) + cos(angle) * radius - 18,
                          top: (280 / 2) + sin(angle) * radius - 18 + 40, // 40 is approx offset
                          child: _buildMapPin(initial, grad),
                        );
                      }),
                  ],
                );
              },
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
                            
                            final mockLoc = _getMockLocation(i);
                            final mockDist = _getMockDistance(i);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
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
                                              const Icon(Icons.location_on, color: kTextDim, size: 12),
                                              const SizedBox(width: 4),
                                              Text('$mockLoc • $mockDist', style: const TextStyle(fontFamily: 'Nunito', fontSize: 12, fontWeight: FontWeight.w600, color: kTextMuted)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    AppIconButton(icon: const Icon(Icons.navigation_outlined, color: kCyan, size: 18)),
                                  ],
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

  Widget _buildRadarCircle(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: kCyan.withOpacity(opacity), width: 1.5),
        color: kCyan.withOpacity(opacity * 0.3),
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
