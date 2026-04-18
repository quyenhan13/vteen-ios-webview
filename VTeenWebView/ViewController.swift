import UIKit
import WebKit

final class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {

    private var webView: WKWebView!
    private let urlString = "https://vteen.io.vn/"

    private let topBar = UIStackView()
    private let statusLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "VTeen Debug"

        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences.allowsContentJavaScript = true
        config.allowsInlineMediaPlayback = true
        config.websiteDataStore = .default()

        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.isOpaque = false
        webView.backgroundColor = .white
        webView.scrollView.backgroundColor = .white
        if #available(iOS 15.0, *) {
            webView.underPageBackgroundColor = .white
        }

        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.text = "App opened"
        statusLabel.textColor = .black
        statusLabel.font = .systemFont(ofSize: 14)
        statusLabel.numberOfLines = 0

        topBar.axis = .horizontal
        topBar.spacing = 8
        topBar.distribution = .fillEqually
        topBar.translatesAutoresizingMaskIntoConstraints = false

        let localBtn = makeButton("Test Local", action: #selector(loadLocalHTML))
        let siteBtn = makeButton("Open Site", action: #selector(loadSite))
        let clearBtn = makeButton("Clear Cache", action: #selector(clearCache))

        topBar.addArrangedSubview(localBtn)
        topBar.addArrangedSubview(siteBtn)
        topBar.addArrangedSubview(clearBtn)

        view.addSubview(topBar)
        view.addSubview(statusLabel)
        view.addSubview(webView)

        NSLayoutConstraint.activate([
            topBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            topBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            topBar.heightAnchor.constraint(equalToConstant: 44),

            statusLabel.topAnchor.constraint(equalTo: topBar.bottomAnchor, constant: 8),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),

            webView.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 8),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        loadLocalHTML()
    }

    private func makeButton(_ title: String, action: Selector) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(title, for: .normal)
        btn.backgroundColor = .systemBlue
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 10
        btn.addTarget(self, action: action, for: .touchUpInside)
        return btn
    }

    @objc private func loadLocalHTML() {
        statusLabel.text = "Loading local HTML..."
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <style>
            body { font-family: -apple-system; background: #ffffff; color: #111111; padding: 24px; }
            .box { background: #f3f4f6; padding: 20px; border-radius: 16px; }
            h1 { margin: 0 0 12px 0; color: #2563eb; }
          </style>
        </head>
        <body>
          <div class="box">
            <h1>WKWebView OK</h1>
            <p>Nếu bạn thấy màn này thì app và ViewController đang chạy đúng.</p>
            <p>Bấm <b>Open Site</b> để thử mở vteen.io.vn.</p>
          </div>
        </body>
        </html>
        """
        webView.loadHTMLString(html, baseURL: nil)
    }

    @objc private func loadSite() {
        guard let url = URL(string: urlString) else {
            statusLabel.text = "URL invalid"
            return
        }

        statusLabel.text = "Loading site: \(urlString)"
        let request = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalCacheData,
            timeoutInterval: 60
        )
        webView.load(request)
    }

    @objc private func clearCache() {
        let types = WKWebsiteDataStore.allWebsiteDataTypes()
        WKWebsiteDataStore.default().removeData(
            ofTypes: types,
            modifiedSince: Date(timeIntervalSince1970: 0)
        ) { [weak self] in
            self?.statusLabel.text = "Cache cleared"
        }
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        statusLabel.text = "didStartProvisionalNavigation"
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        statusLabel.text = "didCommit"
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        statusLabel.text = "didFinish: \(webView.url?.absoluteString ?? "no url")"
        title = webView.title ?? "Loaded"
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        statusLabel.text = "didFailProvisionalNavigation: \(error.localizedDescription)"
        showErrorPage("didFailProvisionalNavigation", error: error)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        statusLabel.text = "didFail: \(error.localizedDescription)"
        showErrorPage("didFail", error: error)
    }

    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        statusLabel.text = "WebContent process terminated"
        showSimpleHTML(title: "Process terminated", message: "WKWebView process bị terminate.")
    }

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

    private func showErrorPage(_ stage: String, error: Error) {
        let nsError = error as NSError
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <style>
            body { font-family: -apple-system; background: #fff; color: #111; padding: 24px; }
            .box { background: #fee2e2; border-radius: 16px; padding: 20px; }
            h2 { color: #b91c1c; margin-top: 0; }
            code { word-break: break-word; display: block; margin-top: 8px; }
          </style>
        </head>
        <body>
          <div class="box">
            <h2>\(stage)</h2>
            <p>\(nsError.localizedDescription)</p>
            <code>domain: \(nsError.domain)</code>
            <code>code: \(nsError.code)</code>
          </div>
        </body>
        </html>
        """
        webView.loadHTMLString(html, baseURL: nil)
    }

    private func showSimpleHTML(title: String, message: String) {
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <style>
            body { font-family: -apple-system; background: #fff; color: #111; padding: 24px; }
          </style>
        </head>
        <body>
          <h2>\(title)</h2>
          <p>\(message)</p>
        </body>
        </html>
        """
        webView.loadHTMLString(html, baseURL: nil)
    }
}
