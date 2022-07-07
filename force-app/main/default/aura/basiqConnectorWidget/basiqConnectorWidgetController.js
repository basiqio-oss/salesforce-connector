({
	init: function (cmp, event, helper) {
		helper.setUI(cmp);
		$A.enqueueAction(helper.createGetExistigLinkAction(cmp));
		$A.enqueueAction(helper.createFetchExistingConnectionObjectsAction(cmp));
	},

	handleCreateLink: function (cmp, event, helper) {
		$A.enqueueAction(helper.createGetBasiqLinkAction(cmp));
	},

	handleCopyLink: function (cmp, event, helper) {
		helper.copyLink(cmp);
		helper.showSuccessToast("Link copied to clipboard");
	},

	handleDeleteLink: function (cmp, event, helper) {
		$A.enqueueAction(helper.createDeleteBasiqLinkAction(cmp));
	},

	handleRefreshClick: function (cmp, event, helper) {
		const connectionsData = cmp.find("connections");
		if (connectionsData) {
			let connectionList;
			if (!Array.isArray(connectionsData)) {
				connectionList = [];
				connectionList.push(connectionsData);
			} else {
				connectionList = connectionsData;
			}
			let connectionIdList = [];
			let refreshConnectionsInProgress = cmp.get("v.refreshConnectionsInProgress");
			for (let i = 0; i < connectionList.length; ++i) {
				if (connectionList[i].get("v.checked") && !refreshConnectionsInProgress.find((el) => el == connectionList[i].get("v.value"))) {
					connectionIdList.push(connectionList[i].get("v.value"));
				}
			}
			if (connectionIdList.length === 0) {
				$A.enqueueAction(helper.createRetriveConnectionsAction(cmp));
			} else {
				$A.enqueueAction(helper.createRefreshConnectionAction(cmp, connectionIdList));
			}
		} else {
			$A.enqueueAction(helper.createRetriveConnectionsAction(cmp));
		}
	},

	handleRevokeClick: function (cmp, event, helper) {
		const connectionsData = cmp.find("connections");
		if (connectionsData) {
			let connectionList;
			if (!Array.isArray(connectionsData)) {
				connectionList = [];
				connectionList.push(connectionsData);
			} else {
				connectionList = connectionsData;
			}
			let connectionIdList = [];
			let refreshConnectionsInProgress = cmp.get("v.refreshConnectionsInProgress");
			for (let i = 0; i < connectionList.length; ++i) {
				if (connectionList[i].get("v.checked") && !refreshConnectionsInProgress.find((el) => el == connectionList[i].get("v.value"))) {
					connectionIdList.push(connectionList[i].get("v.value"));
				}
			}
			for (let i = 0; i < connectionIdList.length; ++i) {
				$A.enqueueAction(helper.createRevokeConnectionAction(cmp, connectionIdList[i]));
			}
		}
	},

	handleMainCheckBoxClick: function (cmp, event, helper) {
		let checked = event.getSource().get("v.checked");
		const connections = cmp.find("connections");
		if (connections) {
			if (!Array.isArray(connections)) {
				connections.set("v.checked", checked);
			} else {
				for (let i = 0; i < connections.length; ++i) {
					connections[i].set("v.checked", checked);
				}
			}
		}
	},

	handleMinimizeClick: function (cmp, event, helper) {
		let minimizedName = "utility:contract_alt";
		let maximizedName = "utility:expand_alt";
		let newName = "";
		let minimizedClass = "slds-hide";
		let maximizedClass = "slds-show";
		let newClass = "";

		let minimized = cmp.get("v.minimizeClassName") == minimizedClass;
		if (minimized) {
			newName = minimizedName;
			newClass = maximizedClass;
		} else {
			newName = maximizedName;
			newClass = minimizedClass;
		}

		window.localStorage.setItem("minimizeIconName", newName);
		window.localStorage.setItem("minimizeClassName", newClass);

		cmp.set("v.minimizeIconName", newName);
		cmp.set("v.minimizeClassName", newClass);
	},

	handleInstitutionArrowClick: function (cmp, event, helper) {
		let column = parseInt(event.getSource().getLocalId(), 10);
		let ascending = cmp.get("v.connectionSortingAscending");
		helper.sortConnections(cmp, column, ascending);
		cmp.set("v.connectionSortingColumn", column);
		cmp.set("v.connectionSortingAscending", !ascending);
	}
});