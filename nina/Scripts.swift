//
//  shell_scripts.swift
//  nina
//
//  Created by Kunal Mansukhani on 09/03/24.
//

import Foundation

func deleteFile(at path: String) {
    let fileManager = FileManager.default
    
    do {
        try fileManager.removeItem(atPath: path)
        print("File deleted successfully at path: \(path)")
    } catch {
        print("Error deleting file at path: \(path)")
        print("Error description: \(error.localizedDescription)")
    }
}


func createShellScript(with instructions: String, at path: String) -> String? {

    // Create a URL for the script file or directory
    let cleanedInstructions = instructions
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .replacingOccurrences(of: "```bash", with: "")
        .replacingOccurrences(of: "```", with: "")
        .trimmingCharacters(in: .whitespacesAndNewlines)

    let fileURL: URL

    if path.hasSuffix(".sh") {

        fileURL = URL(fileURLWithPath: path)

    } else {

        let fileName = "script.sh"

        let directoryURL = URL(fileURLWithPath: path, isDirectory: true)

        fileURL = directoryURL.appendingPathComponent(fileName)

    }

    // Create the file if it doesn't exist

    let fileManager = FileManager.default

    if !fileManager.fileExists(atPath: fileURL.path) {

        do {

            try "".write(to: fileURL, atomically: true, encoding: .utf8)

        } catch {

            print("Error: Failed to create file at \(fileURL.path): \(error)")

            return nil

        }

    }

    // Write the instructions to the file

    do {

        try cleanedInstructions.write(to: fileURL, atomically: true, encoding: .utf8)

    } catch {

        print("Error: Failed to write to \(fileURL.path): \(error)")

        return nil

    }

    // Mark the file as executable

    do {

        try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: fileURL.path)

    } catch {

        print("Error: Failed to set permissions for \(fileURL.path): \(error)")

        return nil

    }

    let task = Process()

    task.executableURL = URL(fileURLWithPath: "/usr/bin/xattr")

    task.arguments = ["-d", "com.apple.quarantine", fileURL.path]

    do {

        try task.run()

        try task.waitUntilExit()

    } catch {

        print("Error: Failed to remove quarantine flag from \(fileURL.path): \(error)")

        return nil

    }

    // Return the absolute path of the created file

    return String(fileURL.path)

}

func executeShellScript(at path: String) {
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/bin/bash")
    task.arguments = [path]
    
    do {
        try task.run()
        task.waitUntilExit()
    } catch {
        print("Error executing shell script: \(error)")
    }
}
