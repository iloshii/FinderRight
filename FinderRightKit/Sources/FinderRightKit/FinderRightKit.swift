/// FinderRightKit — macOS Finder 右键增强应用核心业务逻辑层
///
/// 提供 Action 注册、配置管理、应用检测、文件操作等基础服务。

@_exported import struct Foundation.URL
@_exported import class Foundation.UserDefaults

// Re-export key types for convenience
// ActionCategory, FinderAction — from Models/ActionProtocol.swift
// ActionRegistry — from Services/ActionRegistry.swift
// SharedConfig — from Services/SharedConfig.swift
// AppDetector — from Services/AppDetector.swift
// FileOperationService — from Services/FileOperationService.swift
