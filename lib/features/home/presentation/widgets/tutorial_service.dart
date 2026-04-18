import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:babytracker/features/home/providers/tutorial_keys.dart';

class HomeTutorialTargets {
  static List<TargetFocus> createTargets() {
    return [
      TargetFocus(
        identify: "topSectionTarget",
        keyTarget: TutorialKeys.topSectionKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.only(top: 20),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Bebeğinizin Profili & Aşı Takvimi",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 22,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Bebeğinizin bilgilerini buradan görebilirsiniz. Sağ köşedeki şırınga ikonuna tıklayarak Aşı Takvimi sekmesine erişebilirsiniz.",
                      style: TextStyle(
                          color: Colors.white, fontSize: 17, height: 1.4),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "quickActionsTarget",
        keyTarget: TutorialKeys.quickActionsKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.only(top: 20),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hızlı Aktiviteler",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 22,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Uyku, Beslenme ve Bez değişimi gibi günlük rutinleri buradan tek dokunuşla kaydedebilirsiniz.",
                      style: TextStyle(
                          color: Colors.white, fontSize: 17, height: 1.4),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "chartSectionTarget",
        keyTarget: TutorialKeys.chartSectionKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.only(top: 20),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Haftalık Grafikler",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 22,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Son 7 güne ait uyku ve beslenme düzeninizi özet grafikten takip edebilirsiniz.",
                      style: TextStyle(
                          color: Colors.white, fontSize: 17, height: 1.4),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "syncButtonTarget",
        keyTarget: TutorialKeys.syncButtonKey,
        alignSkip: Alignment.bottomRight,
        shape: ShapeLightFocus.Circle,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.only(top: 20),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Senkronizasyon",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 22,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Verilerinizi kendi ailenizin diğer bireyleriyle senkronize etmek için buraya dokunabilirsiniz.",
                      style: TextStyle(
                          color: Colors.white, fontSize: 17, height: 1.4),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "bottomNavTarget",
        keyTarget: TutorialKeys.bottomNavKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.only(bottom: 20),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Menü Çubuğu",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 22,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Diğer tüm özelliklere (AI Koç, Uyku kütüphanesi, Akademi ve Ayarlar) buradan hızlıca geçiş yapabilirsiniz.",
                      style: TextStyle(
                          color: Colors.white, fontSize: 17, height: 1.4),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    ];
  }

  static late TutorialCoachMark _tutorialCoachMark;

  static void showTutorial({
    required BuildContext context,
    VoidCallback? onFinish,
  }) {
    _tutorialCoachMark = TutorialCoachMark(
      targets: createTargets(),
      colorShadow: Colors.black,
      textSkip: "Atla",
      paddingFocus: 10,
      opacityShadow: 0.95,
      hideSkip: false,
      onFinish: onFinish,
      // "herhangi bir yere basınca diğerine geçsin"
      onClickOverlay: (target) {
        _tutorialCoachMark.next();
      },
      onClickTarget: (target) {
        _tutorialCoachMark.next();
      },
      onSkip: () {
        onFinish?.call();
        return true;
      },
    );

    _tutorialCoachMark.show(context: context);
  }
}
