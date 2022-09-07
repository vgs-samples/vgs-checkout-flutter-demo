//
//  DemoAppConfiguration.swift
//  Runner

import Foundation

/// Setup your configuration details here.
class DemoAppConfiguration {

	/// Shared instance.
	static let shared = DemoAppConfiguration()

	/// no:doc
	private init() {}

	/// Set your vault id here. https://www.verygoodsecurity.com/terminology/nomenclature#vault
	var vaultId = "VAULT_ID"

	/// Set tenant id matching your payment orchestration configuration.
	var paymentOrchestrationTenantId = "TENANT_ID"

	/// Set environment - `sandbox` for testing or `live` for production.
	var environment = "sandbox"
}
