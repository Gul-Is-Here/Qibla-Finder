package com.qibla_compass_offline.app

import android.os.Bundle
import android.widget.RelativeLayout
import com.ryanheise.audioservice.AudioServiceFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.MethodChannel
import com.inmobi.sdk.InMobiSdk
import com.inmobi.sdk.SdkInitializationListener
import com.inmobi.ads.InMobiInterstitial
import com.inmobi.ads.InMobiBanner
import com.inmobi.ads.listeners.InterstitialAdEventListener
import com.inmobi.ads.listeners.BannerAdEventListener
import com.inmobi.ads.AdMetaInfo
import com.inmobi.ads.InMobiAdRequestStatus
import org.json.JSONObject
import android.util.Log

class MainActivity : AudioServiceFragmentActivity() {
    private val CHANNEL = "com.qibla_compass_offline.app/inmobi"
    private val TAG = "InMobiAds"
    
    private var methodChannel: MethodChannel? = null
    private var interstitialAd: InMobiInterstitial? = null
    private var bannerAd: InMobiBanner? = null
    private var isInterstitialReady = false
    private var isBannerReady = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "initialize" -> {
                    val accountId = call.argument<String>("accountId")
                    if (accountId != null) {
                        initializeInMobi(accountId, result)
                    } else {
                        result.error("INVALID_ARGUMENT", "Account ID is required", null)
                    }
                }
                "loadInterstitial" -> {
                    val placementId = call.argument<String>("placementId")
                    if (placementId != null) {
                        loadInterstitial(placementId.toLong())
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGUMENT", "Placement ID is required", null)
                    }
                }
                "showInterstitial" -> {
                    if (isInterstitialReady && interstitialAd != null) {
                        interstitialAd?.show()
                        result.success(true)
                    } else {
                        result.success(false)
                    }
                }
                "isInterstitialReady" -> {
                    result.success(isInterstitialReady && interstitialAd?.isReady() == true)
                }
                "dispose" -> {
                    interstitialAd = null
                    isInterstitialReady = false
                    result.success(true)
                }
                "loadBanner" -> {
                    val placementId = call.argument<String>("placementId")
                    if (placementId != null) {
                        loadBanner(placementId.toLong())
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGUMENT", "Placement ID is required", null)
                    }
                }
                "isBannerReady" -> {
                    result.success(isBannerReady)
                }
                "destroyBanner" -> {
                    bannerAd?.destroy()
                    bannerAd = null
                    isBannerReady = false
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun initializeInMobi(accountId: String, result: MethodChannel.Result) {
        try {
            // Enable debug/log mode for development (disable in production)
            InMobiSdk.setLogLevel(InMobiSdk.LogLevel.DEBUG)
            
            // Consent object for GDPR compliance
            // TCF and GPP strings are auto-detected from SDK 10.7.5+
            val consentObject = JSONObject()
            
            // Initialize on UI thread as required by InMobi
            runOnUiThread {
                InMobiSdk.init(this, accountId, consentObject, object : SdkInitializationListener {
                    override fun onInitializationComplete(error: Error?) {
                        if (error == null) {
                            Log.d(TAG, "✅ InMobi SDK initialized successfully")
                            Log.d(TAG, "📌 InMobi SDK Version: ${InMobiSdk.getVersion()}")
                            
                            // Log device ID for test device registration
                            Log.d(TAG, "📱 Register this device ID in InMobi Dashboard for test ads:")
                            Log.d(TAG, "📱 Device ID: Use 'Publisher device Id' from logs above")
                            
                            result.success(true)
                        } else {
                            Log.e(TAG, "❌ InMobi SDK initialization failed: ${error.message}")
                            result.success(false)
                        }
                    }
                })
            }
        } catch (e: Exception) {
            Log.e(TAG, "❌ InMobi initialization error: ${e.message}")
            result.error("INIT_ERROR", e.message, null)
        }
    }

    private fun loadInterstitial(placementId: Long) {
        try {
            Log.d(TAG, "📥 Loading InMobi Interstitial with placement: $placementId")
            
            interstitialAd = InMobiInterstitial(this, placementId, object : InterstitialAdEventListener() {
                
                override fun onAdFetchSuccessful(ad: InMobiInterstitial, info: AdMetaInfo) {
                    Log.d(TAG, "📦 Interstitial ad fetched, preparing to load...")
                }
                
                override fun onAdLoadSucceeded(ad: InMobiInterstitial, info: AdMetaInfo) {
                    Log.d(TAG, "✅ Interstitial loaded successfully - Creative ID: ${info.creativeID}")
                    isInterstitialReady = true
                    runOnUiThread {
                        methodChannel?.invokeMethod("onInterstitialLoaded", null)
                    }
                }

                override fun onAdLoadFailed(ad: InMobiInterstitial, status: InMobiAdRequestStatus) {
                    Log.e(TAG, "❌ Interstitial load failed: ${status.statusCode} - ${status.message}")
                    isInterstitialReady = false
                    runOnUiThread {
                        methodChannel?.invokeMethod("onInterstitialLoadFailed", "${status.statusCode}: ${status.message}")
                    }
                }
                
                override fun onAdWillDisplay(ad: InMobiInterstitial) {
                    Log.d(TAG, "📺 Interstitial will display")
                }

                override fun onAdDisplayed(ad: InMobiInterstitial, info: AdMetaInfo) {
                    Log.d(TAG, "📺 Interstitial displayed")
                    runOnUiThread {
                        methodChannel?.invokeMethod("onInterstitialShown", null)
                    }
                }
                
                override fun onAdDisplayFailed(ad: InMobiInterstitial) {
                    Log.e(TAG, "❌ Interstitial display failed")
                    isInterstitialReady = false
                    runOnUiThread {
                        methodChannel?.invokeMethod("onInterstitialDisplayFailed", null)
                    }
                }

                override fun onAdClicked(ad: InMobiInterstitial, params: MutableMap<Any, Any>?) {
                    Log.d(TAG, "👆 Interstitial clicked")
                    runOnUiThread {
                        methodChannel?.invokeMethod("onInterstitialClicked", null)
                    }
                }

                override fun onAdDismissed(ad: InMobiInterstitial) {
                    Log.d(TAG, "✅ Interstitial dismissed")
                    isInterstitialReady = false
                    runOnUiThread {
                        methodChannel?.invokeMethod("onInterstitialDismissed", null)
                    }
                }
                
                override fun onUserLeftApplication(ad: InMobiInterstitial) {
                    Log.d(TAG, "👋 User left application from interstitial")
                }
                
                override fun onRewardsUnlocked(ad: InMobiInterstitial, rewards: MutableMap<Any, Any>?) {
                    Log.d(TAG, "🎁 Rewards unlocked: $rewards")
                    runOnUiThread {
                        methodChannel?.invokeMethod("onRewardsUnlocked", rewards?.toString())
                    }
                }
                
                override fun onAdImpression(ad: InMobiInterstitial) {
                    Log.d(TAG, "📊 Ad impression logged")
                }
            })
            
            interstitialAd?.load()
        } catch (e: Exception) {
            Log.e(TAG, "❌ Error loading interstitial: ${e.message}")
            e.printStackTrace()
        }
    }

    private fun loadBanner(placementId: Long) {
        try {
            Log.d(TAG, "📥 Loading InMobi Banner with placement: $placementId")
            
            runOnUiThread {
                // Destroy existing banner if any
                bannerAd?.destroy()
                
                bannerAd = InMobiBanner(this, placementId)
                
                // Set banner size (320x50 is standard mobile banner)
                val layoutParams = RelativeLayout.LayoutParams(
                    (320 * resources.displayMetrics.density).toInt(),
                    (50 * resources.displayMetrics.density).toInt()
                )
                bannerAd?.layoutParams = layoutParams
                
                // Set refresh interval (60 seconds)
                bannerAd?.setRefreshInterval(60)
                
                // Set animation type for refresh
                bannerAd?.setAnimationType(InMobiBanner.AnimationType.ROTATE_HORIZONTAL_AXIS)
                
                bannerAd?.setListener(object : BannerAdEventListener() {
                    
                    override fun onAdFetchSuccessful(ad: InMobiBanner, info: AdMetaInfo) {
                        Log.d(TAG, "📦 Banner ad fetched, preparing to load...")
                    }
                    
                    override fun onAdLoadSucceeded(ad: InMobiBanner, info: AdMetaInfo) {
                        Log.d(TAG, "✅ Banner loaded successfully - Creative ID: ${info.creativeID}")
                        isBannerReady = true
                        runOnUiThread {
                            methodChannel?.invokeMethod("onBannerLoaded", null)
                        }
                    }

                    override fun onAdLoadFailed(ad: InMobiBanner, status: InMobiAdRequestStatus) {
                        Log.e(TAG, "❌ Banner load failed: ${status.statusCode} - ${status.message}")
                        isBannerReady = false
                        runOnUiThread {
                            methodChannel?.invokeMethod("onBannerLoadFailed", "${status.statusCode}: ${status.message}")
                        }
                    }

                    override fun onAdDisplayed(ad: InMobiBanner) {
                        Log.d(TAG, "📺 Banner displayed")
                        runOnUiThread {
                            methodChannel?.invokeMethod("onBannerDisplayed", null)
                        }
                    }

                    override fun onAdDismissed(ad: InMobiBanner) {
                        Log.d(TAG, "✅ Banner dismissed")
                        runOnUiThread {
                            methodChannel?.invokeMethod("onBannerDismissed", null)
                        }
                    }

                    override fun onAdClicked(ad: InMobiBanner, params: MutableMap<Any, Any>?) {
                        Log.d(TAG, "👆 Banner clicked")
                        runOnUiThread {
                            methodChannel?.invokeMethod("onBannerClicked", null)
                        }
                    }

                    override fun onUserLeftApplication(ad: InMobiBanner) {
                        Log.d(TAG, "👋 User left application from banner")
                    }

                    override fun onRewardsUnlocked(ad: InMobiBanner, rewards: MutableMap<Any, Any>?) {
                        Log.d(TAG, "🎁 Banner rewards unlocked: $rewards")
                    }
                    
                    override fun onAdImpression(ad: InMobiBanner) {
                        Log.d(TAG, "📊 Banner impression logged")
                    }
                })
                
                // Load the banner ad
                bannerAd?.load()
            }
        } catch (e: Exception) {
            Log.e(TAG, "❌ Error loading banner: ${e.message}")
            e.printStackTrace()
        }
    }

    override fun onDestroy() {
        bannerAd?.destroy()
        bannerAd = null
        interstitialAd = null
        super.onDestroy()
    }
}
