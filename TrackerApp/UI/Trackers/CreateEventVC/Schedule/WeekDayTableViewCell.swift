import UIKit

protocol WeekDayTableViewCellDelegate: AnyObject {
    func stateChanged(for day: WeekDay, isOn: Bool)
}

final class WeekDayTableViewCell: UITableViewCell {
    public weak var delegate: WeekDayTableViewCellDelegate?
    var weekDay: WeekDay?
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var switchCell: UISwitch = {
        let switchCell = UISwitch()
        switchCell.onTintColor = .switchColor
        switchCell.addTarget(self, action: #selector(onSwitchValueChanged(_:)), for: .valueChanged)
        switchCell.translatesAutoresizingMaskIntoConstraints = false
        return switchCell
    }()
    
    static let identifier = "WeekDayTableViewCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: WeekDayTableViewCell.identifier)
        setupView()
        setupLayout()
    }
    
    private func setupView() {
        self.contentView.addSubview(label)
        self.contentView.addSubview(switchCell)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
        label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
        
        switchCell.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        switchCell.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func onSwitchValueChanged(_ control: UISwitch) {
        guard let weekDay else { return }
        delegate?.stateChanged(for: weekDay, isOn: control.isOn)
    }
}
    
   
