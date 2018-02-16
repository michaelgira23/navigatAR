//
//  UIViewExtensions.swift
//  navigatAR
//
//  Created by Michael Gira on 2/4/18.
//  Copyright © 2018 MICDS Programming. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
	func fadeIn(_ duration: TimeInterval = 0.1, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
		UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations: {
			self.alpha = 1.0
		}, completion: completion)  }

	func fadeOut(_ duration: TimeInterval = 0.1, delay: TimeInterval = 0.0, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in}) {
		UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations: {
			self.alpha = 0.0
		}, completion: completion)
	}
}
