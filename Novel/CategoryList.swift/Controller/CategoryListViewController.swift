//
//  HistoryListViewController.swift
//  Novel
//
//  Created by Иван Абрамов on  12.07.2020.
//  Copyright © 2020 Иван Абрамов. All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds

enum TypeOfReward {
    case Heart
    case Energy
    case None
}

class CategoryListViewController: UIViewController, NavigationBarDelegate, GADRewardedAdDelegate, BonusUIViewDelegate {
    
    
    func leftButtonTapped() {
          self.typeOfReward = .Heart
            
        // Ad successfully loaded.
        if self.rewardedAdvideo?.isReady == true {
            stopActivityIndicator()
            readyToPresentAd = false
            self.rewardedAdvideo?.present(fromRootViewController: self, delegate:self)
        } else {
            readyToPresentAd = true
            startActivityIndicator(withBlur: true, andText: "Загружаем рекламное видео...", showCloseButton: true, closeCompletion: {
                print("\n\nClose download ad\n\n")
                self.readyToPresentAd = false
                self.stopActivityIndicator()
            })
            
            rewardedAdvideo = createAndLoadRewardedAd()
        }
    }
    
    func rightButtonTapped() {
        self.typeOfReward = .Energy
        
        // Ad successfully loaded.
        if self.rewardedAdvideo?.isReady == true {
            stopActivityIndicator()
            readyToPresentAd = false
            self.rewardedAdvideo?.present(fromRootViewController: self, delegate:self)
        } else {
            readyToPresentAd = true
            startActivityIndicator(withBlur: true, andText: "Загружаем рекламное видео...", showCloseButton: true, closeCompletion: {
                print("\n\nClose download ad\n\n")
                self.readyToPresentAd = false
                self.stopActivityIndicator()
            })
            
            rewardedAdvideo = createAndLoadRewardedAd()
        }
    }
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var rewardedAdvideo: GADRewardedAd?
    var typeOfReward: TypeOfReward?
    var readyToPresentAd: Bool = false
    
    var ref: DatabaseReference!
    var user: AppUser!
    var categories = Array<Category>()
    var bonusView: BonusUIView?
    var bonusTappedCompetion = {}
    
    var blurEffect: UIBlurEffect?
    var currentCellsRowNumber: Int = 1

    var activityIndicator = UIActivityIndicatorView(style: .large)
    var activityIndicatorText: UILabel!
    var closeActivityIndicatorClosure: (() -> ())?
    var timer: Timer?
    
    @IBOutlet weak var customNavigationBar: CustomNavigationBar!
    
//    MARK: - ViewLifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let currentUser = Auth.auth().currentUser else { return }
        user = AppUser(user: currentUser)
        ref = Database.database().reference(withPath: "categories")
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = compositionalLayout
        
        customNavigationBar.delegate = self
        
        
        collectionView.insetsLayoutMarginsFromSafeArea = false
        
        startActivityIndicator(withBlur: true, andText: "Загружаем истории...", showCloseButton: false, closeCompletion: {})
//        addreferalBonus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.title = "Истории"
        
        rewardedAdvideo = createAndLoadRewardedAd()
        readyToPresentAd = false
//        let rewardedAdvideo = GADRewardedAd(adUnitID: "ca-app-pub-3940256099942544/1712485313")
//
//        rewardedAdvideo.load(GADRequest()) { error in
//            if error != nil {
//                rewardedAdvideo.load(GADRequest())
//            }
//        }
        
        startObserveUser()
        
        DispatchQueue.global(qos: .background).async {
            self.ref.observe(.value, with: {[weak self] (snapshot) in
                       var _categories = Array<Category>()
                       var recomendations = Array<Category>()
                       
                       for item in snapshot.children {
                           let category = Category(snapshot: item as! DataSnapshot)
                           
                           if category.name == "Рекомендации" {
                               recomendations.append(category)
                           } else {
                                 _categories.append(category)
                           }
                       }
                       
                    
                       self?.categories = recomendations
                       
                       self?.categories += _categories
                      
                       DispatchQueue.main.async {
                        self?.stopActivityIndicator()
                           // reload collection view here:
                            self?.collectionView.reloadData()
                       }
                })
        }
       
        
//        scrollSectionCellsAutomatically()
    }
    
