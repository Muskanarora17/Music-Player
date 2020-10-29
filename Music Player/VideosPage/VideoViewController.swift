//
//  VideoViewController.swift
//  TuneIn
//
//  Created by Muskan on 28/10/20.
//

import UIKit
import AVKit

class VideoViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let videos = ["Pexels", "Colorful Ferris Wheel in Motion","Aerial Shot Of Seacoast"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = 70
        
        tableView.register(UINib(nibName: "VideoTableViewCell", bundle: nil), forCellReuseIdentifier: "video")
        
        
    }
    

}

extension VideoViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "video", for: indexPath) as! VideoTableViewCell
        
        cell.label.text = videos[indexPath.row]
        
        cell.videoImage.layer.cornerRadius = 30
        
        cell.isSelected = false
        cell.isHighlighted = false
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        let cell = tableView.cellForRow(at: indexPath)
        
        let video = cell?.textLabel?.text
        let player = AVPlayer(url: URL(fileURLWithPath: Bundle.main.path(forResource: video, ofType: "mp4")!))
//                let layer = AVPlayerLayer(player: player)
//                layer.frame = view.bounds
//                layer.videoGravity = .resizeAspectFill
//                view.layer.addSublayer(layer)
//                player.volume = 0
//                player.play()
        let vc = AVPlayerViewController()
                vc.player = player
                present(vc, animated: true)
        
        
    }
    
    
    
    
}
