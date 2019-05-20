package com.danielcwilson.plugins.analytics;

import com.google.android.gms.analytics.GoogleAnalytics;
import com.google.android.gms.analytics.Logger.LogLevel;
import com.google.android.gms.analytics.HitBuilders;
import com.google.android.gms.analytics.HitBuilders.HitBuilder;
import com.google.android.gms.analytics.Tracker;
import com.google.android.gms.analytics.ecommerce.Product;
import com.google.android.gms.analytics.ecommerce.ProductAction;


import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.Map.Entry;
import android.util.Log;

public class UniversalAnalyticsPlugin extends CordovaPlugin {
    public static final String DEFAUlT_TRACKER_NAME = "default";
    public static final String START_TRACKER = "startTrackerWithId";
    public static final String TRACK_VIEW = "trackView";
    public static final String TRACK_EVENT = "trackEvent";
    public static final String TRACK_EXCEPTION = "trackException";
    public static final String TRACK_TIMING = "trackTiming";
    public static final String TRACK_METRIC = "trackMetric";
    public static final String TRACK_START_CHECKOUT = "trackStartCheckout";
    public static final String ADD_DIMENSION = "addCustomDimension";
    public static final String ADD_TRANSACTION = "addTransaction";

    // Enhanced Ecommerce
    public static final String SEND_PRODUCT_EVENT = "sendProductEvent";

    public static final String SET_ALLOW_IDFA_COLLECTION = "setAllowIDFACollection";
    public static final String SET_USER_ID = "setUserId";
    public static final String SET_ANONYMIZE_IP = "setAnonymizeIp";
    public static final String SET_OPT_OUT = "setOptOut";
    public static final String SET_APP_VERSION = "setAppVersion";
    public static final String GET_VAR = "getVar";
    public static final String SET_VAR = "setVar";
    public static final String DISPATCH = "dispatch";
    public static final String DEBUG_MODE = "debugMode";
    public static final String ENABLE_UNCAUGHT_EXCEPTION_REPORTING = "enableUncaughtExceptionReporting";
    public static final String TAG = "AnalyticsService";

    public Boolean debugModeEnabled = false;
    public HashMap<Integer, String> customDimensions = new HashMap<Integer, String>();
    public HashMap<Integer, Float> customMetrics = new HashMap<Integer, Float>();