//  Observe user profile
    
    func startObserveUser() {
        let userRef = Database.database().reference(withPath: "users/\(user.uid)")
        
        print("User ref: \(userRef.description()) UID: \(user.uid)")
        
        userRef.observe(.value, with: {(snapshot) in
            if type(of: (snapshot.value  as! [String: AnyObject])) != NSNull.self {
                self.user = AppUser(snapshot: snapshot)
                
                self.customNavigationBar.setHeartCurrency(withValue: self.user.heartCurrency)
                self.customNavigationBar.setEnergyCurrency(withValue: self.user.energyCurrency)
                
                 print("\n\nUpdate user info\n\n")
            }
        })
    }
    
//    MARK:- Activity indicator
    
    func startActivityIndicator(withBlur blur: Bool, andText text: String, showCloseButton: Bool, closeCompletion: @escaping () -> ()) {
        print("\n\nStart to display activity indicator\n\n")
        
        if blur {
            blurEffect = UIBlurEffect(style: UIBlurEffect.Style.extraLight)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = self.view.bounds
            blurEffectView.tag = 99
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.view.addSubview(blurEffectView)
            
            if !text.isEmpty {
                
                let frame = CGRect(x: 0, y: 0, width: 200, height: 35)
                let label = UILabel(frame: frame)
                blurEffectView.contentView.addSubview(label)
                
                label.textAlignment = .center
                label.text = text
                label.sizeToFit()
                label.textColor = .black
                label.center = self.view.center.applying(CGAffineTransform(translationX: 0, y: -45))
            }
            
            guard showCloseButton else { return }
                
            let frame = CGRect(x: 40, y: 40, width: 60, height: 60)
            let closeButton = UIButton(frame: frame)
            closeButton.setImage(UIImage(named: "cancel"), for: .normal)
            closeButton.tintColor = .black
            
            closeButton.addTarget(self, action: #selector(closeActivityIndicator), for: .touchUpInside)
            closeActivityIndicatorClosure = closeCompletion
            blurEffectView.contentView.addSubview(closeButton)
            
//            closeButton.tar
        }
        
        self.view.addSubview(activityIndicator)
        activityIndicator.center = self.view.center
        activityIndicator.startAnimating()
    }
    
    func stopActivityIndicator() {
        print("\n\nStop to display activity indicator\n\n")
        
        view.viewWithTag(99)?.removeFromSuperview()
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }
    
    @objc func closeActivityIndicator() {
        if let closure = closeActivityIndicatorClosure {
            closure()
        }
    }
    
//    MARK:- BonusView
    
    func addreferalBonus() {
        let userRef = Database.database().reference(withPath: "users")
        
        userRef.child("\(user.uid)").observeSingleEvent(of: .value, with: {(snapshot) in
            let user = AppUser(snapshot: snapshot)
            if !(user.didAddreferalBonus) {
                _ = getBonuses(completion: { bonuses in
                    
                    self.presentBonusView(withTitle: "Вы получили бонус!", andSubtitle: "Бонус за регистрацию по реферальной ссылке \(bonuses.referalBonuse) энергии") {
                        userRef.child("\(user.uid)/energyCurrency").setValue((user.energyCurrency) + bonuses.referalBonuse)
                        userRef.child("\(user.uid)/didAddreferalBonus").setValue(true)
                    }
                    
                    userRef.child("\(user.refCode)").observeSingleEvent(of: .value, with: {(snapshot) in
                        if snapshot.exists() {
                            let user = AppUser(snapshot: snapshot)
                            userRef.child("\(user.refCode)/energyCurrency").setValue((user.energyCurrency) + bonuses.referalBonuse)
                        }
                    })

                })
            }
        })
    }
    
    func presentBonusView(withTitle title: String, andSubtitle subtitle: String, completion: @escaping () -> ()) {
        let uiscreenBounds = UIScreen.main.bounds
        let rect = CGRect(x: 0, y: 0, width: uiscreenBounds.width * 0.8, height: uiscreenBounds.width * 0.8 * 55 / 35)
        
        bonusView = BonusUIView(frame: rect)
        bonusView?.center = self.view.center
        bonusView?.delegate = self
        bonusView?.setTitle(withText: title)
        bonusView?.setSubtitle(withText: subtitle)
        
        bonusTappedCompetion = completion
        
        blurEffect = UIBlurEffect(style: UIBlurEffect.Style.extraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        blurEffectView.tag = 100
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(blurEffectView)
        
        self.view.addSubview(bonusView!)
    }
    
    func bonusButtonTapped() {
        bonusTappedCompetion()
        bonusView?.removeFromSuperview()
        view.viewWithTag(100)?.removeFromSuperview()
    }
    
//    MARK:- Automatic scroll of sections
    
    func scrollSectionCellsAutomatically() {
        timer =  Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(scrollToCell), userInfo: nil, repeats: true)
    }
    
    @objc func scrollToCell() {
        guard recomendationSectionIsVisible() == true else { return }
            
        let indexPath: IndexPath = IndexPath(row: currentCellsRowNumber, section: 0)
        
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        
        if ((currentCellsRowNumber) < 10 - 1) {
            currentCellsRowNumber += 1

        } else {
           currentCellsRowNumber = 0
        }
    }
    
    func recomendationSectionIsVisible() -> Bool {
        for cell in collectionView.visibleCells {
            if collectionView.indexPath(for: cell)?.section == 0 {
                return true
            }
        }
        
        return false
    }
    
    func printCategories() {
        for category in categories {
            print("\(category.name) \n")
        }
    }
    
    func createCategories() {
        let category = Category(name: "Военный", color: UIColor.red.toHex!)
        ref.child(category.name).setValue(["name": category.name, "color": category.color])
        
        let category2 = Category(name: "Драма", color: UIColor.green.toHex!)
        ref.child(category2.name).setValue(["name": category2.name, "color": category2.color])
        
        let category3 = Category(name: "Любовный", color: UIColor.cyan.toHex!)
        ref.child(category3.name).setValue(["name": category3.name, "color": category3.color])
        
        let category4 = Category(name: "Приключенческий", color: UIColor.yellow.toHex!)
        ref.child(category4.name).setValue(["name": category4.name, "color": category4.color])
    }
    
    func createStories() {
        
    }
    
//   MARK:- Handle internal currency
    
    func updateEnergyCurrency(withValue value: Int) {
        let userRef = Database.database().reference(withPath: "users/\(user.uid)")
        userRef.child("energyCurrency").setValue(user.energyCurrency + value)
    }
    
    func updateHeartCurrency(withValue value: Int) {
        let userRef = Database.database().reference(withPath: "users/\(user.uid)")
        userRef.child("heartCurrency").setValue(user.heartCurrency + value)
       }
    
//  MARK:- Handle mobile ad video
    
    func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
        switch typeOfReward {
        case .Energy:
            presentBonusView(withTitle: "Вы получили бонус!", andSubtitle: "Бонус за просмотр рекламы - 5 энергий", completion: {
                self.updateEnergyCurrency(withValue: 5)
            })
            break
        case .Heart:
            presentBonusView(withTitle: "Вы получили бонус!", andSubtitle: "Бонус за просмотр рекламы - 5 энергий", completion: {
                self.updateHeartCurrency(withValue: 1)
            })
            break
        default:
            break
        }
        
        typeOfReward = .None
        
        print("User did earn reward")
    }
    
    func rewardedAdDidDismiss(_ rewardedAd: GADRewardedAd) {
        rewardedAdvideo = createAndLoadRewardedAd()
    }
    
    func createAndLoadRewardedAd() -> GADRewardedAd? {
        let newRewardedAd = GADRewardedAd(adUnitID: "ca-app-pub-3940256099942544/1712485313")
        newRewardedAd.load(GADRequest()) { error in
        if let error = error {
          print("Loading failed: \(error)")
            
          Notifications().showAlert(title: "Не можем загрузить видео", message: "Возможно, проблема с интернетом, попробуйте снова", buttonText: "Ок", view: self)
        } else {
            print("Loading Succeeded")
            self.stopActivityIndicator()
            
            if self.rewardedAdvideo?.isReady == true {
                guard self.readyToPresentAd else { return }
                self.rewardedAdvideo?.present(fromRootViewController: self, delegate:self)
            }
        }
      }
      return newRewardedAd
    }
    
    
