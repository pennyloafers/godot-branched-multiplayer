##### NOTE!
Currently a Work-in-progress: The hope is to make this fully fledged multiplayer implementation that anyone can template from or develop on.
This will also be used as a test bench to test making custom implementations within a test suites to make synchronization robust between server and client.

# Branched Multiplayer
This repository is an exploration of Godot 4.x SceneMultiplayer API to its fullest.


## Features and Architecture
- Central Authority
- ENet
- Branched MultiplayerAPIs
- Multiplayer Nodes (MultiplayerSynchronizer, MultiplayerSpawner)
- MultiplayerAPIExtension wrapping SceneMultiplayer for debug output

## Roadmap
- TODO: MultiplayerPeerExtension wrapping EnetPacketPeer
- TODO: Built-in packet delay and packet loss modifiers.
- TODO: lots of user facing UI for statistics
- TODO: lots of options for adjusting synchronization
- TODO: various sandbox test scenarious and game design 3d/2d/ui
- TODO: testbench ( bring your own component )

## Preview
[position_only.webm](https://github.com/user-attachments/assets/ec509dc3-7801-44f1-b032-fedfa7be4a8f)

[input_position.webm](https://github.com/user-attachments/assets/eb0aa207-2a62-4b76-ba2d-287b6ea01564)

[all.webm](https://github.com/user-attachments/assets/76c9e647-208d-4d89-9c44-54f2064c1a9a)

[all_short.webm](https://github.com/user-attachments/assets/525a4eed-0b4f-4b01-9049-ea0731ac60bd)
