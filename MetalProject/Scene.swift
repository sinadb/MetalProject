//
//  Scene.swift
//  MetalProject
//
//  Created by Sina Dashtebozorgy on 03/04/2023.
//

import Foundation
import Metal
import MetalKit
import AppKit



func cushionedVertexDescriptor() -> MTLVertexDescriptor {
    
    let posAttrib = Attribute(format: .float4, offset: 0, length: 16, bufferIndex: 0)

    let normalAttrib = Attribute(format: .float4, offset: MemoryLayout<Float>.stride*4,length: 16, bufferIndex: 0)
    let texAttrib = Attribute(format: .float4, offset: MemoryLayout<Float>.stride*8, length : 16, bufferIndex: 0)
    let tangentAttrib = Attribute(format: .float4, offset: MemoryLayout<Float>.stride*12, length : 16, bufferIndex: 0)
    let bitangentAttrib = Attribute(format: .float4, offset: MemoryLayout<Float>.stride*16, length : 16, bufferIndex: 0)
   
    
    
    return createVertexDescriptor(attributes: posAttrib,normalAttrib,texAttrib,tangentAttrib,bitangentAttrib)
}


func generalVertexDescriptor() -> MTLVertexDescriptor {
    
    let posAttrib = Attribute(format: .float4, offset: 0, length: 16, bufferIndex: 0)
    let normalAttrib = Attribute(format: .float3, offset: MemoryLayout<Float>.stride*4,length: 12, bufferIndex: 0)
    let texAttrib = Attribute(format: .float2, offset: MemoryLayout<Float>.stride*7, length : 8, bufferIndex: 0)
    let tangentAttrib = Attribute(format: .float4, offset: MemoryLayout<Float>.stride*9, length : 16, bufferIndex: 0)
    let bitangentAttrib = Attribute(format: .float4, offset: MemoryLayout<Float>.stride*13, length : 16, bufferIndex: 0)
   
    
    
    return createVertexDescriptor(attributes: posAttrib,normalAttrib,texAttrib,tangentAttrib,bitangentAttrib)
}


func generalTextureSampler(device : MTLDevice) -> MTLSamplerState {
    let samplerDC = MTLSamplerDescriptor()
    samplerDC.magFilter = .linear
    samplerDC.minFilter = .linear
    samplerDC.rAddressMode = .clampToEdge
    samplerDC.sAddressMode = .clampToEdge
    samplerDC.tAddressMode = .clampToEdge
    samplerDC.normalizedCoordinates = true
    
    return device.makeSamplerState(descriptor: samplerDC)!
}

func createPipelineForDisplacementMapping(device : MTLDevice, vertexDescriptor : MTLVertexDescriptor) -> pipeLine {
    var False = false
    var True = true
    let tempFC = functionConstant()
    
    vertexDescriptor.layouts[0].stepFunction = .perPatchControlPoint
    vertexDescriptor.layouts[0].stepRate = 1
    
    tempFC.setValue(type: .bool, value: &False, at: FunctionConstantValues.cube)
    tempFC.setValue(type: .bool, value: &True, at: FunctionConstantValues.flat)
    tempFC.setValue(type: .bool, value: &False, at: FunctionConstantValues.constant_colour)
    tempFC.setValue(type: .bool, value: &False, at: FunctionConstantValues.is_skyBox)
    tempFC.setValue(type: .bool, value: &True, at: FunctionConstantValues.has_normalMap)
    tempFC.setValue(type: .bool, value: &True, at: FunctionConstantValues.has_displacementMap)
    tempFC.setValue(type: .bool, value: &False, at: FunctionConstantValues.shadow_map)
    
    return pipeLine(device, "post_tesselation_tri", "simple_shader_fragment", vertexDescriptor, tempFC.functionConstant, tesselation: true)!
}


func createPipelineForNormalMappedMesh(device : MTLDevice, vertexDescriptor : MTLVertexDescriptor) -> pipeLine {
    
    var False = false
    var True = true
    let tempFC = functionConstant()
    
    
    tempFC.setValue(type: .bool, value: &False, at: FunctionConstantValues.cube)
    tempFC.setValue(type: .bool, value: &True, at: FunctionConstantValues.flat)
    tempFC.setValue(type: .bool, value: &False, at: FunctionConstantValues.constant_colour)
    tempFC.setValue(type: .bool, value: &False, at: FunctionConstantValues.is_skyBox)
    tempFC.setValue(type: .bool, value: &True, at: FunctionConstantValues.has_normalMap)
    tempFC.setValue(type: .bool, value: &False, at: FunctionConstantValues.has_displacementMap)
    tempFC.setValue(type: .bool, value: &False, at: FunctionConstantValues.shadow_map)
    
    return pipeLine(device, "simple_shader_vertex", "simple_shader_fragment", vertexDescriptor, tempFC.functionConstant)!
    
    
}

