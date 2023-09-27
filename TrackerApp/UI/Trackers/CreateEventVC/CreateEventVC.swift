import UIKit

enum Event {
    case regular
    case irregular
    
    var titleText: String {
        switch self {
        case .regular:
            return "Новая привычка"
        case .irregular:
            return "Новое нерегулярное событие"
        }
    }
}

protocol CreateEventVCDelegate: AnyObject {
    func createTracker(_ tracker: Tracker, categoryName: String)
}

class CreateEventVC: UIViewController {
    private let emojies = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍒",
        "🍔", "🥦", "🏓", "🥇", "🎸", "🏝"
    ]
    
    private let colors: [UIColor] = [.color1, .color2, .color3, .color4, .color5, .color6, .color7, .color8, .color9, .color10, .color11, .color12, .color13, .color14, .color15, .color16, .color17, .color18]
    
    private var collectionViewHeader = ["Emoji", "Цвет"]
    private let event: Event
    private let nameCell = ["Категория", "Расписание"]
    private let limitNumberOfCharacters = 38
    private var numberOfCharacters = 0
    private var heightAnchor: NSLayoutConstraint?
    private var schedule: [WeekDay] = [] {
        didSet {
            updateCreateEventButton()
        }
    }
    
    private var category: TrackerCategoryModel? = nil {
        didSet {
            updateCreateEventButton()
        }
    }
    private var selectedEmojiCell: IndexPath? = nil
    private var selectedColorCell: IndexPath? = nil
    private var selectedEmoji: String = "" {
        didSet {
            updateCreateEventButton()
        }
    }
    private var selectedColor: UIColor? = nil {
        didSet {
            updateCreateEventButton()
        }
    }
    private var scheduleSubTitle: String = ""
    private var dayOfWeek: [String] = []
    
    var selectedCategory: TrackerCategoryModel?
    var categorySubTitle: String = ""
    
    public weak var delegate: CreateEventVCDelegate?
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        scrollView.frame = view.bounds
        scrollView.contentSize = contentSize
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private var contentSize: CGSize {
        CGSize(width: view.frame.width, height: view.frame.height + 400)
    }
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = event.titleText
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.indent(size: 10)
        textField.placeholder = "Введите название трекера"
        textField.textColor = .ypBlack
        textField.backgroundColor = .backgroundColor
        textField.layer.cornerRadius = 16
        textField.font = .systemFont(ofSize: 17)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        UITextField.appearance().clearButtonMode = .whileEditing
        textField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        return textField
    }()
    
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypRed
        label.font = .systemFont(ofSize: 17)
        label.textAlignment = .justified
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var createEventView: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundColor
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var forwardImage1: UIImageView = {
        let forwardImage = UIImageView()
        forwardImage.image = UIImage(named: "chevronForward")
        forwardImage.translatesAutoresizingMaskIntoConstraints = false
        return forwardImage
    }()
    
    private lazy var forwardImage2: UIImageView = {
        let forwardImage = UIImageView()
        forwardImage.image = UIImage(named: "chevronForward")
        forwardImage.translatesAutoresizingMaskIntoConstraints = false
        return forwardImage
    }()
    
    private lazy var categoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(categoryButtonAction), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var categoryButtonTitle: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "Категория"
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var categoryButtonSubTitle: UILabel = {
        let label = UILabel()
        label.textColor = .ypGray
        label.text = categorySubTitle
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var scheduleButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(scheduleButtonAction), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var scheduleButtonTitle: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "Расписание"
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var scheduleButtonSubTitle: UILabel = {
        let label = UILabel()
        label.textColor = .ypGray
        label.text = scheduleSubTitle
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emojiAndColorCollectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.register(EmojiAndColorCollectionViewCell.self, forCellWithReuseIdentifier: EmojiAndColorCollectionViewCell.identifier)
        collectionView.register(EmojiAndColorSupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: EmojiAndColorSupplementaryView.identifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    private lazy var buttonBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var createEventButton: UIButton = {
        let button = UIButton()
        button.setTitle("Создать", for: .normal)
        button.backgroundColor = .gray
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(createEventButtonAction), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(UIColor.ypRed, for: UIControl.State.normal)
        button.backgroundColor = .clear
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(cancelButtonAction), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(_ event: Event) {
        self.event = event
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addSubviews()
        setupLayout()
        emojiAndColorCollectionView.allowsMultipleSelection = true
    }
    
    func updateCreateEventButton() {
        createEventButton.isEnabled = textField.text?.isEmpty == false && selectedColor != nil && !selectedEmoji.isEmpty && category != nil
        if event == .regular {
            createEventButton.isEnabled = createEventButton.isEnabled && !schedule.isEmpty
        }
        
        if createEventButton.isEnabled {
            createEventButton.backgroundColor = .ypBlack
        } else {
            createEventButton.backgroundColor = .gray
        }
    }
    
    @objc func createEventButtonAction() {
        var tracker: Tracker?
        if event == .regular {
            tracker = Tracker(id: UUID(), name: textField.text ?? "", color: selectedColor, emoji: selectedEmoji, schedule: schedule)
        } else {
            schedule = WeekDay.allCases
            tracker = Tracker(id: UUID(), name: textField.text ?? "", color: selectedColor, emoji: selectedEmoji, schedule: schedule)
        }
        guard let tracker = tracker else { return }
        delegate?.createTracker(tracker, categoryName: category?.name ?? "Без категории")
        dismiss(animated: true)
    }
    
    @objc private func cancelButtonAction() {
        dismiss(animated: true)
    }
    
    @objc private func categoryButtonAction() {
        let categoryVC = CategoryListView(delegate: self, selectedCategory: category)
        present(categoryVC, animated: true)
    }
    
    @objc private func scheduleButtonAction() {
        let scheduleVC = ScheduleVC()
        scheduleVC.delegate = self
        scheduleVC.schedule = schedule
        present(scheduleVC, animated: true)
    }
    
    private func addSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(label)
        scrollView.addSubview(textField)
        scrollView.addSubview(errorLabel)
        scrollView.addSubview(createEventView)
        createEventView.addSubview(categoryButton)
        categoryButton.addSubview(forwardImage1)
        if event == .regular {
            createEventView.addSubview(separatorView)
            createEventView.addSubview(scheduleButton)
            scheduleButton.addSubview(forwardImage2)
        }
        updateScheduleButton()
        updateCategoryButton()
        scrollView.addSubview(emojiAndColorCollectionView)
        scrollView.addSubview(buttonBackgroundView)
        buttonBackgroundView.addSubview(createEventButton)
        buttonBackgroundView.addSubview(cancelButton)
    }
    
    private func setupLayout() {
        let createEventViewHeight: CGFloat = event == .regular ? 150 : 75
        heightAnchor = errorLabel.heightAnchor.constraint(equalToConstant: 0)
        var constraints = [
            label.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
            label.heightAnchor.constraint(equalToConstant: 25),
            label.widthAnchor.constraint(equalToConstant: 250),
            
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            textField.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 38),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            errorLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 0),
            errorLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            heightAnchor!,
            
            createEventView.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 16),
            createEventView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            createEventView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            createEventView.heightAnchor.constraint(equalToConstant: createEventViewHeight),
            
            categoryButton.topAnchor.constraint(equalTo: createEventView.topAnchor),
            categoryButton.bottomAnchor.constraint(equalTo:  self.event == .regular ? separatorView.topAnchor : createEventView.bottomAnchor),
            categoryButton.trailingAnchor.constraint(equalTo: createEventView.trailingAnchor),
            categoryButton.leadingAnchor.constraint(equalTo: createEventView.leadingAnchor),
            
            forwardImage1.trailingAnchor.constraint(equalTo: categoryButton.trailingAnchor, constant: -24),
            forwardImage1.centerYAnchor.constraint(equalTo: categoryButton.centerYAnchor),
            
            emojiAndColorCollectionView.topAnchor.constraint(equalTo: createEventView.bottomAnchor, constant: 22),
            emojiAndColorCollectionView.bottomAnchor.constraint(equalTo: buttonBackgroundView.topAnchor),
            emojiAndColorCollectionView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            emojiAndColorCollectionView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            emojiAndColorCollectionView.widthAnchor.constraint(equalToConstant: scrollView.bounds.width - 32),
            emojiAndColorCollectionView.heightAnchor.constraint(equalToConstant: 400),
            
            buttonBackgroundView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            buttonBackgroundView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            buttonBackgroundView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            buttonBackgroundView.heightAnchor.constraint(equalToConstant: 80),
            
            cancelButton.leadingAnchor.constraint(equalTo: buttonBackgroundView.leadingAnchor, constant: 20),
            cancelButton.bottomAnchor.constraint(equalTo: buttonBackgroundView.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            cancelButton.widthAnchor.constraint(equalToConstant: 161),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            
            createEventButton.trailingAnchor.constraint(equalTo: buttonBackgroundView.trailingAnchor, constant: -20),
            createEventButton.bottomAnchor.constraint(equalTo: buttonBackgroundView.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            createEventButton.widthAnchor.constraint(equalToConstant: 161),
            createEventButton.heightAnchor.constraint(equalToConstant: 60)
        ]
        
        if event == .regular {
            constraints += [
                separatorView.centerYAnchor.constraint(equalTo: createEventView.centerYAnchor),
                separatorView.trailingAnchor.constraint(equalTo: createEventView.trailingAnchor, constant: -10),
                separatorView.leadingAnchor.constraint(equalTo: createEventView.leadingAnchor, constant: 10),
                separatorView.heightAnchor.constraint(equalToConstant: 0.5),
                
                scheduleButton.topAnchor.constraint(equalTo: separatorView.bottomAnchor),
                scheduleButton.bottomAnchor.constraint(equalTo: createEventView.bottomAnchor),
                scheduleButton.trailingAnchor.constraint(equalTo: createEventView.trailingAnchor),
                scheduleButton.leadingAnchor.constraint(equalTo: createEventView.leadingAnchor),
                forwardImage2.trailingAnchor.constraint(equalTo: scheduleButton.trailingAnchor, constant: -24),
                forwardImage2.centerYAnchor.constraint(equalTo: scheduleButton.centerYAnchor)
            ]
        }
        NSLayoutConstraint.activate(constraints)
    }
    
    func updateScheduleButton() {
        if scheduleSubTitle == "" {
            scheduleButton.addSubview(scheduleButtonTitle)
            NSLayoutConstraint.activate([
                scheduleButtonTitle.centerYAnchor.constraint(equalTo: scheduleButton.centerYAnchor),
                scheduleButtonTitle.leadingAnchor.constraint(equalTo: scheduleButton.leadingAnchor, constant: 16)
            ])
            scheduleButtonSubTitle.isHidden = true
        } else {
            scheduleButton.addSubview(scheduleButtonTitle)
            scheduleButton.addSubview(scheduleButtonSubTitle)
            NSLayoutConstraint.activate([
                scheduleButtonTitle.leadingAnchor.constraint(equalTo: scheduleButton.leadingAnchor, constant: 16),
                scheduleButtonTitle.topAnchor.constraint(equalTo: scheduleButton.topAnchor, constant: 15),
                scheduleButtonSubTitle.leadingAnchor.constraint(equalTo: scheduleButton.leadingAnchor, constant: 16),
                scheduleButtonSubTitle.bottomAnchor.constraint(equalTo: scheduleButton.bottomAnchor, constant: -13)
            ])
            scheduleButtonSubTitle.text = scheduleSubTitle
            scheduleButtonSubTitle.isHidden = false
        }
    }
    
    func updateCategoryButton() {
        if categorySubTitle == "" {
            categoryButton.addSubview(categoryButtonTitle)
            NSLayoutConstraint.activate([
                categoryButtonTitle.centerYAnchor.constraint(equalTo: categoryButton.centerYAnchor),
                categoryButtonTitle.leadingAnchor.constraint(equalTo: categoryButton.leadingAnchor, constant: 16)
            ])
        } else {
            categoryButton.addSubview(categoryButtonTitle)
            categoryButton.addSubview(categoryButtonSubTitle)
            NSLayoutConstraint.activate([
                categoryButtonTitle.leadingAnchor.constraint(equalTo: categoryButton.leadingAnchor, constant: 16),
                categoryButtonTitle.topAnchor.constraint(equalTo: categoryButton.topAnchor, constant: 15),
                categoryButtonSubTitle.leadingAnchor.constraint(equalTo: categoryButton.leadingAnchor, constant: 16),
                categoryButtonSubTitle.bottomAnchor.constraint(equalTo: categoryButton.bottomAnchor, constant: -13)
            ])
            categoryButtonSubTitle.text = categorySubTitle
        }
    }
    
    @objc func textFieldChanged() {
        updateCreateEventButton()
        guard let number = textField.text?.count else { return }
        numberOfCharacters = number
        if numberOfCharacters < limitNumberOfCharacters {
            errorLabel.text = ""
            heightAnchor?.constant = 0
        } else {
            errorLabel.text = "Ограничение 38 символов"
            heightAnchor?.constant = 32
        }
    }
}

extension UITextField {
    
    func indent(size:CGFloat) {
        self.leftView = UIView(frame: CGRect(x: self.frame.minX, y: self.frame.minY, width: size, height: self.frame.height))
        self.leftViewMode = .always
    }
}

extension CreateEventVC: UITextFieldDelegate {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        let maxLenght = limitNumberOfCharacters
        let currentString = (textField.text ?? "") as NSString
        let newString = currentString.replacingCharacters(in: range, with: string)
        
        return newString.count <= maxLenght
    }
}

