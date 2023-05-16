//
//  Renderer.swift
//  MetalProject
//
//  Created by Sina Dashtebozorgy on 22/12/2022.
//

import Foundation
import Metal
import MetalKit
import AppKit














class Renderer : NSObject, MTKViewDelegate {
    
  
    
 
    let True = true
    let False = false
   
    
    let device: MTLDevice
    let commandQueue : MTLCommandQueue
    var cameraLists = [Camera]()
    
    let pipeline : pipeLine
   
    var frameSephamore = DispatchSemaphore(value: 1)
    var fps = 0
     var frameConstants = FrameConstants(viewMatrix: simd_float4x4(eye: simd_float3(0), center: simd_float3(0,0,-1), up: simd_float3(0,1,0)) , projectionMatrix: simd_float4x4(fovRadians: 3.14/2, aspectRatio: 2.0, near: 0.1, far: 50))
    
    let depthStencilState : MTLDepthStencilState
    
    
     var moveTriangle : Bool = true
    
    
   
    let gridMesh : GridMesh
    var camera : Camera
     
    var length : Float = 0.06
    let minBound = simd_float3(-3,-3,-16)
    let maxBound = simd_float3(3,3,-10)
    let voxelizedMesh : Voxel
    
    let testGBufferPipeLine : pipeLine
    let spotGBufferTestMesh : Mesh
    let depthRenderTargetGBuffer : MTLTexture
    let AlbedoRenderTargetGBuffer : MTLTexture
    let EyeNormalRenderTargetGBuffer : MTLTexture
    let EyePositionRenderTargetGBuffer : MTLTexture
    
    
    let testArgumentBufferPipeLine : MTLRenderPipelineState
    //let argumentBuffer : MTLBuffer
    
    
    let quadVertices : [Float] = [
        
        -1,-1,0,1, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0,
         1,-1,0,1, 0,0,0,0, 1,0,0,0, 0,0,0,0, 0,0,0,0,
         1,1,0,1,  0,0,0,0, 1,1,0,0, 0,0,0,0, 0,0,0,0,
         -1,1,0,1, 0,0,0,0, 0,1,0,0, 0,0,0,0, 0,0,0,0,
    ]
    
    let quadIndices : [uint16] = [
    
        0,1,2,
        0,2,3
        
    ]
    
    let fullScreenQuad : Mesh
    
    let meshShaderPipeline : MTLRenderPipelineState
    
    let computePipelineState : MTLComputePipelineState
    
    let inputTexture : MTLTexture
    
    let functionTable : MTLVisibleFunctionTable
    
    let frameBufferTexture : MTLTexture
    
    init?(mtkView: MTKView){
        
        
        device = mtkView.device!
        mtkView.preferredFramesPerSecond = 120
        commandQueue = device.makeCommandQueue()!
        mtkView.colorPixelFormat = .rgba8Unorm
        mtkView.depthStencilPixelFormat = .depth32Float
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.isDepthWriteEnabled = true
        depthStencilDescriptor.depthCompareFunction = .lessEqual
        depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor)!
        
        camera = Camera(for: mtkView, eye: simd_float3(0), centre: simd_float3(0,0,-1))
        cameraLists.append(camera)
           
        let vertexDescriptor = cushionedVertexDescriptor()
        let allocator = MTKMeshBufferAllocator(device: device)
        let cubeMDLMesh = MDLMesh(boxWithExtent: simd_float3(1,1,1), segments: simd_uint3(1,1,1), inwardNormals: false, geometryType: .triangles, allocator: allocator)
        
        pipeline = pipeLine(device, "render_vertex", "render_fragment", vertexDescriptor, false)!
       
        let halfLength : Float = length * 0.5
        
        gridMesh = GridMesh(device: device, minBound: minBound, maxBound: maxBound, length: length)
        
        
      
        
       
        
        voxelizedMesh = Voxel(device: device, address: "spot_triangulated", minmax: [minBound,maxBound], gridLength: length)
        
        testGBufferPipeLine = pipeLine(device, "gBuffer_vertex", "gBuffer_fragment", vertexDescriptor, false)!
        spotGBufferTestMesh = Mesh(device: device, address: "spot_triangulated")
        //spotGBufferTestMesh = Mesh(device: device, Mesh: cubeMDLMesh)!
        
