//
//  LoginViewController.swift
//  InstaThing
//
//  Created by Ahmadreza on 3/13/22.
//

import UIKit
import WebKit
import RxCocoa

class LoginViewController: UIViewController {
    
    var webView = WKWebView()
    var rur = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
}

// MARK: - Setup Views
extension LoginViewController {
    
    func setupView() {
        
        setupWebView()
    }
    
    func setupWebView() {
        webView = WKWebView(frame: view.bounds)
        view.addSubview(webView)
        setUserAgent()
        webView.uiDelegate = self
        webView.navigationDelegate = self
        let url = URL(string: "https://www.instagram.com")!
        webView.load(URLRequest(url: url))
    }
    
    func setUserAgent() {
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.customUserAgent = userAgent
    }
}

// MARK: - Web View Functions
extension LoginViewController: WKNavigationDelegate, WKUIDelegate, WKHTTPCookieStoreObserver {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("finished loading: \(webView.url?.absoluteString ?? "")")
        if let cookies = HTTPCookieStorage.shared.cookies {
            var csrftoken = ""
            var ds_user_id = ""
            var sessionid = ""
            var shbid = ""
            var shbts = ""
            var ig_did = ""
            var mid = ""
            for cookie in cookies {
                print("cook: ")
                print(cookie)
                switch cookie.name {
                case "csrftoken": csrftoken = cookie.value
                case "ds_user_id": ds_user_id = cookie.value
                case "sessionid": sessionid = cookie.value
                case "shbid": shbid = cookie.value
                case "shbts": shbts = cookie.value
                case "ig_did": ig_did = cookie.value
                case "mid": mid = cookie.value
                default: break
                }
                HTTPCookieStorage.shared.setCookie(cookie)
            }
            let finalCookie = "csrftoken=\(csrftoken); ds_user_id=\(ds_user_id); rur=“\(rur)”; sessionid=\(sessionid); shbid=“\(shbid)”; shbts=“\(shbts)”; ig_did=\(ig_did); ig_nrcb=1; mid=\(mid)".replacingOccurrences(of: "“", with: "").replacingOccurrences(of: "”", with: "")
            print("finalCookie: \(finalCookie)")
            if rur != "" {
                cookie = finalCookie
                dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if let response = navigationResponse.response as? HTTPURLResponse, let allHttpHeaders = response.allHeaderFields as? [String: String], let responseUrl = response.url {
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: allHttpHeaders, for: responseUrl)
            for cookie in cookies {
                print("cook: ")
                print(cookie)
                switch cookie.name {
                case "rur": rur = cookie.value
                default: break
                }
                HTTPCookieStorage.shared.setCookie(cookie)
            }
        }
        decisionHandler(.allow)
    }
}
