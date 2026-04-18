import UIKit
import WebKit

final class ViewController: UIViewController {

    private let initialURL = URL(string: "https://vteen.io.vn/")!

    private var webView: WKWebView!
    private let progressView = UIProgressView(progressViewStyle: .default)

    private let fallbackView = UIView()
    private let messageLabel = UILabel()
    private let retryButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "VTeen"
        view.backgroundColor = .white

        setupWebView()
        setupUI()
        loadInitialPage()
    }

    deinit {
        webView?.removeObserver(
            self,
            forKeyPath: #keyPath(WKWebView.estimatedProgress)
        )
    }

    private func setupWebView() {
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences.allowsContentJavaScript = true
        config.allowsInlineMediaPlayback = true
        config.websiteDataStore = .default()

        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true

        // KHÔNG ép customUserAgent ở đây.
        // Để WebView dùng UA mặc định của iOS trước, tránh server phản ứng lạ.

        webView.isOpaque = false
        webView.backgroundColor = .white
        webView.scrollView.backgroundColor = .white
        webView.translatesAutoresizingMaskIntoConstraints = false

        webView.addObserver(
            self,
            forKeyPath: #keyPath(WKWebView.estimatedProgress),
            options: .new,
            context: nil
        )
    }

    private func setupUI() {
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progress = 0
        progressView.isHidden = true

        fallbackView.translatesAutoresizingMaskIntoConstraints = false
        fallbackView.backgroundColor = .white
        fallbackView.isHidden = true

        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.textColor = .black
        messageLabel.font = .systemFont(ofSize: 16)

        retryButton.translatesAutoresizingMaskIntoConstraints = false
        retryButton.setTitle("Tải lại", for: .normal)
        retryButton.addTarget(self, action: #selector(retryLoad), for: .touchUpInside)

        view.addSubview(progressView)
        view.addSubview(webView)
        view.addSubview(fallbackView)

        fallbackView.addSubview(messageLabel)
        fallbackView.addSubview(retryButton)

        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            webView.topAnchor.constraint(equalTo: progressView.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            fallbackView.topAnchor.constraint(equalTo: progressView.bottomAnchor),
            fallbackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            fallbackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            fallbackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            messageLabel.centerXAnchor.constraint(equalTo: fallbackView.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: fallbackView.centerYAnchor, constant: -20),
            messageLabel.leadingAnchor.constraint(equalTo: fallbackView.leadingAnchor, constant: 24),
            messageLabel.trailingAnchor.constraint(equalTo: fallbackView.trailingAnchor, constant: -24),

            retryButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 16),
            retryButton.centerXAnchor.constraint(equalTo: fallbackView.centerXAnchor)
        ])

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Back",
            style: .plain,
            target: self,
            action: #selector(goBack)
        )

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .refresh,
            target: self,
            action: #selector(refreshPage)
        )

        navigationItem.leftBarButtonItem?.isEnabled = false
    }

    private func loadInitialPage() {
        hideFallback()

        let request = URLRequest(
            url: initialURL,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 60
        )

        webView.load(request)
    }

    @objc private func goBack() {
        if webView.canGoBack {
            webView.goBack()
        }
        navigationItem.leftBarButtonItem?.isEnabled = webView.canGoBack
    }

    @objc private func refreshPage() {
        hideFallback()
        webView.reload()
    }

    @objc private func retryLoad() {
        loadInitialPage()
    }

    private func showFallback(message: String) {
        messageLabel.text = message
        fallbackView.isHidden = false
        progressView.isHidden = true
    }

    private func hideFallback() {
        fallbackView.isHidden = true
    }

    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        guard keyPath == #keyPath(WKWebView.estimatedProgress) else { return }

        let progress = Float(webView.estimatedProgress)
        progressView.setProgress(progress, animated: true)
        progressView.isHidden = progress >= 1.0
    }
}

extension ViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        hideFallback()
        progressView.isHidden = false
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title ?? "VTeen"
        navigationItem.leftBarButtonItem?.isEnabled = webView.canGoBack
        progressView.isHidden = true
    }

    func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        showFallback(message: "Không tải được trang.\n\(error.localizedDescription)")
    }

    func webView(
        _ webView: WKWebView,
        didFail navigation: WKNavigation!,
        withError error: Error
    ) {
        showFallback(message: "Trang tải thất bại.\n\(error.localizedDescription)")
    }

    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        webView.reload()
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }

        if let scheme = url.scheme?.lowercased(),
           ["tel", "mailto", "sms"].contains(scheme) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            decisionHandler(.cancel)
            return
        }

        decisionHandler(.allow)
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationResponse: WKNavigationResponse,
        decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void
    ) {
        if let httpResponse = navigationResponse.response as? HTTPURLResponse,
           httpResponse.statusCode >= 400 {
            showFallback(message: "Máy chủ trả về lỗi \(httpResponse.statusCode).")
            decisionHandler(.cancel)
            return
        }

        decisionHandler(.allow)
    }
}

extension ViewController: WKUIDelegate {

    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
}
