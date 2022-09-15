package com.example.vgs_checkout_flutter_demo

import android.content.Intent
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.example.vgs_checkout_flutter_demo.channel.CustomConfigChannel
import com.example.vgs_checkout_flutter_demo.channel.PayoptConfigChannel
import io.flutter.embedding.android.FlutterFragment

private const val FRAGMENT_TAG = " com.example.vgs_checkout_flutter_demo.main_fragment"

class MainActivity : AppCompatActivity(R.layout.activity_main) {

    private var fragment: FlutterFragment? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        startFragment()
    }

    override fun onPostResume() {
        super.onPostResume()
        fragment?.onPostResume()
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        fragment?.onNewIntent(intent)
    }

    override fun onBackPressed() {
        fragment?.onBackPressed()
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        @Suppress("DEPRECATION")
        fragment?.onRequestPermissionsResult(requestCode, permissions, grantResults)
    }

    override fun onUserLeaveHint() {
        fragment?.onUserLeaveHint()
    }

    override fun onTrimMemory(level: Int) {
        super.onTrimMemory(level)
        fragment?.onTrimMemory(level)
    }

    private fun startFragment() {
        fragment = supportFragmentManager.findFragmentByTag(FRAGMENT_TAG) as? FlutterFragment
        if (fragment == null) {
            fragment = MainFragment().also {
                supportFragmentManager.beginTransaction()
                    .add(R.id.fcvContainer, it, FRAGMENT_TAG)
                    .addToBackStack(null)
                    .commit()
            }
        }
    }
}

/** We need to use FlutterFragment because Flatter Activity uses deprecated way of handling onActivityResult. */
class MainFragment : FlutterFragment() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        flutterEngine?.let {
            CustomConfigChannel(this, it)
            PayoptConfigChannel(this, it)
        }
    }
}
