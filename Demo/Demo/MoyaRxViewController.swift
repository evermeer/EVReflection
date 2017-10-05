import UIKit
import EVReflection
import RxSwift


class ViewController: BaseViewController {
    var disposeBag = DisposeBag()
    
    // MARK: - API Stuff
    
    override func downloadRepositories(_ username: String) {
        GitHubRxMoyaProvider.request(.userRepositories(username)) { (result) in
            switch result {
            case .success(let response):
                do {
                    self.repos = try response.RmapArray(to: Repository.self)
                    self.tableView.reloadData()
                } catch let error {
                    print("parse error = \(error)")
                    self.showError(error)
                }
            case .failure(let error):
                print("request error = \(error)")
                self.showError(error)
            }
        }
    }
    
    override func downloadZen() {
        GitHubRxMoyaProvider.request(.zen) { (result) in
            switch result {
            case .success(let response):
                do {
                    let message = try response.mapString()
                    let alertController = UIAlertController(title: "Zen", message: message, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                        alertController.dismiss(animated: true, completion: nil)
                    })
                    alertController.addAction(ok)
                    self.present(alertController, animated: true, completion: nil)
                } catch let error {
                    print("parse error = \(error)")
                    self.showError(error)
                }
            case .failure(let error):
                print("request error = \(error)")
                self.showError(error)
            }
        }
    }
    
    func showError(_ error: Error) {
        let alertController = UIAlertController(title: "GitHub Fetch", message: error.localizedDescription, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            alertController.dismiss(animated: true, completion: nil)
        })
        alertController.addAction(ok)
        self.present(alertController, animated: true, completion: nil)
    }
}

