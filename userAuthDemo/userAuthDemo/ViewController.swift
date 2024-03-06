//
//  ViewController.swift
//  userAuthDemo
//
//  Created by Rakesh Shrestha on 05/03/2024.
//

import UIKit
import FacebookLogin
import FBSDKCoreKit
import GoogleSignIn
import AuthenticationServices

class ViewController: UIViewController {
    
    
    @IBOutlet weak var loginText: UILabel!
    
    @IBOutlet weak var googleButton: UIButton!
    
    @IBOutlet weak var appleButton: UIButton!
    
    @IBOutlet weak var fbButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func pressedFbButton(_ sender: Any) {
        if let token = AccessToken.current,
                !token.isExpired {
                // User is logged in, do work such as go to next view controller.
            print("Access token: \(token.tokenString)")
            self.fetchUserFbProfile()
            }
        else{
            fbLogin()
        }
    }
    
    @IBAction func pressedGoogleButton(_ sender: Any) {
        print("logged in with google")
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if error != nil || user == nil {
              // Show the app's signed-out state.
                GIDSignIn.sharedInstance.signIn(withPresenting: self) { signInResult, error in
                    guard error == nil else { return }

                    // If sign in succeeded, display the app's main content View.
                    guard let signInResult = signInResult else { return }
                    self.loginText.text = "\(signInResult.user.profile?.name) has logged in from Google"
                  }
            } else {
              // Show the app's signed-in state.
                guard let user = user else { return }
                print("googleUser is signed in")
                self.loginText.text = "\(user.profile!.name) has logged in from Google"
                
            }
          }
    }
    
    @IBAction func pressedAppleButton(_ sender: Any) {
        let appleIDDetails = ASAuthorizationAppleIDProvider()
        let request = appleIDDetails.createRequest()
        request.requestedScopes = [.email, .fullName]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.performRequests()
    }
    
    func fbLogin() {
        let loginManager = LoginManager()
                loginManager.logIn(permissions: ["public_profile"], from: self) { result, error in
                    if let error = error {
                        print("Encountered Erorr: \(error)")
                    } else if let result = result, result.isCancelled {
                        print("Cancelled")
                    } else {
                        print("Logged In")
                        self.fetchUserFbProfile()
                    }
                }
    }
    
    func fetchUserFbProfile()
        {
            let graphRequest : GraphRequest = GraphRequest(graphPath: "me", parameters: ["fields":"id, email, name, picture.width(480).height(480)"])
            
            graphRequest.start(completionHandler: { (connection, result, error) -> Void in
                
                if ((error) != nil)
                {
                    print("Error took place: \(error)")
                }
                else if let resultDict = result as? [String: Any], let profileName = resultDict["name"] as? String {
                    // Assuming nameLabel is your UILabel outlet
                    self.loginText.text = "\(profileName) has logged in with fb"
                    }
                })
            }
        }

extension ViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            let userIdentifier = appleIDCredential.user
            print(appleIDCredential.fullName)
            break
        default:
            break
        }
    }
}
