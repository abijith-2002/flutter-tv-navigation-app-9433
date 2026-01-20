package com.example.android_tv_flutter_frontend

import io.flutter.embedding.android.FlutterActivity

/**
 * MainActivity for the Android TV Flutter app.
 *
 * NOTE:
 * This project previously attempted to override Flutter embedding render mode via
 * `getRenderMode(): RenderMode`, but the current Flutter Android embedding version
 * in this repo does not expose `RenderMode`, causing a Kotlin compilation error.
 *
 * SurfaceView vs TextureView strategy:
 * - We prefer a manifest-driven configuration (see AndroidManifest.xml meta-data)
 *   to request SurfaceView rendering for better compatibility on some Android TV
 *   emulators/devices with incomplete GLES/EGL support (white screen issues).
 */
class MainActivity : FlutterActivity()
