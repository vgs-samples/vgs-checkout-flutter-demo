package com.example.vgs_checkout_flutter_demo.channel

import android.util.Log
import androidx.fragment.app.Fragment
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.LifecycleOwner
import com.example.vgs_checkout_flutter_demo.utils.toEnvironment
import com.google.gson.Gson
import com.verygoodsecurity.vgscheckout.VGSCheckout
import com.verygoodsecurity.vgscheckout.VGSCheckoutCallback
import com.verygoodsecurity.vgscheckout.VGSCheckoutOnInitListener
import com.verygoodsecurity.vgscheckout.config.VGSCheckoutAddCardConfig
import com.verygoodsecurity.vgscheckout.exception.VGSCheckoutException
import com.verygoodsecurity.vgscheckout.model.VGSCheckoutResult
import com.verygoodsecurity.vgscheckout.model.VGSCheckoutResult.*
import com.verygoodsecurity.vgscheckout.model.VGSCheckoutResultBundle.Keys.ADD_CARD_RESPONSE
import com.verygoodsecurity.vgscheckout.model.VGSCheckoutResultBundle.Keys.IS_PRE_SAVED_CARD
import com.verygoodsecurity.vgscheckout.model.VGSCheckoutResultBundle.Keys.SHOULD_SAVE_CARD
import com.verygoodsecurity.vgscheckout.model.response.VGSCheckoutCardResponse
import com.verygoodsecurity.vgscheckout.networking.command.core.VGSCheckoutCancellable
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class PayoptConfigChannel(fragment: Fragment, engine: FlutterEngine) : VGSCheckoutCallback {

    private var checkout: VGSCheckout
    private var channel: MethodChannel

    init {
        var cancellable: VGSCheckoutCancellable? = null
        fragment.lifecycle.addObserver(object : DefaultLifecycleObserver {

            override fun onDestroy(owner: LifecycleOwner) {
                cancellable?.cancel()
            }
        })
        checkout = VGSCheckout(fragment, this)
        channel = MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler { call, result ->
            val arguments = call.arguments as HashMap<*, *>
            when (call.method) {
                METHOD_NAME -> cancellable = startPayoutCheckoutConfig(
                    arguments["tenant_id"] as String,
                    arguments["environment"] as String,
                    arguments["access_token"] as String,
                    (arguments["saved_fin_ids"] as ArrayList<*>).mapNotNull { it as? String },
                    object : VGSCheckoutOnInitListener {

                        override fun onCheckoutInitializationFailure(exception: VGSCheckoutException) {
                            result.error(
                                exception.code.toString(),
                                exception.message,
                                exception.localizedMessage
                            )
                        }

                        override fun onCheckoutInitializationSuccess() {
                            result.success(mapOf<String, Any>("STATUS_START" to "SUCCESS"))
                        }
                    }
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

    private fun startPayoutCheckoutConfig(
        tenantId: String,
        environment: String,
        accessToken: String,
        savedCards: List<String>,
        initListener: VGSCheckoutOnInitListener
    ): VGSCheckoutCancellable? {
        Log.d("CustomConfigChannel", "tenantId = $tenantId")
        Log.d("CustomConfigChannel", "environment = $environment")
        Log.d("PayoptConfigChannel", "accessToken = $accessToken")
        Log.d("PayoptConfigChannel", "savedCards = $savedCards")
        checkout.onCheckoutInitListener = initListener
        return checkout.present(
            VGSCheckoutAddCardConfig.Builder(tenantId)
                .setEnvironment(environment.toEnvironment())
                .setAccessToken(accessToken)
                .setSavedCardsIds(savedCards)
                .build()
        )
    }

    private fun getResultData(result: VGSCheckoutResult): Map<String, Any?> {
        val data = mutableMapOf<String, Any?>()
        val card = result.data.getParcelable<VGSCheckoutCardResponse>(ADD_CARD_RESPONSE)?.body
        val isPreSavedCard = result.data.getBoolean(IS_PRE_SAVED_CARD) == true
        data["STATUS"] = if (result is Success) "FINISHED_SUCCESS" else "FINISHED_ERROR"
        data["PAYMENT_METHOD"] = if (isPreSavedCard) "SAVED_CARD" else "NEW_CARD"
        if (!isPreSavedCard) data["SHOULD_SAVE_CARD"] = result.data.getBoolean(SHOULD_SAVE_CARD)
        if (!card.isNullOrEmpty()) data["DATA"] = Gson().fromJson(card, Map::class.java)
        data["DESCRIPTION"] = "Success: \n $card"
        return data
    }

    private companion object {

        const val CHANNEL_NAME = "vgs.com.checkout/payoptAddCardConfig"
        const val METHOD_NAME = "startCheckoutAddCardConfig"
    }
}