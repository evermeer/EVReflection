import UIKit
import EVReflection

class BaseViewController: UITableViewController {
    var repos = [Repository]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadRepositories("evermeer")
    }
    
    // MARK: - API Stuff
    
    func downloadRepositories(_ username: String) {
        assert(true, "Needs to be implemented")
    }
    
    func downloadZen() {
        assert(true, "Needs to be implemented")
    }
    
    // MARK: - User Interaction
    
    @IBAction func searchWasPressed(_ sender: UIBarButtonItem) {
        var usernameTextField: UITextField?
        
        let promptController = UIAlertController(title: "Username", message: nil, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            if let usernameTextField = usernameTextField {
                self.downloadRepositories(usernameTextField.text!)
            }
        })
        _ = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
        }
        promptController.addAction(ok)
        promptController.addTextField { (textField) -> Void in
            usernameTextField = textField
        }
        present(promptController, animated: true, completion: nil)
    }
    
    @IBAction func zenWasPressed(_ sender: UIBarButtonItem) {
        downloadZen()
    }
    
    // MARK: - Table View
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
        let repo = repos[(indexPath as NSIndexPath).row]
        cell.textLabel?.text = repo.name
        return cell
    }
}