func createPipelineForFlatTexturedMesh(device : MTLDevice, vertexDescriptor : MTLVertexDescriptor) -> pipeLine {
    
    var False = false
    var True = true
    let tempFC = functionConstant()
    
    
    tempFC.setValue(type: .bool, value: &False, at: FunctionConstantValues.cube)
    tempFC.setValue(type: .bool, value: &True, at: FunctionConstantValues.flat)
    tempFC.setValue(type: .bool, value: &False, at: FunctionConstantValues.constant_colour)
    tempFC.setValue(type: .bool, value: &False, at: FunctionConstantValues.is_skyBox)
    tempFC.setValue(type: .bool, value: &False, at: FunctionConstantValues.has_normalMap)
    tempFC.setValue(type: .bool, value: &False, at: FunctionConstantValues.has_displacementMap)
    tempFC.setValue(type: .bool, value: &False, at: FunctionConstantValues.shadow_map)
    
    return pipeLine(device, "simple_shader_vertex", "simple_shader_fragment", vertexDescriptor, tempFC.functionConstant)!
    
    
}

func createPipelineForShadowMapping(device : MTLDevice, vertexDescriptor : MTLVertexDescriptor) -> pipeLine {
    var False = false
    var True = true
    let tempFC = functionConstant()
    
    
    tempFC.setValue(type: .bool, value: &False, at: FunctionConstantValues.cube)
    tempFC.setValue(type: .bool, value: &False, at: FunctionConstantValues.flat)
    tempFC.setValue(type: .bool, value: &False, at: FunctionConstantValues.constant_colour)
    tempFC.setValue(type: .bool, value: &False, at: FunctionConstantValues.is_skyBox)
    tempFC.setValue(type: .bool, value: &False, at: FunctionConstantValues.has_normalMap)
    tempFC.setValue(type: .bool, value: &False, at: FunctionConstantValues.has_displacementMap)
    tempFC.setValue(type: .bool, value: &True, at: FunctionConstantValues.shadow_map)
    
    return pipeLine(device, "simple_shader_vertex", "simple_shader_fragment", vertexDescriptor, tempFC.functionConstant)!
}

func createPipelineForShadowsWithColour(device : MTLDevice, vertexDescriptor : MTLVertexDescriptor) -> pipeLine {
    var False = false
    var True = true
    let tempFC = functionConstant()
    
    
    tempFC.setValue(type: .bool, value: &False, at: FunctionConstantValues.cube)
    tempFC.setValue(type: .bool, value: &False, at: FunctionConstantValues.flat)
    tempFC.setValue(type: .bool, value: &True, at: FunctionConstantValues.constant_colour)
    tempFC.setValue(type: .bool, value: &False, at: FunctionConstantValues.is_skyBox)
    tempFC.setValue(type: .bool, value: &False, at: FunctionConstantValues.has_normalMap)
    tempFC.setValue(type: .bool, value: &False, at: FunctionConstantValues.has_displacementMap)
    tempFC.setValue(type: .bool, value: &True, at: FunctionConstantValues.shadow_map)
    
    return pipeLine(device, "simple_shader_vertex", "shadow_fragment", vertexDescriptor, tempFC.functionConstant)!
}

func createPipelineForShadowsWithFlatTexture(device : MTLDevice, vertexDescriptor : MTLVertexDescriptor) -> pipeLine {
    var False = false
    var True = true
    let tempFC = functionConstant()
    
    
    tempFC.setValue(type: .bool, value: &False, at: FunctionConstantValues.cube)
    tempFC.setValue(type: .bool, value: &True, at: FunctionConstantValues.flat)
    tempFC.setValue(type: .bool, value: &False, at: FunctionConstantValues.constant_colour)
    tempFC.setValue(type: .bool, value: &False, at: FunctionConstantValues.is_skyBox)
    tempFC.setValue(type: .bool, value: &False, at: FunctionConstantValues.has_normalMap)
    tempFC.setValue(type: .bool, value: &False, at: FunctionConstantValues.has_displacementMap)
    tempFC.setValue(type: .bool, value: &True, at: FunctionConstantValues.shadow_map)
    
    return pipeLine(device, "simple_shader_vertex", "shadow_fragment", vertexDescriptor, tempFC.functionConstant)!
}

