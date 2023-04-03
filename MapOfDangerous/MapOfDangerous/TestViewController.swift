////
////  TestViewController.swift
////  MapOfDangerous
////
////  Created by 張文煥 on 2021/12/22.
////
//
//import UIKit
//
//class TestViewController: UIViewController {
//
//    @IBOutlet weak var testTableView: UITableView!
//    var dataTitle: String?
//    var data: DangerousDetailData?
//    var messageStr: String?
//    var model: DangerousModel?
//    var index: Int?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        testTableView.delegate = self
//        testTableView.dataSource = self
//        testTableView.register(UINib(nibName: "TitleTableViewCell", bundle: nil), forCellReuseIdentifier: TitleTableViewCell.reuseIdentifier)
//        testTableView.register(UINib(nibName: "DiscordTableViewCell", bundle: nil), forCellReuseIdentifier: DiscordTableViewCell.reuseIdentifier)
//
//        print("討論串的編號：\(String(describing: index))")
//
//
//        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "didAddMessage"), object: nil, queue: nil)  {
//            noti in
//            self.testTableView.reloadData()
//        }
//
//    }
//
//    deinit {
//        NotificationCenter.default.removeObserver(self)
//    }
//
//
//
//}
//
//extension TestViewController: UITableViewDelegate{
//
//}
//
//extension TestViewController: UITableViewDataSource{
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if let model = self.model {
//            guard let index = self.index else { return 1}
//            return model.getDiscussCount(row: index)+1
//        } else {
//            return 1
//        }
//
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if indexPath.row == 0 {
//            guard let cell = tableView.dequeueReusableCell(withIdentifier: TitleTableViewCell.reuseIdentifier, for: indexPath) as? TitleTableViewCell else{ return UITableViewCell() }
//            guard let data = data else { return UITableViewCell() }
//        //    guard let url = data.shotLink else { return UITableViewCell() }
//            cell.setData(title: data.title, type: data.type, describe: data.description, time: data.uploadTime, url: data.shotLink ?? nil)
//
//            return cell
//
//        } else {
//            guard let cell = tableView.dequeueReusableCell(withIdentifier: DiscordTableViewCell.reuseIdentifier, for: indexPath) as? DiscordTableViewCell else{
//                return UITableViewCell()
//            }
//            guard let model = self.model else { return UITableViewCell() }
//            guard let index = self.index else { return UITableViewCell() }
//
//            guard let data = model.getMessage(row: index, index: indexPath.row-1) else { return UITableViewCell() }
//
//            cell.setData(time: data.commentTime, message: data.comment)
//
//            return cell
//        }
//
//    }
//
//
//}
//
//extension TestViewController: UITextViewDelegate{
//    func textViewDidBeginEditing(_ textView: UITextView) {
//        textView.text = nil
//        textView.textColor = .black
//    }
//
//    func textViewDidEndEditing(_ textView: UITextView) {
//        self.messageStr = textView.text
//    }
//
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.view.endEditing(true)
//
//    }
//}
//
