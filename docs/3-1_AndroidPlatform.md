# Android Platform Development

## Overview

HADK is a cross-platform development framework. This document provides complete examples for compiling and running agents on the Android platform, including cross-compilation configuration and Android Studio project integration. 

## Cross-compilation Reference

For complete cross-compilation examples and configurations, please refer to: [Cross-Compilation Agent Example](https://gitlab.xpaas.lenovo.com/latc/Components/hybrid-agent-rumtime/hadk_dylibs/-/tree/main?ref_type=heads)

## Agent Development

For the agent implementation used, please refer to: [Single Node Agent Development Guide](https://gitlab.xpaas.lenovo.com/latc/Components/hybrid-agent-rumtime/hadk_apps/-/tree/android/src/single_node?ref_type=heads)

## Android Studio Integration

We provide a complete Android Studio example project that demonstrates how to call cross-compiled agents through `Kotlin + JNI` and execute  `local tool calls` to implement a simple chatbot.

For the complete Android Studio example project, please refer to: [Android Demo Project](https://gitlab.xpaas.lenovo.com/liusong9/hadkdemo)

### Local Tools

This demo provides the following local tools that can be called through function call:

- Control device Bluetooth on/off
- Dynamically adjust device screen brightness
- Control device flashlight on/off
- Control device volume
- Screen capture
