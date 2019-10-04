//
//  DetailsViewController.swift
//  Mobile Test
//

import UIKit
import SDWebImage

class DetailsViewController:UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet var profileImageView:UIImageView!
    @IBOutlet var profileUsernameLabel:UILabel!
    @IBOutlet var profileEmailLabel:UILabel!
    @IBOutlet var followersTableView:UITableView!
    
    var profileImageURL=""
    var profileUsername=""
    var profileEmail=""
    var followersURL=""
    var followersArray=NSMutableArray()
    
    override func viewDidLoad()
    {
        self.title="Details"
        
        profileImageView.sd_setImage(with:URL(string:profileImageURL), placeholderImage:nil)
        profileUsernameLabel.text=profileUsername
        profileEmailLabel.text=profileEmail
        
        getFollowersFromAPI()
        
        super.viewDidLoad()
    }
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        return followersArray.count
    }
    
    func tableView(_ tableView:UITableView, cellForRowAt indexPath:IndexPath)->UITableViewCell
    {
        let cell=tableView.dequeueReusableCell(withIdentifier:"FollowersTableViewCell") as! FollowersTableViewCell
        
        cell.followerImageView.sd_setImage(with:URL(string:(followersArray[indexPath.row] as! Follower).followerImageURL), placeholderImage:nil)
        cell.followerUsernameLabel.text=(followersArray[indexPath.row] as! Follower).followerUsername
        
        return cell
    }
    
    func getFollowersFromAPI()
    {
        let apiURL=URL(string:followersURL)!
        
        let activityIndicatorView=UIActivityIndicatorView(style:.gray)
        activityIndicatorView.center=view.center
        activityIndicatorView.hidesWhenStopped=true
        view.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        
        let task=URLSession.shared.dataTask(with:apiURL){(data, response, error) in
            
            DispatchQueue.main.async{
                activityIndicatorView.stopAnimating()
                
                if let error=error
                {
                    print("error: \(error)")
                }
                else
                {
                    if let response=response as? HTTPURLResponse
                    {
                        if response.statusCode==404
                        {
                            return
                        }
                    }
                    if let data=data
                    {
                        let tempFollowersArray=try! JSONSerialization.jsonObject(with:data, options:[]) as! NSArray
                        
                        for tempFollower in tempFollowersArray
                        {
                            let tempFollowerDic=tempFollower as! NSDictionary
                            
                            let follower=Follower()
                            follower.followerImageURL=tempFollowerDic["avatar_url"] as! String
                            follower.followerUsername=tempFollowerDic["login"] as! String
                            
                            self.followersArray.add(follower)
                        }
                        
                        self.followersTableView.reloadData()
                    }
                }
            }
        }
        task.resume()
    }
}
