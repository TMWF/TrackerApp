import UIKit

class CategoryListView: UIViewController {
    private let viewModel: CategoryListViewModel
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "Категория"
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "star")
        return imageView
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "Привычки и события можно объединять по смыслу"
        label.numberOfLines = 2
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton()
        button.setTitle("Добавить категорию", for: .normal)
        button.titleLabel?.textColor = .white
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(addCategoryButtonAction), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: CategoryTableViewCell.identifier)
        tableView.separatorColor = .ypGray
        tableView.backgroundColor = .white
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsMultipleSelection = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    init(delegate: CategoryListViewModelDelegate?, selectedCategory: TrackerCategoryModel?) {
        viewModel = CategoryListViewModel(delegate: delegate, selectedCategory: selectedCategory)
        super.init(nibName: nil, bundle: nil)
        viewModel.onChange = self.tableView.reloadData
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addSubviews()
        setupLayout()
    }
    
    private func addSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(imageView)
        view.addSubview(label)
        view.addSubview(addCategoryButton)
        view.addSubview(tableView)
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
            
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            label.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            label.heightAnchor.constraint(equalToConstant: 50),
            label.widthAnchor.constraint(equalToConstant: 200),
            
            addCategoryButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            
            tableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -10),
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    @objc
    private func addCategoryButtonAction() {
        let createCategoryVC = CreateCategoryVC()
        createCategoryVC.delegate = self
        present(createCategoryVC, animated: true)
    }
    
    private func actionSheet(categoryToDelete: TrackerCategoryModel) {
        let alert = UIAlertController(title: "Эта категория точно не нужна?",
                                      message: nil,
                                      preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Удалить",
                                      style: .destructive) { [weak self] _ in
            self?.viewModel.deleteCategory(categoryToDelete)
        })
        alert.addAction(UIAlertAction(title: "Отменить",
                                      style: .cancel) { _ in
            
        })
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func makeContextMenu(_ indexPath: IndexPath) -> UIMenu {
        let category = viewModel.categories[indexPath.row]
        let rename = UIAction(title: "Редактировать", image: nil) { [weak self] action in
            let editCategoryVC = EditCategoryVC()
            editCategoryVC.editableCategory = category
            self?.present(editCategoryVC, animated: true)
        }
        let delete = UIAction(title: "Удалить", image: nil, attributes: .destructive) { [weak self] action in
            self?.actionSheet(categoryToDelete: category)
        }
        return UIMenu(children: [rename, delete])
    }
    
    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { suggestedActions in
            return self.makeContextMenu(indexPath)
        })
    }
}

extension CategoryListView: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        let count = viewModel.categories.count
        tableView.isHidden = count == 0
        return count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let categoryCell = tableView.dequeueReusableCell(withIdentifier: CategoryTableViewCell.identifier) as? CategoryTableViewCell else {
            return UITableViewCell()
        }
        
        let categoryName = viewModel.categories[indexPath.row].name
        categoryCell.label.text = categoryName
        if indexPath.row == viewModel.categories.count - 1 {
            categoryCell.separatorInset = UIEdgeInsets(top: 0, left: categoryCell.bounds.size.width + 200, bottom: 0, right: 0);
            categoryCell.contentView.clipsToBounds = true
            categoryCell.contentView.layer.cornerRadius = 16
            categoryCell.contentView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        } else if indexPath.row == 0 {
            categoryCell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            categoryCell.contentView.clipsToBounds = true
            categoryCell.contentView.layer.cornerRadius = 16
            categoryCell.contentView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        } else {
            categoryCell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            categoryCell.contentView.layer.cornerRadius = 0
        }
        categoryCell.checkmarkImage.isHidden = viewModel.selectedCategory?.name != categoryName
        categoryCell.selectionStyle = .none
        return categoryCell
    }
}

extension CategoryListView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let categoryCell = tableView.cellForRow(at: indexPath) as? CategoryTableViewCell else {
            return
        }
        guard let selectedCategoryName = categoryCell.label.text else { return }
        categoryCell.checkmarkImage.isHidden = !categoryCell.checkmarkImage.isHidden
        viewModel.selectCategory(with: selectedCategoryName)
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let categoryCell = tableView.cellForRow(at: indexPath) as? CategoryTableViewCell else {
            return
        }
        categoryCell.checkmarkImage.isHidden = true
    }
}

extension CategoryListView: CreateCategoryVCDelegate {
    func createdCategory(_ category: TrackerCategoryModel) {
        viewModel.selectCategory(category)
        viewModel.selectCategory(with: category.name)
    }
}
