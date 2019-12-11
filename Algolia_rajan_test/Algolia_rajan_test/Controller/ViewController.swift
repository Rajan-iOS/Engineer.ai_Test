//
//  ViewController.swift
//  Algolia_rajan_test
//
//  Created by PCQ143 on 11/12/19.
//  Copyright © 2019 tatvasoft. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController {

    //MARK:- Outlets
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet var footerView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK:- Variable
    var pagecount = 0
    var arrayPost: [PostDetails] = []
    var isPageCompleted = false
    
    var refreshController: UIRefreshControl?
    
    //MARK:- Life cycle method
    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepareView()
    }
    
    //MARK:- View methods
    private func prepareView() {
        self.pagecount = 0
        self.callAPI()
        
        // set Navigation title
        self.setNavigationTitle()
 
        // add pull to refresh
        self.addRefreshController()
    }
    
    //MARK:- refresh controller method
    private func addRefreshController() {
        if self.refreshController == nil {
            refreshController = UIRefreshControl()
            
            self.tblView.refreshControl = refreshController
            self.refreshController?.addTarget(self, action: #selector(self.pullToRefresh), for: .valueChanged)
        }
    }
    
    @objc private func pullToRefresh() {
        self.pagecount = 0
        self.callAPI()
    }
    
    //MARK:- Web service method
    private func callAPI() {
        let url = "https://hn.algolia.com/api/v1/search_by_date?tags=story&page=" + "\(self.pagecount)"
        
        //Network indicater
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            switch response.result{
            case .success(let value):
                let json = JSON(value)
                if self.pagecount == 0 {
                    self.refreshController?.endRefreshing()
                    self.arrayPost.removeAll()
                    self.setNavigationTitle()
                }
                
                if let httpStatusCode = response.response?.statusCode {
                    switch httpStatusCode {
                    case 200:
                        let postList = json["hits"].arrayValue
                        let totalCount = json["nbPages"].intValue
                        
                        if self.pagecount < totalCount {
                            self.isPageCompleted = false
                            for index in 0..<postList.count {
                                let dictPost = JSON(postList[index].dictionaryValue)
                                let post = PostDetails(parameter: dictPost)
                                self.arrayPost.append(post)
                            }
                            self.activityIndicator.stopAnimating()
                        } else {
                            self.isPageCompleted = true
                        }
                        self.tblView.reloadData()
                        break
                    default:
                        break
                    }
                }
                
            case .failure(let error):
                self.refreshController?.endRefreshing()
                print(error.localizedDescription)
                break
            }
        }
    }
    
    //MARK:- helper method
    
    private func setNavigationTitle() {
        let filterArray = self.arrayPost.filter({$0.isPostSelected == true})
        
        if filterArray.count == 0 {
            self.title = "Number of selected post: 0"
        } else {
            self.title = filterArray.count > 1 ? "Number of selected posts: " + "\(filterArray.count)" : "Number of selected post: " + "\(filterArray.count)"
        }
    }
}

extension ViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayPost.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlgoliaCell", for: indexPath) as! AlgoliaCell
        
        let objPostDetail = self.arrayPost[indexPath.row]
        cell.lblTitle.text = objPostDetail.title
        cell.lblDate.text = objPostDetail.createdDate
        cell.toggleSwitch.isOn = objPostDetail.isPostSelected
        cell.backgroundColor = objPostDetail.isPostSelected ? UIColor.lightGray : UIColor.white
        
        if indexPath.row == self.arrayPost.count - 1 && !self.isPageCompleted {
            self.pagecount = self.pagecount + 1
            activityIndicator.startAnimating()
            self.callAPI()
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = self.arrayPost[indexPath.row]
        post.isPostSelected = !post.isPostSelected
        tableView.reloadRows(at: [indexPath], with: .automatic)
        self.setNavigationTitle()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if isPageCompleted == true || self.arrayPost.count == 0 {
            return UIView()
        }
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if isPageCompleted == true || self.arrayPost.count == 0 {
            return 0.0001
        }
        return 70
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0001
    }
}

class AlgoliaCell: UITableViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var toggleSwitch: UISwitch!
    
}