    public HashMap<String, Tracker> trackers = new HashMap<String, Tracker>();

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (START_TRACKER.equals(action)) {
            String id = args.getString(0);
            int dispatchPeriod = args.length() > 1 ? args.getInt(1) : 30;
            String trackerName = this.getTrackerNameFromArgs(args, 2);
            this.startTracker(trackerName, id, dispatchPeriod, callbackContext);
            return true;
        } else if (TRACK_VIEW.equals(action)) {
            int length = args.length();
            String screen = args.getString(0);
            Tracker tracker = this.getTrackerFromArgs(args, 3);
            this.trackView(tracker, screen, length > 1 && !args.isNull(1) ? args.getString(1) : "",
                    length > 2 && !args.isNull(2) ? args.getBoolean(2) : false, callbackContext);
            return true;
        } else if (TRACK_EVENT.equals(action)) {
            int length = args.length();
            if (length > 0) {
              Tracker tracker = this.getTrackerFromArgs(args, 5);
              this.trackEvent(tracker, args.getString(0), length > 1 ? args.getString(1) : "",
                      length > 2 ? args.getString(2) : "", length > 3 ? args.getLong(3) : 0,
                      length > 4 ? args.getBoolean(4) : false, callbackContext);
            }
            return true;
        } else if (TRACK_EXCEPTION.equals(action)) {
            String description = args.getString(0);
            Boolean fatal = args.getBoolean(1);
            Tracker tracker = this.getTrackerFromArgs(args, 2);
            this.trackException(tracker, description, fatal, callbackContext);
            return true;
        } else if (TRACK_TIMING.equals(action)) {
            int length = args.length();
            if (length > 0) {
              Tracker tracker = this.getTrackerFromArgs(args, 4);
              this.trackTiming(tracker, args.getString(0), length > 1 ? args.getLong(1) : 0,
                        length > 2 ? args.getString(2) : "", length > 3 ? args.getString(3) : "", callbackContext);
            }
            return true;
        } else if (TRACK_METRIC.equals(action)) {
            int length = args.length();
            if (length > 0) {
              this.trackMetric(args.getInt(0), length > 1 ? args.getString(1) : "", callbackContext);
            }
            return true;
        } else if (TRACK_START_CHECKOUT.equals(action)) {
          int length = args.length();
          if (length > 0) {
            Tracker tracker = this.getTrackerFromArgs(args, 2);
            this.trackStartCheckout(
              tracker,
              args.getJSONObject(0),
              args.getString(1), // screen name
              callbackContext);
          }
          return true;
        } else if (ADD_DIMENSION.equals(action)) {
            Integer key = args.getInt(0);
            String value = args.getString(1);
            this.addCustomDimension(key, value, callbackContext);
            return true;
        } else if (ADD_TRANSACTION.equals(action)) {
            int length = args.length();
            if (length > 0) {
              Tracker tracker = this.getTrackerFromArgs(args, 2);
              this.addTransaction(
                tracker,
                args.getJSONObject(0),
                args.getString(1), // screen name
                callbackContext);
            }
            return true;
        }
        else if (SEND_PRODUCT_EVENT.equals(action)) {
            int length = args.length();

            if (length > 0) {
              Tracker tracker = this.getTrackerFromArgs(args, 9);
              this.sendProductEvent(
                tracker,
                args.getString(0),
                length > 1 ? args.getString(1) : "",
                length > 2 ? args.getString(2) : "",
                length > 3 ? args.getString(3) : "",
                length > 4 ? args.getString(4) : "",
                length > 5 && !args.isNull(5) ? args.getInt(5) : 1,
                length > 6 ? args.getString(6) : "",
                length > 7 ? args.getString(7) : "",
                length > 8 ? args.getString(8) : "",
                callbackContext
              );
            }
            return true;
        } else if (SET_ALLOW_IDFA_COLLECTION.equals(action)) {
          Tracker tracker = this.getTrackerFromArgs(args, 1);
          this.setAllowIDFACollection(tracker, args.getBoolean(0), callbackContext);
        } else if (SET_USER_ID.equals(action)) {
          String userId = args.getString(0);
          Tracker tracker = this.getTrackerFromArgs(args, 1);
          this.setUserId(tracker, userId, callbackContext);
        } else if (SET_ANONYMIZE_IP.equals(action)) {
          boolean anonymize = args.getBoolean(0);
          Tracker tracker = this.getTrackerFromArgs(args, 1);
          this.setAnonymizeIp(tracker, anonymize, callbackContext);
        } else if (SET_OPT_OUT.equals(action)) {
          boolean optout = args.getBoolean(0);
          Tracker tracker = this.getTrackerFromArgs(args, 1);
          this.setOptOut(tracker, optout, callbackContext);
        } else if (SET_APP_VERSION.equals(action)) {
          String version = args.getString(0);
          Tracker tracker = this.getTrackerFromArgs(args, 1);
          this.setAppVersion(tracker, version, callbackContext);
        } else if (GET_VAR.equals(action)) {
          String variable = args.getString(0);
          Tracker tracker = this.getTrackerFromArgs(args, 1);
          this.getVar(tracker, variable, callbackContext);
        } else if (SET_VAR.equals(action)) {
          String variable = args.getString(0);
          String value = args.getString(1);
          Tracker tracker = this.getTrackerFromArgs(args, 2);
          this.setVar(tracker, variable, value, callbackContext);
          return true;
        } else if (DISPATCH.equals(action)) {
          Tracker tracker = this.getTrackerFromArgs(args, 0);
          this.dispatch(tracker, callbackContext);
          return true;
        } else if (DEBUG_MODE.equals(action)) {
          this.debugMode(callbackContext);
        } else if (ENABLE_UNCAUGHT_EXCEPTION_REPORTING.equals(action)) {
          Boolean enable = args.getBoolean(0);
          Tracker tracker = this.getTrackerFromArgs(args, 1);
          this.enableUncaughtExceptionReporting(tracker, enable, callbackContext);
        }
        return false;
    }

    private String getTrackerNameFromArgs(JSONArray args, Integer index) throws JSONException {
      int length = args.length();
      String trackerName = length > index && !args.isNull(index) ? args.getString(index) : DEFAUlT_TRACKER_NAME;

      return trackerName;
    }

    private Tracker getTrackerFromArgs(JSONArray args, Integer index) throws JSONException {
      return trackers.get(this.getTrackerNameFromArgs(args, index));
    }

    private void startTracker(String trackerName, String id, int dispatchPeriod, CallbackContext callbackContext) {
        if (null != id && id.length() > 0) {
            Tracker tracker = GoogleAnalytics.getInstance(this.cordova.getActivity()).newTracker(id);
            trackers.put(trackerName, tracker);
            callbackContext.success("tracker started");
            GoogleAnalytics.getInstance(this.cordova.getActivity()).setLocalDispatchPeriod(dispatchPeriod);
        } else {
            callbackContext.error("tracker id is not valid");
        }
    }

    private void addCustomDimension(Integer key, String value, CallbackContext callbackContext) {
        if (key <= 0) {
            callbackContext.error("Expected positive integer argument for key.");
            return;
        }

        if (null == value || value.length() == 0) {
            // unset dimension
            customDimensions.remove(key);
            callbackContext.success("custom dimension stopped");
        } else {
            customDimensions.put(key, value);
            callbackContext.success("custom dimension started");
        }
    }

    private <T> void addCustomDimensionsAndMetricsToHitBuilder(T builder) {
        //unfortunately the base HitBuilders.HitBuilder class is not public, therefore have to use reflection to use
        //the common setCustomDimension (int index, String dimension) and setCustomMetrics (int index, Float metric) methods
        try {
            Method builderMethod = builder.getClass().getMethod("setCustomDimension", Integer.TYPE, String.class);

            for (Entry<Integer, String> entry : customDimensions.entrySet()) {
                Integer key = entry.getKey();
                String value = entry.getValue();
                try {
                    builderMethod.invoke(builder, (key), value);
                } catch (IllegalArgumentException e) {
                } catch (IllegalAccessException e) {
                } catch (InvocationTargetException e) {
                }
            }
        } catch (SecurityException e) {
        } catch (NoSuchMethodException e) {
        }

        try {
            Method builderMethod = builder.getClass().getMethod("setCustomMetric", Integer.TYPE, Float.TYPE);

            for (Entry<Integer, Float> entry : customMetrics.entrySet()) {
                Integer key = entry.getKey();
                Float value = entry.getValue();
                try {
                    builderMethod.invoke(builder, (key), value);
                } catch (IllegalArgumentException e) {
                } catch (IllegalAccessException e) {
                } catch (InvocationTargetException e) {
                }
            }
        } catch (SecurityException e) {
        } catch (NoSuchMethodException e) {
        }
    }

    private void addProductsToHitBuilder(HitBuilder builder, JSONArray products) throws JSONException {
        for (int i = 0; i < products.length(); i++) {
          JSONObject productData = products.getJSONObject(i);

          Product product =  new Product()
              .setId(productData.getString("id"))
              .setName(productData.getString("name"))
              .setPrice(productData.getDouble("price"));

          if (productData.has("category")) {
            product.setCategory(productData.getString("category"));
          }

          if (productData.has("brand")) {
            product.setBrand(productData.getString("brand"));
          }

          if (productData.has("variant")) {
            product.setVariant(productData.getString("variant"));
          }

          if (productData.has("couponCode")) {
            product.setCouponCode(productData.getString("couponCode"));
          }

          if (productData.has("quantity")) {
            product.setQuantity(productData.getInt("quantity"));
          } else {
            product.setQuantity(1);
          }

          builder.addProduct(product);
        }
    }

    private void trackView(Tracker tracker, String screenname, String campaignUrl, boolean newSession, CallbackContext callbackContext) {
        if (tracker == null) {
            callbackContext.error("Tracker not started");
            return;
        }

        if (null != screenname && screenname.length() > 0) {
            tracker.setScreenName(screenname);

            HitBuilders.ScreenViewBuilder hitBuilder = new HitBuilders.ScreenViewBuilder();
            addCustomDimensionsAndMetricsToHitBuilder(hitBuilder);

            if (!campaignUrl.equals("")) {
                hitBuilder.setCampaignParamsFromUrl(campaignUrl);
            }

            if (!newSession) {
                tracker.send(hitBuilder.build());
            } else {
                tracker.send(hitBuilder.setNewSession().build());
            }

            callbackContext.success("Track Screen: " + screenname);
        } else {
            callbackContext.error("Expected one non-empty string argument.");
        }
    }

    private void trackEvent(Tracker tracker, String category, String action, String label, long value, boolean newSession,
            CallbackContext callbackContext) {

        if (tracker == null) {
            callbackContext.error("Tracker not started");
            return;
        }

        if (null != category && category.length() > 0) {
            HitBuilders.EventBuilder hitBuilder = new HitBuilders.EventBuilder();
            addCustomDimensionsAndMetricsToHitBuilder(hitBuilder);

            if (!newSession) {
                tracker.send(
                        hitBuilder.setCategory(category).setAction(action).setLabel(label).setValue(value).build());
            } else {
                tracker.send(hitBuilder.setCategory(category).setAction(action).setLabel(label).setValue(value)
                        .setNewSession().build());
            }

            callbackContext.success("Track Event: " + category);
        } else {
            callbackContext.error("Expected non-empty string arguments.");
        }
    }

    private void trackMetric(Integer key, String value, CallbackContext callbackContext) {
        if (key <= 0) {
            callbackContext.error("Expected positive integer argument for key.");
            return;
        }

        if (null == value || value.length() == 0) {
            // unset metric
            customMetrics.remove(key);
            callbackContext.success("custom metric stopped");
        } else {
            Float floatValue;
            try {
                floatValue = Float.parseFloat(value);
            } catch (NumberFormatException e) {
                callbackContext.error("Expected string formatted number for value.");
                return;
            }

            customMetrics.put(key, floatValue);
            callbackContext.success("custom metric started");
        }
    }

    private void trackException(Tracker tracker, String description, Boolean fatal, CallbackContext callbackContext) {
        if (tracker == null) {
            callbackContext.error("Tracker not started");
            return;
        }

        if (null != description && description.length() > 0) {
            HitBuilders.ExceptionBuilder hitBuilder = new HitBuilders.ExceptionBuilder();
            addCustomDimensionsAndMetricsToHitBuilder(hitBuilder);

            tracker.send(hitBuilder.setDescription(description).setFatal(fatal).build());
            callbackContext.success("Track Exception: " + description);
        } else {
            callbackContext.error("Expected non-empty string arguments.");
        }
    }

    private void trackTiming(Tracker tracker, String category, long intervalInMilliseconds, String name, String label,
            CallbackContext callbackContext) {
        if (tracker == null) {
            callbackContext.error("Tracker not started");
            return;
        }

        if (null != category && category.length() > 0) {
            HitBuilders.TimingBuilder hitBuilder = new HitBuilders.TimingBuilder();
            addCustomDimensionsAndMetricsToHitBuilder(hitBuilder);

            tracker.send(hitBuilder.setCategory(category).setValue(intervalInMilliseconds).setVariable(name)
                    .setLabel(label).build());
            callbackContext.success("Track Timing: " + category);
        } else {
            callbackContext.error("Expected non-empty string arguments.");
        }
    }

    private void trackStartCheckout(Tracker tracker, JSONObject checkoutModel, String screenName, CallbackContext callbackContext) throws JSONException {
      if (tracker == null) {
          callbackContext.error("Tracker not started");
          return;
      }

      HitBuilders.ScreenViewBuilder hitBuilder = new HitBuilders.ScreenViewBuilder();
      addCustomDimensionsAndMetricsToHitBuilder(hitBuilder);

      JSONArray products = checkoutModel.getJSONArray("products");
      addProductsToHitBuilder(hitBuilder, products);

      ProductAction productAction = new ProductAction(ProductAction.ACTION_CHECKOUT);

      if (checkoutModel.has("actionField")) {
        JSONObject actionFieldModel = checkoutModel.getJSONObject("actionField");

        if (actionFieldModel.has("step")) {
          productAction.setCheckoutStep(actionFieldModel.getInt("step"));
        }

        if (actionFieldModel.has("option")) {
          productAction.setCheckoutOptions(actionFieldModel.getString("option"));
        }
      }

      hitBuilder.setProductAction(productAction);
      tracker.setScreenName(screenName);

      if (checkoutModel.has("currencyCode")) {
        tracker.set("&cu", checkoutModel.getString("currencyCode"));
      }

      tracker.send(hitBuilder.build());

      callbackContext.success("Start checkout success");
    }

    private void addTransaction(Tracker tracker, JSONObject transaction, String screenName, CallbackContext callbackContext) throws JSONException {
        Log.v(TAG, " addTransaction " + tracker);

        if (tracker == null) {
            callbackContext.error("Tracker not started");
            return;
        }

        String transactionId = transaction.getString("id");

        if (null == transactionId || transactionId.length() == 0) {
          callbackContext.error("Expected non-empty ID.");
          return;
        }

        HitBuilders.ScreenViewBuilder hitBuilder = new HitBuilders.ScreenViewBuilder();
        addCustomDimensionsAndMetricsToHitBuilder(hitBuilder);

        JSONArray products = transaction.getJSONArray("products");
        addProductsToHitBuilder(hitBuilder, products);

        ProductAction productAction = new ProductAction(ProductAction.ACTION_PURCHASE)
            .setTransactionId(transactionId);

        if (transaction.has("affiliation")) {
          productAction.setTransactionAffiliation(transaction.getString("affiliation"));
        }

        if (transaction.has("revenue")) {
          productAction.setTransactionRevenue(transaction.getDouble("revenue"));
        }

        if (transaction.has("tax")) {
          productAction.setTransactionTax(transaction.getDouble("tax"));
        }

        if (transaction.has("shipping")) {
          productAction.setTransactionShipping(transaction.getDouble("shipping"));
        }

        if (transaction.has("couponCode")) {
          productAction.setTransactionCouponCode(transaction.getString("couponCode"));
        }

        hitBuilder.setProductAction(productAction);
        tracker.setScreenName(screenName);

        if (transaction.has("currencyCode")) {
          tracker.set("&cu", transaction.getString("currencyCode"));
        }

        tracker.send(hitBuilder.build());

        callbackContext.success("Add Transaction: " + transactionId);
    }

    private void sendProductEvent(Tracker tracker, String productId, String productName,
      String category, String brand, String variant, Integer position,
      String currencyCode, String screenName, String productActionType,
      CallbackContext callbackContext) {

        Log.v(TAG, " sendProductEvent for action - " + productActionType);

        if (tracker == null) {
            callbackContext.error("Tracker not started");
            return;
        }

        if (null != productId && productId.length() > 0) {
          Product product =  new Product()
              .setId(productId)
              .setName(productName)
              .setCategory(category)
              .setBrand(brand)
              .setVariant(variant)
              .setPosition(position);

          addCustomDimensionsAndMetricsToHitBuilder(product);

          ProductAction productAction = new ProductAction(productActionType);

          HitBuilders.ScreenViewBuilder builder = new HitBuilders.ScreenViewBuilder()
              .addProduct(product)
              .setProductAction(productAction);

          tracker.setScreenName(screenName);
          tracker.set("&cu", currencyCode);
          tracker.send(builder.build());

          callbackContext.success("Add Product: " + productId);
        } else {
          callbackContext.error("Expected non-empty ID.");
        }
    }

    private void setAllowIDFACollection(Tracker tracker, Boolean enable, CallbackContext callbackContext) {
        if (tracker == null) {
            callbackContext.error("Tracker not started");
            return;
        }

        tracker.enableAdvertisingIdCollection(enable);
        callbackContext.success("Enable Advertising Id Collection: " + enable);
    }

    private void setVar(Tracker tracker, String variable, String value, CallbackContext callbackContext) {
        if (tracker == null) {
            callbackContext.error("Tracker not started");
            return;
        }

        tracker.set(variable, value);
        callbackContext.success("Set variable " + variable + "to " + value);
    }

    private void dispatch(Tracker tracker, CallbackContext callbackContext) {
        if (tracker == null) {
            callbackContext.error("Tracker not started");
            return;
        }

        GoogleAnalytics.getInstance(this.cordova.getActivity()).dispatchLocalHits();
        callbackContext.success("dispatch sent");
    }

    private void getVar(Tracker tracker, String variable, CallbackContext callbackContext) {
        if (tracker == null) {
            callbackContext.error("Tracker not started");
            return;
        }

        String result = tracker.get(variable);
        callbackContext.success(result);
    }

    private void debugMode(CallbackContext callbackContext) {
        // GAv4 Logger is deprecated!
        // GoogleAnalytics.getInstance(this.cordova.getActivity()).getLogger().setLogLevel(LogLevel.VERBOSE);

        // To enable verbose logging execute "adb shell setprop log.tag.GAv4 DEBUG"
        // and then "adb logcat -v time -s GAv4" to inspect log entries.
        GoogleAnalytics.getInstance(this.cordova.getActivity()).setDryRun(true);

        this.debugModeEnabled = true;
        callbackContext.success("debugMode enabled");
    }

    private void setAnonymizeIp(Tracker tracker, boolean anonymize, CallbackContext callbackContext) {
        if (tracker == null) {
            callbackContext.error("Tracker not started");
            return;
        }

        tracker.setAnonymizeIp(anonymize);
        callbackContext.success("Set AnonymizeIp " + anonymize);
    }

    private void setOptOut(Tracker tracker, boolean optout, CallbackContext callbackContext) {
        if (tracker == null) {
            callbackContext.error("Tracker not started");
            return;
        }

        GoogleAnalytics.getInstance(this.cordova.getActivity()).setAppOptOut(optout);
        callbackContext.success("Set Opt-Out " + optout);
    }

    private void setUserId(Tracker tracker, String userId, CallbackContext callbackContext) {
        if (tracker == null) {
            callbackContext.error("Tracker not started");
            return;
        }

        tracker.set("&uid", userId);
        callbackContext.success("Set user id" + userId);
    }

    private void setAppVersion(Tracker tracker, String version, CallbackContext callbackContext) {
        if (tracker == null) {
          callbackContext.error("Tracker not started");
          return;
        }

        tracker.set("&av", version);
        callbackContext.success("Set app version: " + version);
    }

    private void enableUncaughtExceptionReporting(Tracker tracker, Boolean enable, CallbackContext callbackContext) {
        if (tracker == null) {
          callbackContext.error("Tracker not started");
          return;
        }

        tracker.enableExceptionReporting(enable);
        callbackContext.success((enable ? "Enabled" : "Disabled") + " uncaught exception reporting");
    }
}
