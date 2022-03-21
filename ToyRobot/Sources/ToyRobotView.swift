//
//  ToyRobotVC.swift
//  ToyRobot
//
//  Created by Fred Alardo on 20/3/2022.
//

import UIKit

class ToyRobotView: UIViewController {
	@IBOutlet weak var consoleInput: UITextField!
	@IBOutlet weak var yellowShip: UIButton!
	@IBOutlet weak var greenShip: UIButton!
	@IBOutlet weak var redShip: UIButton!
	@IBOutlet weak var blueShip: UIButton!
	@IBOutlet weak var reportText: UITextView!
	@IBOutlet weak var boardImageView: UIImageView!
	@IBOutlet weak var facingLbl: UILabel!
	@IBOutlet weak var clearReport: UIButton!
	
	private var board: BoardLayer!
	private var toyRobotControler: ToyRobotControler = ToyRobotControler()
	private var shipBtn: [(spaceship: SpaceshipType, btn: UIButton)] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		toyRobotControler.delegate = self
		consoleInput.delegate = self
		consoleInput.becomeFirstResponder()
		updateReport(nil, clear: true)
		board = BoardLayer(boardImageView)
		initialise()
		boardImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(layerTap(_:))))
	}
	
	@objc func layerTap(_ sender: UITapGestureRecognizer) {
		guard sender.state == .ended, let tappedView = sender.view else { return }

		let location = sender.location(in: tappedView)
		let hitTestLocation = tappedView.layer.superlayer!.convert(location, from: tappedView.layer)
		if let layer = tappedView.layer.hitTest(hitTestLocation) {
			print("Hit test returned <\(layer.name ?? "unknown")> with frame \(layer.frame)")
			if let name = layer.name, toyRobotControler.shipPosition == nil {
				let values = name.split(separator: ":")
				toyRobotControler.place(position: (x: Int(values[0]) ?? 0, y: Int(values[1]) ?? 0), face: toyRobotControler.face)
			}
		}
	}
	
	@IBAction func spaceshipBTnTapped(_ sender: UIButton) {
		switch sender {
			case blueShip:
				toyRobotControler.shipType = .Blue
			case redShip:
				toyRobotControler.shipType = .Red
			case yellowShip:
				toyRobotControler.shipType = .Yellow
			default:
				toyRobotControler.shipType = .Green
		}
	}
	
	@IBAction func moveBtnTapped(_ sender: Any) {
		toyRobotControler.moveForward()
	}
	
	@IBAction func leftBtnTapped(_ sender: Any) {
		toyRobotControler.turnLeft()
	}
	
	@IBAction func rightBtnTapped(_ sender: Any) {
		toyRobotControler.turnRight()
	}
	
	@IBAction func validateBtnTapped(_ sender: Any) {
		toyRobotControler.processCommand(consoleInput.text)
	}
	
	@IBAction func clearReportTapped(_ sender: Any) {
		updateReport(nil, clear: true)
	}
	
	@IBAction func reportTapped(_ sender: Any) {
		toyRobotControler.report()
	}
	
	@IBAction func resetTapped(_ sender: Any) {
		toyRobotControler.reset()
		board.reset()
		updateReport(nil, clear: true)
	}
	
	func updateSpaceShipSelection() {
		for item in shipBtn {
			if item.spaceship == toyRobotControler.shipType {
				item.btn.layer.cornerRadius = 10
				item.btn.layer.backgroundColor = UIColor.link.cgColor
				board.updateShipt(ship: item.spaceship)
			} else {
				item.btn.layer.backgroundColor = UIColor.clear.cgColor
			}
		}
	}
	
	func updateFacing() {
		switch toyRobotControler.face {
			case .North:
				facingLbl.text = "N"
			case .East:
				facingLbl.text = "E"
			case .South:
				facingLbl.text = "S"
			case .West:
				facingLbl.text = "W"
		}
	}
	
	func initialise () {
		for item in SpaceshipType.allCases {
			switch item {
				case .Blue:
					shipBtn.append((spaceship: .Blue, btn: blueShip))
				case .Red:
					shipBtn.append((spaceship: .Red, btn: redShip))
				case .Green:
					shipBtn.append((spaceship: .Green, btn: greenShip))
				case .Yellow:
					shipBtn.append((spaceship: .Yellow, btn: yellowShip))
			}
		}
		updateSpaceShipSelection()
		updateFacing()
	}
	
	func updateReport(_ text: String?, clear: Bool = false) {
		if clear {
			reportText.text = ""
		}
		if let _text = text {
			reportText.text.append("\n> \(_text)")
		}
		clearReport.isHidden = reportText.text.isEmpty
		consoleInput.text = nil
	}

}

// MARK: - ToyRobotControlerDelegate
extension ToyRobotView: ToyRobotControlerDelegate {
	func reportCommand(msg: String) {
		updateReport(msg)
	}
	
	func move() {
		updateReport("MOVE")
		board.updatePosition(position: toyRobotControler.shipPosition)
	}
	
	func turn(_ isLeft: Bool) {
		updateReport(isLeft ? "LEFT" : "RIGHT")
		updateFacing()
		board.rotatePosition(angle: isLeft ? -90 : 90)
	}
	
	func place() {
		updateReport("PLACE \(toyRobotControler.shipPosition!.x), \(toyRobotControler.shipPosition!.y), \(toyRobotControler.face.rawValue)")
		updateFacing()
		board.placeShip(position: toyRobotControler.shipPosition!, ship: toyRobotControler.shipType, face: toyRobotControler.face)
	}
	
	func didSelectShip() {
		updateSpaceShipSelection()
	}
}

// MARK: - UITextFieldDelegate
extension ToyRobotView: UITextFieldDelegate {
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		toyRobotControler.processCommand(textField.text)
		textField.text = nil
		return false
	}
}

