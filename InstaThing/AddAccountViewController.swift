//
//  AddAccountViewController.swift
//  InstaThing
//
//  Created by Ahmadreza on 3/13/22.
//

import UIKit
import RxSwift
import RxCocoa

class AddAccountViewController: UIViewController {
    
    var accounts = BehaviorRelay<[Account]>.init(value: [])
    var tableView = UITableView()
    var textField = UITextField()
    var bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupObservers()
    }
}

// MARK: - Setup Functions
extension AddAccountViewController {
    
    func setupView() {
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        setupTextField()
        setupTableView()
    }
    
    func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(closeAction), name: StrigKeys.block.getNotificationName(), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(closeAction), name: StrigKeys.challenge.getNotificationName(), object: nil)
    }
    
    func setupTextField() {
        textField = UITextField(frame: CGRect(origin: CGPoint(x: 10, y: 10), size: CGSize(width: view.bounds.width - 40, height: 40)))
        view.addSubview(textField)
        textField.placeholder = "Search here..."
        textField.rx.controlEvent([.editingChanged])
            .asObservable().throttle(.seconds(3), scheduler: MainScheduler.instance).subscribe({ [weak self] _ in
                guard let self = self else { return }
                if let text = self.textField.text, text.count > 2 {
                    self.searchAccounts(with: text)
                }
            }).disposed(by: bag)
    }
    
    func setupTableView() {
        let position = CGPoint(x: 10, y: textField.layer.position.y + textField.bounds.height / 2)
        let size = CGSize(width: textField.bounds.width, height: UIScreen.main.bounds.height - position.y)
        tableView = UITableView(frame: CGRect(origin: position, size: size))
        view.addSubview(tableView)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        accounts.bind(to: tableView.rx.items(cellIdentifier: "cell", cellType: UITableViewCell.self)) { (row, item, cell) in
            cell.textLabel?.text = item.user?.username ?? "?"
        }.disposed(by: bag)
        tableView.rx.modelSelected(Account.self).subscribe(onNext: { account in
            self.saveaccount(account)
        }).disposed(by: bag)
    }
    
    func setupNavigationBar() {
        let close = UIBarButtonItem(title: "close", style: .done, target: self, action: #selector(closeAction))
        navigationItem.rightBarButtonItem = close
    }
}

// MARK: - API Functions
extension AddAccountViewController {
    
    func searchAccounts(with text: String) {
        NetworkLayer.shared.searchusers(text: text).subscribe(onNext: { userData in
            self.accounts.accept(userData.users ?? [])
        }, onError: { error in
            print(error.localizedDescription)
        },
        onCompleted: {
            print("Completed event.")
        }).disposed(by: bag)
    }
}

// MARK: - Actions
extension AddAccountViewController {
    
    func saveaccount(_ account: Account) {
        guard let name = account.user?.username else { return }
        if UserDefaults.standard.data(forKey: name) != nil {
            print(name, "already exist!")
        } else {
            do {
                let endoder = JSONEncoder()
                let data = try endoder.encode(account)
                UserDefaults.standard.set(data, forKey: name)
                usernames.append(name)
            } catch {
                print("failed to encode account:", name)
            }
        }
    }
    
    @objc func closeAction() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