func createPipelineForShadowsWithNormalMap(device : MTLDevice, vertexDescriptor : MTLVertexDescriptor) -> pipeLine {
    var False = false
    var True = true
    let tempFC = functionConstant()
    
    
    tempFC.setValue(type: .bool, value: &False, at: FunctionConstantValues.cube)
    tempFC.setValue(type: .bool, value: &True, at: FunctionConstantValues.flat)
    tempFC.setValue(type: .bool, value: &False, at: FunctionConstantValues.constant_colour)
    tempFC.setValue(type: .bool, value: &False, at: FunctionConstantValues.is_skyBox)
    tempFC.setValue(type: .bool, value: &True, at: FunctionConstantValues.has_normalMap)
    tempFC.setValue(type: .bool, value: &False, at: FunctionConstantValues.has_displacementMap)
    tempFC.setValue(type: .bool, value: &True, at: FunctionConstantValues.shadow_map)
    
    return pipeLine(device, "simple_shader_vertex", "shadow_fragment", vertexDescriptor, tempFC.functionConstant)!
}





class DefaultScene {
    
    var fps = 0
    let device : MTLDevice
    var defaultPipeline : pipeLine
    var flatTexturedMeshPipeline : pipeLine
    var renderShadowPipeline : pipeLine
    var renderShadows = false
    var depthMap : Texture?
    
    
    var lightTransforms = [lightConstants]()
    var lightCamera : Camera?
    
    var defaultDepthStencilState : MTLDepthStencilState
    var defaultVertexDescriptor : MTLVertexDescriptor
    var sceneConstant : FrameConstants
    var defaultSamplerState : MTLSamplerState
    var sceneCamera : Camera
    
    var defaultMeshes = [Mesh]()
    var flatTexturedMeshed = [Mesh]()
    var normalMappedMesh = [Mesh]()
    var renderDepth = false
    
    var shadowAndConstantColourPipeline : pipeLine
    var shadowAndFlatTexturePipeline : pipeLine
    var shadowAndNormalMappedPipeline : pipeLine
    var normalMappedPipeline : pipeLine
    var sceneLights = [Lights]()
    var totalShadowCasters : Int = 0
    var pointLightPos = [simd_float4]()
    
    init(device : MTLDevice, projectionMatrix : simd_float4x4, attachTo camera : Camera) {
        var False = false
        var True = true
        self.device = device
        
        sceneCamera = camera
        
        
        defaultSamplerState = generalTextureSampler(device: device)
        
        let defaultFunctionConstant = functionConstant()
        
        
        defaultFunctionConstant.setValue(type: .bool, value: &False, at: FunctionConstantValues.cube)
        defaultFunctionConstant.setValue(type: .bool, value: &False, at: FunctionConstantValues.flat)
        defaultFunctionConstant.setValue(type: .bool, value: &True, at: FunctionConstantValues.constant_colour)
        defaultFunctionConstant.setValue(type: .bool, value: &False, at: FunctionConstantValues.is_skyBox)
        defaultFunctionConstant.setValue(type: .bool, value: &False, at: FunctionConstantValues.has_normalMap)
        defaultFunctionConstant.setValue(type: .bool, value: &False, at: FunctionConstantValues.has_displacementMap)
        defaultFunctionConstant.setValue(type: .bool, value: &False, at: FunctionConstantValues.shadow_map)
        
        defaultVertexDescriptor = generalVertexDescriptor()
        
        let depthState = MTLDepthStencilDescriptor()
        depthState.depthCompareFunction = .lessEqual
        depthState.isDepthWriteEnabled = true
        defaultDepthStencilState = device.makeDepthStencilState(descriptor: depthState)!
        
        
        
        
        sceneConstant = FrameConstants(viewMatrix: camera.cameraMatrix, projectionMatrix: projectionMatrix)
        
        
        defaultPipeline = pipeLine(device, "simple_shader_vertex", "simple_shader_fragment", defaultVertexDescriptor, defaultFunctionConstant.functionConstant)!
        flatTexturedMeshPipeline = createPipelineForFlatTexturedMesh(device: device, vertexDescriptor: defaultVertexDescriptor)
        renderShadowPipeline = createPipelineForShadowMapping(device: device, vertexDescriptor: defaultVertexDescriptor)
        
        shadowAndFlatTexturePipeline = createPipelineForShadowsWithFlatTexture(device: device, vertexDescriptor: defaultVertexDescriptor)
        shadowAndConstantColourPipeline = createPipelineForShadowsWithColour(device: device, vertexDescriptor: defaultVertexDescriptor)
        normalMappedPipeline = createPipelineForNormalMappedMesh(device: device, vertexDescriptor: defaultVertexDescriptor)
        
        shadowAndNormalMappedPipeline = createPipelineForShadowsWithNormalMap(device: device, vertexDescriptor: defaultVertexDescriptor)
        
        camera.scene = self
        
    }
    
