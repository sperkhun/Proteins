//
//  Reader.swift
//  Swifty_Proteins
//
//  Created by Serhii PERKHUN on 10/27/18.
//  Copyright © 2018 Ivan SELETSKYI. All rights reserved.
//

import Foundation

class Reader {
    
    func getProteinsArr() {
        guard let fileName = Bundle.main.path(forResource: "ligands", ofType: "txt") else{
            print("NO FILE")
            return}
        guard let ligands = try? String(contentsOf: URL(fileURLWithPath: fileName)) else{
            print("NO CONTENT")
            return}
        Ligands.ligands = ligands.components(separatedBy: "\n").filter {$0 != ""}
    }
    
    func getModel(name: String) -> Bool {
        guard let url = URL(string: "http://files.rcsb.org/ligands/view/\(name)_ideal.sdf") else {return false}
        do {
            let str = try String(contentsOf: url)
            if str == "" {
                return false
            }
            parseScene(scene: str, name: name)
        }
        catch {
            return false
        }
        return true
    }
    
    func parseScene(scene: String?, name: String) {
        if let str = scene?.components(separatedBy: "\n").filter({$0 != ""}) {
            if str.first! != name {
                print("Error")
                return
            }
            let atoms = Int(str[2][0..<3].trimmingCharacters(in: NSCharacterSet.whitespaces))! + 2
            let bounds = Int(str[2][3..<6].trimmingCharacters(in: NSCharacterSet.whitespaces))! + atoms
            for i in 3 ... atoms {
                let params = str[i].components(separatedBy: NSCharacterSet.whitespaces).filter {$0 != ""}
                let atom = (Float(params[0])!, Float(params[1])!, Float(params[2])!, params[3].capitalizingFirstLetter(), atomName[params[3]]!.0, atomName[params[3]]!.1)
                Ligands.LigandsGeom.append(atom)
            }
            if bounds >= atoms + 1 {
                for i in atoms + 1 ... bounds {
                    let from = Int(str[i][0..<3].trimmingCharacters(in: NSCharacterSet.whitespaces))!
                    let to = Int(str[i][3..<6].trimmingCharacters(in: NSCharacterSet.whitespaces))!
                    let number = Int(str[i][6..<9].trimmingCharacters(in: NSCharacterSet.whitespaces))!
                    let bound = (from, to, number)
                    Ligands.boundsGeom.append(bound)
                }
            }
        }
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }
    
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }
    
    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
}
