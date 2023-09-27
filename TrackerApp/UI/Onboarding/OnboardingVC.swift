import UIKit

class OnboardingVC: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    private lazy var pages: [UIViewController] = {
        return [blueVC, redVC]
    }()
    
    private lazy var blueVC: UIViewController = {
        let blueVC = UIViewController()
        let image = "onboardingBlue.pdf"
        blueVC.view.addBackground(image: image)
        return blueVC
    }()
    
    private lazy var redVC: UIViewController = {
        let redVC = UIViewController()
        let image = "onboardingRed.pdf"
        redVC.view.addBackground(image: image)
        return redVC
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .ypBlack
        pageControl.pageIndicatorTintColor = UIColor.ypBlack.withAlphaComponent(0.3)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    private lazy var blueVCLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 32)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.text = "Отслеживайте только то, что хотите"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var BlueVCEnterButton: UIButton = {
        let button = UIButton()
        button.setTitle("Вот это технологии!", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(enterButtonAction), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var redVCLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 32)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.text = "Даже если это не литры воды и йога"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var redVCEnterButton: UIButton = {
        let button = UIButton()
        button.setTitle("Вот это технологии!", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(enterButtonAction), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        
        if let first = pages.first { setViewControllers([first], direction: .forward, animated: true, completion: nil)
        }
        addBlueVC()
        addRedVC()
        addPageControl()
    }
    
    private func addBlueVC() {
        blueVC.view.addSubview(blueVCLabel)
        blueVC.view.addSubview(BlueVCEnterButton)
        
        NSLayoutConstraint.activate([
            blueVCLabel.bottomAnchor.constraint(equalTo: blueVC.view.safeAreaLayoutGuide.bottomAnchor, constant: -290),
            blueVCLabel.centerXAnchor.constraint(equalTo: blueVC.view.safeAreaLayoutGuide.centerXAnchor),
            blueVCLabel.widthAnchor.constraint(equalToConstant: 343),
            
            BlueVCEnterButton.heightAnchor.constraint(equalToConstant: 60),
            BlueVCEnterButton.leadingAnchor.constraint(equalTo: blueVC.view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            BlueVCEnterButton.trailingAnchor.constraint(equalTo: blueVC.view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            BlueVCEnterButton.bottomAnchor.constraint(equalTo: blueVC.view.safeAreaLayoutGuide.bottomAnchor, constant: -71)
        ])
    }
    
    private func addRedVC() {
        redVC.view.addSubview(redVCLabel)
        redVC.view.addSubview(redVCEnterButton)
        
        NSLayoutConstraint.activate([
            redVCLabel.bottomAnchor.constraint(equalTo: redVC.view.safeAreaLayoutGuide.bottomAnchor, constant: -290),
            redVCLabel.centerXAnchor.constraint(equalTo: redVC.view.safeAreaLayoutGuide.centerXAnchor),
            redVCLabel.widthAnchor.constraint(equalToConstant: 343),
            
            redVCEnterButton.heightAnchor.constraint(equalToConstant: 60),
            redVCEnterButton.leadingAnchor.constraint(equalTo: redVC.view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            redVCEnterButton.trailingAnchor.constraint(equalTo: redVC.view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            redVCEnterButton.bottomAnchor.constraint(equalTo: redVC.view.safeAreaLayoutGuide.bottomAnchor, constant: -71)
        ])
    }
    
    private func addPageControl() {
        view.addSubview(pageControl)
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -155),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    @objc private func enterButtonAction() {
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid Configuration")
        }
        window.rootViewController = TabBarController.configure()
        UserDefaults.standard.set(true, forKey: "isOnbordingShown")
    }
    
    // MARK: - UIPageViewControllerDataSource
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else {
            return pages.last
        }
        return pages[previousIndex]
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        let nextIndex = viewControllerIndex + 1
        guard nextIndex < pages.count else {
            return pages.first
        }
        return pages[nextIndex]
    }
    
    // MARK: - UIPageViewControllerDelegate
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool)
    {
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}

extension UIView {
    
    func addBackground(image: String) {
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        let imageViewBackground = UIImageView(frame: CGRectMake(0, 0, width, height))
        imageViewBackground.image = UIImage(named: image)
        imageViewBackground.contentMode = UIView.ContentMode.scaleAspectFill
        self.addSubview(imageViewBackground)
        self.sendSubviewToBack(imageViewBackground)
    }
}
