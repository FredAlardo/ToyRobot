//
//  BoardLayer.swift
//  ToyRobot
//
//  Created by Fred Alardo on 20/3/2022.
//

import Foundation
import UIKit
import GLKit

class BoardLayer: CALayer {
	private var grid: [CALayer] = []
	private var shipLayer: CALayer!
	private var shipType: SpaceshipType!
	private var shipAngle: CGFloat = 0
	
	var isPlaced: Bool = false
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	init(_ parentImg: UIImageView) {
		super.init()
		self.frame = parentImg.bounds
		parentImg.layer.borderWidth = 3
		parentImg.layer.borderColor = UIColor.link.cgColor
		parentImg.layer.cornerRadius = 10
		parentImg.layer.addSublayer(self)
		setupGridLayout()
		setupRocketLayout()
	}
	
	func reset() {
		shipAngle = 0
		isPlaced = false
		shipType = .Blue
		shipLayer.contents = nil
	}
	
	func setupRocketLayout() {
		shipLayer = CALayer()
		if let cell = grid.first(where: {$0.name == "0:0"}) {
			shipLayer.frame = cell.frame
			shipLayer.backgroundColor = UIColor.clear.cgColor
		}
		self.addSublayer(shipLayer)
	}
	
	func setupGridLayout() {
		var position: CGPoint = CGPoint(x: self.frame.origin.x, y: self.frame.origin.y)
		let cellSize: CGSize = CGSize(width: (self.frame.width / CGFloat(maxColumns)), height: (self.frame.height / CGFloat(maxRows)))
		for column in 0...maxColumns - 1 {
			for row in 0...maxRows - 1 {
				var isClear: Bool = false
				let x = (cellSize.width * CGFloat(column))
				let y = (cellSize.height * CGFloat(row))
				position = CGPoint(x: x, y: y)
				
				if column.isMultiple(of: 2) {
					isClear = row.isMultiple(of: 2)
				} else {
					isClear = !row.isMultiple(of: 2)
				}
				
				let layer = CALayer()
				layer.frame = CGRect(origin: position, size: cellSize)
				layer.backgroundColor = isClear ? UIColor.clear.cgColor : UIColor.black.cgColor
				layer.opacity = 0.7
				layer.name = "\(column):\(abs(maxRows - 1 - row))"
				grid.append(layer)
				self.addSublayer(layer)
			}
		}
	}
	
	func updateShipt(ship: SpaceshipType) {
		if isPlaced {
			shipType = ship
			shipLayer.contents = shipType.getImage()?.cgImage
		}
	}
	
	func placeShip(position: (x: Int, y: Int), ship: SpaceshipType, face: CardinalCoord) {
		shipLayer.contents = nil
		shipAngle = 0
		switch face {
			case .North:
				shipAngle = 0
			case .East:
				shipAngle = 90
			case .South:
				shipAngle = 180
			case .West:
				shipAngle = -90
		}
		isPlaced = true
		updatePosition(position: position)
		rotatePosition(angle: 0)
		updateShipt(ship: ship)
	}
	
	func rotatePosition(angle: CGFloat) {
		if isPlaced {
			shipAngle += angle
			shipLayer.transform = CATransform3DMakeRotation(shipAngle / 180.0 * .pi, 0.0, 0.0, 1.0)
		}
	}
	
	func updatePosition(position: (x: Int, y: Int)?) {
		guard let _position = position else {
			return
		}
		
		if let cell = grid.first(where: { $0.name == "\(_position.x):\(_position.y)" }) {
			shipLayer.frame = cell.frame
		}
	}
	
	override func hitTest(_ p: CGPoint) -> CALayer? {
		var selectedLayer: CALayer? = nil
		for cell in grid where selectedLayer == nil {
			if let _cell = cell.hitTest(p) {
				selectedLayer = _cell
			}
		}
		return selectedLayer
	}
}