    func addDrawable(mesh : Mesh){
       
        mesh.init_instance_buffers(with: sceneCamera.cameraMatrix)
        if(!(mesh.has_flat)){
            defaultMeshes.append(mesh)
        }
        else if(mesh.has_normal){
            print("has normal")
            normalMappedMesh.append(mesh)
        }
        else {
            flatTexturedMeshed.append(mesh)
        }
        
    }
    
    
    func cameraHasBeenUpdated(){
       
        
        for mesh in defaultMeshes{
            var ptr = mesh.BufferArray[0].buffer.contents().bindMemory(to: InstanceConstants.self, capacity: mesh.no_instances)
            
           
            
            for i in 0..<mesh.no_instances{
                let normalMatrix = create_normalMatrix(modelViewMatrix: sceneCamera.cameraMatrix * (ptr + i).pointee.modelMatrix)
                
                (ptr + i).pointee.normalMatrix = normalMatrix
               
            }
        }
        
        for mesh in flatTexturedMeshed {
            var ptr = mesh.BufferArray[0].buffer.contents().bindMemory(to: InstanceConstants.self, capacity: mesh.no_instances)
            
           
            
            for i in 0..<mesh.no_instances{
                let normalMatrix = create_normalMatrix(modelViewMatrix: sceneCamera.cameraMatrix * (ptr + i).pointee.modelMatrix)
                
                (ptr + i).pointee.normalMatrix = normalMatrix
               
            }
        }
        
        for mesh in normalMappedMesh {
            var ptr = mesh.BufferArray[0].buffer.contents().bindMemory(to: InstanceConstants.self, capacity: mesh.no_instances)
            
           
            
            for i in 0..<mesh.no_instances{
                let normalMatrix = create_normalMatrix(modelViewMatrix: sceneCamera.cameraMatrix * (ptr + i).pointee.modelMatrix)
                
                (ptr + i).pointee.normalMatrix = normalMatrix
               
            }
        }
        
    }
    
    func convertLightToEyeSpace() -> [Lights]{
        let count = sceneLights.count
        var eyeSpaceLights = [Lights]()
        for i in 0..<count {
            if(sceneLights[i].type == lightType.directional){
                let eyeSpaceDirection = sceneCamera.cameraMatrix * simd_float4(sceneLights[i].direction,0)
                let direction = simd_float3(eyeSpaceDirection.x, eyeSpaceDirection.y, eyeSpaceDirection.z)
                let type = sceneLights[i].type
                let position = sceneLights[i].position
                let light = Lights(direction: direction, position: position, type: type)
                eyeSpaceLights.append(light)
              
            }
        }
        return eyeSpaceLights
    }
    
