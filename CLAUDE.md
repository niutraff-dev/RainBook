# iOS Template App - Architecture Guide

This template provides a scalable iOS app architecture using SwiftUI, Coordinator pattern, and NavigationStorable for type-safe navigation.

**Related Documents:**
- **[Figma Design System Rules](/.claude/rules/figma_design_system_rules.md)** - Integration guidelines for Figma designs, token mappings, and component specifications

## Architecture Overview

```
AppCoordinator (Root)
├── OnboardingCoordinator (Step-based flow)
│   ├── Onboarding1View
│   ├── Onboarding2View
│   └── Onboarding3View
│
├── SessionCoordinator (Tab-based)
│   ├── Feature1Coordinator
│   │   └── Feature1CoordinatorNavigation (NavigationStorable)
│   │       ├── Feature1View + Feature1VM
│   │       └── Feature1DetailView + Feature1DetailVM
│   │
│   ├── Feature2Coordinator
│   │   └── Feature2CoordinatorNavigation
│   │
│   └── Feature3Coordinator
│       └── Feature3CoordinatorNavigation
│       └── SubFlow/ (Modal coordinator example)
│
└── WebView (Remote-controlled redirect)
```

---

## Adding New Features

### 1. Create Feature Folder Structure

```
Session/NewFeature/
├── NewFeatureCoordinator.swift
├── NewFeatureCoordinatorNavigation.swift
├── NewFeatureCoordinatorView.swift
└── Views/
    ├── NewFeatureView.swift
    ├── NewFeatureVM.swift
    ├── NewFeatureDetailView.swift
    └── NewFeatureDetailVM.swift
```

### 2. Create Factory Protocol

```swift
@MainActor
protocol NewFeatureCoordinatorElementsFactory {
    func newFeatureVM() -> NewFeatureVM
    func newFeatureDetailVM() -> NewFeatureDetailVM
}
```

### 3. Create Coordinator (Inline Output Pattern)

```swift
@MainActor
final class NewFeatureCoordinator: ObservableObject {

    // MARK: - Properties

    let navigation: NewFeatureCoordinatorNavigation
    private let elementsFactory: NewFeatureCoordinatorElementsFactory
    private var _viewModel: NewFeatureVM?

    private var viewModel: NewFeatureVM {
        if let vm = _viewModel { return vm }
        let vm = elementsFactory.newFeatureVM()
        vm.output = .init(
            onDetail: { [weak self] in self?.showDetail() }
        )
        _viewModel = vm
        return vm
    }

    // MARK: - Initialization

    init(
        navigation: NewFeatureCoordinatorNavigation,
        elementsFactory: NewFeatureCoordinatorElementsFactory
    ) {
        self.navigation = navigation
        self.elementsFactory = elementsFactory
    }

    // MARK: - Navigation Methods

    func showMain() -> some View {
        navigation.view(for: .main(viewModel))
    }

    private func showDetail() {
        let detailVM = elementsFactory.newFeatureDetailVM()
        detailVM.output = .init(
            onBack: { [weak self] in self?.navigation.navigateBack() }
        )
        navigation.navigateTo(.detail(detailVM))
    }
}
```

### 4. Create Navigation Router

```swift
final class NewFeatureCoordinatorNavigation: NavigationStorable {
    enum Screen: ScreenIdentifiable {
        case main(NewFeatureVM)
        case detail(NewFeatureDetailVM)

        var screenID: ObjectIdentifier {
            switch self {
            case .main(let vm): return ObjectIdentifier(vm)
            case .detail(let vm): return ObjectIdentifier(vm)
            }
        }
    }

    @Published var path: NavigationPath = NavigationPath()

    @ViewBuilder
    func view(for screen: Screen) -> some View {
        switch screen {
        case .main(let vm): NewFeatureView(viewModel: vm)
        case .detail(let vm): NewFeatureDetailView(viewModel: vm)
        }
    }
}
```

### 5. Create Coordinator View

```swift
struct NewFeatureCoordinatorView: View {
    @ObservedObject var coordinator: NewFeatureCoordinator

    var body: some View {
        NavigationStorableView(navigation: coordinator.navigation) {
            coordinator.showMain()
        }
    }
}
```

### 6. Create ViewModel with Output and Localization

