//
//  ViewController.swift
//  NFCSampleProject
//
//  Created by Yani . on 13/12/24.
//

import UIKit
import CoreNFC

class ViewController: UIViewController {
    @IBOutlet var label: UILabel!
    @IBOutlet var button: UIButton!

    var session: NFCTagReaderSession? {
       return _session as? NFCTagReaderSession
    }
    var _session: Any?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.label.text = "Try press scan card"
        self.button.layer.cornerRadius = 20
        button.addTarget(self, action: #selector(scanNFC), for: .touchUpInside)
    }

    @objc
    private func scanNFC() {
        guard NFCTagReaderSession.readingAvailable else {
            print("Device does not support NFC")
            return
        }

        _session = NFCTagReaderSession(pollingOption: [.iso14443, .iso15693], delegate: self)
        session?.alertMessage = "Tap NFC Card to begin scan"
        session?.begin()
    }

    private func setLabel(_ type: String, desc: String) {
        DispatchQueue.main.async {
            self.label.text = "type: \(type) \n\(desc)"
        }
    }

}

extension ViewController: NFCTagReaderSessionDelegate {
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        print("Tag reader session did become active")
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        guard tags.count == 1 else {
            session.invalidate(errorMessage: "Please scan only 1 NFC Card")
            return
        }

        guard let tags = tags.first else {
            return
        }

        session.connect(to: tags) { (error: Error?) in
            if nil != error {
                if error?.localizedDescription == "Missing required entitlement" {
                    self.setLabel("unknown", desc: "")
                    session.invalidate(errorMessage: "Missing required entitlement")
                    return
                }
                print(error.debugDescription)
            }

            if case .miFare(let nFCMiFareTag) = tags {
                let identifier = nFCMiFareTag.identifier as NSData
                self.setLabel("mifare", desc: "\(identifier)")
                session.alertMessage = "Scan NFC Card Successfully"
                session.invalidate()
            }

            if case .iso15693(let nFCISO15693Tag) = tags {
                let identifier = nFCISO15693Tag.identifier as NSData
                self.setLabel("iso15693", desc: "\(identifier)")
                session.alertMessage = "Scan NFC Card Successfully"
                session.invalidate()
            }

            if case .iso7816(let nFCISO7816Tag) = tags {
                let identifier = nFCISO7816Tag.identifier as NSData
                self.setLabel("iso7816", desc: "\(identifier)")
                session.alertMessage = "Scan NFC Card Successfully"
                session.invalidate()
            }
        }
    }

}
