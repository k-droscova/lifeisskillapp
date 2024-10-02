//
//  FlowDelegates.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 02.10.2024.
//

import Foundation
@testable import lifeisskillapp

final class ScanPointFlowDelegateMock: NSObject, ScanPointFlowDelegate {
    
    var onScanPointInvalidPointCalled = false
    var onScanPointNoLocationCalled = false
    var onScanPointProcessSuccessOnlineCalled = false
    var onScanPointProcessSuccessOfflineCalled = false
    var onScanPointOnlineProcessErrorCalled = false
    var onScanPointOfflineProcessErrorCalled = false
    
    var sourceArgument: CodeSource?

    func onScanPointInvalidPoint() {
        onScanPointInvalidPointCalled = true
    }

    func onScanPointNoLocation() {
        onScanPointNoLocationCalled = true
    }

    func onScanPointProcessSuccessOnline(_ source: CodeSource) {
        onScanPointProcessSuccessOnlineCalled = true
        sourceArgument = source
    }

    func onScanPointProcessSuccessOffline(_ source: CodeSource) {
        onScanPointProcessSuccessOfflineCalled = true
        sourceArgument = source
    }

    func onScanPointOnlineProcessError(_ source: CodeSource) {
        onScanPointOnlineProcessErrorCalled = true
        sourceArgument = source
    }

    func onScanPointOfflineProcessError() {
        onScanPointOfflineProcessErrorCalled = true
    }
}