    func drawScene(with commandBuffer : MTLCommandBuffer, in view : MTKView) {
        
        if(renderShadows){
           
            guard let renderPassDescriptor = view.currentRenderPassDescriptor else {return}
            renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1, 1, 1, 1)
            renderPassDescriptor.depthAttachment.clearDepth = 1
            renderPassDescriptor.depthAttachment.loadAction = .clear

            guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {return}
           
            renderEncoder.setRenderPipelineState(shadowAndConstantColourPipeline.m_pipeLine)
            
            sceneConstant.viewMatrix = sceneCamera.cameraMatrix
        
            
            renderEncoder.setVertexBytes(&sceneConstant, length: MemoryLayout<FrameConstants>.stride, index: vertexBufferIDs.frameConstant)
            renderEncoder.setFragmentBytes(&lightTransforms, length: MemoryLayout<lightConstants>.stride*sceneLights.count, index: vertexBufferIDs.lightConstant)
            renderEncoder.setFragmentSamplerState(defaultSamplerState, index: 0)
            renderEncoder.setFrontFacing(.counterClockwise)
            renderEncoder.setDepthStencilState(defaultDepthStencilState)
           
            renderEncoder.setFragmentTexture(depthMap?.texture, index: textureIDs.depth)
            
            var eyeSpaceLights = convertLightToEyeSpace()
            //print(eyeSpaceLights[0].direction)
            renderEncoder.setFragmentBytes(&eyeSpaceLights, length: MemoryLayout<Lights>.stride*sceneLights.count, index: vertexBufferIDs.lightBuffer)
            var count = uint(sceneLights.count)
            renderEncoder.setFragmentBytes(&count, length: MemoryLayout<Int>.stride, index: vertexBufferIDs.lightCount)
            
            for mesh in defaultMeshes{
                mesh.draw(renderEncoder: renderEncoder, with: nil)
            }
            
            renderEncoder.setRenderPipelineState(shadowAndFlatTexturePipeline.m_pipeLine)
            for mesh in flatTexturedMeshed {
                mesh.draw(renderEncoder: renderEncoder, with: nil)
            }
            
            renderEncoder.setRenderPipelineState(shadowAndNormalMappedPipeline.m_pipeLine)
            for mesh in normalMappedMesh{
                mesh.draw(renderEncoder: renderEncoder, with: nil)
            }
            

            renderEncoder.endEncoding()
            return
            
        }
        
        if(renderDepth){
            guard let renderPassDescriptor = view.currentRenderPassDescriptor else {return}
            renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1, 1, 1, 1)
            renderPassDescriptor.depthAttachment.clearDepth = 1
            renderPassDescriptor.depthAttachment.loadAction = .clear

            guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {return}
           
            renderEncoder.setRenderPipelineState(renderShadowPipeline.m_pipeLine)
            
           
            
            sceneConstant.viewMatrix = sceneCamera.cameraMatrix
            renderEncoder.setVertexBytes(&sceneConstant, length: MemoryLayout<FrameConstants>.stride, index: vertexBufferIDs.frameConstant)
            
            
            renderEncoder.setFragmentBytes(&lightTransforms, length: MemoryLayout<lightConstants>.stride, index: vertexBufferIDs.lightConstant)
            renderEncoder.setFragmentSamplerState(defaultSamplerState, index: 0)
            renderEncoder.setFrontFacing(.counterClockwise)
            renderEncoder.setDepthStencilState(defaultDepthStencilState)
            renderEncoder.setFragmentTexture(depthMap?.texture, index: textureIDs.depth)
            //renderEncoder.setCullMode(.back)
            
            for mesh in defaultMeshes{
                mesh.draw(renderEncoder: renderEncoder, with: 1)
            }
            
            //renderEncoder.setRenderPipelineState(renderShadowPipeline.m_pipeLine)
            for mesh in flatTexturedMeshed {
                mesh.draw(renderEncoder: renderEncoder, with: 1)
            }
            

            renderEncoder.endEncoding()
            return
        }
        
        
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else {return}
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1, 1, 1, 1)
        renderPassDescriptor.depthAttachment.clearDepth = 1
        renderPassDescriptor.depthAttachment.loadAction = .clear

        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {return}
       
        renderEncoder.setRenderPipelineState(defaultPipeline.m_pipeLine)
        
//        renderEncoder.setVertexBytes(&(pointLightPos!), length: 16, index: vertexBufferIDs.lightWorldPos)
        sceneConstant.viewMatrix = sceneCamera.cameraMatrix
        
        renderEncoder.setVertexBytes(&sceneConstant, length: MemoryLayout<FrameConstants>.stride, index: vertexBufferIDs.frameConstant)
        renderEncoder.setFragmentSamplerState(defaultSamplerState, index: 0)
        renderEncoder.setFrontFacing(.counterClockwise)
        renderEncoder.setDepthStencilState(defaultDepthStencilState)
        //renderEncoder.setCullMode(.back)
        
        for mesh in defaultMeshes{
            mesh.draw(renderEncoder: renderEncoder, with: 1)
        }
        
        renderEncoder.setRenderPipelineState(flatTexturedMeshPipeline.m_pipeLine)
        for mesh in flatTexturedMeshed {
            mesh.draw(renderEncoder: renderEncoder, with: 1)
        }
        renderEncoder.setRenderPipelineState(normalMappedPipeline.m_pipeLine)
        for mesh in normalMappedMesh{
           
            mesh.draw(renderEncoder: renderEncoder, with: 1)
        }
        

        renderEncoder.endEncoding()
    }
    
    func setPointLight(at position : simd_float4){
        pointLightPos.append(position)
    }
    
}


