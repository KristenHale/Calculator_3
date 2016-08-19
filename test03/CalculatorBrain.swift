//
//  CalculatorBrain.swift
//  test03
//
//  Created by Mac on 16/7/24.
//  Copyright © 2016年 Mac. All rights reserved.
//

import Foundation


class CalculatorBrain {
    private var opstack = [Op]() //Array<Op>()
    private var knownOps = [String:Op]() //Dictionary<String,Op>()
    
    //Printalbe(protocol)
    private enum Op: CustomStringConvertible
    {
        case Operand(Double)
        case UnaryOperation(String,Double -> Double)//一元运算
        case BinaryOperation(String,(Double,Double) -> Double)//二元运算
        
        var description:String{
            get{
                switch self{
                case .Operand(let operand):
                    return "\(operand)"
                case  .UnaryOperation(let symbol,_):
                    return symbol
                case .BinaryOperation(let symbol,_):
                    return symbol
                }
            }
        }
    }
    
    init(){
        func learnOp(op:Op){
            knownOps[op.description] = op
        }
        learnOp(Op.BinaryOperation("×",*))
        //knownOps["×"] = Op.BinaryOperation("×",*)
        knownOps["÷"] = Op.BinaryOperation("÷"){ $1 / $0 }
        knownOps["+"] = Op.BinaryOperation("+",+)
        knownOps["−"] = Op.BinaryOperation("−"){ $1 - $0 }
        knownOps["√"] = Op.UnaryOperation("√", sqrt)
        knownOps["∜"] = Op.UnaryOperation("∜"){ sqrt(sqrt($0))}
        knownOps["log"] = Op.UnaryOperation("log"){ log($0)}
    }
    
    typealias ProperyList = AnyObject
    
    var program:ProperyList {  // guaranteed(保证) to be a Propertylist
        get{
            return opstack.map { $0.description }
//            var returnValue = Array<String>()
//            for op in  opstack{
//                returnValue.append(op.description)
//            }
//            return returnValue
        }
        set{
            if let  opSymbols = newValue as? Array<String>{
                var newOpStack = [Op]()
                for opSymbol in opSymbols {
                    if let op = knownOps[opSymbol] {
                        newOpStack.append(op)
                        
                    } else if let operand = NSNumberFormatter().numberFromString(opSymbol)?.doubleValue{
                        newOpStack.append(.Operand(operand))
                    }
                }
                opstack = newOpStack
            }
        }
    }
    
    //递归运算，返回值（Tuple：运算结果，剩余栈)
    private func evaluate(let ops : [Op]) -> (result:Double?,remainingOps:[Op]) {
        if ops.isEmpty{
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand,remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result{
                    return (operation(operand),operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_,let operation):
                let opp1Evaluation = evaluate(remainingOps)
                if let operand1 = opp1Evaluation.result{
                    let opp2Evaluation = evaluate(opp1Evaluation.remainingOps)
                    if let operand2 = opp2Evaluation.result{
                        return(operation(operand1,operand2),opp2Evaluation.remainingOps)
                    }
                }
            }
        }
        return (nil,ops)//返回失败结果
    }
    
    func evaluate() -> Double? {
        let (result,reaminder) = evaluate(opstack)
        print("\(opstack)  = \(result) with \(reaminder) left over")
        return result
    }
    
    func pushOperand(operand:Double) -> Double?{
       opstack.append(Op.Operand(operand))
       return evaluate()
    }
    
    //执行运算
    func performOperation(symbol:String) ->Double?{
        if let operation = knownOps[symbol] {
            opstack.append(operation)
        }
        return evaluate()
    }
}
