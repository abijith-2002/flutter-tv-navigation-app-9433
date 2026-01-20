package com.example.android_tv_flutter_frontend

import io.flutter.embedding.android.FlutterActivity

/**
 * MainActivity for the Android TV Flutter app.
 *
 * Forces SurfaceView rendering (instead of TextureView) to improve compatibility with
 * some Android TV emulators/devices where GL/EGL support is incomplete and can lead
 * to a persistent white screen.
 */
class MainActivity : FlutterActivity() {

  override fun getRenderMode(): RenderMode {
    // Force SurfaceView.
    return RenderMode.surface
  }
}
