import UIKit

final class StatisticsViewController: UIViewController {
    
    private let trackerRecordStore = TrackerRecordStore()
    private var completedTrackers: [TrackerRecord] = []
    
    private lazy var statisticsTitle: UILabel = {
        let label = UILabel()
        label.textColor = .YPBlack
        label.text = NSLocalizedString("statistics", tableName: "Localizable", comment: "statistics")
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var noStatisticsImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "noStatistics")
        return imageView
    }()
    
    private lazy var noStatisticsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .YPBlack
        label.text = "Анализировать пока нечего"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var completedTrackerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var resultTitle: UILabel = {
        let label = UILabel()
        label.textColor = .YPBlack
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var resultSubTitle: UILabel = {
        let label = UILabel()
        label.textColor = .YPBlack
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        addStatisticsTitle()
        addNoStatisticsImage()
        addNoStatisticsLabel()
        addCompletedTreckerView()
        addResultTitle()
        addResultSubTitle()
        trackerRecordStore.delegate = self
        updateCompletedTrackers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        completedTrackerView.setGradientBorder(width: 1, colors: [.gradientColour1, .gradientColour2, .gradientColour3])
    }
    
    private func addStatisticsTitle() {
        view.addSubview(statisticsTitle)
        NSLayoutConstraint.activate([
            statisticsTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: 88),
            statisticsTitle.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        ])
    }
    
    private func addNoStatisticsImage() {
        view.addSubview(noStatisticsImage)
        NSLayoutConstraint.activate([
            noStatisticsImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            noStatisticsImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noStatisticsImage.widthAnchor.constraint(equalToConstant: 80),
            noStatisticsImage.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    private func addNoStatisticsLabel() {
        view.addSubview(noStatisticsLabel)
        NSLayoutConstraint.activate([
            noStatisticsLabel.topAnchor.constraint(equalTo: noStatisticsImage.bottomAnchor, constant: 8),
            noStatisticsLabel.centerXAnchor.constraint(equalTo: noStatisticsImage.centerXAnchor)
        ])
    }
    
    private func addCompletedTreckerView() {
        view.addSubview(completedTrackerView)
        NSLayoutConstraint.activate([
            completedTrackerView.topAnchor.constraint(equalTo: statisticsTitle.bottomAnchor, constant: 77),
            completedTrackerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            completedTrackerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            completedTrackerView.heightAnchor.constraint(equalToConstant: 90)
        ])
    }
    
    private func addResultTitle() {
        completedTrackerView.addSubview(resultTitle)
        NSLayoutConstraint.activate([
            resultTitle.topAnchor.constraint(equalTo: completedTrackerView.topAnchor, constant: 12),
            resultTitle.leadingAnchor.constraint(equalTo: completedTrackerView.leadingAnchor, constant: 12),
            resultTitle.trailingAnchor.constraint(equalTo: completedTrackerView.trailingAnchor, constant: -12),
            resultTitle.heightAnchor.constraint(equalToConstant: 41)
        ])
    }
    
    private func addResultSubTitle() {
        completedTrackerView.addSubview(resultSubTitle)
        NSLayoutConstraint.activate([
            resultSubTitle.bottomAnchor.constraint(equalTo: completedTrackerView.bottomAnchor, constant: -12),
            resultSubTitle.leadingAnchor.constraint(equalTo: completedTrackerView.leadingAnchor, constant: 12),
            resultSubTitle.trailingAnchor.constraint(equalTo: completedTrackerView.trailingAnchor, constant: -12),
            resultSubTitle.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
    
    func updateCompletedTrackers() {
        completedTrackers = trackerRecordStore.trackerRecords
        resultTitle.text = "\(completedTrackers.count)"
        resultSubTitle.text = String.localizedStringWithFormat(NSLocalizedString("trackerCompleted", tableName: "Localizable", comment: "Число дней"), completedTrackers.count)
        noStatisticsImage.isHidden = completedTrackers.count > 0
        noStatisticsLabel.isHidden = completedTrackers.count > 0
        completedTrackerView.isHidden = completedTrackers.count == 0
    }
}

extension StatisticsViewController: TrackerRecordStoreDelegate {
    func store(_ store: TrackerRecordStore, didUpdate update: TrackerRecordStoreUpdate) {
        updateCompletedTrackers()
    }
}
