package com.example.android_tv_flutter_frontend

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterActivity.RenderMode

class MainActivity : FlutterActivity() {

  // Force SurfaceView rendering for better compatibility with certain Android TV
  // emulator/device EGL/GLES implementations that can fail with TextureView.
  override fun getRenderMode(): RenderMode = RenderMode.surface
}
