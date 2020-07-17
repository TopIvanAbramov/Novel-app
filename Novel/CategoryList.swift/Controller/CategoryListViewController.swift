//
//  HistoryListViewController.swift
//  Novel
//
//  Created by Иван Абрамов on  12.07.2020.
//  Copyright © 2020 Иван Абрамов. All rights reserved.
//

import UIKit
import Firebase

class CategoryListViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var ref: DatabaseReference!
    var user: AppUser!
    var categories = Array<Category>()
    


//    MARK: - ViewLifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let currentUser = Auth.auth().currentUser else { return }
        user = AppUser(user: currentUser)
        ref = Database.database().reference(withPath: "categories")
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = compositionalLayout
        
        self.addreferalBonus()
        
//        startAutomaticScrolling()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tabBarController?.title = "Истории"
        
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
           
            
            self?.collectionView.reloadData()
        })
        
//        startAutomaticScrolling()
    }
    
    
    func addreferalBonus() {
        let userRef = Database.database().reference(withPath: "users")
        
        userRef.child("\(user.uid)").observeSingleEvent(of: .value, with: {(snapshot) in
            let user = AppUser(snapshot: snapshot)
            if !(user.didAddreferalBonus) {
                _ = getBonuses(completion: { bonuses in
                    
                    userRef.child("\(user.uid)/ticketCurrency").setValue((user.ticketCurrency) + bonuses.referalBonuse)
                    userRef.child("\(user.uid)/didAddreferalBonus").setValue(true)
                    
                    userRef.child("\(user.refCode)").observeSingleEvent(of: .value, with: {(snapshot) in
                        if snapshot.exists() {
                            let user = AppUser(snapshot: snapshot)
                            userRef.child("\(user.refCode)/ticketCurrency").setValue((user.ticketCurrency) + bonuses.referalBonuse)
                        }
                    })

                })
            }
        })
    }
    
    func startAutomaticScrolling() {

        _ =  Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.scrollAutomatically), userInfo: nil, repeats: true)
    }


    @objc func scrollAutomatically(_ timer1: Timer) {

        if let coll  = collectionView {
            for cell in coll.visibleCells.filter({ (cell) -> Bool in
                if coll.indexPath(for: cell)?.section == 1 {
                    return true
                } else {
                    return false
                }
            }) {
                let indexPath: IndexPath? = coll.indexPath(for: cell)
                
//                print("Timer: \(indexPath?.row) \(indexPath?.section)")
                
                if ((indexPath?.row)! < 10 - 1){
                    let indexPath1 = IndexPath.init(row: (indexPath?.row)! + 1, section: (indexPath?.section)!)

                    coll.scrollToItem(at: indexPath1, at: .right, animated: true)
                    
                } else {
                    let indexPath1 = IndexPath.init(row: 0, section: (indexPath?.section)!)
                    coll.scrollToItem(at: indexPath1, at: .left, animated: true)
                }

            }
        }
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
                                                        leading: 10.0,
                                                        bottom: 16.0,
                                                        trailing: 50.0)

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
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.8),
                                               heightDimension: .fractionalWidth(0.5)),
            subitem: item,
            count: 1)

        // Section
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 16.0,
                                                        leading: 10.0,
                                                        bottom: 16.0,
                                                        trailing: 50.0)

        // 2. Magic: Horizontal Scroll.
        section.orthogonalScrollingBehavior = .groupPaging //.continuousGroupLeadingBoundary

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
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.06),
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
        
        headerView.backgroundColor = #colorLiteral(red: 1, green: 0.9127054811, blue: 0, alpha: 0.5535875803)
        
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
                cell.contentView.backgroundColor = .white
                cell.contentView.layer.cornerRadius = 8
                
                
                cell.textLabel.text = "Vintage Tales Norman Clougu"
                cell.footerImageView.backgroundColor = #colorLiteral(red: 0.8011650443, green: 0.8013004661, blue: 0.8011472821, alpha: 0.5802489131)
                cell.backgroundImage.image = UIImage(named: "recomendations")
        
                return cell
            
            
        default:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "history", for: indexPath) as! HistoryCollectionViewCell

                cell.backgroundColor = .clear
                cell.layer.masksToBounds = false
                cell.layer.shadowOpacity = 0.23
                cell.layer.shadowRadius = 4
                cell.layer.shadowOffset = CGSize(width: 0, height: 0)
                cell.layer.shadowColor = UIColor.black.cgColor

                // add corner radius on `contentView`
                cell.contentView.backgroundColor = .white
                cell.contentView.layer.cornerRadius = 8
                
                
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
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//
//        let insets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 100)
//
//        return insets
//    }
}

extension UIColor {

    // MARK: - Initialization

    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt32 = 0

        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0

        let length = hexSanitized.count

        guard Scanner(string: hexSanitized).scanHexInt32(&rgb) else { return nil }

        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0

        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0

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
        }

        if alpha {
            return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        } else {
            return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
    }

}
