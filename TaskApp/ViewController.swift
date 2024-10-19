//
//  ViewController.swift
//  TaskApp
//
//  Created by mba2408.starlight kyoei.engine on 2024/10/17.
//

import UIKit
import RealmSwift   // ←追加
import UserNotifications    // 追加

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchField: UISearchBar!
    
    // Realmインスタンスを取得する
    let realm = try! Realm()  // ←追加

    // DB内のタスクが格納されるリスト。
    // 日付の近い順でソート：昇順
    // 以降内容をアップデートするとリスト内は自動的に更新される。
//    var searchCondition:String = ""
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)  // ←追加
//    var isSearch:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.fillerRowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        searchField.delegate = self
    }
    
    // segue で画面遷移する時に呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let inputViewController:InputViewController = segue.destination as! InputViewController

        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        } else {
            inputViewController.task = Task()
        }
    }
    
    // 入力画面から戻ってきた時に TableView を更新させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let searchCondition:String! = searchBar.text
        let latestTasks = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
        tableView.reloadData()
        if searchCondition == "" {
            taskArray = latestTasks
            tableView.reloadData()
        } else {
            taskArray = latestTasks.where({ $0.category.contains(searchCondition) }).sorted(byKeyPath: "date", ascending: true)
            tableView.reloadData()
        }
    }
    
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if isSearch {
//            return searchResult.count
//        } else {
//            return taskArray.count  // ←修正する
//        }
        return taskArray.count
    }

    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        // Cellに値を設定する  --- ここから ---
        var task = taskArray[indexPath.row]
        
//        if isSearch {
//            task = searchResult[indexPath.row]
//        }
        
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateString:String = formatter.string(from: task.date)
        content.secondaryText = "#" + task.category + "　" + dateString
        cell.contentConfiguration = content
        // --- ここまで追加 ---

        return cell
    }

    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue",sender: nil) // ←追加
    }

    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
        return .delete
    }

    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        try! realm.write {
//            self.realm.delete(self.taskArray[indexPath.row])
//            tableView.deleteRows(at: [indexPath], with: .fade)
//        }
        // --- ここから ---
//        if editingStyle == .delete {
//            // データベースから削除する
//            try! realm.write {
//                self.realm.delete(self.taskArray[indexPath.row])
//                tableView.deleteRows(at: [indexPath], with: .fade)
//            }
//        } // --- ここまで追加 ---
        // --- ここから ---
        if editingStyle == .delete {
            // 削除するタスクを取得する
            let task = self.taskArray[indexPath.row]

            // ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id.stringValue)])

            // データベースから削除する
            try! realm.write {
                self.realm.delete(task)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }

            // 未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
            }
        } // --- ここまで変更 ---
    }


}

//extension ViewController: UITableViewDelegate {
//    // UITableViewからdelegateプロパティを経由して呼び出される
//    func tableView(_tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        
//    }
//}
//
//extension ViewController: UITableViewDataSource {
//    // UITableViewからdelegateプロパティを経由して呼び出される
//    func tableView(_tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return taskArray.count  // ←修正する
//    }
//}
        