        spotGBufferTestMesh.createInstance(with: create_modelMatrix(translation: simd_float3(0,0,-0.6),scale: simd_float3(1)))
        spotGBufferTestMesh.init_instance_buffers(with: camera.cameraMatrix)
        
        let width = Int(mtkView.drawableSize.width)
        let height = Int(1702)
        
        
        let depthTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .r32Float, width: width, height: height, mipmapped: true)
        depthTextureDescriptor.usage = [.shaderRead,.renderTarget]
        depthTextureDescriptor.storageMode = .memoryless
        depthTextureDescriptor.mipmapLevelCount = 10
        
        let albedoTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: mtkView.colorPixelFormat, width: width, height: height, mipmapped: true)
        albedoTextureDescriptor.usage = [.shaderRead, .renderTarget]
        albedoTextureDescriptor.storageMode = .memoryless
        albedoTextureDescriptor.mipmapLevelCount = 10
        
        let EyeNormalTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: width, height: height, mipmapped: true)
        EyeNormalTextureDescriptor.usage = [.shaderRead, .renderTarget]
        EyeNormalTextureDescriptor.storageMode = .memoryless
        EyeNormalTextureDescriptor.mipmapLevelCount = 10
        
        let EyePositionTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba32Float, width: width, height: height, mipmapped: true)
        EyePositionTextureDescriptor.usage = [.shaderRead, .renderTarget]
        EyePositionTextureDescriptor.storageMode = .memoryless
        EyePositionTextureDescriptor.mipmapLevelCount = 10
        
        depthRenderTargetGBuffer = device.makeTexture(descriptor: depthTextureDescriptor)!
        AlbedoRenderTargetGBuffer = device.makeTexture(descriptor: albedoTextureDescriptor)!
        EyeNormalRenderTargetGBuffer = device.makeTexture(descriptor: EyeNormalTextureDescriptor)!
        EyePositionRenderTargetGBuffer = device.makeTexture(descriptor: EyePositionTextureDescriptor)!
        
        let library = device.makeDefaultLibrary()!
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.colorAttachments[0].pixelFormat = .rgba8Unorm
        pipelineDescriptor.colorAttachments[1].pixelFormat = .rgba8Unorm
        pipelineDescriptor.colorAttachments[2].pixelFormat = .rgba8Unorm
        pipelineDescriptor.colorAttachments[3].pixelFormat = .rgba32Float
        pipelineDescriptor.colorAttachments[4].pixelFormat = .r32Float
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        pipelineDescriptor.vertexFunction = library.makeFunction(name: "deferred_vertex")
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        
        let fragmentFunction = library.makeFunction(name: "deferred_fragment")
