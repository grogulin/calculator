//
//  ViewController.swift
//  Calculator
//
//  Created by Ярослав Грогуль on 26.11.2022.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var acButton: UIButton!
    @IBOutlet var resultLabel: UILabel!
    
    @IBOutlet var debugLabel: UILabel!
    
    var debug : Bool = false
    
    var firstArg : Decimal = 0
    var secondArg : Decimal = 0
    var result : Decimal = 0
    var tempResult : Float = 0
    var decimalPart : String = ""
    
    var firstArgIsBeingTyped : Bool = true
    var decimalPartIsBeingTyped : Bool = false
    var autoACActive : Bool = false
    
    
    let operations = ["add", "subtract", "multiply", "divide"]
    var currentOperation = ""
    
    var previousOperation = ""
    var previousSecondArg : Decimal = 0
    
    var timer : Timer!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateResultLabel(result: firstArg)
        
        configureACButton()
        if debug {
            startTimer()
        }
        
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(showArgs), userInfo: nil, repeats: true)
    }
    
    @objc func showArgs() {
        debugLabel.text = """
        firstArg = \(firstArg)
        secondArg = \(secondArg)
        result = \(result)
        firstArgIsBeingTyped: \(firstArgIsBeingTyped)
        decimalPartIsBeingTyped: \(decimalPartIsBeingTyped)
        currentOperation: \(currentOperation)
        previousOperation: \(previousOperation)
        previousSecondArg: \(previousSecondArg)
        autoACActive: \(autoACActive)
        """
    }
    
    func configureACButton() {
        acButton.addTarget(self, action: #selector(acButtonPressed), for: .touchUpInside)
    }
    
    @objc func acButtonPressed() {
        firstArg = 0
        secondArg = 0
        result = 0
        decimalPart = ""
        
        firstArgIsBeingTyped = true
        decimalPartIsBeingTyped = false
        updateResultLabel(result: firstArg)
    }
    
    
    @IBAction func numberButtonPressed(_ sender: UIButton) {
        
        guard let numberPressed = sender.titleLabel?.text else { return  }
        
        if autoACActive {
            autoACActive = false
            acButtonPressed()
        }
        
        let number = Int(numberPressed) ?? 0
        
        if decimalPartIsBeingTyped {
            addToDecimalPart(number: number)
        } else {
            if firstArgIsBeingTyped {
                addToFirstArg(number: numberPressed)
            }
            else if !firstArgIsBeingTyped {
                addToSecondArg(number: numberPressed)
            }
        }
    }

    func updateResultLabel(result: Decimal) {
        
        tempResult = Float(truncating: result as NSNumber)
        
        if result.mod(1.0) != 0 {
            resultLabel.text = String(tempResult)
        }
        else {
            resultLabel.text = String(Int(tempResult))
        }
    }
    
    func addToFirstArg(number: String) {
        
        let valueToAdd = String(Int(truncating: firstArg as NSNumber))
        firstArg = Decimal(string: valueToAdd + number) ?? 0
        updateResultLabel(result: firstArg)
    }
    
    func addToSecondArg(number: String) {

        let valueToAdd = String(Int(truncating: secondArg as NSNumber))
        secondArg = Decimal(string: valueToAdd + number) ?? 0
        updateResultLabel(result: secondArg)
    }
    
    func addToDecimalPart(number: Int) {
        decimalPart = decimalPart + String(number)
        
        if firstArgIsBeingTyped {
            firstArg = Decimal(string: String(Int(truncating: firstArg as NSNumber)) + "." + decimalPart) ?? 0
            updateResultLabel(result: firstArg)
        } else {
            secondArg = Decimal(string: String(Int(truncating: secondArg as NSNumber)) + "." + decimalPart) ?? 0
            updateResultLabel(result: secondArg)
        }
    }
    
    func operationButtonPressed() {
        firstArgIsBeingTyped = !firstArgIsBeingTyped
        decimalPartIsBeingTyped = false
        decimalPart = ""
        autoACActive = false
        
        
    }
    
    @IBAction func plusButtonPressed(_ sender: UIButton) {
        operationButtonPressed()
        currentOperation = operations[0]
    }

    
    @IBAction func minusButtonPressed(_ sender: UIButton) {
        operationButtonPressed()
        currentOperation = operations[1]
    }
    
    @IBAction func multiplyButtonPressed(_ sender: UIButton) {
        operationButtonPressed()
        currentOperation = operations[2]
    }
    @IBAction func divideButtonPressed(_ sender: UIButton) {
        operationButtonPressed()
        currentOperation = operations[3]
    }
    
    @IBAction func equalsButtonPressed(_ sender: UIButton) {
        
        if currentOperation != "" {
            runOperation(left: firstArg, right: secondArg, currentOperation: currentOperation)
            
            previousOperation = currentOperation
            previousSecondArg = secondArg
            currentOperation = ""
            secondArg = 0
        }
        else {
            runOperation(left: result, right: previousSecondArg, currentOperation: previousOperation)
        }
        
        firstArgIsBeingTyped = true
        decimalPartIsBeingTyped = false
        
        autoACActive = true
    }
    
    @IBAction func decimalButtonPressed(_ sender: UIButton) {
        decimalPartIsBeingTyped = !decimalPartIsBeingTyped
        resultLabel.text! += "."
    }
    
    func runOperation(left : Decimal, right : Decimal, currentOperation : String) {
        
        switch currentOperation {
            case "add" : result = left + right
            case "subtract" : result = left - right
            case "divide" : result = left / right
            case "multiply" : result = left * right
            default : print("Have no operation to run!")
        }
        
        updateResultLabel(result: result)
        firstArg = result
    }
    
    
    @IBAction func plusMinusButtonPressed(_ sender: UIButton) {
        
        
        if firstArgIsBeingTyped {
            firstArg = -firstArg
            updateResultLabel(result: firstArg)
        }
        else {
            secondArg = -secondArg
            updateResultLabel(result: secondArg)
        }
    }
}

extension Decimal {
    func mod(_ b: Decimal) -> Decimal {
        var d = self/(b)
        var f : Decimal = 0
        NSDecimalRound(&f, &d, 0, .down)
        return self-(b*(f))
    }
}
