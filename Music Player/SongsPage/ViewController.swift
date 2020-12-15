//
//  ViewController.swift
//  Music Player
//
//  Created by Muskan on 22/10/20.
//

import UIKit
import AVKit

class ViewController: UIViewController {
    

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var playButton: UIButton!
    
    var songs: [Song] = []

    //var transparentView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        print(AVPictureInPictureController.isPictureInPictureSupported())
        playButton.layer.cornerRadius = playButton.frame.size.height/2
    
        configure()
        
        self.navigationController?.isNavigationBarHidden = true
        
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = 70
        
        tableView.register(UINib(nibName: "SongsTableViewCell", bundle: nil), forCellReuseIdentifier: "songCell")
        
        }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        tableView.reloadData()
        
        let value = UIInterfaceOrientation.portrait.rawValue
                    UIDevice.current.setValue(value, forKey: "orientation")
        
        
    }
    
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var shouldAutorotate: Bool {
        return true
    }
    
      override public var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
      }
    
    func configure () {
        songs.append (Song(imageName: "badass", trackName: "badass", artistName: "Bensound"))
        songs.append (Song(imageName: "dubstep", trackName: "dubstep", artistName: "Bensound"))
        songs.append (Song(imageName: "energy", trackName: "energy", artistName: "Bensound"))
        songs.append (Song(imageName: "epic", trackName: "epic", artistName: "Bensound"))
        songs.append (Song(imageName: "funkysuspense", trackName: "funkysuspense", artistName: "Bensound"))
        songs.append (Song(imageName: "funnysong", trackName: "funnysong", artistName: "Bensound"))
        songs.append (Song(imageName: "onceagain", trackName: "onceagain", artistName: "Bensound"))
        songs.append (Song(imageName: "creativeminds", trackName: "creativeminds", artistName: "Bensound"))
        songs.append (Song(imageName: "sweet", trackName: "sweet", artistName: "Bensound"))
        
    }
    
    @IBAction func playPressed(_ sender: Any) {
        
        if let vc = storyboard?.instantiateViewController(withIdentifier: "songPlayer") as? SongViewController {
            
            
            vc.songs = songs
            vc.position = 0

            navigationController?.pushViewController(vc, animated: true)                                   
                       }    }
    
    }

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath) as! SongsTableViewCell
        
        cell.songName.text = songs[indexPath.row].trackName.capitalized
        cell.singerLabel.text = songs[indexPath.row].artistName.capitalized
        
        cell.songImage.layer.cornerRadius = 30
        
        cell.songImage.image = UIImage(named: songs[indexPath.row].imageName)
        
        cell.isSelected = false
        cell.isHighlighted = false
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        let cell = tableView.cellForRow(at: indexPath)
        cell?.alpha = 0.2
    
         DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 ) {
            cell?.alpha = 1.0
           
        
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "songPlayer") as? SongViewController {
            
            
            vc.songs = self.songs
            vc.position = indexPath.row

                self.navigationController?.pushViewController(vc, animated: true)
            
                                   
                       }
         }
    }
    
    
    
    
}

struct Song {
    let imageName: String
    let trackName: String
    let artistName: String
}
