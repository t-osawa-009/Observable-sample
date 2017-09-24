// https://github.com/apple/swift-corelibs-foundation/blob/master/Foundation/NSNotification.swift

import Foundation

protocol ObservableProtocol {
    associatedtype T
    var value: T { get set }
    func subscribe(observer: Any, block: @escaping (_ newValue: T, _ oldValue: T) -> ())
    func unsubscribe(observer: Any)
}

public final class Observable<T>: ObservableProtocol {
    private class ObserversEntry: NSObject {
        var observer: AnyObject?
        var block: ObserverBlock?
    }
    
    typealias ObserverBlock = (_ newValue: T, _ oldValue: T) -> ()
    private var _observers: [ObserversEntry]
 
    init(_ value: T) {
        self.value = value
        _observers = []
    }
    
    var value: T {
        didSet {
            _observers.forEach { (entry: ObserversEntry) in
                entry.block?(value, oldValue)
            }
        }
    }
    
    func subscribe(observer: Any, block: @escaping ObserverBlock) {
        let entry = ObserversEntry()
        entry.observer = observer as AnyObject
        entry.block = block
        _observers.append(entry)
    }
    
    func unsubscribe(observer: Any) {
        _observers = removeObserver(with: (observer as AnyObject) as! NSObject)
    }
    
    private func removeObserver(with observer: NSObject) ->  [ObserversEntry] {
        return _observers.filter { entry in
            return entry.observer !== observer
        }
    }
}

class Example {
    var v: Int
    var obs: Observable<Int>
    
    init() {
        let initial = 3
        v = initial
        obs = Observable(initial)
    }
    
    func demo() {
        obs.subscribe(observer: self) { (newValue, oldValue) in
            print(newValue)
        }
        obs.value = 4
        obs.unsubscribe(observer: self)
        obs.value = 6
    }
}

var a = Example()
a.demo()
