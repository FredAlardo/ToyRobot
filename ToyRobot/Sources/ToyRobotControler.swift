//
//  ToyRobotControler.swift
//  ToyRobot
//
//  Created by Fred Alardo on 20/3/2022.
//

import Foundation
import UIKit

protocol ToyRobotControlerDelegate: AnyObject {
	func didSelectShip()
	func move()
	func turn(_ isLeft: Bool)
	func place()
	func reportCommand(msg: String)
}

class ToyRobotControler {
	private var _shipType: SpaceshipType = .Blue
	weak var delegate: ToyRobotControlerDelegate?
	
	var face: CardinalCoord = .North
	var shipPosition: (x: Int, y: Int)? = nil
	
	var shipType: SpaceshipType {
		get {
			return _shipType
		}
		set {
			_shipType = newValue
			if let delegate = delegate {
				delegate.didSelectShip()
			}
		}
	}
	
	func reset() {
		shipPosition = nil
	}
	
	func processCommand(_ command: String?) {
		if let text = command?.trimmingCharacters(in: [" "]).localizedLowercase {
			if text == "move" {
				moveForward()
			} else if text == "left" {
				turnLeft()
			} else if text == "right" {
				turnRight()
			} else if text == "report" {
				report()
			} else if text.starts(with: "place ") {
				processPlaceCommand(text)
			} else {
				invalidCommand()
			}
		} else {
			invalidCommand()
		}
	}
	
	func processPlaceCommand(_ command: String) {
		var cmd = command.trimmingCharacters(in: [" "]).localizedLowercase
		if cmd.starts(with: "place ") {
			cmd = cmd.replacingOccurrences(of: "place ", with: "")
			let values = cmd.split(separator: ",")
			if (shipPosition == nil && values.count == 3) || (shipPosition != nil && values.count > 1) {
				let x = Int(values[0].trimmingCharacters(in: [" "]))
				let y = Int(values[1].trimmingCharacters(in: [" "]))
				var facing: CardinalCoord? = nil
				if (values.count == 3) {
					let facingIndex = CardinalCoord.allCases.firstIndex(where: {$0.rawValue.localizedCaseInsensitiveContains(values[2].trimmingCharacters(in: [" "]))})
					if let _facingIndex = facingIndex {
						facing = CardinalCoord.allCases[_facingIndex]
					}
				}
				if let _ = x, let _ = y {
					place(position: (x: x!, y: y!), face: facing)
				} else {
					invalidCommand("Ilegal placement")
				}
			} else {
				invalidCommand("Ilegal placement")
			}
		}
	}
	
	func place(position: (x: Int, y: Int), face: CardinalCoord?) {
		let columnRange = 0...maxColumns
		let rowRange = 0...maxRows
		if columnRange.contains(position.x) && rowRange.contains(position.y) {
			if let _face = face {
				self.face = _face
			}
			self.shipPosition = position
			if let delegate = delegate {
				delegate.place()
			}
		} else {
			invalidCommand("Ilegal placement")
		}
	}
	
	func moveForward() {
		if let _ = shipPosition {
			var canMove: Bool = false
			switch face {
				case .North:
					canMove = shipPosition!.y < maxRows - 1
					shipPosition!.y += canMove ? 1 : 0
				case .East:
					canMove = shipPosition!.x < maxColumns - 1
					shipPosition!.x += canMove ? 1 : 0
				case .South:
					canMove = shipPosition!.y > 0
					shipPosition!.y += canMove ? -1 : 0
				case .West:
					canMove = shipPosition!.x > 0
					shipPosition!.x += canMove ? -1 : 0
			}
			if canMove {
				if let delegate = delegate {
					delegate.move()
				}
			} else {
				invalidCommand("Ilegal move")
			}
		} else {
			invalidCommand("PLACE first")
		}
	}
	
	func report() {
		if let delegate = delegate {
			let _position = shipPosition != nil ? "\(shipPosition!.x), \(shipPosition!.y)" : "No position"
			delegate.reportCommand(msg: "Output: \(_position), \(face.rawValue)")
		}
	}
	
	func turnLeft() {
		if let _ = shipPosition {
			face.previous()
			if let delegate = delegate {
				delegate.turn(true)
			}
		} else {
			invalidCommand("PLACE first")
		}
	}
	
	func turnRight() {
		if let _ = shipPosition {
			face.next()
			if let delegate = delegate {
				delegate.turn(false)
			}
		} else {
			invalidCommand("PLACE first")
		}
	}
	
	func invalidCommand(_ msg: String = "Unrecognised command") {
		if let delegate = delegate {
			delegate.reportCommand(msg: msg)
		}
	}
}
