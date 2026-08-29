import 'package:get/get.dart';
import '../models/dasha_model.dart';
import '../repositories/dasha_repository.dart';

enum DashaLevel {
  mahadasha,
  antardasha,
  pratyantardasha,
  sookshmadasha,
  pranadasha,
}

class DashaBreadcrumb {
  final DashaLevel level;
  final String title;
  final String? planet;

  DashaBreadcrumb({required this.level, required this.title, this.planet});
}

class DashaController extends GetxController {
  final DashaRepository _repository = DashaRepository();

  var isLoading = false.obs;
  var dashaModel = Rxn<DashaModel>();
  var currentDashaItems = <DashaItem>[].obs;

  // Navigation stack state
  var breadcrumbs = <DashaBreadcrumb>[].obs;

  // Stored birth parameters for sub-dasha API calls
  String? _datetime;
  double? _latitude;
  double? _longitude;
  String _timezone = "+05:30";

  DashaLevel get currentLevel =>
      breadcrumbs.isNotEmpty ? breadcrumbs.last.level : DashaLevel.mahadasha;

  String get currentTitle {
    switch (currentLevel) {
      case DashaLevel.mahadasha:
        return "Mahadasha";
      case DashaLevel.antardasha:
        return "Antardasha";
      case DashaLevel.pratyantardasha:
        return "Pratyantardasha";
      case DashaLevel.sookshmadasha:
        return "Sookshmadasha";
      case DashaLevel.pranadasha:
        return "Pranadasha";
    }
  }

