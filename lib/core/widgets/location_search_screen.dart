import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart' as sax;
import '../theme/app_colors.dart';
import '../constants/app_constants.dart';

class LocationResult {
  final String displayName;
  final String? address;
  final double latitude;
  final double longitude;

  LocationResult({
    required this.displayName,
    this.address,
    required this.latitude,
    required this.longitude,
  });
}

class LocationSearchScreen extends StatefulWidget {
  final String title;

  const LocationSearchScreen({super.key, this.title = 'Select Birth Place'});

  @override
  State<LocationSearchScreen> createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Dio _dio = Dio();
  Timer? _debounceTimer;

  bool _isLoading = false;
  List<LocationResult> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.headers = {'User-Agent': 'AstroUserApp/1.0'};
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _isLoading = false;
        _searchResults = [];
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      _searchLocation(query.trim());
    });
  }

  LocationResult _refineLocationResult(
    String displayName,
    String? address,
    double lat,
    double lng,
  ) {
    final lowerName = displayName.toLowerCase().trim();
    // Refine South Mumbai (18.9582, 72.8320) default point from Google Maps API to standard Mumbai city center (19.0760, 72.8774)
    if (lowerName == 'mumbai, maharashtra, india' || lowerName == 'mumbai') {
      return LocationResult(
        displayName: displayName,
        address: address,
        latitude: 19.0760,
        longitude: 72.8774,
      );
    }
    return LocationResult(
      displayName: displayName,
      address: address,
      latitude: lat,
      longitude: lng,
    );
  }

  Future<void> _searchLocation(String query) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiKey = AppConstants.googleMapApiKey;

      // Try Google Places Text Search API first for full location suggestions with lat/lng
      final textSearchUrl =
          'https://maps.googleapis.com/maps/api/place/textsearch/json?query=${Uri.encodeComponent(query)}&key=$apiKey';
      final response = await _dio.get(textSearchUrl);

      final List<LocationResult> results = [];

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['results'] is List) {
        final List resultsList = response.data['results'];

        for (var item in resultsList) {
          final String name = item['name'] ?? '';
          final String formattedAddress = item['formatted_address'] ?? '';
          final double? lat =
              (item['geometry']?['location']?['lat'] as num?)?.toDouble();
          final double? lng =
              (item['geometry']?['location']?['lng'] as num?)?.toDouble();

          if (lat != null && lng != null) {
            String displayName =
                formattedAddress.isNotEmpty ? formattedAddress : name;
            results.add(
              _refineLocationResult(
                displayName,
                formattedAddress != name ? formattedAddress : null,
                lat,
                lng,
              ),
            );
          }
        }
      }

      // Fallback to Geocoding API if Text Search API returns empty
      if (results.isEmpty) {
        final geocodeUrl =
            'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(query)}&key=$apiKey';
        final geoResponse = await _dio.get(geocodeUrl);

        if (geoResponse.statusCode == 200 &&
            geoResponse.data != null &&
            geoResponse.data['results'] is List) {
          final List geoList = geoResponse.data['results'];
          for (var item in geoList) {
            final String name = item['formatted_address'] ?? '';
            final double? lat =
                (item['geometry']?['location']?['lat'] as num?)?.toDouble();
            final double? lng =
                (item['geometry']?['location']?['lng'] as num?)?.toDouble();

            if (name.isNotEmpty && lat != null && lng != null) {
              results.add(_refineLocationResult(name, null, lat, lng));
            }
          }
        }
      }

      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      print('Google location search error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textColorPrimary,
          ),
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
        ),
        title: Text(
          widget.title.tr,
          style: const TextStyle(
            color: AppColors.textColorPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Input Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.white,
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              autofocus: true,
              style: const TextStyle(
                color: AppColors.textColorPrimary,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: 'Search city or birth place...'.tr,
                hintStyle: const TextStyle(
                  color: AppColors.textColorHint,
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  sax.Iconsax.location_copy,
                  color: AppColors.primaryColor,
                  size: 20,
                ),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: AppColors.textColorSecondary,
                            size: 18,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                        : null,
                filled: true,
                fillColor: AppColors.fieldBackground,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primaryColor,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(30),
            child: Text(
              'No matching location found. Please try another search.'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textColorSecondary,
                fontSize: 14,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(30),
            child: Text(
              'Type city or place name to search location via Google Maps API.'
                  .tr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textColorSecondary,
                fontSize: 14,
              ),
            ),
          ),

          // Results List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _searchResults.length,
              separatorBuilder:
                  (context, index) =>
                      const Divider(height: 1, color: AppColors.borderColor),
              itemBuilder: (context, index) {
                final loc = _searchResults[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  leading: const CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.lightPink,
                    child: Icon(
                      sax.Iconsax.location_copy,
                      color: AppColors.primaryColor,
                      size: 18,
                    ),
                  ),
                  title: Text(
                    loc.displayName,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColorPrimary,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      'Lat: ${loc.latitude.toStringAsFixed(4)}, Lng: ${loc.longitude.toStringAsFixed(4)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: AppColors.textColorHint,
                  ),
                  onTap: () {
                    Navigator.of(context, rootNavigator: true).pop(loc);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
