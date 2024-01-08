//
//  TimeHolder.swift
//  NaturalReminder
//
//  Created by Juan Carrera on 08.10.2023.
//

import Foundation
import Combine

class TimerHolder: ObservableObject {
    private var cancellable: AnyCancellable?
    
    func startTimer(
        every interval: TimeInterval,
        targetDate: Date,
        onUpdate: @escaping (String) -> Void
    ) {
        stopTimer()
        cancellable = Timer.publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .sink { _ in onUpdate(formatTimeLeft(until: targetDate)) }
    }
    
    func stopTimer() {
        cancellable?.cancel()
    }
}
