//
//  ViewController.swift
//  InstaThing
//
//  Created by Ahmadreza on 3/13/22.
//

import UIKit
import RxSwift
import RxRelay
import WebKit

class ViewController: UIViewController {

    var bag = DisposeBag()
    var tableView = UITableView()
    var accounts = BehaviorRelay<[Account]>.init(value: [])

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        accounts.accept(localAccounts)
    }
}

// MARK: - Setup Views
extension ViewController {
    
    func setupViews() {
        setupNavigationBar()
        setupTableView()
    }
    
    func setupNavigationBar() {
        let login = UIBarButtonItem(title: "login", style: .done, target: self, action: #selector(openLoginConctroller))
        navigationItem.rightBarButtonItem = login

        let add = UIBarButtonItem(title: "add account", style: .done, target: self, action: #selector(openAddaccountConctroller))
        navigationItem.leftBarButtonItem = add

        let out = UIBarButtonItem(title: "logout", style: .done, target: self, action: #selector(logout))
        navigationItem.rightBarButtonItems?.append(out)
    }
    
    func setupTableView() {
        tableView = UITableView(frame: view.bounds)
        view.addSubview(tableView)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        accounts.bind(to: tableView.rx.items(cellIdentifier: "cell", cellType: UITableViewCell.self)) { (row, item, cell) in
            cell.textLabel?.text = item.user?.username ?? "?"
        }.disposed(by: bag)
        tableView.rx.modelSelected(Account.self).subscribe(onNext: { account in
            print(account.user?.full_name ?? account.user?.username ?? "?")
        }).disposed(by: bag)
    }
    
    func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(openLoginConctroller), name: StrigKeys.challenge.getNotificationName(), object: nil)
    }
}

// MARK: - Actions
extension ViewController {
    
    @objc func openLoginConctroller() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            let vc = LoginViewController()
            present(vc, animated: true)
        }
    }
    
    @objc func openAddaccountConctroller() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            let vc = AddAccountViewController()
            present(vc, animated: true)
        }
    }
    
    @objc func logout() {
        cookie = ""
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                print("[WebCacheCleaner] Record \(record) deleted")
            }
        }
    }
}

// MARK: -
extension ViewController {
    
}