//        let argumentEncoder = fragmentFunction?.makeArgumentEncoder(bufferIndex: 10)
//        argumentBuffer = device.makeBuffer(length: argumentEncoder!.encodedLength, options: [])!
//        argumentBuffer.label = "ArgumentBuffer"
//        argumentEncoder?.setArgumentBuffer(argumentBuffer, offset: 0)
//        argumentEncoder?.setTexture(AlbedoRenderTargetGBuffer, index: 0)
//        argumentEncoder?.setTexture(depthRenderTargetGBuffer, index: 1)
//        argumentEncoder?.setTexture(EyePositionRenderTargetGBuffer, index: 2)

        pipelineDescriptor.fragmentFunction = fragmentFunction
        
        testArgumentBufferPipeLine = try! device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        
        fullScreenQuad = Mesh(device: device, vertices: quadVertices, indices: quadIndices)
        fullScreenQuad.createInstance(with: create_modelMatrix(translation: simd_float3(0,0,-5)),and: simd_float4(0,1,0,1))
        fullScreenQuad.init_instance_buffers(with: camera.cameraMatrix)
        
        let worldPoint = simd_float4(0,0,-0.1,1)
        var screenPoint = frameConstants.projectionMatrix * worldPoint
        screenPoint = simd_float4(screenPoint.x / screenPoint.w, screenPoint.y / screenPoint.w, screenPoint.z / screenPoint.w, screenPoint.w / screenPoint.w)
        print("The screen point is : ", screenPoint)
        let inverse = frameConstants.projectionMatrix.inverse
        var worldPointRecovered = inverse * screenPoint
        worldPointRecovered = simd_float4(worldPointRecovered.x / worldPointRecovered.w, worldPointRecovered.y / worldPointRecovered.w, worldPointRecovered.z / worldPointRecovered.w, worldPointRecovered.w / worldPointRecovered.w)
        
        print("The recovered world point is : ", worldPointRecovered)
        print(inverse)
        
        let meshPD = MTLMeshRenderPipelineDescriptor()
        meshPD.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
        let objectFunction = library.makeFunction(name: "objectShader")
        meshPD.objectFunction = objectFunction
        meshPD.payloadMemoryLength = 32;
        meshPD.maxTotalThreadsPerObjectThreadgroup = 2
        
        let meshFunction = library.makeFunction(name: "meshShader")
        meshPD.meshFunction = meshFunction
        meshPD.maxTotalThreadsPerMeshThreadgroup = 193
        
        let meshFragmentFunction = library.makeFunction(name: "fragmentShader")
        meshPD.fragmentFunction = meshFragmentFunction
        
        do {
            meshShaderPipeline = try device.makeRenderPipelineState(descriptor: meshPD, options: []).0
        }
        catch {
            print("Mesh render pipeline failed to initialised")
            return nil
        }
        
        
        let inputTextureDC = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: mtkView.colorPixelFormat, width: 3026, height: 1716, mipmapped: false)
        inputTextureDC.usage = [.shaderWrite,.shaderRead]
        
        inputTexture = device.makeTexture(descriptor: inputTextureDC)!
        frameBufferTexture = device.makeTexture(descriptor: inputTextureDC)!
        
        
        let computeDC = MTLComputePipelineDescriptor()
        let kernel = library.makeFunction(name: "test_compute")
        computeDC.computeFunction = kernel
        
        let functionDC = MTLFunctionDescriptor()
        functionDC.name = "even"
        let even = try! library.makeFunction(descriptor: functionDC)
        functionDC.name = "odd"
        let odd = try! library.makeFunction(descriptor: functionDC)
        
        let linkedfunctions = MTLLinkedFunctions()
        linkedfunctions.functions = [odd,even]
        computeDC.linkedFunctions = linkedfunctions
        
        computePipelineState = try! device.makeComputePipelineState(descriptor: computeDC, options: [], reflection: nil)
        
        
        let vftDC = MTLVisibleFunctionTableDescriptor()
        vftDC.functionCount = 2
        functionTable = computePipelineState.makeVisibleFunctionTable(descriptor: vftDC)!
        
        let evenHandle = computePipelineState.functionHandle(function: even)
        functionTable.setFunction(evenHandle, index: 0)
        
        let oddHandle = computePipelineState.functionHandle(function: odd)
        functionTable.setFunction(oddHandle, index: 1)
        
        
        
        
    }
   
    // mtkView will automatically call this function
    // whenever it wants new content to be rendered.
    
    
   
    
    
    func draw(in view: MTKView) {
        
        frameSephamore.wait()
        frameConstants.viewMatrix = camera.cameraMatrix
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {return}
        commandBuffer.addCompletedHandler(){[self] _ in
            frameSephamore.signal()
        }
        
       
      
        guard let renderPass = view.currentRenderPassDescriptor else {return}
        renderPass.colorAttachments[0].clearColor = MTLClearColorMake(1, 1, 1, 1)
        renderPass.colorAttachments[0].texture = frameBufferTexture
        
        
        guard let computeEncoder = commandBuffer.makeComputeCommandEncoder() else {return}
        
        computeEncoder.setComputePipelineState(computePipelineState)
        computeEncoder.setTexture(inputTexture, index: 0)
        computeEncoder.setVisibleFunctionTable(functionTable, bufferIndex: 1)
        let threadCount = 10
        computeEncoder.dispatchThreads(MTLSize(width: threadCount, height: 1, depth: 1), threadsPerThreadgroup: MTLSize(width: 10, height: 10, depth: 1))
        computeEncoder.endEncoding()
        
//        guard let blitEncoder = commandBuffer.makeBlitCommandEncoder() else {return}
//        
//        
//        blitEncoder.copy(from: inputTexture, sourceSlice: 0, sourceLevel: 0, to: frameBufferTexture, destinationSlice: 0, destinationLevel: 0, sliceCount: 1, levelCount: 1)
//        blitEncoder.endEncoding()
        
        
        
        
        
        
//        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPass) else {return}
        
        
        
        
//        renderEncoder.setRenderPipelineState(meshShaderPipeline)
//        var input : [simd_float4] = [simd_float4(0,0,0,1)]
//        renderEncoder.setObjectBytes(&input, length: 32, index: 0)
//        let shaderThreads = MTLSize(width: 1, height: 1, depth: 1)
//        let objectThreads = MTLSize(width: 1, height: 1, depth: 1)
//        let meshThreads = MTLSize(width: 193, height: 1, depth: 1)
//        renderEncoder.drawMeshThreadgroups(shaderThreads, threadsPerObjectThreadgroup: objectThreads, threadsPerMeshThreadgroup: meshThreads)
//       renderEncoder.endEncoding()
        

      
        
        
//        guard let testGBufferRenderPassDescriptor = view.currentRenderPassDescriptor else {return}
//
//        testGBufferRenderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1, 1, 1, 1)
//
//
//        testGBufferRenderPassDescriptor.colorAttachments[1].texture = AlbedoRenderTargetGBuffer
//        testGBufferRenderPassDescriptor.colorAttachments[1].storeAction = .dontCare
//        testGBufferRenderPassDescriptor.colorAttachments[1].loadAction = .clear
//        testGBufferRenderPassDescriptor.colorAttachments[1].clearColor = MTLClearColorMake(1, 1, 1, 0)
//
//
//        testGBufferRenderPassDescriptor.colorAttachments[2].texture = EyeNormalRenderTargetGBuffer
//        testGBufferRenderPassDescriptor.colorAttachments[2].storeAction = .dontCare
//        testGBufferRenderPassDescriptor.colorAttachments[2].loadAction = .clear
//        testGBufferRenderPassDescriptor.colorAttachments[2].clearColor = MTLClearColorMake(1, 1, 1, 1)
//
//        testGBufferRenderPassDescriptor.colorAttachments[3].texture = EyePositionRenderTargetGBuffer
//        testGBufferRenderPassDescriptor.colorAttachments[3].storeAction = .dontCare
//        testGBufferRenderPassDescriptor.colorAttachments[3].loadAction = .clear
//        testGBufferRenderPassDescriptor.colorAttachments[3].clearColor = MTLClearColorMake(1, 1, 1, 1)
//
//        testGBufferRenderPassDescriptor.colorAttachments[4].texture = depthRenderTargetGBuffer
//        testGBufferRenderPassDescriptor.colorAttachments[4].storeAction = .dontCare
//        testGBufferRenderPassDescriptor.colorAttachments[4].loadAction = .clear
//        testGBufferRenderPassDescriptor.colorAttachments[4].clearColor = MTLClearColorMake(1, 1, 1, 1)
        
  
        
//        guard let GBufferRenderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: testGBufferRenderPassDescriptor) else {return}
//        GBufferRenderEncoder.setDepthStencilState(depthStencilState)
//        GBufferRenderEncoder.setFrontFacing(.counterClockwise)
//        GBufferRenderEncoder.setCullMode(.back)
//        GBufferRenderEncoder.setRenderPipelineState(testGBufferPipeLine.m_pipeLine)
//        GBufferRenderEncoder.setVertexBytes(&frameConstants, length: MemoryLayout<FrameConstants>.stride, index: vertexBufferIDs.frameConstant)
//
//        spotGBufferTestMesh.draw(renderEncoder: GBufferRenderEncoder)
//
//
//        let projecViewMatrix = frameConstants.projectionMatrix
//        var inverseProjViewMatrix = projecViewMatrix.inverse
//       // print(inverseProjViewMatrix)
//
//        GBufferRenderEncoder.setRenderPipelineState(testArgumentBufferPipeLine)
//        //GBufferRenderEncoder.setFragmentBuffer(argumentBuffer, offset: 0, index: 10)
//        GBufferRenderEncoder.setFragmentBytes(&inverseProjViewMatrix, length: MemoryLayout<simd_float4x4>.stride, index: 3)
//
//        GBufferRenderEncoder.setVertexBytes(&frameConstants, length: MemoryLayout<FrameConstants>.stride, index: vertexBufferIDs.frameConstant)
//
//        fullScreenQuad.draw(renderEncoder: GBufferRenderEncoder)
//
//
//        GBufferRenderEncoder.endEncoding()
        
        

        
        
       
        
        
        commandBuffer.present(view.currentDrawable!)
       
        commandBuffer.commit()
       
        fps+=1
        
        

       
    }

    // mtkView will automatically call this function
    // whenever the size of the view changes (such as resizing the window).
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
}