```swift
import SwiftUI

@MainActor
final class NewFeatureVM: ObservableObject {

    struct Output {
        let onDetail: () -> Void
    }

    var output: Output?

    // Use LocalizedStringKey for UI strings
    var title: LocalizedStringKey { L10n.newFeature.title }
    var subtitle: LocalizedStringKey { L10n.newFeature.subtitle }

    @Published private(set) var items: [Item] = []
    @Published private(set) var isLoading: Bool = false

    func onDetailTapped() {
        output?.onDetail()
    }
}
```

### 7. Register in SessionCoordinator

Add to `SessionCoordinatorElementsFactory`:
```swift
@MainActor
protocol SessionCoordinatorElementsFactory:
    Feature1CoordinatorElementsFactory,
    Feature2CoordinatorElementsFactory,
    Feature3CoordinatorElementsFactory,
    NewFeatureCoordinatorElementsFactory {}
```

Add builder method:
```swift
func buildNewFeatureCoordinator() -> NewFeatureCoordinator {
    NewFeatureCoordinator(
        navigation: NewFeatureCoordinatorNavigation(),
        elementsFactory: self
    )
}
```

---

## Key Patterns

### Coordinator Output Pattern (Inline)

ViewModel creation and output setup in one place using computed property:

```swift
private var _viewModel: FeatureVM?

private var viewModel: FeatureVM {
    if let vm = _viewModel { return vm }
    let vm = factory.viewModel()
    vm.output = .init(
        onDetail: { [weak self] in self?.showDetail() }
    )
    _viewModel = vm
    return vm
}

func showMain() -> some View {
    navigation.view(for: .main(viewModel))
}
```

### MainActor Convenience Init Pattern

Avoid "Call to main actor-isolated initializer in nonisolated context" warnings:

```swift
// ❌ Wrong - default parameter evaluated in nonisolated context
init(service: Service = Service()) { }

// ✅ Correct - convenience init runs in MainActor context
init(service: Service) {
    self.service = service
}

convenience init() {
    self.init(service: Service())
}
```

### SubFlow Coordinator (Modal Sheets)

For presenting modal flows with their own navigation:

```swift
@MainActor
final class FeatureCoordinator: ObservableObject {
    @Published var subFlowCoordinator: SubFlowCoordinator?

    private func showSubFlow() {
        let coordinator = SubFlowCoordinator()
        coordinator.output = .init(
            onDismiss: { [weak self] in self?.subFlowCoordinator = nil },
            onComplete: { [weak self] in self?.subFlowCoordinator = nil }
        )
        subFlowCoordinator = coordinator
    }
}

// In CoordinatorView:
.sheet(item: $coordinator.subFlowCoordinator) { subFlow in
    SubFlowCoordinatorView(coordinator: subFlow)
}
```

---

## Storage Layer

### KeyValue Property Wrapper

Type-safe key-value storage with KeyPath syntax:

```swift
// Usage in any class:
@KeyValue(\.onboardingCompleted) private var onboardingCompleted: Bool

// Read
if onboardingCompleted { ... }

// Write (persists to UserDefaults)
onboardingCompleted = true
```

### Adding New Storage Keys

1. Add case to `KeyValueStorageKey` enum:
```swift
enum KeyValueStorageKey: String {
    case onboardingShown = "onboarding_shown"
    case userToken = "user_token"  // New key
}
```

2. Add property to `StorageKeys`:
```swift
final class StorageKeys {
    let onboardingCompleted = StorageKey<Bool>(key: .onboardingShown, default: false)
    let userToken = StorageKey<String?>(key: .userToken, default: nil)  // New
}
```

---

## Styling

### Color Palette

Unified color enum - single source of truth for SwiftUI and UIKit:

```swift
// SwiftUI
Text("Hello")
    .foregroundColor(.palette(.black500))
    .background(Color.palette(.primary500))

// UIKit
label.textColor = .palette(.black500)
view.backgroundColor = .palette(.primary100)
```

Available colors: `black50-900`, `white`, `white50-200`, `primary50-900`, `secondary100-500`, `success100/500`, `warning100/500`, `error100/500`, `background`, `backgroundSecondary`, `textPrimary`, `textSecondary`, `textDisabled`

### Typography

