//
//  SimpleStringParser.swift
//  Gravity
//
//  Created by Cooper Knaak on 4/12/15.
//  Copyright (c) 2015 Cooper Knaak. All rights reserved.
//

#if os(iOS)
    import UIKit
#else
    import Cocoa
#endif

open class SimpleStringParser: NSObject {
    
    fileprivate enum ParseError {
        case missingVariable(String)
        case tooManyOperations
    }
    
    open static var defaultVariables:[String:VariableType] = ["π":3.14159265]
    public typealias VariableType = CGFloat
    open static let ParseErrorDomain =   "CC SimpleStringParser::ParseErrorDomain"
    
    open let string:String
    open let variables:[String:VariableType]
    open let alphanumericCharacters:CharacterSet
    open let whitespaceCharacters = CharacterSet.whitespaces
    open let numericCharacters = CharacterSet(charactersIn: "0123456789.")
    open let operationCharacters = CharacterSet(charactersIn: "+-/*")
    
    public init(string:String, variables:[String:VariableType] = SimpleStringParser.defaultVariables) {
        
        var aChars = CharacterSet.alphanumerics
        aChars = CharacterSet.alphanumerics
        aChars.formUnion(CharacterSet.whitespaces)
        aChars.formUnion(CharacterSet(charactersIn: "."))
        for (key, _) in variables {
            aChars.formUnion(CharacterSet(charactersIn: key))
        }
        self.alphanumericCharacters = aChars
        
        
        self.string = string
        self.variables = variables
        
    }//initialize with string
    
    subscript(key:String) -> VariableType? {
        return self.variables[key]
    }//subscript (for variables)
    
    open func valueForString(_ string:String) -> VariableType? {
        
        if let value = self[string] {
            return value
        } else if SimpleStringParser.stringIsNumber(string) {
            return VariableType((string as NSString).floatValue)
        } else {
            return nil
        }
        
    }
    
    open func parse() throws -> VariableType {
        var error: NSError! = NSError(domain: "Migrator", code: 0, userInfo: nil)
        
        if let initialValue = self.valueForString(self.string) {
            return initialValue
        }
        
        
        //        let comps = self.string.componentsSeparatedByCharactersInSet(self.operationCharacters).filter()    { $0 != "" && $0 != " " }
        //        let opers = self.string.componentsSeparatedByCharactersInSet(self.alphanumericCharacters).filter() { $0 != "" && $0 != " " }
        /*var comps = self.string.componentsSeparatedByCharactersInSet(self.operationCharacters)
        comps = comps.map()     { $0.stringByTrimmingCharactersInSet(self.whitespaceCharacters) }
        comps = comps.filter()  { $0 != "" }
        var opers = self.string.componentsSeparatedByCharactersInSet(self.alphanumericCharacters)
        opers = opers.map()     { $0.stringByTrimmingCharactersInSet(self.whitespaceCharacters) }
        opers = opers.filter()  { $0 != "" }*/
        let (comps, opers) = self.getComponentsAndOperations()
        
        if (opers.count >= comps.count) {
            throw self.getErrorForCode(ParseError.tooManyOperations)
        }
        
        /*  The two arguments that correspond to each number
        *  is (iii) & (iii + 1). At the moment, that restricts
        *  strings to only include binary operators (no unary minus).
        *  Also, you must make sure to perform the * / operations
        *  before the + - operations, so I loop for the * /,
        *  generate a new components array, then loop again.
        *
        *   (0) (1) (2)
        *  1 + 2 * 3 - 4
        * (0) (1) (2) (3)
        *
        */

        
        do {
            let (addComps, addOpers) = try self.getAdditionSubtractionComponentsFrom(comps, operations: opers)
            
            var finalValue:VariableType = VariableType((addComps[0] as NSString).floatValue)
            if (addOpers.count <= 0) {
                return finalValue
            }
            
            for (iii, curOperator) in addOpers.enumerated() {
                
                do {
                    let nextValue = try self.getNextValueForIndex(iii, curOperator: curOperator, addComps: addComps, final: finalValue)
                    
                    finalValue = nextValue
                } catch let error1 as NSError {
                    error = error1
                }
                
                /*let curValue =  self.valueForString(addComps[iii])
                let nextValue = self.valueForString(addComps[iii + 1])
                
                switch (curOperator) {
                case "+":
                finalValue += nextValue
                case "-":
                finalValue -= nextValue
                default:
                break
                }*/
            }
            
            return finalValue
        } catch let error1 as NSError {
            error = error1
        }
        
        throw error
    }//parse
    /*
    public func parse() -> VariableType? {
//        var error:NSError? = nil
        do {
            return try self.parse()
        } catch _ {
            return nil
        }
    }//parse
    */
    fileprivate func getComponentsAndOperations() -> (components:[String], operations:[String]) {
        
        var comps = self.string.components(separatedBy: self.operationCharacters)
        comps = comps.map()     { $0.trimmingCharacters(in: self.whitespaceCharacters) }
        comps = comps.filter()  { $0 != "" }
        
        var opers = self.string.components(separatedBy: self.alphanumericCharacters)
        opers = opers.map()     { $0.trimmingCharacters(in: self.whitespaceCharacters) }
        opers = opers.filter()  { $0 != "" }
        
        return (comps, opers)
    }//get component and operation arrays
    
