import 'dart:ffi';

typedef FitParserNative = Pointer<Char> Function(Pointer<Char> path);
typedef FitParserDart = Pointer<Char> Function(Pointer<Char> path);

typedef FreeStringNative = Void Function(Pointer<Char> ptr);
typedef FreeStringDart = void Function(Pointer<Char> ptr);

class FitParserBindings {
  final DynamicLibrary _lib;

  FitParserBindings(this._lib);

  late final parse_fit_data = _lib
      .lookup<NativeFunction<FitParserNative>>('parse_fit_data')
      .asFunction<FitParserDart>();

  late final free_string = _lib
      .lookup<NativeFunction<FreeStringNative>>('free_string')
      .asFunction<FreeStringDart>();
}