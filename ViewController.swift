//
//  ViewController.swift
//  UITextView
//
//  Created by Sonata Girl on 20.07.2022.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textViewBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // назначили делегата(ответсвенного) за выполнение добавленных в класс методы
        textView.delegate = self
        textView.text = ""
        
        textView.font = UIFont.init(name: "AppleSDGothicNeo-Regular", size: 17) //
        textView.backgroundColor = self.view.backgroundColor
        textView.layer.cornerRadius = 10
        
        // подключение "наблюдателя" за открытием клавиатуры
        // который будет вызван если клавиатура откроется
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateTextView(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        // подключение "наблюдателя" за закрытием клавиатуры
        // который будет вызван если клавиатура скроется
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateTextView(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true) //скрытие клавиатуры для любого объекта
        
//        textView.resignFirstResponder() //закрывает клавиутуру для конкретного объекта
    }
    
    @IBAction func updateTextView(notification: Notification) {
        guard
            // словарь userInfo содержит разную информацию, в данный момент о размере клавиатуры ( нам нужен этот размер чтобы понять на какой размер поднять текст над клавиатурой) ( у словаря тип [AnyHashable : Any]
            let userInfo = notification.userInfo as? [String: Any],
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        else {return}
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            textView.contentInset = UIEdgeInsets.zero
        } else {
            // когда клавиатура будет появляться меняем расстояние между текстом и нижней границей textView в размер клавиатуры
            textView.contentInset = UIEdgeInsets(top: 0,
                                                 left: 0,
            // тут вычитаем длину констрейнта для того чтобы текст был ровно над клавиатурой
                                                 bottom: keyboardFrame.height - textViewBottomConstraint.constant,
                                                 right: 0)
            // сидвигаем индикатор прокрутки тоже на значение размера клавиатуры
            textView.scrollIndicatorInsets = textView.contentInset
        }
        
        //определяем зону видимости скролинга
        textView.scrollRangeToVisible(textView.selectedRange)
    }
}

extension ViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.backgroundColor = .white
        textView.textColor = .gray
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.backgroundColor = self.view.backgroundColor
        textView.textColor = .black
    }
    
    //вызывается при каждом вводе символа
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        countLabel.text = "\(textView.text.count)"
        
        print("Text count: \(text.count)")
        print("Range lenth: \(range.length)")
       
        return textView.text.count + (text.count - range.length) <= 60
    }
}