iOS Human Interface Guidelines typography with SF Pro system fonts. Each style supports four weights: `.regular`, `.medium`, `.semibold`, `.bold`

**Available styles:**

| Style | Size | Use Case |
|-------|------|----------|
| `.largeTitle` | 34pt | Screen titles |
| `.title1` | 28pt | Section headers |
| `.title2` | 22pt | Subsection headers |
| `.title3` | 20pt | Small headers |
| `.headline` | 17pt | Emphasized body text (always semibold) |
| `.body` | 17pt | Primary body text |
| `.callout` | 16pt | Secondary text |
| `.subheadline` | 15pt | Descriptive text |
| `.footnote` | 13pt | Supporting text |
| `.caption1` | 12pt | Fine print |
| `.caption2` | 11pt | Very small text |

**Example usage:**

```swift
Text("Screen Title")
    .typography(.largeTitle.bold)

Text("Section Header")
    .typography(.title1.regular)

Text("Body text with regular weight for readability")
    .typography(.body.regular)

Text("Emphasized text uses semibold by default")
    .typography(.headline.semibold)

Text("Small supporting text")
    .typography(.caption2.medium)
```

**In Views:**

```swift
struct FeatureView: View {
    @ObservedObject var viewModel: FeatureVM

    var body: some View {
        VStack(spacing: 16) {
            // Header
            Text(viewModel.title)
                .typography(.title1.bold)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Content
            VStack(spacing: 8) {
                Text(viewModel.subtitle)
                    .typography(.body.regular)
                    .foregroundStyle(.secondary)

                Text(viewModel.description)
                    .typography(.subheadline.regular)
                    .foregroundStyle(.secondary)
            }

            // Footer
            Text(viewModel.footnote)
                .typography(.caption1.regular)
                .foregroundStyle(.tertiary)
        }
        .padding()
    }
}
```

Font family configuration in `FontFamily` enum (uses SF Pro Text system fonts).

---

## Localization

### L10n Type-Safe Keys

```swift
// In SwiftUI Views:
Text(L10n.common.ok)
Text(L10n.feature1.title)

// As String:
let title = L10n.feature1.title.string

// With arguments:
let message = L10n.format("Hello, %@", userName)
```

### Adding New Localized Strings

1. Add to all `Localizable.strings` files (en, de, es):
```
"myFeature.title" = "My Feature";
```

2. Add to `L10n` enum:
```swift
enum myFeature {
    static let title = LocalizedStringKey("myFeature.title")
}
```

### File Structure
```
Resources/
├── en.lproj/Localizable.strings  (English - Base)
├── de.lproj/Localizable.strings  (German)
└── es.lproj/Localizable.strings  (Spanish)
```

---

## Services

### Single Source of Truth Pattern

Services use AsyncStream for reactive updates with a single source of truth:

```swift
@MainActor
protocol TemplateServiceProtocol {
    var currentItems: [Item] { get }           // Synchronous read
    var itemsStream: AsyncStream<[Item]> { get } // Reactive updates
    func refresh() async throws               // Trigger refresh
}

@MainActor
final class TemplateService: TemplateServiceProtocol {
    private(set) var currentItems: [Item] = []
    private var continuation: AsyncStream<[Item]>.Continuation?

    private(set) lazy var itemsStream: AsyncStream<[Item]> = {
        AsyncStream { [weak self] continuation in
            self?.continuation = continuation
            if let items = self?.currentItems {
                continuation.yield(items)
            }
        }
    }()

    func refresh() async throws {
        let items = try await fetchFromNetwork()
        currentItems = items
        continuation?.yield(items)
    }
}
```

### ViewModel Usage with Task Cancellation

ViewModels observe the stream and handle task cancellation:

```swift
@MainActor
final class FeatureVM: ObservableObject {
    private var loadTask: Task<Void, Never>?
    private var observeTask: Task<Void, Never>?

    func onAppear() {
        startObservingItems()
        loadItems()
    }

    func onDisappear() {
        loadTask?.cancel()
        observeTask?.cancel()
    }

    private func startObservingItems() {
        observeTask?.cancel()
        observeTask = Task { [weak self] in
            guard let self else { return }
            for await items in service.itemsStream {
                guard !Task.isCancelled else { break }
                self.items = items
            }
        }
    }

    private func loadItems() {
        loadTask?.cancel()
        loadTask = Task { [weak self] in
            guard let self else { return }
            isLoading = true
            defer { isLoading = false }

            do {
                try Task.checkCancellation()
                try await service.refresh()
            } catch is CancellationError {
                // Task cancelled, no error
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    deinit {
        loadTask?.cancel()
        observeTask?.cancel()
    }
}
```

