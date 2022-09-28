//
//  MetalBuffer.swift
//  drawLoop
//
//  Created by Rishabh Natarajan on 14/09/22.
////
//  MetalBuffer.swift
//  Metallic
//
//  Created by Akshay on 25/09/19.
//  Copyright © 2019 Fluid Touch Pte Ltd. All rights reserved.
//

import Metal
private let defaultIncrement: Int = 1000

class MetalBuffer<T> : RoundRobinConfirm,Equatable {
    public static func == (lhs: MetalBuffer<T>, rhs: MetalBuffer<T>) -> Bool {
        return lhs.uuid == rhs.uuid;
    }

    var uuid = UUID().uuidString;
    var buffer: MTLBuffer
    var count: Int
    private var capacity: Int
    private var expand: Int
    private var mtlDevice:MTLDevice

    init(vertices: [T], expand: Int? = nil,mtlDevice:MTLDevice) {
        self.count = vertices.count
        self.expand = (expand ?? defaultIncrement)

        var length = vertices.isEmpty ? 1 : vertices.count;
        if(self.expand > 0) {
            length += 0;
        }
        let bufferLength =  MemoryLayout<T>.stride * length
        self.buffer = mtlDevice.makeBuffer(bytes: vertices, length: bufferLength, options: [.cpuCacheModeWriteCombined])!
        self.mtlDevice=mtlDevice
        self.capacity = (vertices.count + self.expand);
    }

    deinit {
        buffer.setPurgeableState(.empty)
    }

    public func append(_ vertices: [T]) {
        if self.count + vertices.count < self.capacity {
            memcpy(self.buffer.contents()+self.count*MemoryLayout<T>.stride, vertices, vertices.count*MemoryLayout<T>.stride);
            self.count += vertices.count
        }
        else {
            let length = (self.count + vertices.count + defaultIncrement)*MemoryLayout<T>.stride
            let newBuffer = self.mtlDevice.makeBuffer(length: length , options: [.cpuCacheModeWriteCombined]);

            memcpy(newBuffer!.contents(), self.buffer.contents(), self.count*MemoryLayout<T>.stride);
            memcpy(newBuffer!.contents()+self.count*MemoryLayout<T>.stride, vertices, vertices.count*MemoryLayout<T>.stride);

            self.count += vertices.count
            self.capacity = (self.count + defaultIncrement)

            self.buffer.setPurgeableState(.empty)
            self.buffer = newBuffer!
        }
    }

    public func reset()
    {
        if((self.expand > 0) && (self.capacity > self.expand)) {
            let length = MemoryLayout<T>.stride * self.expand
            let buffer = self.mtlDevice.makeBuffer(length: length, options: [.cpuCacheModeWriteCombined]);
            self.buffer.setPurgeableState(.empty)

            self.buffer = buffer!
            self.capacity = self.expand
        }
        self.count = 0
    }
    


    public func set(_ vertices: [T]) {
        print("🔴 😆 Vertex Count", vertices.count, "capacity", self.capacity)
        if vertices.count <= self.capacity {
            memcpy(self.buffer.contents(), vertices, vertices.count*MemoryLayout<T>.stride);
            self.count = vertices.count
        }
        else {
            let length = MemoryLayout<T>.stride * (vertices.count + defaultIncrement)
            let buffer = self.mtlDevice.makeBuffer(bytes: vertices, length: length, options: [.cpuCacheModeWriteCombined])
            self.count = vertices.count
            self.capacity = (vertices.count + defaultIncrement)

            self.buffer.setPurgeableState(.empty)
            self.buffer = buffer!
        }
    }

    public var vertices: [T] {
        let vertexArray = UnsafeMutablePointer<T>(OpaquePointer(self.buffer.contents()))
        return (0 ..< count).map { vertexArray[$0] }
    }
}
