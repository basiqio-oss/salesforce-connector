({
	createGenerateAffordabilityReportAction: function (cmp) {
		cmp.set("v.generateInProgress", true);

		let parentComponent = cmp.get("v.parent");
		const recordId = parentComponent.get("v.recordId");
		const objectName = parentComponent.get("v.sObjectName");
		let postAffordabilityReport = parentComponent.get("c.postAffordabilityReport");

		postAffordabilityReport.setParams({
			recordId: recordId,
			objectName: objectName
		});

		postAffordabilityReport.setCallback(this, function (response) {
			if (response.getState() === "SUCCESS") {
				this.showSuccessToast("Affordability report generated.");
			} else {
				this.showErrorToast("Affordability report error.");
				console.log(response.getError());
			}
			cmp.set("v.generateInProgress", false);
		});

		return postAffordabilityReport;
	},

	createPDFAffordabilityReportAction: function (cmp) {
		cmp.set("v.generateInProgress", true);

		let parentComponent = cmp.get("v.parent");
		const recordId = parentComponent.get("v.recordId");
		const objectName = parentComponent.get("v.sObjectName");
		let postPDFAffordabilityReport = parentComponent.get("c.postPDFAffordabilityReport");

		postPDFAffordabilityReport.setParams({
			recordId: recordId,
			objectName: objectName
		});

		postPDFAffordabilityReport.setCallback(this, function (response) {
			if (response.getState() === "SUCCESS") {
				this.showSuccessToast("Affordability PDF downloaded to attachments.");
				$A.get('e.force:refreshView').fire();
			} else {
				this.showErrorToast("Affordability PDF download error.");
				console.log(response.getError());
			}
			cmp.set("v.generateInProgress", false);
		});

		return postPDFAffordabilityReport;
	},

	showSuccessToast: function (text) {
		var toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
			type: "success",
			message: text
		});
		toastEvent.fire();
	},

	showErrorToast: function (text) {
		var toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
			type: "error",
			message: text
		});
		toastEvent.fire();
	}
});