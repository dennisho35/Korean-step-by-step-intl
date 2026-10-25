class DisplayToggles {
  bool showRomaji;
  bool showNativePron;
  bool showActualPron;
  bool showTranslation;
  bool showPronNotes;

  DisplayToggles({
    this.showRomaji = true,
    this.showNativePron = true,
    this.showActualPron = true,
    this.showTranslation = true,
    this.showPronNotes = true,
  });

  void applyBeginnerPreset() {
    showRomaji = true;
    showNativePron = true;
    showActualPron = true;
    showTranslation = true;
    showPronNotes = true;
  }

  void applyAdvancedPreset() {
    showRomaji = false;
    showNativePron = false;
    showActualPron = true;
    showTranslation = true;
    showPronNotes = false;
  }

  Map<String, bool> toJson() => {
    'romaji': showRomaji,
    'nativePron': showNativePron,
    'actualPron': showActualPron,
    'translation': showTranslation,
    'pronNotes': showPronNotes,
  };
}