---

## Network Services

### Network Layer Architecture

The app includes a comprehensive network layer for API communication:

```
Services/Network/
├── APIClient.swift              # HTTP client
├── APIError.swift               # Error definitions
├── APIConfiguration.swift       # API config
├── APIEndpoint.swift            # Endpoint definitions
├── LoggerService.swift          # Network logging
├── AppStatusService.swift       # App status logic
├── ServiceFactory.swift         # Service factory
├── Models/
│   ├── AppMode.swift           # App mode (.default, .combat)
│   ├── AppStatus.swift         # App status (.zero, .one)
│   └── AppObjects.swift        # Response models
└── Repositories/
    ├── ObjectsRepository.swift      # Objects API
    ├── StatisticsRepository.swift   # Statistics API
    └── AnalyticsRepository.swift    # Analytics API
```

### Core Components

**APIClient** - Generic HTTP client with error handling:
```swift
protocol APIClientProtocol: Sendable {
    func request(endpoint: APIEndpoint) async -> Data?
    func requestWithResult(endpoint: APIEndpoint) async -> Result<Data, APIError>
}
```

**APIConfiguration** - API configuration with authentication:
```swift
protocol APIConfigurationProtocol: Sendable {
    var baseURL: URL { get }
    var userAgent: String? { get }
    var basicAuth: (username: String, password: String)? { get }
    var appMode: AppMode { get }
    var appVersion: String { get }
}
```

**APIEndpoint** - Type-safe endpoint definitions:
```swift
enum APIEndpoint: Sendable {
    case addObject
    case getObjects(version: String)
    case getStatistics(version: String)

    var path: String { }
    var method: String { }
    var requiresAuth: Bool { }
    var queryItems: [URLQueryItem]? { }
}
```

**LoggerService** - Network request/response logging (DEBUG only):
```swift
protocol LoggerServiceProtocol: Sendable {
    func logRequest(_ request: URLRequest)
    func logResponse(url: URL, statusCode: Int, data: Data?)
    func logError(url: URL, error: Error)
}
```

### App Mode System

**AppMode** - Determines API versioning strategy:
```swift
enum AppMode: Sendable {
    case `default`  // Uses Bundle major version ("1", "2", "3")
    case combat     // Always uses version "2"
}
```

**AppStatus** - Determines UI flow:
```swift
enum AppStatus: Sendable {
    case zero           // Show SessionCoordinator (tabs)
    case one(URL?)      // Show WebView
}
```

### Repositories

**ObjectsRepository** - Fetches app objects:
```swift
protocol ObjectsRepositoryProtocol: Sendable {
    func fetchObjects() async -> AppObjects?
    func fetchObjectsWithResult() async -> FetchObjectsResult
}
```

**StatisticsRepository** - Fetches statistics URL:
```swift
protocol StatisticsRepositoryProtocol: Sendable {
    func fetchStatistics() async -> URL?
}
```

**AnalyticsRepository** - Sends analytics:
```swift
protocol AnalyticsRepositoryProtocol: Sendable {
    func addObject() async -> Bool
}
```

### AppStatusService

**Coordinated status loading** with parallel API calls:
```swift
protocol AppStatusServiceProtocol: Sendable {
    func loadStatus() async -> StatusResult
}

struct StatusResult: Sendable {
    let status: AppStatus
    let pdfUrl: URL?
    let statisticsUrl: URL?
}
```

**Logic:**
1. `.default` mode + version "1" → always `.zero` (Session)
2. `.default` mode + version >= "2" OR `.combat` mode:
   - Any error (400, 500, network) → `.zero` + statisticsUrl
   - HTTP 200 success → `.one(url)` (WebView)

### Service Factory

