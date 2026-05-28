import Foundation
import AppKit
import FinderRightKit

/// 主 App 端的 IPC 监听宿主。
///
/// 责任：
///   1. 启动时确保 IPC 目录存在
///   2. 当主 App 收到自定义 URL `finderright://execute?id=<uuid>` 时，路由到这里的 handle(id:)
///   3. 从 request 文件读 IPCRequest → 调用 FinderRightService → 写 response 文件
///
/// 我们不主动监听目录，而是依赖扩展先写文件、再用 URL scheme 唤醒主 App。
/// 这避免了不必要的 fswatch 后台开销，并保证"请求顺序"严格。
final class IPCWatcher {

    static let shared = IPCWatcher()
    private init() {}

    private let service = FinderRightService()
    private let queue = DispatchQueue(label: "com.finderright.app.ipc", qos: .userInitiated)

    func start() {
        do {
            try IPCBridge.ensureDirectory()
            NSLog("[IPCWatcher] ready, ipc dir = \(IPCBridge.pendingDir.path)")
        } catch {
            NSLog("[IPCWatcher] failed to create ipc dir: \(error)")
        }
    }

    /// 主 App 收到 URL scheme 触发后，调用此方法
    /// URL 形如：finderright://execute?id=<uuid>
    func handle(url: URL) {
        guard url.scheme == IPCBridge.urlScheme else {
            NSLog("[IPCWatcher] unexpected url scheme: \(url)")
            return
        }
        guard let comps = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let id = comps.queryItems?.first(where: { $0.name == "id" })?.value else {
            NSLog("[IPCWatcher] url missing id: \(url)")
            return
        }
        NSLog("[IPCWatcher] received request id=\(id)")
        queue.async { [weak self] in
            self?.processRequest(id: id)
        }
    }

    private func processRequest(id: String) {
        let reqURL = IPCBridge.requestFile(id: id)
        let respURL = IPCBridge.responseFile(id: id)

        do {
            let data = try Data(contentsOf: reqURL)
            let request = try JSONDecoder().decode(IPCRequest.self, from: data)
            NSLog("[IPCWatcher] decoded request action=\(request.action)")

            let response = service.handle(request)

            let respData = try JSONEncoder().encode(response)
            try respData.write(to: respURL, options: .atomic)
            NSLog("[IPCWatcher] wrote response id=\(id) success=\(response.success)")

            // 清掉 request 文件（response 由扩展读完后删除）
            try? FileManager.default.removeItem(at: reqURL)
        } catch {
            NSLog("[IPCWatcher] processRequest error id=\(id): \(error)")
            // 即使出错也写一个 response，避免扩展死等
            let failed = IPCResponse(id: id, success: false, message: "主 App 处理失败: \(error.localizedDescription)")
            if let data = try? JSONEncoder().encode(failed) {
                try? data.write(to: respURL, options: .atomic)
            }
        }
    }
}
