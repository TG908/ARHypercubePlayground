//
//  MetalLiveViewController.swift
//
//  Created by Tim Gymnich on 14.03.18.
//  Copyright © 2018 Tim Gymnich. All rights reserved.
//

import UIKit
import ARKit
import MetalKit
import Metal
import PlaygroundSupport

extension MTKView : RenderDestinationProvider {}

@objc(MetalLiveViewController)
public class MetalLiveViewController: UIViewController, MTKViewDelegate, ARSessionDelegate, PlaygroundLiveViewSafeAreaContainer {
    
    var session: ARSession!
    var renderer: Renderer!
    var anchors: [ARAnchor] = []

    override public func viewDidLoad() {
        super.viewDidLoad()
        // Set the view's delegate
        session = ARSession()
        session.delegate = self

        // Set the view to use the default device
        if let view = self.view as? MTKView {
            view.device = MTLCreateSystemDefaultDevice()
            view.backgroundColor = UIColor.clear
            view.delegate = self

            guard view.device != nil else {
                NSLog("Metal is not supported on this device")
                return
            }

            // Configure the renderer to draw to the view
            renderer = Renderer(session: session, metalDevice: view.device!, renderDestination: view)
            renderer.drawRectResized(size: view.bounds.size)
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(MetalLiveViewController.handleTap(gestureRecognize:)))
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(MetalLiveViewController.handlePan(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
        view.addGestureRecognizer(panGesture)
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        session.run(configuration)
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Pause the view's session
        session.pause()
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    static public func makeFromStoryboard() -> MetalLiveViewController {
        let bundle = Bundle(for: MetalLiveViewController.self)
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        return storyboard.instantiateViewController(withIdentifier: "MetalLiveViewController") as! MetalLiveViewController
    }

    @objc
    func handleTap(gestureRecognize: UITapGestureRecognizer) {
        // Create anchor using the camera's current position
        if let currentFrame = session.currentFrame {

            // Create a transform with a translation of 1 meter in front of the camera
            var translation = matrix_identity_float4x4
            translation.columns.3.z = -1
            let transform = simd_mul(currentFrame.camera.transform, translation)

            // Add a new anchor to the session and remove all the old anchors
            let anchor = ARAnchor(transform: transform)
            anchors.forEach { session.remove(anchor: $0) }
            session.add(anchor: anchor)
            anchors.append(anchor)
        }
    }
    
    @objc
    func handlePan(gestureRecognizer: UIPanGestureRecognizer) {
        
        let velocity = gestureRecognizer.velocity(in: self.view)
        
        renderer.rotationX += Float(velocity.x) / 10000
        renderer.rotationY += Float(velocity.y) / 10000
    }
    
    public func changeRotationAxis(horizontal: Plane4D, vertical: Plane4D) {
        renderer.horizontalPlane = horizontal
        renderer.verticalPlane = vertical
    }

    // MARK: - MTKViewDelegate

    // Called whenever view changes orientation or layout is changed
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        renderer.drawRectResized(size: size)
    }

    // Called whenever the view needs to render
    public func draw(in view: MTKView) {
        renderer.update()
    }

    // MARK: - ARSessionDelegate

    public func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user

    }

    public func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay

    }

    public func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required

    }
}


