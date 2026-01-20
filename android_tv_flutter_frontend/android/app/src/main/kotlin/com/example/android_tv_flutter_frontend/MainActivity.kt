package com.example.android_tv_flutter_frontend

import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterSurfaceView

class MainActivity : FlutterActivity() {

  /**
   * Force SurfaceView rendering for better compatibility with certain Android TV
   * emulator/device EGL/GLES implementations that can fail with TextureView.
   *
   * This avoids using FlutterActivity.RenderMode / getRenderMode(), which is not
   * available in some Flutter embedding versions (and was causing compilation failures).
   */
  override fun provideFlutterSurfaceView(context: Context): FlutterSurfaceView {
    // Keeping the default settings; we only want to ensure SurfaceView is used.
    return FlutterSurfaceView(context)
  }
}