//  MARK:- CollectionViewCompositionalLayout
    
    private lazy var compositionalLayout: UICollectionViewCompositionalLayout = {
        let layout = UICollectionViewCompositionalLayout { [weak self]
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            switch sectionIndex {
            case 0:
                return self?.setupRecomendationListSection()
            default:
                return self?.setupCategoryListSection()
            }
        }
        layout.register(BackgroundDecorationView.self,
        forDecorationViewOfKind: "background")
        
        return layout
    }()
    
    func setupCategoryListSection() -> NSCollectionLayoutSection {
        // 1. Creating section layout. Item -> Group -> Section
        // Item
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalHeight(1.0)))
        item.contentInsets = NSDirectionalEdgeInsets(top: 0.0,
                                                     leading: 8.0,
                                                     bottom: 0.0,
                                                     trailing: 8.0)

        // Group
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(140),
                                               heightDimension: .absolute(210)),
            subitem: item,
            count: 1)

        // Section
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 16.0,
                                                        leading: 0.0,
                                                        bottom: 16.0,
                                                        trailing: 0.0)

        // 2. Magic: Horizontal Scroll.
        section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary

        // 3. Creating header layout
        section.boundarySupplementaryItems = [headerViewSupplementaryItem]
        
        let backgroundItem = NSCollectionLayoutDecorationItem.background(elementKind: "background")
        section.decorationItems = [backgroundItem]
        
        return section
    }
    
    func setupRecomendationListSection() -> NSCollectionLayoutSection {
        // 1. Creating section layout. Item -> Group -> Section
        // Item
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalHeight(1.0)))
        item.contentInsets = NSDirectionalEdgeInsets(top: 0.0,
                                                     leading: 8.0,
                                                     bottom: 0.0,
                                                     trailing: 8.0)

        // Group
