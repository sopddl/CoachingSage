// Coaching/Selector/SportCodeMapping.swift
// Story 3.2 — pont SportCode (app) ↔ Sport (package Templates).
// Le mismatch unique : SportCode.strengthTraining = "strengthTraining"
// vs Sport.strengthTraining = "strength_training". Tous les autres rawValues
// sont alignés Story 0.5.8.
import Foundation
import TemplateModel

extension Sport {
    init?(sportCode: String) {
        if let direct = Sport(rawValue: sportCode) {
            self = direct
            return
        }
        if sportCode == "strengthTraining" {
            self = .strengthTraining
            return
        }
        return nil
    }
}

extension Level {
    init?(profileLevel: String) {
        self.init(rawValue: profileLevel)
    }
}
