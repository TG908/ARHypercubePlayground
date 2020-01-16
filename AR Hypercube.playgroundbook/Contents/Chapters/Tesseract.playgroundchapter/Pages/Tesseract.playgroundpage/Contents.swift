//#-hidden-code
//
//  Contents.swift
//
//  Created by Tim Gymnich on 14.03.18.
//  Copyright © 2018 Tim Gymnich. All rights reserved.
//

import PlaygroundSupport
import UIKit

let page = PlaygroundPage.current
let liveViewController: MetalLiveViewController = MetalLiveViewController.makeFromStoryboard()
page.needsIndefiniteExecution = true
page.liveView = liveViewController

//#-end-hidden-code
/*:
**What is a tesseract?**
 
A tesseract is a 4 dimensional cube. Meaning it is comprised of 8 cubes just like a cube consists of 6 squares. Those faces are called hyperfaces. A tesseract has in total 8 [cells](glossary://cell), 24 [faces](glossary://face), 32 [edges](glossary://edge) and 16 [vertices](glossary://vertex).


 **How does this playground work?**
 
To visualize the tesseract on a 2D Screen we have to perform 2 perspective [projections](glossary://projection).
The first projection projects our 4D Object into a 3D cube. This 3D cube is then projected on a 2D plane which is what you see in the playground. The camera looking at the 3D cube is then moved based upon device movement, and the 4D cube is rotated on the XW and ZW [plane](glossary://plane) when you swipe your finger across the screen.

**Let's have some fun!**
 
Just tap the screen to create a tesseract.
Try rotating the tesseract with your finger. Go arround the tesseract and make sure to go inside.
The inner cube is colored red and the outer cube is colored green.
 */

// Rotation axis
liveViewController.changeRotationAxis(horizontal: .XW, vertical: .ZW)