class shadowMapScene : DefaultScene {
    var shadowMapPipeline : pipeLine?
    var pointShadowMapPipeline : pipeLine?
    var pointShadowMapRenderPassPipeline : pipeLine?
    
    var renderTarget : MTLTexture?
    var unusedColourTexture : MTLTexture?
    
    // this is a cubearray
    var pointShadowRenderTarget : MTLTexture?
    // this is unused as we are rendering the distance into the colour attachment
    var pointShadowDepthTarget : MTLTexture?
    
    var pointLightConstantsArray = [lightConstants]()
    
    func addDirectionalLight(lightCamera : Camera, with orthoProjection : simd_float4x4){
        let lightProjection = orthoProjection
        
        
        let light = Lights(direction: lightCamera.centre, position: lightCamera.eye, type: uint(lightType.directional))
        
        sceneLights.append(light)
        
       
        lightTransforms.append(lightConstants(lightViewMatrix: lightCamera.cameraMatrix, lightProjectionMatrix: lightProjection))
        
    }
    
    func addPointLight(position : simd_float3){
        
        pointLightPos.append(simd_float4(position.x,position.y,position.z,1))
        let projection = simd_float4x4(fovRadians: 3.14/2, aspectRatio: 1, near: 0.1, far: 20)
        
        var cameraArray = [simd_float4x4]()
        
        cameraArray.append(simd_float4x4(eye: position, center: simd_float3(1,0,0) + position, up: simd_float3(0,-1,0)))
                           
        cameraArray.append(simd_float4x4(eye: position, center: simd_float3(-1,0,0) + position, up: simd_float3(0,-1,0)))
        
        cameraArray.append(simd_float4x4(eye: position, center: simd_float3(0,-1,0) + position, up: simd_float3(0,0,-1)))
           
        cameraArray.append(simd_float4x4(eye: position, center: simd_float3(0,1,0) + position, up: simd_float3(0,0,1)))
                           
        cameraArray.append(simd_float4x4(eye: position, center: simd_float3(0,0,1) + position, up: simd_float3(0,-1,0)))
                   
        cameraArray.append(simd_float4x4(eye: position, center: simd_float3(0,0,-1) + position, up: simd_float3(0,-1,0)))
                   
       
        for i in 0..<6{
            let lightConstant = lightConstants(lightViewMatrix: cameraArray[i], lightProjectionMatrix: projection)
            pointLightConstantsArray.append(lightConstant)
        }
    }
    
    func init_pointShadowMapPipeline(){
        if(pointLightConstantsArray.isEmpty){
            print("Cannot create pipeline as no point lights been added")
            return 
        }
        pointShadowMapPipeline = pipeLine(device, "vertex_shadow_point", "fragment_shadow_point", defaultVertexDescriptor, true, amplificationCount: pointLightConstantsArray.count, colourPixelFormat: .r16Unorm, label: "PointShadowPipeline")
    }
    
    func init_pointShadowRenderTargets(){
        if(pointLightConstantsArray.isEmpty){
            print("Cannot create a cubeMap before any light has been added")
            return
        }
        let shadowMapSize = 1200
        
        let textureDescriptor = MTLTextureDescriptor.textureCubeDescriptor(pixelFormat: .r16Unorm, size: shadowMapSize, mipmapped: false)
        textureDescriptor.storageMode = .private
        textureDescriptor.usage = [.renderTarget, .shaderRead]
        textureDescriptor.textureType = .typeCubeArray
        textureDescriptor.arrayLength = pointLightConstantsArray.count / 6
        
        
        let textureDescriptorDepth = MTLTextureDescriptor.textureCubeDescriptor(pixelFormat: .depth32Float, size: shadowMapSize, mipmapped: false)
        textureDescriptorDepth.storageMode = .private
        textureDescriptorDepth.usage = [.renderTarget, .shaderRead]
        textureDescriptorDepth.textureType = .typeCubeArray
        textureDescriptorDepth.arrayLength = pointLightConstantsArray.count / 6
        
        pointShadowRenderTarget = device.makeTexture(descriptor: textureDescriptor)
        pointShadowDepthTarget = device.makeTexture(descriptor: textureDescriptorDepth)
        
        
        
        
    }
    
    func initShadowMap(){
        let shadowMapSize = 2400
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .depth32Float, width: shadowMapSize, height: shadowMapSize, mipmapped: false)
        textureDescriptor.storageMode = .private
        textureDescriptor.usage = [.renderTarget, .shaderRead]
        textureDescriptor.textureType = .type2DArray
        textureDescriptor.arrayLength = sceneLights.count
        self.renderTarget = self.device.makeTexture(descriptor: textureDescriptor)
        
