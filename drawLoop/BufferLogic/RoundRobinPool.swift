//
//  RoundRobinPool.swift
//  drawLoop
//
//  Created by Rishabh Natarajan on 14/09/22.

import UIKit

protocol RoundRobinConfirm {
    func reset()
}

class RoundRobinPool<T:Equatable>
{
    private var dequeuedItems = Array<T>()
    private var enqueuedItems = Array<T>();

    private var itemCreationBlock : (() -> T);

    required init(withCount count:Int, factoryFunction: @escaping () -> T) {
        self.itemCreationBlock = factoryFunction;
        for _ in 1...count {
            dequeuedItems.append(factoryFunction())
        }
    }

    func dequeueItem() -> T {
        let itemToReturn : T;

        objc_sync_enter(self);
        if let item = dequeuedItems.first {
            itemToReturn = item;
            dequeuedItems.removeFirst();
        }
        else {
            itemToReturn = self.itemCreationBlock();
            print("RoundRobinPool ERROR: extra item created");
        }
        self.enqueuedItems.append(itemToReturn);

        if(itemToReturn is RoundRobinConfirm) {
            (itemToReturn as? RoundRobinConfirm)?.reset();
        }
        objc_sync_exit(self);

        return itemToReturn
    }

    func enqueueItem(_ item : T) {
        objc_sync_enter(self);
        if let index = self.enqueuedItems.index(of: item) {
            let _item = self.enqueuedItems.remove(at: index);
            self.dequeuedItems.append(_item);
        }
        objc_sync_exit(self);
    }

    func enqueueAllItems() {
        objc_sync_enter(self);
        self.enqueuedItems.forEach { (item) in
            self.dequeuedItems.append(item);
        }
        self.enqueuedItems.removeAll();
        objc_sync_exit(self);
    }
}