extension CreateEventVC: ScheduleVCDelegate {
    func createSchedule(schedule: [WeekDay]) {
        self.schedule = schedule
        let scheduleString = schedule.map { $0.shortName }.joined(separator: ", ")
        scheduleSubTitle = scheduleString == "Пн, Вт, Ср, Чт, Пт, Сб, Вс" ? "Каждый день" : scheduleString
        updateScheduleButton()
    }
}

extension CreateEventVC: CategoryListViewModelDelegate {
    func createCategory(category: TrackerCategoryModel) {
        self.category = category
        let categoryString = category.name
        categorySubTitle = categoryString
        updateCategoryButton()
    }
}

extension CreateEventVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var returnValue = Int()
        if section == 0 {
            returnValue = emojies.count
        } else if section == 1 {
            returnValue = colors.count
        }
        return returnValue
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = indexPath.section
        
        guard let cell = emojiAndColorCollectionView.dequeueReusableCell(withReuseIdentifier: "emojiAndColorCollectionViewCell", for: indexPath) as? EmojiAndColorCollectionViewCell
        else {
            return UICollectionViewCell()
        }
        cell.layer.cornerRadius = 16
        
        if section == 0 {
            cell.emojiLabel.text = emojies[indexPath.row]
        } else if section == 1 {
            cell.colorView.backgroundColor = colors[indexPath.row]
            cell.colorView.layer.cornerRadius = 8
        }
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
}

