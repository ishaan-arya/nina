//
//  tree_gen.swift
//  nina
//
//  Created by Abhijeet Sudhir on 09/03/24.
//

import Foundation

func generateDirectoryTree(from path: String, level: Int = 0) -> String {
    do {
        var directoryTree = ""
        let fileManager = FileManager.default
        let files = try fileManager.contentsOfDirectory(atPath: path)

        for file in files {
            let currentPath = "\(path)/\(file)"
            let fileAttributes = try fileManager.attributesOfItem(atPath: currentPath)

            if let fileType = fileAttributes[.type] as? FileAttributeType {
                if fileType == .typeDirectory {
                    directoryTree += "\(String(repeating: " ", count: level * 4))\(file)/\n"
                    directoryTree += generateDirectoryTree(from: currentPath, level: level + 1)
                } else {
                    directoryTree += "\(String(repeating: " ", count: level * 4))\(file)\n"
                }
            }
        }
        return directoryTree
    } catch {
        print("Error generating directory tree: \(error)")
        return ""
    }
}