**Centralized service creation**:
```swift
enum ServiceFactory {
    @MainActor
    static func makeAppStatusService() -> AppStatusServiceProtocol {
        let config = AppConfiguration.apiConfiguration
        let apiClient = APIClient(session: .shared, configuration: config)
        let objectsRepo = ObjectsRepository(apiClient: apiClient, configuration: config)
        let statsRepo = StatisticsRepository(apiClient: apiClient, configuration: config)

        return AppStatusService(
            objectsRepository: objectsRepo,
            statisticsRepository: statsRepo,
            configuration: config
        )
    }

    @MainActor
    static func makeAnalyticsRepository() -> AnalyticsRepositoryProtocol {
        let config = AppConfiguration.apiConfiguration
        let apiClient = APIClient(session: .shared, configuration: config)
        return AnalyticsRepository(apiClient: apiClient)
    }
}
```

### AppCoordinator Integration

**Network services are integrated at app startup**:
```swift
@MainActor
final class AppCoordinator: ObservableObject {
    private let appStatusService: AppStatusServiceProtocol
    private let analyticsRepository: AnalyticsRepositoryProtocol

    func onAppear() async {
        async let statusResult = appStatusService.loadStatus()
        async let analytics = analyticsRepository.addObject()

        let (result, _) = await (statusResult, analytics)

        pdfUrl = result.pdfUrl
        statisticsUrl = result.statisticsUrl
        handleStatus(result.status)
    }
}
```

### Configuration

**Update API configuration in `APIConfiguration.swift`**:
```swift
enum AppConfiguration {
    static var apiConfiguration: APIConfiguration {
        APIConfiguration(
            baseURL: URL(string: "https://api.example.com")!,
            userAgent: "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 ...)",
            basicAuth: ("admin", "password"),
            appMode: .default,
            appVersion: majorAppVersion
        )
    }
}
```

### Adding New Endpoints

1. Add case to `APIEndpoint`:
```swift
enum APIEndpoint {
    case newEndpoint(param: String)

    var path: String {
        case .newEndpoint: return "newEndpoint"
    }
}
```

2. Create repository protocol and implementation:
```swift
protocol NewRepositoryProtocol: Sendable {
    func fetchData() async -> Data?
}

final class NewRepository: NewRepositoryProtocol, Sendable {
    private let apiClient: APIClientProtocol

    func fetchData() async -> Data? {
        await apiClient.request(endpoint: .newEndpoint(param: "value"))
    }
}
```

3. Add to ServiceFactory:
```swift
@MainActor
static func makeNewRepository() -> NewRepositoryProtocol {
    let config = AppConfiguration.apiConfiguration
    let apiClient = APIClient(session: .shared, configuration: config)
    return NewRepository(apiClient: apiClient)
}
```

---

## Notifications System

### Notifications Package Architecture

The app includes a local Swift Package for managing daily notifications:

```
Notifications/
├── Package.swift
└── Sources/
    └── Notifications/
        ├── NotificationMessage.swift
        └── LocalNotificationsController.swift
```

### Notifications Package Components

**NotificationMessage** - Data structure for notification content:
```swift
public struct NotificationMessage: Hashable, Sendable {
    public let title: String
    public let body: String
}
```

**DailyNotificationSchedule** - Configuration for daily notification timing:
```swift
public struct DailyNotificationSchedule: Hashable, Sendable {
    public let identifier: String
    public let hour: Int
    public let minute: Int
}

// Default schedule: 10:00, 13:00, 19:00, 22:30
public extension DailyNotificationSchedule {
    static let standard: [DailyNotificationSchedule] = [
        .init(identifier: "daily-10-00", hour: 10, minute: 0),
        .init(identifier: "daily-13-00", hour: 13, minute: 0),
        .init(identifier: "daily-19-00", hour: 19, minute: 0),
        .init(identifier: "daily-22-30", hour: 22, minute: 30)
    ]
}
```

**LocalNotificationsController** - Main controller for scheduling notifications:
```swift
public protocol LocalNotificationsControlling {
    func requestAuthorization() async -> Bool
    func scheduleDailyNotifications() async
    func scheduleTestNotifications() async
    func removeDailyNotifications() async
}
```

### NotificationsService Integration

**Service Layer** (`Services/NotificationsService.swift`):

