function UniversalAnalyticsClient(trackerName) {
  this.trackerName = trackerName;
}

UniversalAnalyticsClient.prototype.getName = function() {
  return this.trackerName;
};

UniversalAnalyticsClient.prototype.setAllowIDFACollection = function (enable, success, error) {
  cordova.exec(success, error, 'UniversalAnalytics', 'setAllowIDFACollection', [enable, this.trackerName]);
};

UniversalAnalyticsClient.prototype.setUserId = function (id, success, error) {
  cordova.exec(success, error, 'UniversalAnalytics', 'setUserId', [id, this.trackerName]);
};

UniversalAnalyticsClient.prototype.setAnonymizeIp = function (anonymize, success, error) {
  cordova.exec(success, error, 'UniversalAnalytics', 'setAnonymizeIp', [anonymize, this.trackerName]);
};

UniversalAnalyticsClient.prototype.setOptOut = function (optout, success, error) {
  cordova.exec(success, error, 'UniversalAnalytics', 'setOptOut', [optout, this.trackerName]);
};

UniversalAnalyticsClient.prototype.setAppVersion = function (version, success, error) {
  cordova.exec(success, error, 'UniversalAnalytics', 'setAppVersion', [version, this.trackerName]);
};

UniversalAnalyticsClient.prototype.getVar = function (variable, success, error) {
  cordova.exec(success, error, 'UniversalAnalytics', 'getVar', [variable, this.trackerName]);
};

UniversalAnalyticsClient.prototype.setVar = function (variable, value, success, error) {
  cordova.exec(success, error, 'UniversalAnalytics', 'setVar', [variable, value, this.trackerName]);
};

UniversalAnalyticsClient.prototype.dispatch = function (success, error) {
  cordova.exec(success, error, 'UniversalAnalytics', 'dispatch', [this.trackerName]);
};

/* enables verbose logging */
UniversalAnalyticsClient.prototype.debugMode = function (success, error) {
  cordova.exec(success, error, 'UniversalAnalytics', 'debugMode', [this.trackerName]);
};

UniversalAnalyticsClient.prototype.trackMetric = function (key, value, success, error) {
  // as key was formerly documented to be of type string,
  // we need to at least accept string formatted numbers and pass the converted number
  var numberKey = key;
  if (typeof key === "string") {
    numberKey = Number.parseInt(key);
    if (isNaN(numberKey)) {
      throw Error("key must be a valid integer or string formatted integer");
    }
  }

  // as value was formerly documented to be of type string
  // and therefore platform implementations expect value parameter of type string,
  // we need to cast the value parameter to string - although gathered metrics are infact number types.
  var stringValue = value || "";
  if (typeof stringValue !== "string") {
    stringValue = String(value);
  }
  cordova.exec(success, error, 'UniversalAnalytics', 'trackMetric', [numberKey, stringValue, this.trackerName]);
};

UniversalAnalyticsClient.prototype.trackView = function (screen, campaignUrl, newSession, success, error) {
  if (typeof campaignUrl === 'undefined' || campaignUrl === null) {
    campaignUrl = '';
  }

  if (typeof newSession === 'undefined' || newSession === null) {
    newSession = false;
  }

  cordova.exec(success, error, 'UniversalAnalytics', 'trackView', [screen, campaignUrl, newSession, this.trackerName]);
};

UniversalAnalyticsClient.prototype.addCustomDimension = function (key, value, success, error) {
  if (typeof key !== "number") {
    throw Error("key must be a valid integer not '" + typeof key + "'");
  }
  cordova.exec(success, error, 'UniversalAnalytics', 'addCustomDimension', [key, value, this.trackerName]);
};

UniversalAnalyticsClient.prototype.trackEvent = function (category, action, label, value, newSession, success, error) {
  if (typeof label === 'undefined' || label === null) {
    label = '';
  }
  if (typeof value === 'undefined' || value === null) {
    value = 0;
  }

  if (typeof newSession === 'undefined' || newSession === null) {
    newSession = false;
  }

  cordova.exec(success, error, 'UniversalAnalytics', 'trackEvent', [category, action, label, value, newSession, this.trackerName]);
};

/**
 * https://developers.google.com/analytics/devguides/collection/android/v3/exceptions
 */
UniversalAnalyticsClient.prototype.trackException = function (description, fatal, success, error) {
  cordova.exec(success, error, 'UniversalAnalytics', 'trackException', [description, fatal, this.trackerName]);
};

UniversalAnalyticsClient.prototype.trackTiming = function (category, intervalInMilliseconds, name, label, success, error) {
  if (typeof intervalInMilliseconds === 'undefined' || intervalInMilliseconds === null) {
    intervalInMilliseconds = 0;
  }
  if (typeof name === 'undefined' || name === null) {
    name = '';
  }
  if (typeof label === 'undefined' || label === null) {
    label = '';
  }

  cordova.exec(success, error, 'UniversalAnalytics', 'trackTiming', [category, intervalInMilliseconds, name, label, this.trackerName]);
};

/* Google Analytics e-Commerce Tracking */
/* https://developers.google.com/analytics/devguides/collection/analyticsjs/ecommerce */
UniversalAnalyticsClient.prototype.addTransaction = function (transactionId, affiliation, revenue, tax, shipping, currencyCode, success, error) {
  cordova.exec(success, error, 'UniversalAnalytics', 'addTransaction', [transactionId, affiliation, revenue, tax, shipping, currencyCode, this.trackerName]);
};

UniversalAnalyticsClient.prototype.addTransactionItem = function (transactionId, name, sku, category, price, quantity, currencyCode, success, error) {
  cordova.exec(success, error, 'UniversalAnalytics', 'addTransactionItem', [transactionId, name, sku, category, price, quantity, currencyCode, this.trackerName]);
};


/* Google Analytics Enhanced E-Commerce Tracking */
/* https://developers.google.com/analytics/devguides/collection/analyticsjs/enhanced-ecommerce */

UniversalAnalyticsClient.prototype.addProduct = function (
  productId, productName, category, brand, variant,
  position, currencyCode, screenName, productActionList,
  success, error) {


  console.log('AnalyticsService [UniversalAnalyticsClient] [addProduct]');

  cordova.exec(success, error, 'UniversalAnalytics', 'addProduct', [
    productId, productName, category, brand, variant, position,
    currencyCode, screenName, productActionList, this.trackerName
  ]);
};


/* automatic uncaught exception tracking */
UniversalAnalyticsClient.prototype.enableUncaughtExceptionReporting = function (enable, success, error) {
  cordova.exec(success, error, 'UniversalAnalytics', 'enableUncaughtExceptionReporting', [enable, this.trackerName]);
};

module.exports = UniversalAnalyticsClient;
