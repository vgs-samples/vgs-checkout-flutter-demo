package com.example.vgs_checkout_flutter_demo

import android.content.Intent
import android.os.Bundle
import android.util.Log
import androidx.appcompat.app.AppCompatActivity
import com.verygoodsecurity.vgscheckout.VGSCheckout
import com.verygoodsecurity.vgscheckout.config.VGSCheckoutCustomConfig
import com.verygoodsecurity.vgscheckout.config.networking.request.core.VGSCheckoutDataMergePolicy
import com.verygoodsecurity.vgscheckout.config.ui.view.address.VGSCheckoutBillingAddressVisibility
import io.flutter.embedding.android.FlutterFragment
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

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

class MainFragment : FlutterFragment() {

    private lateinit var checkout: VGSCheckout

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        checkout = VGSCheckout(this)
        flutterEngine?.let {
            CustomConfigChannel(it, checkout)
            PayoptConfigChannel(it, checkout)
        }
    }
}

class CustomConfigChannel(
    engine: FlutterEngine,
    private val checkout: VGSCheckout
) {

    init {
        MethodChannel(
            engine.dartExecutor.binaryMessenger,
            CHANNEL_NAME
        ).setMethodCallHandler { call, result ->
            Log.d("Test", "CustomConfigChannel")
            when (call.method) {
                METHOD_NAME -> startCustomCheckoutConfig()
                else -> result.notImplemented()
            }
        }
    }

    private fun startCustomCheckoutConfig() {
        val config = createConfig()
        checkout.present(config)
    }

    private fun createConfig(): VGSCheckoutCustomConfig {
        return VGSCheckoutCustomConfig.Builder("tntipgdjdyl")
            .setCardHolderOptions("card_holder_name")
            .setCardNumberOptions("card_number")
            .setExpirationDateOptions("exp_data")
            .setCVCOptions("card_cvc")
            .setBillingAddressVisibility(VGSCheckoutBillingAddressVisibility.VISIBLE)
            .setCountryOptions("billing_address.country")
            .setCityOptions("billing_address.city")
            .setAddressOptions("billing_address.addressLine1")
            .setOptionalAddressOptions("billing_address.addressLine2")
            .setPostalCodeOptions("billing_address.postal_code")
            .setMergePolicy(VGSCheckoutDataMergePolicy.NESTED_JSON)
            .setPath("post")
            .build()
    }

    private companion object {

        const val CHANNEL_NAME = "vgs.com.checkout/customConfig"
        const val METHOD_NAME = "startCustomCheckoutConfig"
    }
}

class PayoptConfigChannel constructor(
    engine: FlutterEngine,
    private val checkout: VGSCheckout
) {

    init {
        MethodChannel(
            engine.dartExecutor.binaryMessenger,
            NAME
        ).setMethodCallHandler { call, result ->
            Log.d("Test", "PayoptConfigChannel")
            when (call.method) {
                METHOD_NAME -> startPayoutCheckoutConfig()
                else -> result.notImplemented()
            }
        }
    }

    private fun startPayoutCheckoutConfig() {

    }

    private companion object {

        const val NAME = "vgs.com.checkout/payoptAddCardConfig"
        const val METHOD_NAME = "startPayoutCheckoutConfig"
    }
}
