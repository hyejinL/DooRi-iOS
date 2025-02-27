//
//  AddTripViewController.swift
//  DooRiBon
//
//  Created by 한상진 on 2021/07/02.
//

import UIKit

class AddTripViewController: UIViewController {
    
    //MARK:- IBOutlet
    /// Scroll View
    @IBOutlet weak var scrollView: UIScrollView!
    
    /// Label
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    /// TextField
    @IBOutlet weak var tripNameTextField: UITextField!
    @IBOutlet weak var tripLocationTextField: UITextField!
    
    /// Button
    @IBOutlet weak var startNewTripButton: UIButton!
    
    /// View
    @IBOutlet weak var startDateView: UIView!
    @IBOutlet weak var endDateView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var mainView: UIView!
    
    //MARK:- Variable
    
    var photoUrlList: [String] = []
    var photoIsSelected = false
    var selectCheck = false
    var selectedIndex: Int?
    var startDateParsing: String?
    var endDateParsing: String?
    var topLabelData: String = ""
    var buttonData: String = ""
    var groupId: String = ""
    static var code: String = ""
    
    //MARK:- Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        photoListSet()
        bottomShadowSet()
        notificationSet()
        registerForKeyboardNotifications()
        
        scrollView.keyboardDismissMode = .onDrag
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    //MARK:- IBAction
    
    @IBAction func addDateButtonClicked(_ sender: Any) {
        let addDateStoryboard = UIStoryboard(name: "AddDateStoryboard", bundle: nil)
        guard let nextVC = addDateStoryboard.instantiateViewController(identifier: "AddDateViewController") as? AddDateViewController else { return }
        nextVC.modalPresentationStyle = .fullScreen
        nextVC.delegate = self
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- Function
    
    /// 추후 서버 연동시 변경될 함수입니다.
    func configureUI() {
        if topLabelData != "" {
            topLabel.text = topLabelData
            startNewTripButton.setTitle(buttonData, for: .normal)
        }
    }
    
    func photoListSet() {
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        photoCollectionView.register((UINib(nibName: "PhotoCollectionViewCell", bundle: nil)), forCellWithReuseIdentifier: "photoCell")
        AddTripImageService.shared.getData { (result) in
            switch(result)
            {
            case .success(let imageObject):
                if let image = imageObject as? AddTripImageResponse {
                    self.photoUrlList = image.data
                    self.photoCollectionView.reloadData()
                }
            case .requestErr(_):
                return
            case .pathErr:
                return
            case .serverErr:
                return
            case .networkFail:
                return
            }
        }
    }
    
    func notificationSet() {
        NotificationCenter.default.addObserver(self, selector: #selector(checking), name: UITextField.textDidChangeNotification, object: nil)
    }
    
    func bottomShadowSet() {
        bottomView.layer.applyShadow(color: .black, alpha: 0.04, x: 0, y: -3, blur: 10, spread: 0)
    }
    
    @IBAction func startNewTripButtonClicked(_ sender: Any) {
        // 새로운 여행 시작하기
        if topLabelData == "" {
            if let travelName = tripNameTextField.text, let destination = tripLocationTextField.text, let startDate = startDateParsing, let endDate = endDateParsing, let selectedIndex = selectedIndex {
                AddTripService.shared.postData(travelName: travelName, destination: destination, startDate: startDate, endDate: endDate, imageIndex: selectedIndex) {result in
                    switch result {
                    case .success(let data):
                        if let test = data as? AddTripResponse {
                            AddTripViewController.code = test.data?.inviteCode ?? ""
                        }
                        let codeStoryboard = UIStoryboard(name: "MakeCodeStoryboard", bundle: nil)
                        if let nextVC = codeStoryboard.instantiateViewController(identifier: "MakeCodeViewController") as? MakeCodeViewController {
                            nextVC.modalPresentationStyle = .overCurrentContext
                            nextVC.modalTransitionStyle = .crossDissolve
                            self.present(nextVC, animated: true)
                        }
                    case .requestErr(_):
                        print("requestErr")
                        return
                    case .pathErr:
                        print("pathErr")
                        return
                    case .serverErr:
                        print("serverErr")
                        return
                    case .networkFail:
                        print("netWorkFail")
                        return
                    }
                }
            }
        }
        // 여행 편집하기
        else {
            if let travelName = tripNameTextField.text, let destination = tripLocationTextField.text, let startDate = startDateParsing, let endDate = endDateParsing, let selectedIndex = selectedIndex {
                EditTripService.shared.patchData(groupID: groupId, travelName: travelName, destination: destination, startDate: startDate, endDate: endDate, imageIndex: selectedIndex) {result in
                    switch result {
                    case .success(_):
                        print("success")
                        self.navigationController?.popViewController(animated: true)
                    case .requestErr(_):
                        print("requestErr")
                        return
                    case .pathErr:
                        print("pathErr")
                        return
                    case .serverErr:
                        print("serverErr")
                        return
                    case .networkFail:
                        print("netWorkFail")
                        return
                    }
                }
            }
        }
    }
    
    @objc func checking() {
        if tripNameTextField.text != "" && tripLocationTextField.text != "" && photoIsSelected == true && startDateLabel.text != "" {
            startNewTripButton.backgroundColor = Colors.pointOrange.color
            startNewTripButton.isEnabled = true
            startNewTripButton.setTitleColor(.white, for: .normal)
        } else {
            startNewTripButton.backgroundColor = Colors.gray7.color
            startNewTripButton.setTitleColor(Colors.black3.color, for: .normal)
            startNewTripButton.isEnabled = false
        }
    }
}

//MARK:- Extension

extension AddTripViewController: dateLabelProtocol {
    func startEndDateLabelSet(start: String, end: String, startParsing: String, endParsing: String) {
        startDateLabel.text = start
        endDateLabel.text = end
        startDateParsing = startParsing
        endDateParsing = endParsing
        startDateView.backgroundColor = Colors.white9.color
        endDateView.backgroundColor = Colors.white9.color
        checking()
    }
}

extension AddTripViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoUrlList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCollectionViewCell else { return UICollectionViewCell()}
        let url = photoUrlList[indexPath.row]
        if let imgUrl = URL(string: url) {
            cell.imageSet(imageUrl: imgUrl)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !selectCheck {
            photoIsSelected = true
            selectCheck = true
            selectedIndex = indexPath.row
        } else {
            photoIsSelected = false
            selectCheck = false
        }
        checking()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        selectCheck = false
    }
}

extension AddTripViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellSize: CGFloat = Device.width * (76 / 375)
        return CGSize(width: cellSize, height: cellSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 7
    }
}

extension AddTripViewController {
    func registerForKeyboardNotifications() {
        // 옵저버 등록
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    func unregisterForKeyboardNotifications() {
        // 옵저버 등록 해제
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillShowNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillHideNotification,
                                                  object: nil)
    }
    
    @objc func keyboardWillShow(_ noti: NSNotification){}
    @objc func keyboardWillHide(_ notification: Notification) {}
}
