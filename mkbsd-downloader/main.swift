//
//  m.swift
//  mkbsd-downloader
//
//  Created by Thomas Kackley on 9/24/24.
//

import Foundation

// Helper function for delays
func delay(_ milliseconds: Int) {
    Thread.sleep(forTimeInterval: Double(milliseconds) / 1000.0)
}

// Function to download JSON and images
func main() {
    let urlString = "https://storage.googleapis.com/panels-api/data/20240916/media-1a-i-p~s"
    guard let url = URL(string: urlString) else {
        print("⛔ Invalid URL.")
        return
    }
    
    let downloadDir = try! FileManager.default.url(for: .downloadsDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        .appendingPathComponent("panels-download").path()
    
    print(downloadDir)
    
    
    if !FileManager.default.fileExists(atPath: downloadDir) {
        do {
            try FileManager.default.createDirectory(atPath: downloadDir, withIntermediateDirectories: true)
            print("📁 Created directory: \(downloadDir)")
        } catch {
            print("⛔ Failed to create directory: \(error.localizedDescription)")
            return
        }
    }
    
    do {
        // Fetch JSON synchronously
        let jsonData = try Data(contentsOf: url)
        if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
           let data = json["data"] as? [String: Any] {
            
            var fileIndex = 1
            for (_, subproperty) in data {
                if let subpropertyDict = subproperty as? [String: Any],
                   let imageUrlString = subpropertyDict["dhd"] as? String,
                   let imageUrl = URL(string: imageUrlString) {
                    print("🔍 Found image URL!")
                    
                    delay(100) // Slight delay before downloading
                    
                    let ext = imageUrl.pathExtension.isEmpty ? ".jpg" : ".\(imageUrl.pathExtension)"
                    let filename = "\(fileIndex)\(ext)"
                    let filePath = "\(downloadDir)/\(filename)"
                    
                    do {
                        try downloadImage(from: imageUrl, to: filePath)
                        print("🖼️ Saved image to \(filePath)")
                        fileIndex += 1
                    } catch {
                        print("⛔ Failed to download image: \(error.localizedDescription)")
                    }
                    
                    delay(250) // Slight delay between image downloads
                }
            }
        } else {
            print("⛔ JSON does not have a 'data' property at its root.")
        }
    } catch {
        print("⛔ Failed to fetch JSON or parse it: \(error.localizedDescription)")
    }
}

// Function to download an image synchronously
func downloadImage(from url: URL, to filePath: String) throws {
    let imageData = try Data(contentsOf: url) // Download image data synchronously
    try imageData.write(to: URL(fileURLWithPath: filePath)) // Write data to file
}

// ASCII art function
func asciiArt() {
    print("""
     /$$      /$$ /$$   /$$ /$$$$$$$   /$$$$$$  /$$$$$$$
    | $$$    /$$$| $$  /$$/| $$__  $$ /$$__  $$| $$__  $$
    | $$$$  /$$$$| $$ /$$/ | $$  \\ $$| $$  \\__/| $$  \\ $$
    | $$ $$/$$ $$| $$$$$/  | $$$$$$$ |  $$$$$$ | $$  | $$
    | $$  $$$| $$| $$  $$  | $$__  $$ \\____  $$| $$  | $$
    | $$\\  $ | $$| $$\\  $$ | $$  \\ $$ /$$  \\ $$| $$  | $$
    | $$ \\/  | $$| $$ \\  $$| $$$$$$$/|  $$$$$$/| $$$$$$$/
    |__/     |__/|__/  \\__/|_______/  \\______/ |_______/
    """)
    print("")
    print("🤑 Starting downloads from your favorite sellout grifter's wallpaper app...")
}

// Entry point
func start() {
    asciiArt()
    delay(5000) // Delay before starting downloads
    main()
}

start()