  Future<void> fetchDashaDetails({
    required String datetime,
    required double latitude,
    required double longitude,
    String timezone = "+05:30",
  }) async {
    _datetime = datetime;
    _latitude = latitude;
    _longitude = longitude;
    _timezone = timezone;

    isLoading.value = true;
    breadcrumbs.clear();
    breadcrumbs.add(
      DashaBreadcrumb(level: DashaLevel.mahadasha, title: "Mahadasha"),
    );

    try {
      final result = await _repository.getDashaDetails(
        datetime: datetime,
        latitude: latitude,
        longitude: longitude,
        timezone: timezone,
      );
      dashaModel.value = result;
      currentDashaItems.value = result?.data?.mahaDasha ?? [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onDashaItemClick(DashaItem item) async {
    if (_datetime == null || _latitude == null || _longitude == null) return;
    final selectedPlanet = item.planet;
    if (selectedPlanet == null || selectedPlanet.isEmpty) return;

    if (currentLevel == DashaLevel.mahadasha) {
      await _fetchAntardasha(selectedPlanet);
    } else if (currentLevel == DashaLevel.antardasha) {
      await _fetchPratyantardasha(selectedPlanet);
    } else if (currentLevel == DashaLevel.pratyantardasha) {
      await _fetchSookshmadasha(selectedPlanet);
    } else if (currentLevel == DashaLevel.sookshmadasha) {
      await _fetchPranadasha(selectedPlanet);
    }
  }

  Future<void> _fetchAntardasha(String md) async {
    isLoading.value = true;
    try {
      final items = await _repository.getSubDasha(
        datetime: _datetime!,
        latitude: _latitude!,
        longitude: _longitude!,
        timezone: _timezone,
        md: md,
      );
      breadcrumbs.add(
        DashaBreadcrumb(level: DashaLevel.antardasha, title: md, planet: md),
      );
      currentDashaItems.value = items;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchPratyantardasha(String ad) async {
    isLoading.value = true;
    try {
      final md = _getPlanetAtLevel(DashaLevel.antardasha);
      final items = await _repository.getSubSubDasha(
        datetime: _datetime!,
        latitude: _latitude!,
        longitude: _longitude!,
        timezone: _timezone,
        md: md,
        ad: ad,
      );
      breadcrumbs.add(
        DashaBreadcrumb(
          level: DashaLevel.pratyantardasha,
          title: ad,
          planet: ad,
        ),
      );
      currentDashaItems.value = items;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchSookshmadasha(String pd) async {
    isLoading.value = true;
    try {
      final md = _getPlanetAtLevel(DashaLevel.antardasha);
      final ad = _getPlanetAtLevel(DashaLevel.pratyantardasha);
      final items = await _repository.getSubSubSubDasha(
        datetime: _datetime!,
        latitude: _latitude!,
        longitude: _longitude!,
        timezone: _timezone,
        md: md,
        ad: ad,
        pd: pd,
      );
      breadcrumbs.add(
        DashaBreadcrumb(level: DashaLevel.sookshmadasha, title: pd, planet: pd),
      );
      currentDashaItems.value = items;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchPranadasha(String sd) async {
    isLoading.value = true;
    try {
      final md = _getPlanetAtLevel(DashaLevel.antardasha);
      final ad = _getPlanetAtLevel(DashaLevel.pratyantardasha);
      final pd = _getPlanetAtLevel(DashaLevel.sookshmadasha);
      final items = await _repository.getSubSubSubSubDasha(
        datetime: _datetime!,
        latitude: _latitude!,
        longitude: _longitude!,
        timezone: _timezone,
        md: md,
        ad: ad,
        pd: pd,
        sd: sd,
      );
      breadcrumbs.add(
        DashaBreadcrumb(level: DashaLevel.pranadasha, title: sd, planet: sd),
      );
      currentDashaItems.value = items;
    } finally {
      isLoading.value = false;
    }
  }

  String _getPlanetAtLevel(DashaLevel level) {
    for (var b in breadcrumbs) {
      if (b.level == level && b.planet != null) {
        return b.planet!;
      }
    }
    return '';
  }

  Future<void> navigateToBreadcrumbIndex(int index) async {
    if (index < 0 || index >= breadcrumbs.length - 1) return;

    final targetBreadcrumb = breadcrumbs[index];
    breadcrumbs.removeRange(index + 1, breadcrumbs.length);

    if (targetBreadcrumb.level == DashaLevel.mahadasha) {
      currentDashaItems.value = dashaModel.value?.data?.mahaDasha ?? [];
    } else if (targetBreadcrumb.level == DashaLevel.antardasha) {
      final md = targetBreadcrumb.planet ?? '';
      isLoading.value = true;
      try {
        currentDashaItems.value = await _repository.getSubDasha(
          datetime: _datetime!,
          latitude: _latitude!,
          longitude: _longitude!,
          timezone: _timezone,
          md: md,
        );
      } finally {
        isLoading.value = false;
      }
    } else if (targetBreadcrumb.level == DashaLevel.pratyantardasha) {
      final md = _getPlanetAtLevel(DashaLevel.antardasha);
      final ad = targetBreadcrumb.planet ?? '';
      isLoading.value = true;
      try {
        currentDashaItems.value = await _repository.getSubSubDasha(
          datetime: _datetime!,
          latitude: _latitude!,
          longitude: _longitude!,
          timezone: _timezone,
          md: md,
          ad: ad,
        );
      } finally {
        isLoading.value = false;
      }
    } else if (targetBreadcrumb.level == DashaLevel.sookshmadasha) {
      final md = _getPlanetAtLevel(DashaLevel.antardasha);
      final ad = _getPlanetAtLevel(DashaLevel.pratyantardasha);
      final pd = targetBreadcrumb.planet ?? '';
      isLoading.value = true;
      try {
        currentDashaItems.value = await _repository.getSubSubSubDasha(
          datetime: _datetime!,
          latitude: _latitude!,
          longitude: _longitude!,
          timezone: _timezone,
          md: md,
          ad: ad,
          pd: pd,
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  Future<void> goBack() async {
    if (breadcrumbs.length > 1) {
      await navigateToBreadcrumbIndex(breadcrumbs.length - 2);
    }
  }
}
