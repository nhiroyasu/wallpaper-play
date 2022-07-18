import Foundation

protocol Statable {
    static var initial: Self { get }
}

class StateVariable<State: Statable> {
    private var state: State {
        didSet { setObserver?(state) }
    }
    private var setObserver: ((State) -> Void)?
    
    init(_ didSet: @escaping (State) -> Void) {
        state = .initial
        self.setObserver = didSet
    }
    
    func modify<V>(_ keyPath: WritableKeyPath<State, V>, value: V) {
        var newState = state
        newState[keyPath: keyPath] = value
        state = newState
    }

    func get<V>(_ keyPath: KeyPath<State, V>) -> V {
        return state[keyPath: keyPath]
    }
}