extension CreateEventVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = indexPath.section
        let cell = collectionView.cellForItem(at: indexPath) as? EmojiAndColorCollectionViewCell
        if section == 0 {
            if selectedEmojiCell != nil {
                collectionView.deselectItem(at: selectedEmojiCell!, animated: true)
                collectionView.cellForItem(at: selectedEmojiCell!)?.backgroundColor = .white
            }
            cell?.backgroundColor = .lightGray
            selectedEmoji = cell?.emojiLabel.text ?? ""
            selectedEmojiCell = indexPath
        } else if section == 1 {
            if selectedColorCell != nil {
                collectionView.deselectItem(at: selectedColorCell!, animated: true)
                collectionView.cellForItem(at: selectedColorCell!)?.layer.borderWidth = 0
            }
            cell?.layer.borderWidth = 3
            cell?.layer.cornerRadius = 8
            selectedColor = cell?.colorView.backgroundColor ?? nil
            cell?.layer.borderColor = selectedColor?.withAlphaComponent(0.3).cgColor
            selectedColorCell = indexPath
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? EmojiAndColorCollectionViewCell
        collectionView.deselectItem(at: indexPath, animated: true)
        cell?.backgroundColor = .white
        cell?.layer.borderWidth = 0
        if indexPath.section == 0 {
            selectedEmoji = ""
            selectedEmojiCell = nil
        } else {
            selectedColor = nil
            selectedColorCell = nil
        }
    }
}

extension CreateEventVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: 52, height: 52)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        
        var id: String
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = "header"
        case UICollectionView.elementKindSectionFooter:
            id = "footer"
        default:
            id = ""
        }
        
        guard let view = emojiAndColorCollectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as? EmojiAndColorSupplementaryView else { return UICollectionReusableView() }
        let section = indexPath.section
        if section == 0 {
            view.titleLabel.text = collectionViewHeader[0]
        } else if section == 1 {
            view.titleLabel.text = collectionViewHeader[1]
        }
        return view
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width,height: UIView.layoutFittingExpandedSize.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
    }
}
