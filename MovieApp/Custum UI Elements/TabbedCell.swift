//
//  TabbedCell.swift
//  MovieApp
//
//  Created by Lucas Longarini on 2018-11-26.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import UIKit

protocol TabbedCellDelegate {
    func movieTapped(movie:Movie, image: UIImage)
    func tvTapped(tv:Tv, image: UIImage)
}

class TabbedCell: UICollectionViewCell, UITableViewDelegate, UITableViewDataSource, InfoCellDelegate {
    
    @IBOutlet weak var noResultsLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var headerView: UIView!
    var pictureView: UIImageView!
    var delegate: TabbedCellDelegate?
    
    //data
    var cellIndex:Int = -1
    var allPersonInfo:AllPersonInfo?
    var personCredits:PersonCredits?
    
    //second cell segment
    var segmentedControl:TabbedSegmentedControl?
    
    var picCenterY:NSLayoutConstraint?
    var shadowCenterY:NSLayoutConstraint?

    override func awakeFromNib() {
        super.awakeFromNib()        
        tableView.delegate = self
        tableView.dataSource = self
        headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 200))
        headerView.backgroundColor = UIColor.clear
        tableView.tableHeaderView = headerView
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.rowHeight = UITableView.automaticDimension;
        self.tableView.estimatedRowHeight = 44.0;
        pictureView = UIImageView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
        pictureView.layer.cornerRadius = pictureView.frame.height / 2
        pictureView.clipsToBounds = true
        pictureView.image = UIImage(named: "Person Placeholder Image")
        pictureView.contentMode = .scaleAspectFill
        pictureView.backgroundColor = UIColor.white
        headerView.addSubview(pictureView)
        pictureView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint(item: pictureView, attribute: .centerX, relatedBy: .equal, toItem: self.headerView, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        picCenterY = NSLayoutConstraint(item: pictureView, attribute: .centerY, relatedBy: .equal, toItem: self.headerView, attribute: .centerY, multiplier: 1, constant: 0)
        picCenterY!.isActive = true
        NSLayoutConstraint(item: pictureView, attribute: .width, relatedBy: .equal,
            toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 150).isActive = true
        NSLayoutConstraint(item: pictureView, attribute: .height, relatedBy: .equal,
            toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 150).isActive = true
        
        let shadowView = UIView(frame: pictureView.frame)
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.insertSubview(shadowView, belowSubview: pictureView)
        NSLayoutConstraint(item: shadowView, attribute: .centerX, relatedBy: .equal, toItem: self.headerView, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        shadowCenterY = NSLayoutConstraint(item: shadowView, attribute: .centerY, relatedBy: .equal, toItem: self.headerView, attribute: .centerY, multiplier: 1, constant: 0)
        shadowCenterY!.isActive = true
        NSLayoutConstraint(item: shadowView, attribute: .width, relatedBy: .equal,
                           toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 150).isActive = true
        NSLayoutConstraint(item: shadowView, attribute: .height, relatedBy: .equal,
                           toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 150).isActive = true
        shadowView.layer.cornerRadius = shadowView.frame.height / 2
        shadowView.backgroundColor = UIColor.clear
        shadowView.addCircleShadow()
        
    }

    func setImage(image:UIImage?){
        guard let image = image else{return}
        pictureView.image = image
    }
        
    func setSegmentControl(){
        headerView.frame.size.height = 240
        if cellIndex != 1 {return}
        segmentedControl = TabbedSegmentedControl()
        headerView.addSubview(segmentedControl!)
        picCenterY!.constant = -10
        shadowCenterY!.constant = -10
        
        segmentedControl?.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl?.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -4).isActive = true
        segmentedControl?.leadingAnchor.constraint(equalTo: pictureView.leadingAnchor, constant: -60).isActive = true
        segmentedControl?.trailingAnchor.constraint(equalTo: pictureView.trailingAnchor, constant: 60).isActive = true
        
        segmentedControl?.commaSeperatedButtons = "Movies,Tv-Shows"
        segmentedControl?.fontSize = 20
        segmentedControl?.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)

    }
    
    @objc func segmentChanged(){
        self.tableView.reloadData()
        if cellIndex == 1{
            switch self.segmentedControl?.selectedSegmentIndex{
            case 0:
                if self.personCredits?.movies?.count ?? 0 == 0{
                    self.noResultsLabel.alpha = 1
                }
                else{
                    self.noResultsLabel.alpha = 0
                }
            case 1:
                if self.personCredits?.tv?.count ?? 0 == 0{
                    self.noResultsLabel.alpha = 1
                }
                else{
                    self.noResultsLabel.alpha = 0
                }
            default:
                break;
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch cellIndex {
        case 0:
            if let info = allPersonInfo{
                if info.deathday == nil{return 5}
                else{return 6}
            }
            return 0
        case 1:
            guard let credits = self.personCredits else{return 0}
            switch segmentedControl?.selectedSegmentIndex{
            case 0:
                return credits.movies?.count ?? 0
            case 1:
                return credits.tv?.count ?? 0
            default:
                return 0
            }

        default:
            return 0
        }

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch cellIndex{
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath)
            
            cell.detailTextLabel?.numberOfLines = 0
            cell.detailTextLabel?.lineBreakMode = .byWordWrapping
            cell.detailTextLabel?.font = cell.detailTextLabel?.font.withSize(15)
            cell.textLabel?.font = cell.textLabel?.font.withSize(14)
            cell.textLabel?.textColor = UIColor.lightGray

            if let info = allPersonInfo{
                switch indexPath.row{
                case 0:
                    cell.textLabel?.text = "Name"
                    cell.detailTextLabel?.text = info.name ?? "Not Available"
                case 1:
                    if info.deathday != nil && info.deathday != ""{
                        cell.textLabel?.text = "Age of Death"
                        if let deathDay = info.deathday, let birthday = info.birthday{
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-mm-dd"
                            let dday = dateFormatter.date(from: deathDay)
                            let bday = dateFormatter.date(from: birthday)
                            let age = Calendar.current.dateComponents([.year], from: bday!, to: dday!).year!
                            cell.detailTextLabel?.text = "\(age)"
                        }else{cell.detailTextLabel?.text = "Not Available"}
                    }
                    else{
                        cell.textLabel?.text = "Age"
                        if let birthday = info.birthday{
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-mm-dd"
                            let bday = dateFormatter.date(from: birthday)
                            let age = Calendar.current.dateComponents([.year], from: bday!, to: Date()).year!
                            cell.detailTextLabel?.text = "\(age)"
                    
                        }else{cell.detailTextLabel?.text = "Not Available"}
                    }
                case 2:
                    cell.textLabel?.text = "Birthday"
                    if let birthday = info.birthday{
                        let inputDateFormatter = DateFormatter()
                        inputDateFormatter.dateFormat = "yyyy-mm-dd"
                        let bday = inputDateFormatter.date(from:birthday)
                        
                        if bday != nil{
                            let outputDateFormatter = DateFormatter()
                            outputDateFormatter.dateFormat = "MMMM DD, yyy"
                            let newDate = outputDateFormatter.string(from: bday!)
                            cell.detailTextLabel?.text = newDate
                        }
                        else{cell.detailTextLabel?.text = "Not Available"}
                        
                    }else{cell.detailTextLabel?.text = "Not Available"}
                case 3:
                    if let deathDay = info.deathday{
                        cell.textLabel?.text = "Died"
                        let inputDateFormatter = DateFormatter()
                        inputDateFormatter.dateFormat = "yyyy-mm-dd"
                        let dday = inputDateFormatter.date(from: deathDay)
                        
                        if dday != nil{
                            let outputDateFormatter = DateFormatter()
                            outputDateFormatter.dateFormat = "MMMM DD, yyy"
                            let newDate = outputDateFormatter.string(from: dday!)
                            cell.detailTextLabel?.text = newDate
                        }else{cell.detailTextLabel?.text = "Not Available"}
                    }
                    else{
                        cell.textLabel?.text = "From"
                        cell.detailTextLabel?.text = info.placeOfBirth ?? "Not Available"
                    }
                case 4:
                    if info.deathday != nil {
                        cell.textLabel?.text = "From"
                        cell.detailTextLabel?.text = info.placeOfBirth ?? "Not Available"
                    }
                    else{
                        cell.textLabel?.text = "Biography"
                        if let bio = info.biography{
                            if bio == ""{cell.detailTextLabel?.text = "Not Available"}
                            else{cell.detailTextLabel?.text = bio}
                        }
                        else{cell.detailTextLabel?.text = "Not Available"}
                    }
                case 5:
                    if info.deathday != nil{
                        cell.textLabel?.text = "Biography"
                        if let bio = info.biography{
                            if bio == ""{cell.detailTextLabel?.text = "Not Available"}
                            else{cell.detailTextLabel?.text = bio}
                        }
                        else{cell.detailTextLabel?.text = "Not Available"}
                    }
                default:
                    break;
                }
            }

            return cell

        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MediaInfo", for: indexPath) as! InfoCellTableViewCell
            cell.picture.image = UIImage(named: "Image Place Holder")!
            cell.cellIndex = indexPath.row
            switch segmentedControl?.selectedSegmentIndex{
            case 0:
                guard let movies = self.personCredits?.movies else{break}
                let movie = movies[indexPath.row]
                cell.titleLabel?.text = movie.title
                if movie.releaseDate == ""{cell.yearLabel?.text = "Not Available"}
                else{cell.yearLabel?.text = String(movie.releaseDate.prefix(4))}
                if let imageUrl = movie.posterPath{
                    cell.picture?.loadImageUsingCache(urlString: "https://image.tmdb.org/t/p/w185\(imageUrl)")
                }
                cell.mediaType = .movie
                cell.delegate = self
            case 1:
                guard let shows = self.personCredits?.tv else{break}
                let tv = shows[indexPath.row]
                cell.titleLabel?.text = tv.name
                if tv.firstAirDate == ""{cell.yearLabel?.text = "Not Available"}
                else{cell.yearLabel?.text = String(tv.firstAirDate.prefix(4))}
                if let imageUrl = tv.posterPath{
                    cell.picture?.loadImageUsingCache(urlString: "https://image.tmdb.org/t/p/w185\(imageUrl)")
                }
                cell.mediaType = .tv
                cell.delegate = self
            default:
                break;
            }
            return cell
        default:
            return UITableViewCell(style: .default, reuseIdentifier: "default")
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if cellIndex == 1{return 90}
        return UITableView.automaticDimension
    }
    
    func cellTapped(index: Int, mediaType: MediaType) {
        guard let delegate = self.delegate else{return}
        let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as! InfoCellTableViewCell
        let imageToSend:UIImage = cell.picture.image ?? UIImage(named: "Image Place Holder")!
        switch mediaType {
        case .movie:
            guard let movie = self.personCredits?.movies else {return}
            delegate.movieTapped(movie: movie[index], image: imageToSend)
        case .tv:
            guard let tv = self.personCredits?.tv else{return}
            delegate.tvTapped(tv: tv[index], image: imageToSend)
        }
    }
    
}

