import UIKit
import RxSwift
import EVReflection

class MoyaViewController: BaseViewController {
    
    // MARK: - API Stuff
    
    override func downloadRepositories(_ username: String) {
        GitHubMoyaProvider.request(.userRepositories(username), completion: { result in
            var success = true
            var message = "Unable to fetch from GitHub"
            
            switch result {
            case let .success(response):
                do {
                    let repos: [Repository]? = try response.map(toArray: Repository.self)
                    if let repos = repos {
                        // Presumably, you'd parse the JSON into a model object. This is just a demo, so we'll keep it as-is.
                        self.repos = repos
                    } else {
                        success = false
                    }
                } catch {
                    success = false
                }
                self.tableView.reloadData()
            case let .failure(error):
                guard let error = error as? CustomStringConvertible else {
                    break
                }
                message = error.description
                success = false
            }
            
            if !success {
                let alertController = UIAlertController(title: "GitHub Fetch", message: message, preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                  alertController.dismiss(animated: true, completion: nil)
                })
                alertController.addAction(ok)
                self.present(alertController, animated: true, completion: nil)
            }
        })
    }

    override func downloadZen() {
        GitHubMoyaProvider.request(.zen, completion: { result in
            var message = "Couldn't access API"
            if case let .success(response) = result {
                message = (try? response.mapString()) ?? message
            }

            let alertController = UIAlertController(title: "Zen", message: message, preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
              alertController.dismiss(animated: true, completion: nil)
            })
            alertController.addAction(ok)
            self.present(alertController, animated: true, completion: nil)
        })
    }
}

