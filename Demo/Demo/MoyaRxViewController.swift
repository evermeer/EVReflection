import UIKit
import EVReflection
import RxSwift


class ViewController: BaseViewController {
    var disposeBag = DisposeBag()
    
    // MARK: - API Stuff
    
    override func downloadRepositories(_ username: String) {
        GitHubRxMoyaProvider.request(.userRepositories(username))
            .map(toArray: Repository.self)
            .subscribe { event -> Void in
                switch event {
                case .next(let repos):
                    self.repos = repos
                    self.tableView.reloadData()
                case .error(let error):
                    print(error)
                    let alertController = UIAlertController(title: "GitHub Fetch", message: error.localizedDescription, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                        alertController.dismiss(animated: true, completion: nil)
                    })
                    alertController.addAction(ok)
                    self.present(alertController, animated: true, completion: nil)
                default:
                    break
                }
            }.addDisposableTo(disposeBag)
    }
    
    override func downloadZen() {
        GitHubRxMoyaProvider.request(.zen)
            .subscribe { event -> Void in
                switch event {
                case .next(let result):
                    let message = (try? result.mapString()) ?? "Couldn't access API"
                    let alertController = UIAlertController(title: "Zen", message: message, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                        alertController.dismiss(animated: true, completion: nil)
                    })
                    alertController.addAction(ok)
                    self.present(alertController, animated: true, completion: nil)
                case .error(let error):
                    print(error)
                    let alertController = UIAlertController(title: "GitHub Fetch", message: error.localizedDescription, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                        alertController.dismiss(animated: true, completion: nil)
                    })
                    alertController.addAction(ok)
                    self.present(alertController, animated: true, completion: nil)
                default:
                    break
                }
            }.addDisposableTo(disposeBag)
    }
}

