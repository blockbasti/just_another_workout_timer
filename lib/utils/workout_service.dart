import 'dart:async';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Callback function type for handling notification actions
typedef NotificationActionCallback = void Function(String action);

/// Manages background workout timer service and notifications
class WorkoutService {
  static const String _channelId = 'workout_timer_channel';
  static const String _channelName = 'Workout Timer';
  static const int _notificationId = 1;

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;
  static bool _isRunning = false;

  static NotificationActionCallback? _onNotificationAction;

  /// Initialize the workout service
  static Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize local notifications
    const androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.actionId != null && _onNotificationAction != null) {
          _onNotificationAction!(response.actionId!);
        }
      },
    );

    // Create notification channel
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Notifications for workout timer progress',
      importance: Importance.low,
      playSound: false,
      enableVibration: false,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    // Initialize foreground task
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: _channelId,
        channelName: _channelName,
        channelDescription: 'Workout timer running in background',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(1000), // 1 second
        autoRunOnBoot: false,
        autoRunOnMyPackageReplaced: false,
        allowWakeLock: true,
        allowWifiLock: false,
      ),
    );

    _isInitialized = true;
  }

  /// Set the callback for notification actions
  static void setNotificationActionCallback(
      NotificationActionCallback callback) {
    _onNotificationAction = callback;
  }

  /// Start the foreground service
  static Future<bool> startService() async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_isRunning) {
      return true;
    }

    await FlutterForegroundTask.startService(
      serviceId: 1,
      notificationTitle: 'Workout Timer',
      notificationText: 'Starting workout...',
      notificationIcon: null,
      notificationButtons: [
        const NotificationButton(id: 'pause', text: 'Pause'),
        const NotificationButton(id: 'stop', text: 'Stop'),
      ],
      callback: startWorkoutCallback,
    );

    // Assume service started successfully if no exception thrown
    _isRunning = true;
    return true;
  }

  /// Stop the foreground service
  static Future<bool> stopService() async {
    if (!_isRunning) {
      return true;
    }

    await FlutterForegroundTask.stopService();

    // Assume service stopped successfully if no exception thrown
    _isRunning = false;
    return true;
  }

  /// Update the notification with current workout state
  static Future<void> updateNotification({
    required String exerciseName,
    required int remainingSeconds,
    required int currentSet,
    required int totalSets,
    required int currentRep,
    required int totalReps,
    required bool isPaused,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    final timeStr = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    // Update the foreground task notification with current workout state
    await FlutterForegroundTask.updateService(
      notificationTitle: 'Workout Timer - $timeStr',
      notificationText: '$exerciseName\nSet $currentSet/$totalSets, Rep $currentRep/$totalReps',
      notificationButtons: [
        NotificationButton(
          id: isPaused ? 'play' : 'pause',
          text: isPaused ? 'Resume' : 'Pause',
        ),
        const NotificationButton(id: 'stop', text: 'Stop'),
      ],
    );
  }

  /// Check if service is currently running
  static bool get isRunning => _isRunning;
}

/// Foreground task callback (runs in isolate) - MUST be top-level function
@pragma('vm:entry-point')
void startWorkoutCallback() {
  FlutterForegroundTask.setTaskHandler(WorkoutTaskHandler());
}

/// Task handler that runs in the foreground service isolate
class WorkoutTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    // Service started
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // The actual timer logic stays in the main app (Timetable class)
    // This just keeps the service alive
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    await FlutterForegroundTask.clearAllData();
  }

  @override
  void onNotificationButtonPressed(String id) {
    // Send button press event to main app
    FlutterForegroundTask.sendDataToMain({'action': id});
    // Bring app to foreground
    FlutterForegroundTask.launchApp();
  }

  @override
  void onNotificationPressed() {
    // Bring app to foreground when notification is tapped
    FlutterForegroundTask.launchApp();
  }

  @override
  void onNotificationDismissed() {
    // Notification dismissed
  }
}
