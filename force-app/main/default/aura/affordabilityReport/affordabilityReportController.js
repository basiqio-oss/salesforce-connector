({
	handleGenerateAffordabilityReport: function (cmp, event, helper) {
		$A.enqueueAction(helper.createGenerateAffordabilityReportAction(cmp));
	},

	handlePDFAffordabilityReport: function (cmp, event, helper) {
		$A.enqueueAction(helper.createPDFAffordabilityReportAction(cmp));
	}
});