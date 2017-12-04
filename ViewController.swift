import UIKit

class ViewController: UIViewController 
{
    @IBOutlet private weak var display: UILabel!
    @IBOutlet weak var historyDisplay: UILabel!

    @objc var userIsInTheMiddleOfTyping = false

    private var brain = CalculatorBrain()
    private var newExpression = true
    private var presedM = false;

    private var displayValue: Double?
    {
        get 
        {
            return Double(display.text!)!
        }
        set 
        {
            if let value = newValue 
            {
                display.text = withoutDot(digit: String(value))
                historyDisplay.text = (brain.description == "" ? "" : brain.description + (brain.isPartialResult ? "..." : "="))
            } 
            else 
            {
                display.text = "0"
                historyDisplay.text = ""
                userIsInTheMiddleOfTyping = false
            }
        }
    }

    @IBAction func touchDigit(_ sender: UIButton) 
    {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping
        {
            display.text = display.text! + digit
        } 
        else
        {
            display.text = digit
        }
        userIsInTheMiddleOfTyping = true
    }
    
    @IBAction func clear(_ sender: UIButton) 
    {
        brain.clear()
        brain.variable = 0
        displayValue = nil
        historyDisplay.text = ""
        userIsInTheMiddleOfTyping = presedM = false
    }
    
    @IBAction func backspace(_ sender: UIButton) 
    {
        if(userIsInTheMiddleOfTyping)
        {
            var text = display.text!
            if(text == "0") return

            text.remove(at : text.index(before: text.endIndex))

            if(text != "" && text[text.index(before: text.endIndex)] == ".")
            {
                text.remove(at : text.index(before: text.endIndex))
            }
            if(text == "" || text == "-0")
            {
                userIsInTheMiddleOfTyping = false
                text = "0"
            }
            display.text = text;
        }
        else
        {
            brain.undoLast()
            displayValue = brain.result;
        }
    }

    @IBAction private func perfomOperation(_ sender: UIButton) 
    {
        if userIsInTheMiddleOfTyping
        {
            brain.setOperand(operand: displayValue!)
        }
        userIsInTheMiddleOfTyping = false
        if let mathematicalSymbol = sender.currentTitle
        {
            brain.perfomOperation(symbol: mathematicalSymbol)
        }
        displayValue = brain.result
    }
    
    @IBAction func undo(_ sender: UIButton) 
    {
        brain.undoLast()
        displayValue = brain.result    
        if (displayValue == 0)
        {
            userIsInTheMiddleOfTyping = false
        }
    }
    
    @IBAction func touchDot(_ sender: UIButton) 
    {
        if(display.text!.index(of:"." ) == nil)
        {
            display.text = display.text! + "."
            userIsInTheMiddleOfTyping = true
        }
    }

    @IBAction func setM(_ sender: UIButton) 
    {
        userIsInTheMiddleOfTyping = false
        brain.variable = displayValue
        displayValue = brain.result
    }
    
    @IBAction func pushM(_ sender: UIButton) 
    {
        brain.setOperand()
        displayValue = brain.result
    }

    private func withoutDot(digit: String)->String
    {
        let index = digit.index(of:".") ?? digit.endIndex
        let sub = String(digit[index .. <digit.endIndex])
        
        if (sub == ".0")
        {
            return String(digit[digit.startIndex .. <index]);
        }
        else
        {
            return digit            
        }
    }
}