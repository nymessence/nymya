# Story Generation Library for NymyaLang

This library provides advanced story generation capabilities for NymyaLang, with support for multi-character conversations, scenario adaptation, and anti-repetition measures.

## Components

### 1. Core Components:
- `config.nym` - Configuration framework for story generation settings
- `api_client.nym` - API client with retry logic and error handling
- `utils.nym` - Utility functions for text processing and similarity calculations
- `context_builder.nym` - Context and system prompt building with anti-repetition integration

### 2. Character and Story Components:
- `character_loader.nym` - Character loading with voice analysis and private agenda generation
- `repitition_detector.nym` - Advanced repetition detection and pattern blocking
- `response_generator.nym` - Adaptive response generation with anti-repetition strategies
- `scenario_adapter.nym` - Scenario adaptation module for custom scenario integration
- `scenario_progression.nym` - Scenario progression system for advancing conversations through stages
- `environmental_triggers.nym` - Environmental trigger generation for dynamic conversation events

### 3. Main Application:
- `story_test.nym` - Main application file with command-line argument support and complete conversation system

## Features

- **Anti-Repetition Engine**: Sophisticated pattern recognition to prevent repetitive responses
- **Voice Analysis**: Automatic character voice analysis and consistency maintenance
- **Scenario Integration**: Dynamic adaptation to custom scenarios
- **Environmental Triggers**: Contextual events to drive conversation dynamics
- **Private Agendas**: Hidden character motivations that influence responses
- **Cross-Platform**: Works across Linux, Windows, and macOS targets
- **GMP Support**: Arbitrary precision arithmetic for complex calculations

## Usage

```nymya
import storygen.story_test
import storygen.character_loader
import storygen.response_generator

// Load characters and start conversation
var characters = [
    storygen.character_loader.load_character_generic("character1.json"),
    storygen.character_loader.load_character_generic("character2.json")
]

// Run story generation...
```

## Dependencies

- NymyaLang standard library components
- GMP library for high-precision mathematics
- API connectivity for LLM services