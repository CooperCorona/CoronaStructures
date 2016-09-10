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

public class SimpleStringParser: NSObject {
    
    private enum ParseError {
        case MissingVariable(String)
        case TooManyOperations
    }
    
    public static var defaultVariables:[String:VariableType] = ["π":3.14159265]
    public typealias VariableType = CGFloat
    public static let ParseErrorDomain =   "CC SimpleStringParser::ParseErrorDomain"
    
    public let string:String
    public let variables:[String:VariableType]
    public let alphanumericCharacters:NSMutableCharacterSet
    public let whitespaceCharacters = NSCharacterSet.whitespaceCharacterSet()
    public let numericCharacters = NSCharacterSet(charactersInString: "0123456789.")
    public let operationCharacters = NSCharacterSet(charactersInString: "+-/*")
    
    public init(string:String, variables:[String:VariableType] = SimpleStringParser.defaultVariables) {
        
        self.alphanumericCharacters = NSMutableCharacterSet.alphanumericCharacterSet()
        self.alphanumericCharacters.formUnionWithCharacterSet(NSCharacterSet.whitespaceCharacterSet())
        self.alphanumericCharacters.formUnionWithCharacterSet(NSCharacterSet(charactersInString: "."))
        for (key, _) in variables {
            self.alphanumericCharacters.formUnionWithCharacterSet(NSCharacterSet(charactersInString: key))
        }
        
        
        self.string = string
        self.variables = variables
        
    }//initialize with string
    
    subscript(key:String) -> VariableType? {
        return self.variables[key]
    }//subscript (for variables)
    
    public func valueForString(string:String) -> VariableType? {
        
        if let value = self[string] {
            return value
        } else if SimpleStringParser.stringIsNumber(string) {
            return VariableType((string as NSString).floatValue)
        } else {
            return nil
        }
        
    }
    
    public func parse() throws -> VariableType {
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
            throw self.getErrorForCode(ParseError.TooManyOperations)
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
            
            for (iii, curOperator) in addOpers.enumerate() {
                
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
    private func getComponentsAndOperations() -> (components:[String], operations:[String]) {
        
        var comps = self.string.componentsSeparatedByCharactersInSet(self.operationCharacters)
        comps = comps.map()     { $0.stringByTrimmingCharactersInSet(self.whitespaceCharacters) }
        comps = comps.filter()  { $0 != "" }
        
        var opers = self.string.componentsSeparatedByCharactersInSet(self.alphanumericCharacters)
        opers = opers.map()     { $0.stringByTrimmingCharactersInSet(self.whitespaceCharacters) }
        opers = opers.filter()  { $0 != "" }
        
        return (comps, opers)
    }//get component and operation arrays
    
    private func getAdditionSubtractionComponentsFrom(comps:[String], operations opers:[String]) throws -> (add:[String], oper:[String]) {
        
        var index = 0
        var addComps:[String]  = []
        var operComps:[String] = []
        
        var lastWasAdditionOrSubtraction = false
        
        operatorLoop : for (_, curOperator) in opers.enumerate() {
            
            let curString = comps[index]
            let nexString = comps[index + 1]
            let optional_curValue = self.valueForString(curString)
            let optional_nexValue = self.valueForString(nexString)
            
            if (optional_curValue == nil) {
                
                let validError = self.getErrorForCode(ParseError.MissingVariable(curString))
                throw validError
                
            } else if (optional_nexValue == nil) {
                
                let validError = self.getErrorForCode(ParseError.MissingVariable(nexString))
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
        } else if let lastComp = comps.last where lastWasAdditionOrSubtraction {
            addComps.append(lastComp)
        }
        
        return (addComps, operComps)
    }//get next components
    
    private func getNextValueForIndex(iii:Int, curOperator:String, addComps:[String], final:VariableType) throws -> CGFloat {
        
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
                
                let validError = self.getErrorForCode(ParseError.MissingVariable(addComps[iii + 1]))
                throw validError
            }// -- nextValue
            
        } else {
            
            let validError = self.getErrorForCode(ParseError.MissingVariable(addComps[iii]))
            throw validError
        }// -- curValue
        
    }//get next value for index
    
    private func getErrorForCode(code:ParseError) -> NSError {
        
        switch code {
        case .MissingVariable(let key):
            var userInfo:[NSObject:AnyObject] = [:/*SimpleStringParser.MissingVariableKey:key*/]
            userInfo[NSLocalizedDescriptionKey] = "Invalid Variable"
            userInfo[NSLocalizedFailureReasonErrorKey] = "The variable \"\(key)\" does not exist."
            let error = NSError(domain: SimpleStringParser.ParseErrorDomain, code: -1, userInfo: userInfo)
            return error
        case .TooManyOperations:
            var userInfo:[NSObject:AnyObject] = [:]
            userInfo[NSLocalizedDescriptionKey] = "Too Many Operations"
            userInfo[NSLocalizedFailureReasonErrorKey] = "The amount of operations equaled or exceeded the amount of numbers."
            userInfo[NSLocalizedRecoverySuggestionErrorKey] = "Make sure all operations are surrounded by numbers and that all operations are binary (i.e. no unary minus)."
            let error = NSError(domain: SimpleStringParser.ParseErrorDomain, code: -2, userInfo: userInfo)
            return error
        }//
        
    }//get error for code
    
    
    public class func stringIsNumber(string:String) -> Bool {
        
        struct StaticNumericCharacters {
            static let numericCharacters = NSCharacterSet(charactersInString: "0123456789.")
        }
        
        for cur in string.utf16 {
            if (!StaticNumericCharacters.numericCharacters.characterIsMember(cur)) {
                return false
            }
        }
        
        return true
    }//check if string is a number
    
    ///Checks if string is a single number, or just uses CGSizeFromString.
    public class func sizeFromString(string:String) -> CGSize {
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