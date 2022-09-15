package com.example.vgs_checkout_flutter_demo.channel

import android.util.Log
import androidx.fragment.app.Fragment
import com.example.vgs_checkout_flutter_demo.utils.toEnvironment
import com.google.gson.Gson
import com.verygoodsecurity.vgscheckout.VGSCheckout
import com.verygoodsecurity.vgscheckout.VGSCheckoutCallback
import com.verygoodsecurity.vgscheckout.config.VGSCheckoutCustomConfig
import com.verygoodsecurity.vgscheckout.config.networking.request.core.VGSCheckoutDataMergePolicy
import com.verygoodsecurity.vgscheckout.config.ui.view.address.VGSCheckoutBillingAddressVisibility
import com.verygoodsecurity.vgscheckout.model.VGSCheckoutResult
import com.verygoodsecurity.vgscheckout.model.VGSCheckoutResult.*
import com.verygoodsecurity.vgscheckout.model.VGSCheckoutResultBundle.Keys.ADD_CARD_RESPONSE
import com.verygoodsecurity.vgscheckout.model.response.VGSCheckoutCardResponse
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class CustomConfigChannel(fragment: Fragment, engine: FlutterEngine) : VGSCheckoutCallback {

    private var checkout: VGSCheckout
    private var channel: MethodChannel

    init {
        checkout = VGSCheckout(fragment, this)
        channel = MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler { call, result ->
            val arguments = call.arguments as HashMap<*, *>
            when (call.method) {
                METHOD_NAME -> startCustomCheckoutConfig(
                    arguments["vault_id"] as String,
                    arguments["environment"] as String
                )
                else -> result.notImplemented()
            }
        }
    }

    override fun onCheckoutResult(result: VGSCheckoutResult) {
        val data = getResultData(result)
        when (result) {
            is Success -> channel.invokeMethod("handleCheckoutSuccess", data)
            is Failed -> channel.invokeMethod("handleCheckoutFail", data)
            is Canceled -> channel.invokeMethod("handleCancelCheckout", null)
        }
    }

    private fun startCustomCheckoutConfig(vaultId: String, environment: String) {
        Log.d("CustomConfigChannel", "vaultId = $vaultId")
        Log.d("CustomConfigChannel", "environment = $environment")
        val config = createConfig(vaultId, environment)
        checkout.present(config)
    }

    private fun createConfig(vaultId: String, environment: String): VGSCheckoutCustomConfig {
        return VGSCheckoutCustomConfig.Builder(vaultId)
            .setEnvironment(environment.toEnvironment())
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

    private fun getResultData(result: VGSCheckoutResult): Map<String, Any> {
        val data = mutableMapOf<String, Any>()
        val response = result.data.getParcelable<VGSCheckoutCardResponse>(ADD_CARD_RESPONSE)?.body
        data["STATUS"] = if (result is Success) "FINISHED_SUCCESS" else "FINISHED_ERROR"
        if (!response.isNullOrEmpty()) data["DATA"] = Gson().fromJson(response, Map::class.java)
        data["DESCRIPTION"] = "Success: \n $response"
        return data
    }

    private companion object {

        const val CHANNEL_NAME = "vgs.com.checkout/customConfig"
        const val METHOD_NAME = "startCustomCheckoutConfig"
    }
}