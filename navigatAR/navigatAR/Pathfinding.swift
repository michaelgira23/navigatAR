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
	
	func addConnections(to nodes: [GKNodeWrapper]) {
		addConnections(to: nodes, bidirectional: true)
		
		for node in nodes {
			costs[node] = Float(wrappedNode.position.distanceTo(node.wrappedNode.position))
			node.costs[self] = Float(node.wrappedNode.position.distanceTo(wrappedNode.position))
		}
	}
}

func populateGraph(rootSnapshot snapshot: DataSnapshot) -> (nodes: [FirebasePushKey: GKNodeWrapper], graph: GKGraph)? {
	guard let nodeValues = snapshot.childSnapshot(forPath: "nodes").value else { return nil }
	guard let allNodes = try? FirebaseDecoder().decode([FirebasePushKey: Node].self, from: nodeValues) else { return nil }
	let allWrappedNodes = allNodes.mapValues({ GKNodeWrapper(node: $0) })
	let graph = GKGraph(Array(allWrappedNodes.values))
	
	for node in allWrappedNodes.values {
		node.addConnections(to: (node.wrappedNode.connectedTo ?? []).flatMap { allWrappedNodes[$0] })
	}
	
	return (nodes: allWrappedNodes, graph: graph)
}

