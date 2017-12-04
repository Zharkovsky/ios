//
//  File.swift
//  Culculator3-61
//
//  Created by xcode on 11.09.17.
//  Copyright © 2017 VSU. All rights reserved.
//
// 44

import Foundation

private func factorial(digit: Double) -> Double
{
    var res: Double = 1
    var i: Double = 2
    while i <= digit
    {
        res *= i
        i += 1
    }
    return res
}
class CalculatorBrain {
    
    public var result: Double { get { return accumulator } }
    public var description: String { get { return pastValue + currentValue } }
    public var isPartialResult: Bool { get { return pending != nil } }
    
    public var variable: Double = 0.0 { didSet { program = internalProgram as CalculatorBrain.PropertyList } }
    
    private var accumulator = 0.0
    private var pending: PendingBinaryOperationInfo?
    private var currentValue: String = ""
    private var pastValue: String = ""
    private var internalProgram = [AnyObject]()
    
    private var operations: Dictionary<String, Operation> =
        [
            "π" : Operation.Constant(Double.pi),
            "e" : Operation.Constant(M_E),
            "√" : Operation.UnaryOperation(sqrt),
            "х²" : Operation.UnaryOperation({ $0 * $0 }),
            "x⁻¹" : Operation.UnaryOperation({ 1/$0 }),
            "x!"  : Operation.UnaryOperation(factorial),
            "cos" : Operation.UnaryOperation(cos),
            "sin" : Operation.UnaryOperation(sin),
            "tan" : Operation.UnaryOperation(tan),
            "sin⁻¹" : Operation.UnaryOperation(asin),
            "cos⁻¹" : Operation.UnaryOperation(acos),
            "tan⁻¹" : Operation.UnaryOperation(atan),
            "ln" : Operation.UnaryOperation(log),
            "±": Operation.UnaryOperation({ -$0 }),
            "*" : Operation.BinaryOperation({ $0 * $1 }),
            "/" : Operation.BinaryOperation({ $0 / $1 }),
            "+" : Operation.BinaryOperation({ $0 + $1 }),
            "-" : Operation.BinaryOperation({ $0 - $1 }),
            "=" : Operation.Equals
    ]
    
    private struct PendingBinaryOperationInfo
    {
        var binaryFunction: (Double, Double)->Double
        var firstOperand: Double
    }
    
    private enum Operation
    {
        case Constant(Double)
        case UnaryOperation((Double)->Double)
        case BinaryOperation((Double,Double)->Double)
        case Equals
    }
    
    typealias PropertyList = AnyObject
    private var program: PropertyList
    {
        get { return internalProgram as CalculatorBrain.PropertyList }
        set
        {
            clear()
            if let arrayOfOps = newValue as? [AnyObject]
            {
                for op in arrayOfOps
                {
                    if let operand = op as? Double
                    {
                        setOperand(operand: operand)
                    }
                    else if let operation = op as? String
                    {
                        if operations[operation] != nil
                        {
                            perfomOperation(symbol: operation)
                        }
                        else
                        {
                            setOperand()
                        }
                    }
                }
            }
        }
    }
    
    public func setOperand(operand: Double)
    {
        if (operand != accumulator) || isPartialResult
        {
            currentValue = String(operand)
        }
        internalProgram.append(operand as AnyObject)
        accumulator = operand
    }
    
    public func setOperand()
    {
        accumulator = variable
        currentValue = "M"
        internalProgram.append(currentValue as AnyObject)
    }
    
    public func perfomOperation (symbol: String)
    {
        internalProgram.append(symbol as AnyObject)
        
        if let operation = operations[symbol]
        {
            switch operation
            {
            case.Constant(let value):
                accumulator = value
                currentValue = symbol
            case.UnaryOperation(let function):
                currentValue = symbol + "(" + currentValue + ")"
                accumulator = function(accumulator)
            case.BinaryOperation(let function):
                pastValue = pastValue + currentValue + symbol
                currentValue = ""
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: function,firstOperand: accumulator)
            case.Equals:
                currentValue = pastValue + currentValue
                pastValue = ""
                executePendingBinaryOperation()
            }
        }
    }
    
    public func undoLast()
    {
        if !internalProgram.isEmpty
        {
            clear ();
            return
        }
        internalProgram.removeLast()
        program = internalProgram as CalculatorBrain.PropertyList
    }
    
    public func clear()
    {
        internalProgram.removeAll()
        accumulator = 0.0
        pending = nil
        currentValue = ""
        pastValue = ""
    }
    
    private func executePendingBinaryOperation()
    {
        if pending != nil
        {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil
        }
    }
}
