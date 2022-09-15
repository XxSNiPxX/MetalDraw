//
//  LockableBufferPool.swift
//  drawLoop
//
//  Created by Rishabh Natarajan on 14/09/22.
//


import Foundation

class LockableBufferPool<T:Equatable>: RoundRobinPool<T> {
    
    private lazy var renderSemaphore : DispatchSemaphore = {
        return DispatchSemaphore(value: maxBuffersCount);
    }();

    deinit {
        self.removeAllLocks();
    }
    
    override func dequeueItem() -> T {
        self.renderSemaphore.wait();
        let buffer = super.dequeueItem();
        return buffer;
    }
    
    override func enqueueItem(_ item : T) {
        super.enqueueItem(item);
        self.renderSemaphore.signal();
    }
    
    private func removeAllLocks() {
        super.enqueueAllItems();
        for _ in 0..<maxBuffersCount {
            self.renderSemaphore.signal();
        }
    }
}