```swift
@MainActor
final class NotificationsService {
    // Test mode for immediate notifications (5 second intervals)
    static let isTestMode = false

    private let controller: LocalNotificationsControlling

    init(controller: LocalNotificationsControlling = DefaultLocalNotificationsController(
        messagesProvider: TemplateNotificationMessagesProvider()
    )) {
        self.controller = controller
    }

    func requestAuthorization() async -> Bool {
        await controller.requestAuthorization()
    }

    func scheduleNotifications() async {
        if Self.isTestMode {
            await controller.scheduleTestNotifications()
        } else {
            await controller.scheduleDailyNotifications()
        }
    }

    func removeDailyNotifications() async {
        await controller.removeDailyNotifications()
    }
}
```

**Message Provider** - Implements protocol to provide localized notification messages:

```swift
struct TemplateNotificationMessagesProvider: NotificationMessagesProviding {
    var messages: [NotificationMessage] {
        NotificationMessageKeys.all.map { keys in
            NotificationMessage(
                title: localized(keys.title),
                body: localized(keys.body)
            )
        }
    }

    private func localized(_ key: String) -> String {
        NSLocalizedString(key, bundle: .main, comment: "")
    }
}
```

### AppCoordinator Integration

Notifications are automatically managed by `AppCoordinator` based on app status:

```swift
@MainActor
final class AppCoordinator: ObservableObject {
    private let notificationsService: NotificationsService

    init(statusLoader: StatusLoader, notificationsService: NotificationsService) {
        self.statusLoader = statusLoader
        self.notificationsService = notificationsService
        self.overlay = .splash
    }

    convenience init() {
        self.init(
            statusLoader: StatusLoader(),
            notificationsService: NotificationsService()
        )
    }

    private func handleNotifications(for status: AppStatus) {
        Task {
            switch status {
            case .zero:
                // Remove notifications in normal app flow
                await notificationsService.removeDailyNotifications()
            case .one:
                // Schedule notifications in web view mode
                await notificationsService.scheduleNotifications()
            }
        }
    }
}
```

### Notification Messages Localization

Add notification messages to all `Localizable.strings` files:

**English (en.lproj/Localizable.strings)**:
```
"notification.message1.title" = "Daily Reminder";
"notification.message1.body" = "Don't forget to check your tasks today!";
"notification.message2.title" = "Stay on Track";
"notification.message2.body" = "You're doing great! Keep up the momentum.";
// ... up to message10
```

**German (de.lproj/Localizable.strings)**:
```
"notification.message1.title" = "Tägliche Erinnerung";
"notification.message1.body" = "Vergiss nicht, deine Aufgaben heute zu überprüfen!";
// ... up to message10
```

**Spanish (es.lproj/Localizable.strings)**:
```
"notification.message1.title" = "Recordatorio Diario";
"notification.message1.body" = "¡No olvides revisar tus tareas hoy!";
// ... up to message10
```

### Adding the Notifications Package to Xcode

**To complete the integration:**

1. Open `TemplateApp.xcodeproj` in Xcode
2. Select the project in the Project Navigator
3. Select the TemplateApp target
4. Go to "Frameworks, Libraries, and Embedded Content"
5. Click "+" button
6. Click "Add Other" → "Add Package Dependency"
7. Navigate to the `Notifications` folder in your project root
8. Add the Notifications package

**Or use File → Add Package Dependencies:**
1. File → Add Package Dependencies
2. Click "Add Local..." button
3. Navigate to `/path/to/Template-1/Notifications`
4. Add the package

### Testing Notifications

**Test Mode** - Enable immediate notifications for testing:
```swift
// In NotificationsService.swift
static let isTestMode = true  // Schedules 4 notifications at 5-second intervals
```

**Authorization** - Request notification permissions:
```swift
let service = NotificationsService()
let authorized = await service.requestAuthorization()
```

**Schedule** - Schedule daily notifications:
```swift
await service.scheduleNotifications()
```

**Remove** - Remove all scheduled notifications:
```swift
await service.removeDailyNotifications()
```

### Notification Behavior

- **Daily Schedule**: 4 notifications per day at 10:00, 13:00, 19:00, 22:30
- **Random Messages**: Each notification randomly selects from available localized messages
- **Foreground Presentation**: Notifications show even when app is in foreground
- **Sound**: Custom sound "win.wav" (if added to project, otherwise default sound)
- **Repeating**: Daily notifications repeat indefinitely until removed

