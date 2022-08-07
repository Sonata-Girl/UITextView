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
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var progressView: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // назначили делегата(ответсвенного) за выполнение добавленных в класс методы
        textView.delegate = self
        textView.isHidden = true
        
        // настройка для UIView.animate ниже
//        textView.alpha = 0
        //textView.text = ""
        
        textView.font = UIFont.init(name: "AppleSDGothicNeo-Regular", size: 17) //
        textView.backgroundColor = self.view.backgroundColor
        textView.layer.cornerRadius = 10
        
        //  установка дефолтных значений степпера
        stepper.value = 17
        stepper.minimumValue = 10
        stepper.maximumValue = 25
        stepper.tintColor = .white // цвета кнопок
        stepper.backgroundColor = .gray // заливка кнопок
        stepper.layer.cornerRadius = 5 // закругление краев
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        activityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = true
        
        progressView.setProgress(0, animated: true)
        
        // отслеживание появления клавиатуры
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateTextView(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        // отслеживание скрытия клавиатуры
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateTextView(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        
//        UIView.animate(withDuration: 0, delay: 3, options: .curveLinear, animations: {
//            self.textView.alpha = 1
//        }) { (finished) in
//            self.activityIndicator.stopAnimating()
//            self.textView.isHidden = false
//            self.view.isUserInteractionEnabled = false
//        }
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if self.progressView.progress != 1 {
                self.progressView.progress += 0.2
            } else {
                self.activityIndicator.stopAnimating()
                self.textView.isHidden = false
                self.view.isUserInteractionEnabled = false
                self.progressView.isHidden = true
            }
        }
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
    
    @IBAction func sizeFont(_ sender: UIStepper) {
        
        let font = textView.font?.fontName
        let fontSize = CGFloat(sender.value)

        textView.font = UIFont(name: font!, size: fontSize)
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
