({
	confirm: function (cmp, event, helper) {
		var cmpEvent = cmp.getEvent("confirmEvent");
		cmpEvent.setParams({ confirmed: true });
		cmpEvent.fire();
		cmp.set("v.isModalOpen", false);
	},

	cancel: function (cmp, event, helper) {
		cmp.set("v.isModalOpen", false);
	}
});