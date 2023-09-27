import UIKit

protocol CreateCategoryVCDelegate {
    func createdCategory(_ category: TrackerCategoryModel)
}

class CreateCategoryVC: UIViewController {
    var delegate: CreateCategoryVCDelegate?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "Новая категория"
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.indent(size: 10)
        textField.placeholder = "Введите название категории"
        textField.textColor = .ypBlack
        textField.backgroundColor = .backgroundColor
        textField.layer.cornerRadius = 16
        textField.font = .systemFont(ofSize: 17)
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        UITextField.appearance().clearButtonMode = .whileEditing
        textField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        return textField
    }()
    
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.textColor = .white
        button.backgroundColor = .gray
        button.isEnabled = true
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(addCategoryButtonAction), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let trackerCategoryStore = TrackerCategoryStore()
    
    @objc func textFieldChanged() {
        if textField.text != "" {
            addCategoryButton.backgroundColor = .black
            addCategoryButton.isEnabled = true
        } else {
            addCategoryButton.backgroundColor = .gray
            addCategoryButton.isEnabled = false
        }
    }
    
    @objc func addCategoryButtonAction() {
        if let categoryName = textField.text {
            let category = TrackerCategoryModel(name: categoryName, trackers: [])
            try? trackerCategoryStore.addNewTrackerCategory(category)
            delegate?.createdCategory(category)
            dismiss(animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addSubviews()
        setupLayout()
    }
    
    private func addSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(textField)
        view.addSubview(addCategoryButton)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
            
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            
            addCategoryButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
       ])
    }
}