//        let group = NSCollectionLayoutGroup.vertical(
//            layoutSize: NSCollectionLayoutSize(widthDimension:                                                    .fractionalWidth(0.8),
//                                               heightDimension: .fractionalWidth(0.5)),
//                                                subitem: item,
//                                                count: 1)

        let group = NSCollectionLayoutGroup.vertical(
        layoutSize: NSCollectionLayoutSize(
                                            widthDimension:  .fractionalWidth(0.8),
                                            heightDimension: .fractionalWidth(0.5)),
                                            subitem: item,
                                            count: 1
                                            )
        
        // Section
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 16.0,
                                                        leading: 0.0,
                                                        bottom: 16.0,
                                                        trailing: 0.0)

//        section.offs
        
        // 2. Magic: Horizontal Scroll.
        section.orthogonalScrollingBehavior = .groupPagingCentered

        // 3. Creating header layout
        section.boundarySupplementaryItems = [headerViewSupplementaryItem]
        
        let backgroundItem = NSCollectionLayoutDecorationItem.background(elementKind: "background")
        section.decorationItems = [backgroundItem]
        
        return section
    }
    
    
//  Set section background color
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == "background" {
            view.backgroundColor = UIColor(hex: categories[indexPath.section].color)
        }

    }
    
    private lazy var headerViewSupplementaryItem: NSCollectionLayoutBoundarySupplementaryItem = {
        let headerViewItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.00),
                                               heightDimension: .absolute(44)),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top)
        headerViewItem.pinToVisibleBounds = false

        return headerViewItem
    }()
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.ref.removeAllObservers()
    }
}

