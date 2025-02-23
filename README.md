##### NOTE!
Currently a Work-in-progress: The hope is to make this fully fledged multiplayer implementation that anyone can template from or develop on.
This will also be used as a test bench to test making custom implementations within a test suites to make synchronization robust between server and client.

# Branched Multiplayer
This repository is an exploration of Godot 4.x SceneMultiplayer API to its fullest.


## Features and Architecture
- Central Authority
- Branched MultiplayerAPIs for single and split viewports in one process.
- Uses Multiplayer Nodes. (MultiplayerSynchronizer, MultiplayerSpawner)
- SceneMultiplayer wrapped with MultiplayerAPIExtension for debug output.
- ENetMultiplayerPeer wrapped with MultiplayerPeerExtension with configurable packet delay, loss, and jitter.
- Non-destructive and editable SceneReplicationConfigs for MultiplayerSynchronizers.

## Roadmap
- TODO: Built-in packet delay and packet loss modifiers.
- TODO: lots of user facing UI for statistics
- TODO: lots of options for adjusting synchronization
- TODO: various sandbox test scenarious and game design 3d/2d/ui
- TODO: Make editor pluggin to support 3rd party projects.

## Preview
[position_only.webm](https://github.com/user-attachments/assets/ec509dc3-7801-44f1-b032-fedfa7be4a8f)

[input_position.webm](https://github.com/user-attachments/assets/eb0aa207-2a62-4b76-ba2d-287b6ea01564)

[all.webm](https://github.com/user-attachments/assets/76c9e647-208d-4d89-9c44-54f2064c1a9a)

[obstacles.webm](https://github.com/user-attachments/assets/3e6ff79a-82b1-4159-833d-e20439804297)
