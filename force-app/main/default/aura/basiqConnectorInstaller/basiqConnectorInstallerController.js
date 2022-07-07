({
	init: function (cmp, event, helper) {
		const navService = cmp.find("navService");
		const pageReference = {
			type: "standard__objectPage",
			attributes: {
				objectApiName: "Contact",
				actionName: "home"
			}
		};
		cmp.set("v.accountPageReference", pageReference);
		var defaultUrl = "#";
		navService.generateUrl(pageReference).then(
			$A.getCallback(function (url) {
				cmp.set("v.accountPageURL", url ? url : defaultUrl);
			}),
			$A.getCallback(function (error) {
				cmp.set("v.accountPageURL", defaultUrl);
			})
		);
		let checkStoredApiKey = cmp.get("c.checkStoredApiKey");
		checkStoredApiKey.setCallback(this, function (response) {
			const state = response.getState();
			if (state === "SUCCESS") {
				const apiKeyStored = response.getReturnValue();
				cmp.set("v.apiKeyStored", apiKeyStored);
			}
			cmp.set("v.apiKeyChecked", true);
		});
		$A.enqueueAction(checkStoredApiKey);

		cmp.set("v.installerSteps", [
			{ label: "Step 1 : Authenticate", value: "step-1" },
			{ label: "Step 2 : Map Fields", value: "step-2" },
			{ label: "Finalise", value: "step-3" }
		]);
		const defaultIndex = 0;
		cmp.set("v.currentStep", { value: cmp.get("v.installerSteps")[defaultIndex].value, index: defaultIndex });

		let actionLeadFields = cmp.get("c.getLeadFieldApiNames");
		let actionContactFields = cmp.get("c.getContactFieldApiNames");

		actionLeadFields.setCallback(this, function (response) {
			console.log(response.getError());
			const state = response.getState();
			if (state === "SUCCESS") {
				const data = response.getReturnValue();
				let options = [];
				for (let i = 0; i < data.length; ++i) {
					options.push({ value: data[i], label: data[i] });
				}
				cmp.set("v.leadEmailOptions", options);
				cmp.set("v.leadMobileOptions", options);
			} else {
				console.log("Failed with state: " + state);
			}
		});

		actionContactFields.setCallback(this, function (response) {
			console.log(response.getError());
			const state = response.getState();
			if (state === "SUCCESS") {
				const data = response.getReturnValue();
				let options = [];
				for (let i = 0; i < data.length; ++i) {
					options.push({ value: data[i], label: data[i] });
				}
				cmp.set("v.contactEmailOptions", options);
				cmp.set("v.contactMobileOptions", options);
			} else {
				console.log("Failed with state: " + state);
			}
		});
		$A.enqueueAction(actionLeadFields);
		$A.enqueueAction(actionContactFields);
	},

	handleCancel: function (cmp, event, helper) {
		const currentStep = cmp.get("v.currentStep");
		const previousStep = currentStep.index - 1;
		const currentStepContent = helper.getInstallStepsText(previousStep);
		cmp.set("v.currentStep", { value: cmp.get("v.installerSteps")[previousStep].value, index: previousStep });
		if (currentStepContent) {
			helper.setHeaderTitleAndText(previousStep, currentStepContent.title, currentStepContent.text, currentStepContent.img);
		}

		cmp.set("v.nextEnabled", true);
	},

	handleNext: function (cmp, event, helper) {
		const currentStep = cmp.get("v.currentStep");
		const nextStepSucces = (cmp) => {
			const nextIndex = currentStep.index + 1;
			const currentStepContent = helper.getInstallStepsText(nextIndex);

			cmp.set("v.currentStep", { value: cmp.get("v.installerSteps")[nextIndex].value, index: nextIndex });
			if (currentStepContent) {
				helper.setHeaderTitleAndText(nextIndex, currentStepContent.title, currentStepContent.text, currentStepContent.img);
			}
		};

		if (currentStep.index === 0) {
			const apiInput = cmp.find("basiqapikeyform");
			const inputVal = apiInput.get("v.value");

			let actionCheckAPIKey = cmp.get("c.checkBasiqApiKey");
			actionCheckAPIKey.setParams({
				apiKey: inputVal
			});
			let actionStoreAPIKey = cmp.get("c.storeApiKey");
			actionStoreAPIKey.setParams({
				apiKey: inputVal
			});
			actionCheckAPIKey.setCallback(this, function (response) {
				console.log(response.getError());
				const state = response.getState();
				if (state === "SUCCESS") {
					actionStoreAPIKey.setCallback(this, function (response) {
						console.log(response.getError());
						const state = response.getState();
						if (state === "SUCCESS") {
							cmp.set("v.apiKeyStored", true);
							nextStepSucces(cmp);
						} else {
							console.log("Failed with state: " + state);
						}
					});
					$A.enqueueAction(actionStoreAPIKey);
				} else {
					const state = response.getState();
					cmp.set("v.errorModalOpen", true);
					cmp.set("v.errorMessage", "API key not valid!");
				}
			});
			$A.enqueueAction(actionCheckAPIKey);
		} else if (currentStep.index === 1) {
			const elInput = cmp.find("emailLead");
			const mlInput = cmp.find("mobileLead");
			const ecInput = cmp.find("emailContact");
			const mcInput = cmp.find("mobileContact");

			let actionStoreMappings = cmp.get("c.storeMappingFields");
			console.log(elInput.get("v.value"));
			console.log(mlInput.get("v.value"));

			actionStoreMappings.setParams({
				contactEmail: ecInput.get("v.value"),
				contactMobile: mcInput.get("v.value"),
				leadEmail: elInput.get("v.value"),
				leadMobile: mlInput.get("v.value")
			});

			actionStoreMappings.setCallback(this, function (response) {
				console.log(response.getError());
				const state = response.getState();
				if (state === "SUCCESS") {
					nextStepSucces(cmp);
				} else {
					console.log("Failed with state: " + state);
					cmp.set("v.errorModalOpen", true);
					cmp.set("v.errorMessage", state);
				}
			});

			$A.enqueueAction(actionStoreMappings);
		}

		cmp.set("v.nextEnabled", true);
	},

	handleAPIKeyInput: function (cmp, event, helper) {
		const apiInput = event.getSource();
		const inputVal = apiInput.get("v.value");
		if (inputVal.length > 0) {
			cmp.set("v.nextEnabled", false);
		} else {
			cmp.set("v.nextEnabled", true);
		}
	},

	handleMappingInput: function (cmp) {
		const elInput = cmp.find("emailLead");
		const mlInput = cmp.find("mobileLead");
		const ecInput = cmp.find("emailContact");
		const mcInput = cmp.find("mobileContact");
		const cInput = cmp.find("changePer");
		if (elInput.get("v.value") && mlInput.get("v.value") && ecInput.get("v.value") && mcInput.get("v.value") && cInput.get("v.value").length) {
			cmp.set("v.nextEnabled", false);
		} else {
			cmp.set("v.nextEnabled", true);
		}
	},

	handleFinish: function (cmp) {
		const navService = cmp.find("navService");
		const pageReference = cmp.get("v.accountPageReference");
		navService.navigate(pageReference);
	},

	handleEdit: function (cmp) {
		cmp.set("v.confirmModalOpen", true);
	},

	handleConfirmed: function (cmp, event) {
		var confirmed = event.getParam("confirmed");
		if (confirmed) {
			let actionRemoveAPIKey = cmp.get("c.removeApiKey");
			actionRemoveAPIKey.setCallback(this, function (response) {
				const state = response.getState();
				if (state === "SUCCESS") {
					cmp.set("v.apiKeyStored", false);
				}
			});
			$A.enqueueAction(actionRemoveAPIKey);
		}
	}
});