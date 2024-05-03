import UIKit

class University: Decodable {
    let name: String
    let country: String
    let stateProvince: String?
    let alphaTwoCode: String
    let domains: [String]
    let webPages: [String]
    
    enum CodingKeys: String, CodingKey {
        case name
        case country
        case stateProvince = "state-province"
        case alphaTwoCode = "alpha_two_code"
        case domains
        case webPages = "web_pages"
    }
}

class UniversityTableViewCell: UITableViewCell {
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .black
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let countryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor(white: 0.1, alpha: 1.0)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let websideTextView: UITextView = {
        let textView = UITextView()
        textView.isUserInteractionEnabled = true
        textView.isEditable = false
        textView.isSelectable = true
        textView.dataDetectorTypes = .link
        textView.isScrollEnabled = false
        textView.textContainerInset = .zero
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    let alphaTwoCodeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .init(white: 0.3, alpha: 1.0)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.85, alpha: 1.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(nameLabel)
        addSubview(countryLabel)
        addSubview(alphaTwoCodeLabel)
        addSubview(websideTextView)
        addSubview(separatorView)
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 16),
            
            countryLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            countryLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            countryLabel.trailingAnchor.constraint(equalTo: centerXAnchor, constant: 8),
            
            alphaTwoCodeLabel.topAnchor.constraint(equalTo: countryLabel.bottomAnchor, constant: 8),
            alphaTwoCodeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            alphaTwoCodeLabel.trailingAnchor.constraint(equalTo: centerXAnchor, constant: 8),
            alphaTwoCodeLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -8),
            
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            websideTextView.topAnchor.constraint(equalTo: countryLabel.topAnchor),
            websideTextView.leadingAnchor.constraint(equalTo: centerXAnchor, constant: 8),
            websideTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 16),
            websideTextView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class ViewController: UIViewController {

    let searchTextField = UITextField()
    let tableView = UITableView()
    let loader = UIActivityIndicatorView(style: .large)
    var items: [University] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        view.backgroundColor = .white
        
        searchTextField.placeholder = "Поиск"
        searchTextField.borderStyle = .roundedRect
        searchTextField.clearButtonMode = .whileEditing
        searchTextField.returnKeyType = .search
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.leftViewMode = .always
        searchTextField.delegate = self
        let leftView = UIView(frame: .init(origin: .zero, size: CGSize(width: 22, height: 16)))
        let imageView = UIImageView(image: UIImage(systemName: "magnifyingglass")?.withRenderingMode(.alwaysTemplate))
        imageView.tintColor = .black
        leftView.addSubview(imageView)
        imageView.frame = .init(x: 6, y: 0, width: 16, height: 16)
        searchTextField.leftView = leftView
        searchTextField.addTarget(self, action: #selector(changeSearchTextField(_:)), for: .editingChanged)
        view.addSubview(searchTextField)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.register(UniversityTableViewCell.self, forCellReuseIdentifier: "UniversityTableViewCell")
        view.addSubview(tableView)
        
        loader.hidesWhenStopped = true
        loader.color = UIColor(red: 77.0/255, green: 169.0/255, blue: 112.0/255, alpha: 1.0)
        view.addSubview(loader)
        
        NSLayoutConstraint.activate([
            searchTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 16),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        loader.startAnimating()
        let request = URLRequest(url: URL(string: "http://universities.hipolabs.com/search")!)
        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.sync {
                self.loader.stopAnimating()
                if let error {
                    self.showError(message: error.localizedDescription)
                } else if let data {
                    let items = try! JSONDecoder().decode([University].self, from: data)
                    self.items = items
                    self.tableView.reloadData()
                }
            }
        }.resume()
    }


    func showError(message: String) {
        let alertVC = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Ok", style: .default))
        
        present(alertVC, animated: true)
    }
    
    @objc func changeSearchTextField(_ textField: UITextField) {
        let text = textField.text ?? ""
        let query = text.isEmpty ? "" : "?name=\(text)"
        let request = URLRequest(url: URL(string: "http://universities.hipolabs.com/search\(query)")!)
        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.sync {
                self.loader.stopAnimating()
                if let error {
                    self.showError(message: error.localizedDescription)
                } else if let data {
                    let items = try! JSONDecoder().decode([University].self, from: data)
                    self.items = items
                    self.tableView.reloadData()
                }
            }
        }
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UniversityTableViewCell()
        
        let item = items[indexPath.row]
        cell.nameLabel.text = item.name
        var country = item.country
        if let stateProvince = item.stateProvince {
            country += ", \(stateProvince)"
        }
        cell.countryLabel.text = country
        cell.alphaTwoCodeLabel.text = "Alpha Two Code: \(item.alphaTwoCode)"
        
        if !item.webPages.isEmpty {
            let text = "Web pages:\n" + item.webPages.joined(separator: ",\n")
            let attributedString = NSMutableAttributedString(string: text)
            attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 14, weight: .medium), range: NSRange(location: 0, length: attributedString.length))
            for strUrl in item.webPages {
                let url = URL(string: strUrl)!
                let range = attributedString.mutableString.range(of: strUrl)
                attributedString.addAttribute(.link, value: url, range: range)
            }
            cell.websideTextView.attributedText = attributedString
            cell.websideTextView.isHidden = false
        } else {
            cell.websideTextView.isHidden = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        loader.startAnimating()
        let request = URLRequest(url: URL(string: "http://universities.hipolabs.com/search")!)
        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.sync {
                self.loader.stopAnimating()
                if let error {
                    self.showError(message: error.localizedDescription)
                } else if let data {
                    let items = try! JSONDecoder().decode([University].self, from: data)
                    self.items = items
                    self.tableView.reloadData()
                }
            }
        }.resume()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

