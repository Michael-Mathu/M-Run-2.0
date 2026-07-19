import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:flutter/services.dart';
import 'mwendo_fit_parser_bindings.dart';

class MwendoFitParser {
  late final DynamicLibrary _lib;
  late final FitParserBindings _bindings;

  MwendoFitParser._();
  static final instance = MwendoFitParser._();

  Future<void> initialize() async {
    if (Platform.isAndroid) {
      final bytes = await rootBundle.load('assets/libmwendo_fit_parser_rust.so');
      _lib = DynamicLibrary.open('mwendo_fit_parser_rust.so');
    } else if (Platform.isIOS) {
      _lib = DynamicLibrary.process();
    } else {
      _lib = DynamicLibrary.open('libmwendo_fit_parser_rust.so');
    }
    _bindings = FitParserBindings(_lib);
  }

  Future<FitParseResult> parseBytes(Uint8List bytes) async {
    final pathStr = '/data/user/0/com.mwendo.app/files/${DateTime.now().millisecondsSinceEpoch}.fit';
    final pathPtr = pathStr.toNativeUtf8();
    
    try {
      final resultPtr = _bindings.parse_fit_data(pathPtr.cast<Char>());
      if (resultPtr == nullptr) {
        throw Exception('Failed to parse FIT data: null pointer returned');
      }
      try {
        final jsonStr = resultPtr.cast<Utf8>().toDartString();
        return FitParseResult.fromJson(_parseJson(jsonStr));
      } finally {
        freeString(resultPtr);
      }
    } finally {
      malloc.free(pathPtr);
    }
  }

  void freeString(Pointer<Char> ptr) {
    _bindings.free_string(ptr);
  }

  Map<String, dynamic> _parseJson(String json) {
    try {
      return jsonDecode(json) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }
}

class FitParseResult {
  final String activityId;
  final double distanceM;
  final int durationMs;
  final List<FitTrackpoint> trackpoints;

  FitParseResult({
    required this.activityId,
    required this.distanceM,
    required this.durationMs,
    required this.trackpoints,
  });

  factory FitParseResult.fromJson(Map<String, dynamic> json) {
    return FitParseResult(
      activityId: json['id'] ?? '',
      distanceM: (json['distance_m'] ?? 0).toDouble(),
      durationMs: json['duration_ms'] ?? 0,
      trackpoints: [],
    );
  }
}

class FitTrackpoint {
  final double lat;
  final double lng;
  final double elevation;
  final DateTime timestamp;

  FitTrackpoint({
    required this.lat,
    required this.lng,
    required this.elevation,
    required this.timestamp,
  });
}