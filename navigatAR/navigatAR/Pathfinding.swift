//
//  Pathfinding.swift
//  navigatAR
//
//  Created by Nick Clifford on 2/15/18.
//  Copyright © 2018 MICDS Programming. All rights reserved.
//

import CodableFirebase
import Firebase
import GameplayKit

class GKNodeWrapper: GKGraphNode {
	let wrappedNode: Node
	var costs: [GKGraphNode: Float] = [:]
	
	init(node: Node) {
		wrappedNode = node
		super.init()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func cost(to node: GKGraphNode) -> Float {
		return costs[node] ?? 0
	}
	
	func addConnection(to nodes: [GKNodeWrapper]) {
		addConnections(to: nodes, bidirectional: true)
		
		for node in nodes {
			costs[node] = Float(wrappedNode.position.distanceTo(node.wrappedNode.position))
			node.costs[self] = Float(node.wrappedNode.position.distanceTo(wrappedNode.position))
		}
	}
}

