// PDF.swift
//
// swift-pdf-standard
//
// Unified PDF API with ergonomic coordinate system.
//
// This module provides a high-level API for PDF generation that uses
// a top-left origin with y increasing downward (matching HTML/CSS).
// Coordinates are automatically transformed to PDF's bottom-left origin
// at the final emission stage.

/// PDF namespace for high-level document generation
public enum PDF: Sendable {}
