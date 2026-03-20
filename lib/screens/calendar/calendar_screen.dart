import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/common_widgets.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final days = [
      ('L', null), ('M', null), ('M', null), ('J', null), ('V', null), ('S', null), ('D', null),
    ];
    const rows = [
      ['', '', '', '', '', '1', '2'],
      ['3', '4', '5', '6', '7', '8*', '9'],
      ['10', '11', '12', '13', '14*', '15', '16'],
      ['17', '18', '19', '20T*', '21', '22', '23'],
      ['24S*', '25', '26', '27', '28*', '29', '30'],
      ['31', '', '', '', '', '', ''],
    ];

    final events = [
      (kPink, '🎂 Anniversaire de Sophie', '18:00 – 22:00', ['Famille', 'Restaurant'], [kGradMain, kGradPink, kGradCyan], ['A', 'M', 'L']),
      (kCyan, '📞 Appel Grand-père', '10:00 – 10:30', ['Appel vidéo'], [kGradMain], ['A']),
      (kGreen, '🏫 Réunion parents Lucas', '14:00 – 15:00', ['École'], [kGradMain, kGradPink], ['A', 'M']),
    ];

    return Scaffold(
      backgroundColor: kBg2,
      body: Column(
        children: [
          const SafeArea(
            bottom: false,
            child: SizedBox.shrink(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Agenda', style: TextStyle(fontFamily: 'Sora', fontSize: 22, fontWeight: FontWeight.w700, color: kText)),
                Row(children: [
                  AppIconButton(icon: const Icon(Icons.calendar_month_outlined, color: kTextMuted, size: 18)),
                  const SizedBox(width: 8),
                  AppIconButton(isAccent: true, icon: const Icon(Icons.add, color: Colors.white, size: 18)),
                ]),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                // Mini calendar
                SurfaceCard(
                  padding: const EdgeInsets.all(16),
                  radius: 18,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Mars 2026', style: TextStyle(fontFamily: 'Sora', fontSize: 16, fontWeight: FontWeight.w700, color: kText)),
                          Row(children: [
                            _calNavBtn(Icons.chevron_left),
                            const SizedBox(width: 6),
                            _calNavBtn(Icons.chevron_right),
                          ]),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Day headers
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: ['L', 'M', 'M', 'J', 'V', 'S', 'D']
                            .map((d) => Expanded(child: Center(child: Text(d, style: const TextStyle(fontFamily: 'Nunito', fontSize: 11, fontWeight: FontWeight.w800, color: kTextDim)))))
                            .toList(),
                      ),
                      const SizedBox(height: 8),
                      // Calendar grid
                      ...rows.map((row) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: row.map((d) {
                          final isToday = d.contains('T');
                          final isSelected = d.contains('S') && !d.contains('T');
                          final hasEvent = d.contains('*');
                          final label = d.replaceAll(RegExp(r'[TS*]'), '');
                          return Expanded(
                            child: Container(
                              height: 34,
                              margin: const EdgeInsets.symmetric(vertical: 2),
                              decoration: isToday
                                  ? BoxDecoration(gradient: kGradMain, borderRadius: BorderRadius.circular(10))
                                  : isSelected
                                      ? BoxDecoration(
                                          color: kPurple.withAlpha(38),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: kPurple.withAlpha(64), width: 1),
                                        )
                                      : null,
                              alignment: Alignment.center,
                              child: label.isEmpty
                                  ? const SizedBox()
                                  : Stack(
                                      alignment: Alignment.center,
                                      clipBehavior: Clip.none,
                                      children: [
                                        Text(
                                          label,
                                          style: TextStyle(
                                            fontFamily: 'Nunito',
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: isToday ? Colors.white : isSelected ? kPurpleLight : kTextMuted,
                                          ),
                                        ),
                                        if (hasEvent)
                                          Positioned(
                                            bottom: -4,
                                            child: Container(
                                              width: 4,
                                              height: 4,
                                              decoration: BoxDecoration(
                                                color: isToday ? Colors.white60 : kPink,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                            ),
                          );
                        }).toList(),
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const SectionHeader(title: 'Mardi 24 Mars'),
                ...events.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SurfaceCard(
                    padding: const EdgeInsets.all(14),
                    radius: 14,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(width: 4, decoration: BoxDecoration(color: e.$1, borderRadius: BorderRadius.circular(10))),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(e.$2, style: const TextStyle(fontFamily: 'Nunito', fontSize: 14, fontWeight: FontWeight.w800, color: kText)),
                              const SizedBox(height: 4),
                              Row(children: [
                                const Icon(Icons.access_time_outlined, size: 12, color: kTextDim),
                                const SizedBox(width: 4),
                                Text(e.$3, style: const TextStyle(fontFamily: 'Nunito', fontSize: 12, fontWeight: FontWeight.w600, color: kTextMuted)),
                              ]),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                children: e.$4.map((tag) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: e.$1.withAlpha(38),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(tag, style: TextStyle(fontFamily: 'Nunito', fontSize: 11, fontWeight: FontWeight.w700, color: e.$1)),
                                )).toList(),
                              ),
                            ],
                          ),
                        ),
                        // Member avatars
                        ...(e.$5 as List<LinearGradient>).asMap().entries.map((entry) => Transform.translate(
                          offset: Offset(-entry.key * 6.0, 0),
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              gradient: entry.value,
                              borderRadius: BorderRadius.circular(7),
                              border: Border.all(color: kSurface, width: 1.5),
                            ),
                            alignment: Alignment.center,
                            child: Text((e.$6 as List<String>)[entry.key],
                                style: const TextStyle(fontFamily: 'Nunito', fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)),
                          ),
                        )),
                      ],
                    ),
                  ),
                )),
                const SizedBox(height: 20),
              ],
            ),
          ),
          AppBottomNavBar(currentIndex: 2, onTap: (i) => handleNavBarTap(context, i, 2)),
        ],
      ),
    );
  }

  static Widget _calNavBtn(IconData icon) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(color: kSurface2, borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, color: kTextMuted, size: 14),
    );
  }
}
