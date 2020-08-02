//
//  Renderer.swift
//  MetalBasic1
//
//  Created by garbage on 01/08/2020.
//  Copyright © 2020 tmcg. All rights reserved.
//

import Metal
import MetalKit


class Renderer : NSObject, MTKViewDelegate {
    
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    let view: MTKView
    let pipelineState: MTLRenderPipelineState
    let vertexBuffer: MTLBuffer?
    
    let vertices = [Vertex(position: [-1, -1, 0], color: [1, 0, 0, 1]),
    Vertex(position: [0, 1, 0], color: [0, 1, 0, 1]),
    Vertex(position: [1, -1, 0], color: [0, 0, 1, 1])]
    
    // This is the initializer for the Renderer class.
    // We will need access to the mtkView later, so we add it as a parameter here.
    init?(mtkView: MTKView) {
        view = mtkView
        device = mtkView.device!
        print("Renderer init, using device: \(device.name)")

        commandQueue = device.makeCommandQueue()!
        do {
            pipelineState = try Renderer.createPipeline(device: device, view: view)
        } catch {
            print("Unable to compile render pipeline state: \(error)")
            return nil
        }
        
        // a buffer sized vertex count times float size
        vertexBuffer = device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<Vertex>.size, options: [])
    }

    // mtkView will automatically call this function
    // whenever it wants new content to be rendered.
    func draw(in view: MTKView) {
        // Get an available command buffer
        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
        
        // Get the default MTLRenderPassDescriptor from the MTKView argument
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }

        // Change default settings. For example, we change the clear color from black to red.
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 1)
        
        // We compile renderPassDescriptor to a MTLRenderCommandEncoder.
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
        
        
        // use our pipelne
        renderEncoder.setRenderPipelineState(pipelineState)
        
        // the vertex buffer. Offset 0 so it is read from the beginning. Index 0 since it is the only VB we have as of now
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        
        // draw a triangle that is defined from the start of the VB along 3 vertices
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        
        // This finalizes the encoding of drawing commands.
        renderEncoder.endEncoding()
        
        // Tell Metal to send the rendering result to the MTKView when rendering completes
        commandBuffer.present(view.currentDrawable!)
        
        // Finally, send the encoded command buffer to the GPU.
        commandBuffer.commit()
    }

    // mtkView will automatically call this function
    // whenever the size of the view changes (such as resizing the window).
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {

    }
    
    // this is basically static function so it can be called from the init
    class func createPipeline(device: MTLDevice, view: MTKView) throws -> MTLRenderPipelineState {
        let library = device.makeDefaultLibrary()
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        pipelineDescriptor.vertexFunction = library?.makeFunction(name: "vertex_shader")
        pipelineDescriptor.fragmentFunction = library?.makeFunction(name: "fragment_shader")
        
        return try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
}