    fileprivate func getAdditionSubtractionComponentsFrom(_ comps:[String], operations opers:[String]) throws -> (add:[String], oper:[String]) {
        
        var index = 0
        var addComps:[String]  = []
        var operComps:[String] = []
        
        var lastWasAdditionOrSubtraction = false
        
        operatorLoop : for (_, curOperator) in opers.enumerated() {
            
            let curString = comps[index]
            let nexString = comps[index + 1]
            let optional_curValue = self.valueForString(curString)
            let optional_nexValue = self.valueForString(nexString)
            
            if (optional_curValue == nil) {
                
                let validError = self.getErrorForCode(ParseError.missingVariable(curString))
                throw validError
                
            } else if (optional_nexValue == nil) {
                
                let validError = self.getErrorForCode(ParseError.missingVariable(nexString))
                throw validError
            }
            
            //I check to see if they are nil earlier,
            //so the values are guarunteed to exist.
            let curValue = optional_curValue!
            let nexValue = optional_nexValue!
            
            switch curOperator {
            case "+", "-":
                addComps.append(curString)
                operComps.append(curOperator)
                lastWasAdditionOrSubtraction = true
            case "*":
                addComps.append("\(curValue * nexValue)")
                lastWasAdditionOrSubtraction = false
                break operatorLoop
            case "/":
                addComps.append("\(curValue / nexValue)")
                lastWasAdditionOrSubtraction = false
                break operatorLoop
            default:
                break
            }
            
            index += 1
        }
        
        if (index < opers.count - 1) {
            for iii in (index + 1)..<opers.count {
                operComps.append(opers[iii])
                addComps.append(comps[iii + 1])
            }/*
            for iii in index..<comps.count {
            addComps.append(comps[iii])
            }*/
            return try self.getAdditionSubtractionComponentsFrom(addComps, operations: operComps)
        } else if let lastComp = comps.last , lastWasAdditionOrSubtraction {
            addComps.append(lastComp)
        }
        
        return (addComps, operComps)
    }//get next components
    
    fileprivate func getNextValueForIndex(_ iii:Int, curOperator:String, addComps:[String], final:VariableType) throws -> CGFloat {
        
        if let _ = self.valueForString(addComps[iii]) {
            
            if let nextValue = self.valueForString(addComps[iii + 1]) {
                
                var finalValue = final
                switch (curOperator) {
                case "+":
                    finalValue += nextValue
                case "-":
                    finalValue -= nextValue
                default:
                    break
                }
                
                return finalValue
            } else {
                
                let validError = self.getErrorForCode(ParseError.missingVariable(addComps[iii + 1]))
                throw validError
            }// -- nextValue
            
        } else {
            
            let validError = self.getErrorForCode(ParseError.missingVariable(addComps[iii]))
            throw validError
        }// -- curValue
        
    }//get next value for index
    
    fileprivate func getErrorForCode(_ code:ParseError) -> NSError {
        
        switch code {
        case .missingVariable(let key):
            var userInfo:[String: Any] = [:/*SimpleStringParser.MissingVariableKey:key*/]
            userInfo[NSLocalizedDescriptionKey] = "Invalid Variable"
            userInfo[NSLocalizedFailureReasonErrorKey] = "The variable \"\(key)\" does not exist."
            let error = NSError(domain: SimpleStringParser.ParseErrorDomain, code: -1, userInfo: userInfo)
            return error
        case .tooManyOperations:
            var userInfo:[String: Any] = [:]
            userInfo[NSLocalizedDescriptionKey] = "Too Many Operations"
            userInfo[NSLocalizedFailureReasonErrorKey] = "The amount of operations equaled or exceeded the amount of numbers."
            userInfo[NSLocalizedRecoverySuggestionErrorKey] = "Make sure all operations are surrounded by numbers and that all operations are binary (i.e. no unary minus)."
            let error = NSError(domain: SimpleStringParser.ParseErrorDomain, code: -2, userInfo: userInfo)
            return error
        }//
        
    }//get error for code
    
    
    open class func stringIsNumber(_ string:String) -> Bool {
        
        struct StaticNumericCharacters {
            static let numericCharacters = CharacterSet(charactersIn: "0123456789.")
        }
        
        for cur in string.utf16 {
            if (!StaticNumericCharacters.numericCharacters.contains(UnicodeScalar(cur)!)) {
                return false
            }
        }
        
        return true
    }//check if string is a number
    
    ///Checks if string is a single number, or just uses CGSizeFromString.
    open class func sizeFromString(_ string:String) -> CGSize {
        if SimpleStringParser.stringIsNumber(string) {
            return CGSize(square: string.getCGFloatValue())
        } else {
            #if os(iOS)
            return CGSizeFromString(string)
            #else
            return NSSizeFromString(string)
            #endif
        }
    }
    
}//simple string parser
