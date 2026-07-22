import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart' as sax;
import '../theme/app_colors.dart';
import '../constants/app_constants.dart';

class LocationResult {
  final String displayName;
  final double latitude;
  final double longitude;

  LocationResult({
    required this.displayName,
    required this.latitude,
    required this.longitude,
  });
}

class LocationSearchScreen extends StatefulWidget {
  final String title;

  const LocationSearchScreen({
    super.key,
    this.title = 'Select Birth Place',
  });

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
    _dio.options.headers = {
      'User-Agent': 'AstroUserApp/1.0',
    };
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

    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _searchLocation(query.trim());
    });
  }

  Future<void> _searchLocation(String query) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiKey = AppConstants.googleMapApiKey;
      final url = 'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(query)}&key=$apiKey';
      final response = await _dio.get(url);

      if (response.statusCode == 200 && response.data != null && response.data['results'] is List) {
        final List resultsList = response.data['results'];
        final List<LocationResult> results = [];

        for (var item in resultsList) {
          final String name = item['formatted_address'] ?? '';
          final double? lat = (item['geometry']?['location']?['lat'] as num?)?.toDouble();
          final double? lng = (item['geometry']?['location']?['lng'] as num?)?.toDouble();

          if (name.isNotEmpty && lat != null && lng != null) {
            results.add(LocationResult(
              displayName: name,
              latitude: lat,
              longitude: lng,
            ));
          }
        }

        setState(() {
          _searchResults = results;
        });
      }
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textColorPrimary),
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
        ),
        title: Text(
          widget.title,
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
              style: const TextStyle(color: AppColors.textColorPrimary, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Search city or birth place...',
                hintStyle: const TextStyle(color: AppColors.textColorHint, fontSize: 14),
                prefixIcon: const Icon(sax.Iconsax.location_copy, color: AppColors.primaryColor, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.textColorSecondary, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.fieldBackground,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5),
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

          if (!_isLoading && _searchController.text.trim().isNotEmpty && _searchResults.isEmpty)
            const Padding(
              padding: EdgeInsets.all(30),
              child: Text(
                'No matching location found. Please try another search.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textColorSecondary, fontSize: 14),
              ),
            ),

          if (_searchController.text.trim().isEmpty)
            const Padding(
              padding: EdgeInsets.all(30),
              child: Text(
                'Type city or place name to search location via Google Maps API.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textColorSecondary, fontSize: 14),
              ),
            ),

          // Results List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _searchResults.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.borderColor),
              itemBuilder: (context, index) {
                final loc = _searchResults[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  leading: const CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.lightPink,
                    child: Icon(sax.Iconsax.location_copy, color: AppColors.primaryColor, size: 18),
                  ),
                  title: Text(
                    loc.displayName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColorPrimary,
                    ),
                  ),
                  subtitle: Text(
                    'Lat: ${loc.latitude.toStringAsFixed(4)}, Lng: ${loc.longitude.toStringAsFixed(4)}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textColorSecondary,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textColorHint),
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
