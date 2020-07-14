//
//  HistoryListTableViewCell.swift
//  Novel
//
//  Created by Иван Абрамов on 12.07.2020.
//  Copyright © 2020 Иван Абрамов. All rights reserved.
//

import UIKit

class CategoryListTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    var dataSourceDelegate: UICollectionViewDataSource?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        print("\n\nAwake from nib\n\n")
        
        registerCell()
    }

    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configure(withCategory category: Category) {
//        DispatchQueue.main.async {
//            self.collectionView.register(HistoryCollectionViewCell.self, forCellWithReuseIdentifier: "history")
//
//            self.collectionView.reloadData()
//        }
    }
    
    func registerCell() {
        self.collectionView.register(HistoryCollectionViewCell.self, forCellWithReuseIdentifier: "history")
    }
    
    func setCollectionViewDataSourceDelegate(dataSourceDelegate: UICollectionViewDataSource & UICollectionViewDelegate) {
        
        print("set dalaegate&datasource for collectionView")
        DispatchQueue.main.async {
            self.collectionView.delegate = dataSourceDelegate
            self.collectionView.dataSource = dataSourceDelegate
//            self.collectionView.tag = row
            self.collectionView.reloadData()
        }
       }
}

extension CategoryListTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "history", for: indexPath) as! HistoryCollectionViewCell
        
        cell.backgroundColor = .red
        cell.historyName.text = "Temp"
        
        print("\n\nConfigure collection cell\n\n")
        
        return cell
    }
    
    
}
