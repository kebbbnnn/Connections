import SwiftUI
import Combine
import Contacts

internal final class GroupsObserver: BaseObserver {
    @Published internal var results: [CNGroup] = []

    private var cancellable: AnyCancellable?

    private let predicate: NSPredicate?
    private let animation: Animation?

    internal init(predicate: NSPredicate?, animation: Animation?) {
        self.predicate = predicate
        self.animation = animation
        super.init()
        
        self.requestAccessIfNeeded { result in
            if case let .success(success) = result, success {
                self.refetch(animated: true)
            }
        }
        
        self.cancellable = NotificationCenter.default
            .publisher(for: Notification.Name.CNContactStoreDidChange)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.refetch(animated: true)
            }

        refetch(animated: false)
    }

    private func refetch(animated: Bool) {
        guard self.isAuthorized else { return }
        
        var groups: [CNGroup] = []

        defer {
            withAnimation(animated ? self.animation : nil) { self.results = groups }
        }

        do {
            groups = try self.store.groups(matching: self.predicate)
        } catch {
            print(error)
        }
    }
}
