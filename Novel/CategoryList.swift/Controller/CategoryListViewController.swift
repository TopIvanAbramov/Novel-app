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
        
        createCategories()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tabBarController?.title = "Истории"
        
        self.ref.observe(.value, with: {[weak self] (snapshot) in
            var _categories = Array<Category>()
            for item in snapshot.children {
                let category = Category(snapshot: item as! DataSnapshot)
                _categories.append(category)
            }
            
            self?.categories = _categories
            self?.collectionView.reloadData()
        })
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
    
//    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
//
////        Log.printLog(identifier: elementKind, message: indexPath)
//        if elementKind == UICollectionView.elementKindSectionHeader, let view = view as? UIView {
//
//            view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
//        } else if elementKind == SectionView.kind {
//            
//            view.backgroundColor = UIColor(hex: categories[indexPath.section].color)
////            let evenSectionColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
////            let oddSectionColor = #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1)
////
////            view.backgroundColor = (indexPath.section % 2 == 0) ? evenSectionColor : oddSectionColor
//        }
//    }
    
    
    private lazy var compositionalLayout: UICollectionViewCompositionalLayout = {
        let layout = UICollectionViewCompositionalLayout { [weak self]
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
//            switch sectionIndex) {
//            case .brandNames:
                return self?.setupCategoryListSection()
//            case .catFoods:
//                return self?.setupCatFoodsSection()
//            case .cats:
//                return self?.setupCatsSection()
//            case .none:
//                fatalError("Should not be none ")
//            }
        }
        
//        let backgroundView = BackgroundDecorationView()
//        backgroundView.backgroundColor = .red
        
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
            layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(120),
                                               heightDimension: .absolute(150)),
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
    
    
//  Set section background color
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == "background" {
            view.backgroundColor =  UIColor(hex: categories[indexPath.section].color)
        }

    }
    
    private lazy var headerViewSupplementaryItem: NSCollectionLayoutBoundarySupplementaryItem = {
        let headerViewItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
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
        
        return headerView
      default:
        assert(false, "Invalid element type")
      }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "history", for: indexPath) as! HistoryCollectionViewCell

        cell.backgroundColor = .white
        cell.historyName.text = "История"
        
        cell.historyImage.image = UIImage(named: "book-cover")
        
        return cell
    }
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