---

## Project Structure

```
Template-1/
├── Notifications/                # Local Swift Package
│   ├── Package.swift
│   └── Sources/
│       └── Notifications/
│           ├── NotificationMessage.swift
│           └── LocalNotificationsController.swift
│
└── TemplateApp/
    ├── App/                      # App entry and root coordinator
    ├── Navigation/               # Navigation protocols
    ├── Onboarding/               # Onboarding flow
    │   └── Views/
    ├── Session/                  # Main session
    │   ├── Feature1/
    │   │   └── Views/
    │   ├── Feature2/
    │   │   └── Views/
    │   ├── Feature3/
    │   │   ├── Views/
    │   │   └── SubFlow/          # Modal flow example
    │   │       └── Views/
    │   └── WebView/
    ├── Services/                 # Business logic (async/await)
    │   ├── Network/              # Network layer
    │   │   ├── APIClient.swift
    │   │   ├── APIError.swift
    │   │   ├── APIConfiguration.swift
    │   │   ├── APIEndpoint.swift
    │   │   ├── LoggerService.swift
    │   │   ├── AppStatusService.swift
    │   │   ├── ServiceFactory.swift
    │   │   ├── Models/
    │   │   │   ├── AppMode.swift
    │   │   │   ├── AppStatus.swift
    │   │   │   └── AppObjects.swift
    │   │   └── Repositories/
    │   │       ├── ObjectsRepository.swift
    │   │       ├── StatisticsRepository.swift
    │   │       └── AnalyticsRepository.swift
    │   ├── TemplateService.swift
    │   └── NotificationsService.swift
    ├── Storage/                  # KeyValue, StorageKeys, DefaultsStorage
    ├── Extensions/               # ColorPalette, Typography, Localization
    └── Resources/                # Assets, Localizable strings
        ├── en.lproj/
        ├── de.lproj/
        └── es.lproj/
```

---

## Quick Reference

| Component | Purpose |
|-----------|---------|
| `AppCoordinator` | Root state (onboarding/session/webView), manages Network & Notifications |
| `SessionCoordinator` | Tab factory, creates feature coordinators |
| `FeatureCoordinator` | Manages feature navigation with inline output |
| `FeatureCoordinatorNavigation` | NavigationStorable implementation |
| `FeatureCoordinatorView` | SwiftUI view wrapper |
| `FeatureVM` | Observable ViewModel with Output |
| `FeatureView` | SwiftUI view |
| `APIClient` | Generic HTTP client with error handling |
| `APIConfiguration` | API configuration with auth and versioning |
| `ServiceFactory` | Centralized service creation |
| `AppStatusService` | Coordinated app status loading with parallel calls |
| `ObjectsRepository` | Fetches app objects from API |
| `StatisticsRepository` | Fetches statistics URL from API |
| `AnalyticsRepository` | Sends analytics events to API |
| `NotificationsService` | Wrapper for LocalNotificationsController, manages daily notifications |
| `LocalNotificationsController` | Core notifications logic (from Notifications package) |
| `@KeyValue` | Property wrapper for storage |
| `L10n` | Type-safe localization |
| `.palette(.color)` | Color palette access |
| `.typography()` | Text styling modifier |

---

## Code Style

### File Organization

```swift
// MARK: - Properties
// MARK: - Initialization
// MARK: - Navigation Methods (for Coordinators)
// MARK: - Actions (for ViewModels)
// MARK: - Private Methods
// MARK: - Preview (for Views)
```

### Naming Conventions

```swift
// Coordinators
class FeatureCoordinator { }
class FeatureCoordinatorNavigation { }
struct FeatureCoordinatorView { }

// ViewModels
class FeatureVM { }
class FeatureDetailVM { }

// Views
struct FeatureView { }
struct FeatureDetailView { }
```

---

## Dependencies

This template has **no external dependencies**. It uses only:
- SwiftUI
- Combine (minimal, for @Published)
- WebKit (for WebView)
- UserNotifications (for local notifications)

**Local Package:**
- `Notifications` - Local Swift Package for managing daily notifications

Add dependencies as needed for your specific project.
