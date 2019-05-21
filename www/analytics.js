
var UniversalAnalyticsClient = require('./analyticsClient');

var trackers = {};

function UniversalAnalyticsPlugin() {};

UniversalAnalyticsPlugin.prototype.getAll = function() {
  var keys = Object.keys(trackers);

  return keys.map(function (key) {
    return trackers[key];
  });
};

UniversalAnalyticsPlugin.prototype.getDefaultTracker = function () {
  return this.getByName('default');
};

UniversalAnalyticsPlugin.prototype.getByName = function (trackerName) {
  return trackers[trackerName];
};

UniversalAnalyticsPlugin.prototype.startTrackerWithId = function(id, dispatchPeriod, success, error, trackerName) {
  if (!trackerName) {
    trackerName = 'default';
  }

  var analyticsClient = new UniversalAnalyticsClient(trackerName);
  trackers[trackerName] = analyticsClient;

  if (typeof dispatchPeriod === 'undefined' || dispatchPeriod === null) {
    dispatchPeriod = 30;
  } else if (typeof dispatchPeriod === 'function' && typeof error === 'undefined') {
    // Called without dispatchPeriod but with a callback.
    // Looks like the original API was used so shift parameters over to remain compatible.
    error = success;
    success = dispatchPeriod;
    dispatchPeriod = 30;
  }
  cordova.exec(function () {
    success && success(analyticsClient);
  }, error, 'UniversalAnalytics', 'startTrackerWithId', [id, dispatchPeriod, trackerName]);

  return analyticsClient;
};

module.exports = new UniversalAnalyticsPlugin();
