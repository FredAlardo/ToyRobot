//
//  Global.Enums.swift
//  ToyRobot
//
//  Created by Fred Alardo on 20/3/2022.
//

import UIKit

let maxColumns: Int = 6
let maxRows: Int = 6

enum CardinalCoord : String, CaseIterable {
	case North = "North"
	case East = "East"
	case South = "South"
	case West = "West"
	
	mutating func next() {
		let allCases = type(of: self).allCases
		self = allCases[(allCases.firstIndex(of: self)! + 1) % allCases.count]
	}
	
	mutating func previous() {
		let allCases = type(of: self).allCases
		let _index = (self == .North) ? allCases.count - 1 : allCases.firstIndex(of: self)! - 1
		self = allCases[_index % allCases.count]
	}
}

enum SpaceshipType : Int, CaseIterable {
	case Blue = 1
	case Red = 2
	case Green = 3
	case Yellow = 4
	
	func getImage() -> UIImage? {
		switch self {
			case .Blue:
				return UIImage(named: "spacecraft_blue")
			case .Red:
				return UIImage(named: "spacecraft_red")
			case .Green:
				return UIImage(named: "spacecraft_green")
			case .Yellow:
				return UIImage(named: "spacecraft_yellow")
		}
	}
}