        super.depthMap = Texture(texture: renderTarget!, index: textureIDs.depth)
        let textureDescriptorColour = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm_srgb, width: shadowMapSize, height: shadowMapSize, mipmapped: false)
        textureDescriptorColour.storageMode = .private
        textureDescriptorColour.usage = [.renderTarget, .shaderRead]
        textureDescriptorColour.textureType = .type2DArray
        textureDescriptorColour.arrayLength = sceneLights.count
        unusedColourTexture = self.device.makeTexture(descriptor: textureDescriptorColour)
        
    }
    
    override init(device : MTLDevice, projectionMatrix : simd_float4x4, attachTo camera : Camera){
        super.init(device: device, projectionMatrix: projectionMatrix, attachTo: camera)
        super.renderShadows = true
        
       
        shadowMapPipeline = pipeLine(device, "vertex_shadow", "fragment_shadow", defaultVertexDescriptor ,true)
        
        pointShadowMapRenderPassPipeline = pipeLine(device, "vertex_point_shadow_render", "fragment_point_shadow_render", defaultVertexDescriptor, false,label: "RenderPointShadowPipeline")
        
       
        
        
    }
    
    func shadowPass(with commandBuffer : MTLCommandBuffer, in view : MTKView) {
        
        
       fps+=1
        
        
            
            
            
            guard let renderPassDescriptor = view.currentRenderPassDescriptor else {return}
            renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1, 1, 1, 1)
            renderPassDescriptor.colorAttachments[0].texture = unusedColourTexture!
            renderPassDescriptor.depthAttachment.clearDepth = 1
            renderPassDescriptor.depthAttachment.loadAction = .clear
            renderPassDescriptor.depthAttachment.storeAction = .store
            renderPassDescriptor.depthAttachment.texture = renderTarget!
            renderPassDescriptor.renderTargetArrayLength = sceneLights.count

            guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {return}
           
            renderEncoder.setRenderPipelineState(shadowMapPipeline!.m_pipeLine)
            
          
            // update lighttransforms here
            
        
            
        renderEncoder.setVertexBytes(&lightTransforms, length: MemoryLayout<lightConstants>.stride*sceneLights.count, index: vertexBufferIDs.lightConstant)
            renderEncoder.setFragmentSamplerState(defaultSamplerState, index: 0)
            renderEncoder.setFrontFacing(.counterClockwise)
            renderEncoder.setDepthStencilState(defaultDepthStencilState)
            renderEncoder.setDepthBias(0.05, slopeScale: 0.1, clamp: 0)
            
            for mesh in defaultMeshes{
                if let _ = mesh.is_shadow_caster{
                    var sliceIndex = [uint]()
                    for i in 0..<sceneLights.count{
                        for j in 0..<mesh.no_instances{
                            sliceIndex.append(uint(i))
                        }
                    }
                    var count = mesh.no_instances
                    renderEncoder.setVertexBytes(&count, length: MemoryLayout<Int>.stride, index: vertexBufferIDs.lightCount)
                    renderEncoder.setVertexBytes(&sliceIndex, length: MemoryLayout<uint>.size*sliceIndex.count, index: 10)
                    mesh.draw(renderEncoder: renderEncoder, with: mesh.no_instances * sceneLights.count, culling: .front)
                }
                
            }
            
            
            for mesh in flatTexturedMeshed {
                if let _ = mesh.is_shadow_caster{
                    var sliceIndex = [Int]()
                    for i in 0..<sceneLights.count{
                        for j in 0..<mesh.no_instances{
                            sliceIndex.append(i)
                        }
                    }
                    var count = mesh.no_instances
                    renderEncoder.setVertexBytes(&count, length: MemoryLayout<Int>.stride, index: vertexBufferIDs.lightCount)
                    renderEncoder.setVertexBytes(&sliceIndex, length: MemoryLayout<Int>.stride*sliceIndex.count, index: 10)
                    mesh.draw(renderEncoder: renderEncoder, with: mesh.no_instances * sceneLights.count, culling: .front)
                }
            }
            for mesh in normalMappedMesh {
                if let _ = mesh.is_shadow_caster{
                    var sliceIndex = [Int]()
                    for i in 0..<sceneLights.count{
                        for j in 0..<mesh.no_instances{
                            sliceIndex.append(i)
                        }
                    }
                    var count = mesh.no_instances
                    renderEncoder.setVertexBytes(&count, length: MemoryLayout<Int>.stride, index: vertexBufferIDs.lightCount)
                    renderEncoder.setVertexBytes(&sliceIndex, length: MemoryLayout<Int>.stride*sliceIndex.count, index: 10)
                    mesh.draw(renderEncoder: renderEncoder, with: mesh.no_instances * sceneLights.count, culling: .front)
                }
            }
            

            renderEncoder.endEncoding()
        
        
        super.drawScene(with: commandBuffer, in: view)
    }
    
    
    func test_pointShadowDepthPass(with commandBuffer : MTLCommandBuffer, in view : MTKView){
        
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else {return}
        renderPassDescriptor.colorAttachments[0].texture = pointShadowRenderTarget
        renderPassDescriptor.depthAttachment.texture = pointShadowDepthTarget
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1, 1, 1, 1)
        renderPassDescriptor.depthAttachment.clearDepth = 1
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.depthAttachment.loadAction = .clear
        renderPassDescriptor.renderTargetArrayLength = pointLightConstantsArray.count
        
        
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {return}
        
        renderEncoder.setRenderPipelineState(pointShadowMapPipeline!.m_pipeLine)
        renderEncoder.setDepthStencilState(defaultDepthStencilState)
        renderEncoder.setVertexBytes(&pointLightPos, length: MemoryLayout<simd_float4>.stride*pointLightPos.count, index: vertexBufferIDs.lightPos)
        renderEncoder.setVertexAmplificationCount(pointLightConstantsArray.count, viewMappings: nil)
        renderEncoder.setVertexBytes(&pointLightConstantsArray, length: MemoryLayout<lightConstants>.stride*pointLightConstantsArray.count, index: vertexBufferIDs.lightConstant)
        
        for mesh in defaultMeshes{
            if let _ = mesh.is_shadow_caster{
                mesh.draw(renderEncoder: renderEncoder, with: nil, culling: .front)
            }
            
        }
        
        
        for mesh in flatTexturedMeshed {
            if let _ = mesh.is_shadow_caster{
                mesh.draw(renderEncoder: renderEncoder, with: nil, culling: .front)
            }
        }
        for mesh in normalMappedMesh {
            if let _ = mesh.is_shadow_caster{
                mesh.draw(renderEncoder: renderEncoder, with: nil, culling: .front)
            }
        }
        
        renderEncoder.endEncoding()
        
        test_pointShadowRenderPass(with: commandBuffer, in: view)
        
        
        
    }
    
    func test_pointShadowRenderPass(with commandBuffer : MTLCommandBuffer, in view : MTKView){
        
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else {return}
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1, 1, 1, 1)
        renderPassDescriptor.depthAttachment.clearDepth = 1
        renderPassDescriptor.depthAttachment.loadAction = .clear
        
        
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {return}
        renderEncoder.setRenderPipelineState(pointShadowMapRenderPassPipeline!.m_pipeLine)
        sceneConstant.viewMatrix = sceneCamera.cameraMatrix
        renderEncoder.setVertexBytes(&sceneConstant, length: MemoryLayout<FrameConstants>.stride, index: vertexBufferIDs.frameConstant)
        renderEncoder.setFragmentTexture(pointShadowRenderTarget, index: textureIDs.cubeMap)
        renderEncoder.setFragmentBytes(&pointLightPos, length: MemoryLayout<simd_float4>.stride*pointLightPos.count, index: vertexBufferIDs.lightPos)
        
        var eyeLightPos = [simd_float4]()
        
        for i in 0..<pointLightPos.count {
            let position = sceneConstant.viewMatrix * pointLightPos[i]
            eyeLightPos.append(position)
        }
        renderEncoder.setFragmentBytes(&eyeLightPos, length: MemoryLayout<simd_float4>.stride*eyeLightPos.count, index: 10)
        
        
        for mesh in defaultMeshes{
           
                mesh.draw(renderEncoder: renderEncoder, with: nil, culling: .front)
            
            
        }
        
        
        for mesh in flatTexturedMeshed {
          
                mesh.draw(renderEncoder: renderEncoder, with: nil, culling: .front)
            
        }
        for mesh in normalMappedMesh {
           
                mesh.draw(renderEncoder: renderEncoder, with: nil, culling: .front)
            
        }
        renderEncoder.endEncoding()
        
        
        
    }

    
    
}
