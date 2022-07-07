({
	createGetExistigLinkAction: function (cmp) {
		const recordId = cmp.get("v.recordId");
		const objectName = cmp.get("v.sObjectName");
		let getBasiqLinkObject = cmp.get("c.getBasiqConnectLinkFromObject");
		getBasiqLinkObject.setParams({
			recordId: recordId,
			objectName: objectName
		});
		getBasiqLinkObject.setCallback(this, function (response) {
			if (response.getState() === "SUCCESS") {
				const connectLink = response.getReturnValue();
				if (connectLink) {
					cmp.set("v.connectLinkValue", connectLink);
					cmp.set("v.buttonCreateLabel", "Update link");
					cmp.set("v.buttonCreateIcon", "utility:refresh");
					cmp.set("v.connectLinkDisabled", false);
					cmp.set("v.connectLinkVisible", "slds-show");
				}
			} else {
				const error = JSON.parse(response.getError()[0].message);
				cmp.set("v.errorModalOpen", true);
				cmp.set("v.errorMessage", error.message ? error.message : "Failed to load Basiq widget");
			}
		});

		return getBasiqLinkObject;
	},

	createFetchExistingConnectionObjectsAction: function (cmp) {
		const recordId = cmp.get("v.recordId");
		const objectName = cmp.get("v.sObjectName");
		let fetchExistingConnectionObjects = cmp.get("c.fetchExistingConnectionObjects");

		fetchExistingConnectionObjects.setParams({
			recordId: recordId,
			objectName: objectName
		});

		fetchExistingConnectionObjects.setCallback(this, function (response) {
			if (response.getState() === "SUCCESS") {
				const data = JSON.parse(response.getReturnValue());
				if (!data || data.length == 0) {
					$A.enqueueAction(this.createRetriveConnectionsAction(cmp));
				} else {
					data.sort(function (connection1, connection2) {
						var institution1 = connection1.institution.toUpperCase();
						var institution2 = connection2.institution.toUpperCase();
						return institution1 < institution2 ? -1 : institution1 > institution2 ? 1 : 0;
					});
					cmp.set("v.connectionList", data);
				}
			} else {
				let error;
				try {
					error = JSON.parse(response.getError()[0].message);
				} catch (e) {
					error = response.getError()[0].message;
				}
				cmp.set("v.errorModalOpen", true);
				cmp.set("v.errorTitle", error.title ? error.title : "Error");
				cmp.set("v.errorMessage", error.message ? error.message : "Failed to load existing connections");
			}
		});

		return fetchExistingConnectionObjects;
	},

	createGetBasiqLinkAction: function (cmp) {
		const recordId = cmp.get("v.recordId");
		const objectName = cmp.get("v.sObjectName");
		let getBasiqLink = cmp.get("c.getBasiqLink");
		getBasiqLink.setParams({
			recordId: recordId,
			objectName: objectName
		});
		getBasiqLink.setCallback(this, function (response) {
			if (response.getState() === "SUCCESS") {
				const connectLink = response.getReturnValue();
				if (connectLink) {
					cmp.set("v.connectLinkValue", connectLink);
					cmp.set("v.buttonCreateLabel", "Update link");
					cmp.set("v.buttonCreateIcon", "utility:refresh");
					cmp.set("v.connectLinkDisabled", false);
					cmp.set("v.connectLinkVisible", "slds-show");
				}
			} else {
				let error;
				try {
					error = JSON.parse(response.getError()[0].message);
				} catch (e) {
					error = response.getError()[0].message;
				}
				cmp.set("v.errorModalOpen", true);
				cmp.set("v.errorTitle", error.title ? error.title : "Error");
				cmp.set("v.errorMessage", error.message ? error.message : "Action failed");
			}
		});

		return getBasiqLink;
	},

	createDeleteBasiqLinkAction: function (cmp) {
		const recordId = cmp.get("v.recordId");
		const objectName = cmp.get("v.sObjectName");

		let deleteBasiqLink = cmp.get("c.deleteBasiqLink");
		deleteBasiqLink.setParams({
			recordId: recordId,
			objectName: objectName
		});
		deleteBasiqLink.setCallback(this, function (response) {
			if (response.getState() === "SUCCESS") {
				cmp.set("v.connectLinkValue", "Link not created");
				cmp.set("v.buttonCreateLabel", "Create Link");
				cmp.set("v.buttonCreateIcon", "utility:add");
				cmp.set("v.connectLinkDisabled", true);
				cmp.set("v.connectLinkVisible", "slds-hide");
				this.showInfoToast("Link has been disabled");
			} else {
				const error = JSON.parse(response.getError()[0].message);
				cmp.set("v.errorModalOpen", true);
				cmp.set("v.errorTitle", error.title);
				cmp.set("v.errorMessage", error.message ? error.message : "Action failed");
			}
		});

		return deleteBasiqLink;
	},

	createRefreshConnectionAction: function (cmp, connectionIdList) {
		let refreshConnection = cmp.get("c.refreshConnections");
		const recordId = cmp.get("v.recordId");
		const objectName = cmp.get("v.sObjectName");

		const boxes = cmp.find("connections");
		let connections;
		if (Array.isArray(boxes)) {
			connections = boxes;
		} else {
			connections = [];
			connections.push(boxes);
		}
		for (let i = 0; i < connectionIdList.length; i++) {
			if (connections.find((el) => el.get("v.value") == connectionIdList[i])) {
				this.addConnectionStatusMessage(cmp, connectionIdList[i], "Waiting in queue...");
			}
		}

		refreshConnection.setParams({
			recordId: recordId,
			objectName: objectName,
			connectionIdListData: JSON.stringify(connectionIdList)
		});

		refreshConnection.setCallback(this, function (response) {
			if (response.getState() === "SUCCESS") {
				const data = JSON.parse(response.getReturnValue());
				if (data) {
					let connectionJobList = [];
					for (let i = 0; i < data.length; ++i) {
						if (data[i].error) {
							this.removeConnectionFromActiveRefershList(cmp, data[i].id);
							this.addConnectionStatusMessage(cmp, data[i].id, data[i].error);
						} else {
							connectionJobList.push(data[i].id);
						}
					}
					$A.enqueueAction(this.createCheckRefreshJobAction(cmp, recordId, objectName, connectionJobList));
				}
			} else {
				const error = JSON.parse(response.getError()[0].message);
				cmp.set("v.errorModalOpen", true);
				cmp.set("v.errorMessage", error.message ? error.message : "Failed to load Basiq widget");
			}
		});
		return refreshConnection;
	},

	createCheckRefreshJobAction: function (cmp, recordId, objectName, connectionIdList) {
		cmp.set("v.refreshConnectionsInProgress", connectionIdList);
		let checkRefreshJobStatuses = cmp.get("c.checkRefreshJobStatuses");
		checkRefreshJobStatuses.setParams({
			recordId: recordId,
			objectName: objectName,
			connectionIdListData: JSON.stringify(connectionIdList)
		});
		checkRefreshJobStatuses.setCallback(this, function (response) {
			if (response.getState() === "SUCCESS") {
				let data = [];
				connectionIdList = [];
				const responseValue = response.getReturnValue();
				if (responseValue != null) {
					data = JSON.parse(responseValue);
				}
				for (let i = 0; i < data.length; ++i) {
					if (data[i].error) {
						this.addConnectionStatusMessage(cmp, data[i].id, data[i].error);
						this.removeConnectionFromActiveRefershList(cmp, data[i].id);
					} else if (data[i].data) {
						this.addConnectionStatusMessage(cmp, data[i].id, data[i].data.message, data[i].data.lastUsed);
						if ((data[i].data.title === "retrieve-transactions" && data[i].data.status === "success") || data[i].data.status === "failed") {
							this.removeConnectionFromActiveRefershList(cmp, data[i].id);
							if (data[i].data.title === "retrieve-transactions" && data[i].data.status === "success") {
								$A.enqueueAction(this.createStoreConnectionFinancialDataAction(cmp, recordId, objectName, data[i].id));
							}
						} else {
							connectionIdList.push(data[i].id);
						}
					} else {
						this.removeConnectionFromActiveRefershList(cmp, data[i].id);
					}
				}
				if (connectionIdList.length > 0) {
					setTimeout(function () {
						checkRefreshJobStatuses.setParams({
							recordId: recordId,
							objectName: objectName,
							connectionIdListData: JSON.stringify(connectionIdList)
						});
						$A.enqueueAction(checkRefreshJobStatuses);
					}, 5000);
				}
			} else {
				let error;
				try {
					error = JSON.parse(response.getError()[0].message);
				} catch (e) {
					error = response.getError()[0].message;
				}
				console.log(error);
				cmp.set("v.errorModalOpen", true);
				cmp.set("v.errorTitle", error.title ? error.title : "Error");
				cmp.set("v.errorMessage", error.message ? error.message : "Failed to refresh existing connections");
			}
		});

		return checkRefreshJobStatuses;
	},

	createStoreConnectionFinancialDataAction: function (cmp, recordId, objectName, connectionId) {
		let storeConnectionFinancialData = cmp.get("c.storeConnectionFinancialData");
		storeConnectionFinancialData.setParams({
			recordId: recordId,
			objectName: objectName,
			connectionId: connectionId
		});

		storeConnectionFinancialData.setCallback(this, function (response) {
			this.removeConnectionFromActiveRefershList(cmp, connectionId);
			if (response.getState() === "SUCCESS") {
				console.log(response.getState());
			} else {
				let error;
				try {
					error = JSON.parse(response.getError()[0].message);
				} catch (e) {
					error = response.getError()[0].message;
				}
				console.log(error);
				this.addConnectionStatusMessage(cmp, connectionId, error.message ? error.message : "Failed to store Basiq financial data");
			}
		});

		return storeConnectionFinancialData;
	},

	createRetriveConnectionsAction: function (cmp) {
		cmp.set("v.retrieveConnectionsInProgress", true);
		const recordId = cmp.get("v.recordId");
		const objectName = cmp.get("v.sObjectName");
		let retriveConnections = cmp.get("c.retriveConnections");
		retriveConnections.setParams({
			recordId: recordId,
			objectName: objectName
		});
		retriveConnections.setCallback(this, function (response) {
			if (response.getState() === "SUCCESS") {
				let data = [];
				const responseValue = response.getReturnValue();
				if (responseValue != null) {
					data = JSON.parse(responseValue);
				}
				cmp.set("v.connectionList", data);
				let connectionIdList = [];
				for (let i = 0; i < data.length; ++i) {
					connectionIdList.push(data[i].id);
				}
				$A.enqueueAction(this.createRefreshConnectionAction(cmp, connectionIdList));
			} else {
				this.showErrorToast("Failed to refresh Basiq connections");
				console.log(response.getError());
			}
			cmp.set("v.retrieveConnectionsInProgress", false);
		});
		return retriveConnections;
	},

	createRevokeConnectionAction: function (cmp, connectionId) {
		const recordId = cmp.get("v.recordId");
		const objectName = cmp.get("v.sObjectName");
		let revokeConnection = cmp.get("c.revokeConnection");
		revokeConnection.setParams({
			recordId: recordId,
			objectName: objectName,
			connectionId: connectionId
		});
		revokeConnection.setCallback(this, function (response) {
			if (response.getState() === "SUCCESS") {
				let list = cmp.get("v.connectionList");
				cmp.set(
					"v.connectionList",
					list.filter((row) => row.id !== connectionId)
				);
			} else {
				const error = JSON.parse(response.getError()[0].message);
				this.addConnectionStatusMessage(cmp, connectionId, error.message ? error.message : "Failed to revoke Basiq consent");
			}
		});
		return revokeConnection;
	},

	removeConnectionFromActiveRefershList: function (cmp, connectionId) {
		let refreshConnectionsInProgress = cmp.get("v.refreshConnectionsInProgress");
		const index = refreshConnectionsInProgress.indexOf(connectionId);
		if (index > -1) {
			refreshConnectionsInProgress.splice(index, 1);
		}
		cmp.set("v.refreshConnectionsInProgress", refreshConnectionsInProgress);
	},

	addConnectionStatusMessage: function (cmp, connectionId, status, lastUsed) {
		let list = cmp.get("v.connectionList");
		cmp.set(
			"v.connectionList",
			list.map((row) => {
				if (row.id === connectionId) {
					row.status = status;
					if (lastUsed) row.lastUsed = lastUsed;
				}
				return row;
			})
		);
	},

	copyLink: function (cmp) {
		let link = cmp.get("v.connectLinkValue");
		var hiddenInput = document.createElement("input");
		hiddenInput.setAttribute("value", link);
		document.body.appendChild(hiddenInput);
		hiddenInput.select();
		document.execCommand("copy");
		document.body.removeChild(hiddenInput);
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
	},

	showInfoToast: function (text) {
		var toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
			type: "info",
			message: text
		});
		toastEvent.fire();
	},

	setUI: function (cmp) {
		let minimizeIconName = window.localStorage.getItem("minimizeIconName");
		let minimizeClassName = window.localStorage.getItem("minimizeClassName");
		if (minimizeIconName && minimizeClassName) {
			cmp.set("v.minimizeIconName", minimizeIconName);
			cmp.set("v.minimizeClassName", minimizeClassName);
		}
	},

	sortConnections: function (cmp, column, ascending) {
		let connections = cmp.get("v.connectionList");
		connections.sort(function (connection1, connection2) {
			var attrib1;
			var attrib2;
			switch (column) {
				case 0:
					attrib1 = connection1.institution.toUpperCase();
					attrib2 = connection2.institution.toUpperCase();
					break;
				case 1:
					attrib1 = connection1.status.toUpperCase();
					attrib2 = connection2.status.toUpperCase();
					break;
				case 2:
					attrib1 = connection1.lastUsed;
					attrib2 = connection2.lastUsed;
					break;
			}
			if (!ascending) {
				return attrib1 < attrib2 ? -1 : attrib1 > attrib2 ? 1 : 0;
			} else {
				return attrib1 > attrib2 ? -1 : attrib1 < attrib2 ? 1 : 0;
			}
		});
		cmp.set("v.connectionList", connections);
	}
});