//  MARK:- CollectionViewDelegateDataSource

extension CategoryListViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showStory", sender: self)
    }
    
    
//  Setup Category Header
    
    func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
      switch kind {
      case UICollectionView.elementKindSectionHeader:
        guard
          let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "sectionHeader",
            for: indexPath) as? SectionHeaderView
            
          else {
            fatalError("Invalid view type")
        }
            
        headerView.label.text = categories[indexPath.section].name
        
//        headerView.backgroundColor = #colorLiteral(red: 1, green: 0.9127054811, blue: 0, alpha: 0.5535875803)
        headerView.backgroundView.backgroundColor = .clear //#colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1) //#colorLiteral(red: 1, green: 0.9127054811, blue: 0, alpha: 0.5535875803)
        
        headerView.layer.cornerRadius = 8
        headerView.clipsToBounds = true
//        headerView.layer
//        footerView.layer.cornerRadius = 50
//        footerView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
//        footerView.clipsToBounds = true
        
        return headerView
      default:
        assert(false, "Invalid element type")
      }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.section {
            case 0:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recomendations", for: indexPath) as! RecomendationsCollectionViewCell

                cell.backgroundColor = .clear
                cell.layer.masksToBounds = false
                cell.layer.shadowOpacity = 0.23
                cell.layer.shadowRadius = 4
                cell.layer.shadowOffset = CGSize(width: 0, height: 0)
                cell.layer.shadowColor = UIColor.black.cgColor

                // add corner radius on `contentView`
                cell.contentView.backgroundColor = .clear //.white
                cell.contentView.layer.cornerRadius = 8
                
                
                cell.textLabel.text = "Vintage Tales Norman Clougu"
                cell.footerImageView.backgroundColor = #colorLiteral(red: 0.8011650443, green: 0.8013004661, blue: 0.8011472821, alpha: 0.5802489131)
                cell.backgroundImage.image = UIImage(named: "recomendations")
        
                return cell
            
            
        default:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "history", for: indexPath) as! HistoryCollectionViewCell

//                cell.backgroundColor = .clear
//                cell.layer.masksToBounds = false
//                cell.layer.shadowOpacity = 0.23
//                cell.layer.shadowRadius = 4
//                cell.layer.shadowOffset = CGSize(width: 0, height: 0)
//                cell.layer.shadowColor = UIColor.black.cgColor
                
                cell.historyImage.backgroundColor = .clear
                cell.historyImage.layer.masksToBounds = false
                cell.historyImage.clipsToBounds = true
                cell.historyImage.layer.shadowOpacity = 0.23
                cell.historyImage.layer.shadowRadius = 4
                cell.historyImage.layer.shadowOffset = CGSize(width: 0, height: 0)
                cell.historyImage.layer.shadowColor = UIColor.black.cgColor
                

                // add corner radius on 'contentView'
//                cell.contentView.layer.cornerRadius = 8
                
                cell.historyImage.layer.cornerRadius = 8
                
                cell.historyName.text = "Vintage Tales Norman Clougi"
                
                cell.historyImage.image = UIImage(named: "book-cover")
            
                return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.contentView.layer.masksToBounds = true
        let radius = cell.contentView.layer.cornerRadius
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: radius).cgPath
    }
}

extension UIColor {

    // MARK: - Initialization

    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0

        let length = hexSanitized.count
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0

            print("\n\nWithout alpha \n\n")
            
        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
            
            print("\n\nWith alpha: \(a)\n\n")

        } else {
            return nil
        }
        self.init(red: r, green: g, blue: b, alpha: a)
    }

    // MARK: - Computed Properties

    var toHex: String? {
        return toHex()
    }

    // MARK: - From UIColor to String

    func toHex(alpha: Bool = false) -> String? {
        guard let components = cgColor.components, components.count >= 3 else {
            return nil
        }

        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)

        if components.count >= 4 {
            a = Float(components[3])
            
            print("ALpha: \(a)")
        }

        if alpha {
            return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        } else {
            return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
    }

}
