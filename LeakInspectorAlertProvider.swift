@objc class LeakInspectorAlertProvider: NSObject, LeakInspectorDelegate {

    private weak var alertView: UIAlertView?
    private weak var alertController: AnyObject?

    func didLeakReference(ref: AnyObject, name: String) {
        // dismiss any already visible alert
        if let alertController = self.alertController {
            alertController.dismissViewControllerAnimated(false, completion: nil)
        } else if let alertView = self.alertView {
            alertView.dismissWithClickedButtonIndex(0, animated: false)
        }

        let title = "Leak Inspector"
        let message = "Detected possible leak of \(name)"
        let ok = "OK"
        if #available(iOS 8.0, *) {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: ok, style: UIAlertActionStyle.Default, handler: nil))
            alertController.show()
            self.alertController = alertController
        } else {
            let alertView = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: ok)
            alertView.show()
            self.alertView = alertView
        }
    }

}

@available(iOS 8.0, *)
extension UIAlertController {

    func show() {
        present(animated: true, completion: nil)
    }

    func present(animated animated: Bool, completion: (() -> Void)?) {
        if let rootVC = UIApplication.sharedApplication().keyWindow?.rootViewController {
            presentFromController(rootVC, animated: animated, completion: completion)
        }
    }

    private func presentFromController(controller: UIViewController, animated: Bool, completion: (() -> Void)?) {
        if  let navVC = controller as? UINavigationController, let visibleVC = navVC.visibleViewController {
            presentFromController(visibleVC, animated: animated, completion: completion)
        } else if let tabVC = controller as? UITabBarController, let selectedVC = tabVC.selectedViewController {
            presentFromController(selectedVC, animated: animated, completion: completion)
        } else {
            controller.presentViewController(self, animated: animated, completion: completion)
        }
    }

}