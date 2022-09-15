package com.example.vgs_checkout_flutter_demo.utils

import com.verygoodsecurity.vgscheckout.model.VGSCheckoutEnvironment

fun String.toEnvironment(): VGSCheckoutEnvironment {
    return when {
        contains("sandbox", true) -> VGSCheckoutEnvironment.Sandbox()
        contains("live", true) -> VGSCheckoutEnvironment.Live()
        else -> throw IllegalArgumentException("Invalid environment")
    }
}