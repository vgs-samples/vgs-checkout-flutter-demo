package com.example.vgs_checkout_flutter_demo.utils

import com.verygoodsecurity.vgscheckout.model.VGSCheckoutEnvironment

private const val SANDBOX = "sandbox"
private const val LIVE = "live"

fun String.toEnvironment(): VGSCheckoutEnvironment {
    return when {
        startsWith(SANDBOX, true) -> VGSCheckoutEnvironment.Sandbox(this.removePrefix(SANDBOX))
        startsWith(LIVE, true) -> VGSCheckoutEnvironment.Live(this.removePrefix(LIVE))
        else -> VGSCheckoutEnvironment.Sandbox()
    }
}