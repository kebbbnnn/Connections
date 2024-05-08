import SwiftUI
import Combine
import Contacts

internal final class ContactsObserver: BaseObserver {
    @Published internal var results: [CNContact] = []
    
    private var cancellable: AnyCancellable?

    private let request: CNContactFetchRequest
    private let animation: Animation?

    internal init(request: CNContactFetchRequest, animation: Animation?) {
        self.request = request
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
        
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }

            do {
                var contacts: [CNContact] = []
                try store.enumerateContacts(with: request) { contact, _ in
                    contacts.append(contact)
                }
                DispatchQueue.main.async {
                    withAnimation(animated ? self.animation : nil) { self.results = contacts }
                }
            } catch { print(error) }
        }
    }
}
