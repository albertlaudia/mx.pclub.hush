import Flutter
import UIKit
import home_widget  // home_widget package

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Register background task for widget refresh.
    if #available(iOS 16.1, *) {
      BGTaskScheduler.shared.register(
        forTaskWithIdentifier: "app.lock.refresh",
        using: nil
      ) { task in
        self.handleAppRefresh(task: task as! BGAppRefreshTask)
      }
    }

    // Set the initial group for the home_widget package (must match Runner.entitlements).
    HomeWidgetPlugin.setAppGroupId("group.mx.pclub.lock")

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  @available(iOS 16.1, *)
  private func handleAppRefresh(task: BGAppRefreshTask) {
    scheduleAppRefresh()
    let queue = OperationQueue()
    queue.maxConcurrentOperationCount = 1
    let operation = BlockOperation {
      // The Dart side does the actual streak read/write via home_widget.
      // We just kick the widget timeline here.
      if #available(iOS 14.0, *) {
        WidgetCenter.shared.reloadAllTimelines()
      }
    }
    task.expirationHandler = {
      queue.cancelAllOperations()
    }
    operation.completionBlock = {
      task.setTaskCompleted(success: !operation.isCancelled)
    }
    queue.addOperation(operation)
  }

  @available(iOS 16.1, *)
  private func scheduleAppRefresh() {
    let request = BGAppRefreshTaskRequest(identifier: "app.lock.refresh")
    request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 60)
    do {
      try BGTaskScheduler.shared.submit(request)
    } catch {
      print("Could not schedule app refresh: \(error)")
    }
  }
}
