package com.slalomdigital.applicationctrl;

import android.content.Context;
import android.content.SharedPreferences;

/**
 * Created with IntelliJ IDEA.
 * User: aaronc
 * Date: 8/12/13
 * Time: 3:44 PM
 * To change this template use File | Settings | File Templates.
 */
public class ApplicationCtrl {
    public static final String PREFERENCES = "opscheck_preferences";
    public static final String SHOULD_CONNECT = "should_connect";

    public static void check(CheckListener checkListener, boolean showPopup, Context context) {
        // Create the async task and check
        CheckTask checkTask = new CheckTask(checkListener, showPopup, context);
        checkTask.execute();
    }

    public static void check(Context context) {
        ApplicationCtrl.check(null, true, context);
    }

    public static boolean shouldConnect(Context context) {
        // check the preferences to see if connections should be allowed...
        SharedPreferences opsCheckPrefs = context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE);
        return opsCheckPrefs.getBoolean(SHOULD_CONNECT, true);
    }
}