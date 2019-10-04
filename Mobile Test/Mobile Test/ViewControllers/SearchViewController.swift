//
//  SearchViewController.swift
//  Mobile Test
//

import UIKit

class SearchViewController:UIViewController, UITextFieldDelegate
{
    @IBOutlet var searchTextField:UITextField!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated:Bool)
    {
        super.viewWillAppear(animated)
        searchTextField.text=""
    }
    
    @IBAction func search()
    {
        if searchTextField.text != ""
        {
            searchTextField.resignFirstResponder()
            getProfileFromAPI()
        }
        else
        {
            showAlert("Please enter username or email")
        }
    }
    
    func textFieldShouldReturn(_ textField:UITextField)->Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    func showAlert(_ message:String)
    {
        let alertController=UIAlertController(title:"Message", message:message, preferredStyle:.alert)
        alertController.addAction(UIAlertAction(title:"OK", style:.cancel, handler:nil))
        present(alertController, animated:true)
    }
    
    func getProfileFromAPI()
    {
        let apiURL=URL(string:"https://api.github.com/users/"+searchTextField.text!)!
        
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
                            self.showAlert("Not Found")
                            return
                        }
                    }
                    if let data=data
                    {
                        let tempDic=try! JSONSerialization.jsonObject(with:data, options:[]) as! NSDictionary
                        
                        let storyboard=UIStoryboard(name:"Main", bundle:nil)
                        let DVC=storyboard.instantiateViewController(withIdentifier:"DetailsViewController") as! DetailsViewController
                        DVC.profileImageURL=tempDic["avatar_url"] as! String
                        DVC.profileUsername=tempDic["login"] as! String
                        
                        if let value=tempDic["email"] as? String
                        {
                            DVC.profileEmail=value
                        }
                        else
                        {
                            DVC.profileEmail="N/A"
                        }
                        
                        DVC.followersURL=tempDic["followers_url"] as! String
                        self.navigationController?.pushViewController(DVC, animated:true)
                    }
                }
            }
        }
        task.resume()
    }
}
