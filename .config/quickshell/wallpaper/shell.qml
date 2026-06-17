//@ pragma UseQApplication
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtMultimedia

ShellRoot {
    PanelWindow {
        id: root

        anchors { top: true; bottom: true; left: true; right: true }
        color: "transparent"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        WlrLayershell.namespace: "wallpaper-picker"

        readonly property string scripts: "/home/plo/.config/hypr/scripts"
        property color accent: "#7aa2f7"
        property color accent2: "#9bbcff"
        property color themeBg: "#16181f"
        property string current: ""

        // "" = no shader, "RANDOM" = random shader, otherwise a .glsl path.
        property string selectedShader: ""
        function shaderArg() {
            return selectedShader === "" ? "none"
                 : selectedShader === "RANDOM" ? "--shuffle"
                 : selectedShader;
        }
        function choose(wallpaperArg) {
            Quickshell.execDetached(["bash", scripts + "/set-wallpaper.sh", wallpaperArg, shaderArg()]);
            Qt.quit();
        }
        function chooseCurrent() {
            if (grid.currentIndex >= 0 && grid.currentIndex < viewModel.count)
                choose(viewModel.get(grid.currentIndex).video);
        }
        // Surprise me: random wallpaper + random shader, ignoring the selection.
        function shuffleBoth() {
            Quickshell.execDetached(["bash", scripts + "/set-wallpaper.sh", "--shuffle", "--shuffle"]);
            Qt.quit();
        }
        function fuzzy(q, s) {
            let j = 0;
            for (let i = 0; i < s.length && j < q.length; i++)
                if (s[i] === q[j]) j++;
            return j === q.length;
        }
        function matches(name) {
            const q = search.text.toLowerCase();
            return q.length === 0 || fuzzy(q, name.toLowerCase());
        }
        function rebuild() {
            viewModel.clear();
            for (let i = 0; i < allModel.count; i++) {
                const it = allModel.get(i);
                if (matches(it.name))
                    viewModel.append({ thumb: it.thumb, video: it.video, name: it.name });
            }
            grid.currentIndex = viewModel.count > 0 ? 0 : -1;
        }

        readonly property var sel: (grid.currentIndex >= 0 && grid.currentIndex < viewModel.count)
                                   ? viewModel.get(grid.currentIndex) : null

        // --- theme data ---
        FileView {
            path: "/home/plo/.cache/wallust/accent"
            blockLoading: true
            Component.onCompleted: {
                const lines = text().split("\n").filter(l => l.length > 0);
                if (lines[0]) root.accent = lines[0];
                if (lines[1]) root.accent2 = lines[1];
            }
        }
        FileView {
            path: "/home/plo/.config/ghostty/wallust"
            blockLoading: true
            Component.onCompleted: {
                const m = text().match(/background\s*=\s*(#[0-9A-Fa-f]{6})/);
                if (m) root.themeBg = m[1];
            }
        }
        FileView {
            path: "/home/plo/.cache/phonto/current"
            blockLoading: true
            Component.onCompleted: root.current = text().trim()
        }

        ListModel { id: allModel }
        ListModel { id: viewModel }
        Process {
            command: ["bash", root.scripts + "/wallpaper-list.sh"]
            running: true
            stdout: SplitParser {
                onRead: line => {
                    const p = line.split("\t");
                    if (p.length < 3) return;
                    allModel.append({ thumb: p[0], video: p[1], name: p[2] });
                    if (root.matches(p[2])) {
                        viewModel.append({ thumb: p[0], video: p[1], name: p[2] });
                        if (grid.currentIndex < 0) grid.currentIndex = 0;
                    }
                }
            }
        }

        // --- shader list (None / Random / each .glsl in phonto's shaders dir) ---
        ListModel {
            id: shaderModel
            ListElement { sname: "None"; spath: "" }
            ListElement { sname: "󰓞 Random"; spath: "RANDOM" }
        }
        Process {
            command: ["bash", "-c", "find ~/.config/phonto/shaders -name '*.glsl' | sort"]
            running: true
            stdout: SplitParser {
                onRead: line => {
                    if (line.length === 0) return;
                    const base = line.split("/").pop().replace(/\.glsl$/, "");
                    shaderModel.append({ sname: base, spath: line });
                }
            }
        }

        // --- shared video player, created LAZILY so it doesn't block window open.
        //     The QtMultimedia import is cheap, but instantiating MediaPlayer
        //     initializes the FFmpeg backend (~0.18s), so defer it to just after
        //     the window is on screen. ---
        Loader {
            id: playerLoader
            active: false
            sourceComponent: MediaPlayer { loops: MediaPlayer.Infinite }
        }
        // Warm the player a blink after the window is up (off the critical path).
        Timer { interval: 40; running: true; onTriggered: playerLoader.active = true }

        property string pendingVideo: root.sel ? root.sel.video : ""
        onPendingVideoChanged: previewDebounce.restart()
        // Debounce so fast arrow-key scrubbing doesn't thrash the decoder.
        Timer {
            id: previewDebounce
            interval: 150
            onTriggered: {
                playerLoader.active = true;
                const player = playerLoader.item;
                if (!player) return;
                if (!grid.currentItem || root.pendingVideo === "") { player.stop(); return; }
                player.videoOutput = grid.currentItem.sink;
                player.source = "file://" + root.pendingVideo;
                player.play();
            }
        }

        // --- dim backdrop ---
        Rectangle {
            anchors.fill: parent
            color: "#000000"
            opacity: 0.5
            MouseArea { anchors.fill: parent; onClicked: Qt.quit() }
        }

        // --- panel ---
        Rectangle {
            anchors.centerIn: parent
            width: Math.min(parent.width - 140, 1320)
            height: Math.min(parent.height - 100, 880)
            radius: 16
            color: Qt.lighter(root.themeBg, 1.25)
            border.color: root.accent
            border.width: 2

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 22
                spacing: 16

                // --- header: search + shuffle ---
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    Rectangle {
                        Layout.fillWidth: true
                        height: 40; radius: 9
                        color: Qt.darker(root.themeBg, 1.2)
                        border.color: root.accent; border.width: 1
                        Text {
                            anchors { left: parent.left; leftMargin: 12; verticalCenter: parent.verticalCenter }
                            text: ""; color: root.accent; font.pixelSize: 16
                        }
                        TextInput {
                            id: search
                            anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter
                                      leftMargin: 38; rightMargin: 12 }
                            color: "#ffffff"; font.pixelSize: 15; clip: true
                            focus: true
                            Component.onCompleted: forceActiveFocus()
                            onTextChanged: root.rebuild()
                            Text {
                                anchors.fill: parent; verticalAlignment: Text.AlignVCenter
                                text: "Search wallpapers…  (Ctrl+S shuffle · Ctrl+R shuffle + shader)"
                                color: "#80ffffff"; font: search.font
                                visible: search.text.length === 0
                            }
                            Keys.onPressed: event => {
                                if (event.modifiers & Qt.ControlModifier) {
                                    if (event.key === Qt.Key_S) { root.choose("--shuffle"); event.accepted = true; return; }
                                    if (event.key === Qt.Key_R) { root.shuffleBoth(); event.accepted = true; return; }
                                }
                                switch (event.key) {
                                case Qt.Key_Up:    grid.moveCurrentIndexUp();    event.accepted = true; break;
                                case Qt.Key_Down:  grid.moveCurrentIndexDown();  event.accepted = true; break;
                                case Qt.Key_Left:  grid.moveCurrentIndexLeft();  event.accepted = true; break;
                                case Qt.Key_Right: grid.moveCurrentIndexRight(); event.accepted = true; break;
                                case Qt.Key_Return:
                                case Qt.Key_Enter: root.chooseCurrent(); event.accepted = true; break;
                                case Qt.Key_Tab: {  // cycle the selected shader
                                    let i = 0;
                                    for (let k = 0; k < shaderModel.count; k++)
                                        if (shaderModel.get(k).spath === root.selectedShader) { i = k; break; }
                                    root.selectedShader = shaderModel.get((i + 1) % shaderModel.count).spath;
                                    event.accepted = true; break;
                                }
                                case Qt.Key_Escape:
                                    if (search.text.length > 0) search.text = ""; else Qt.quit();
                                    event.accepted = true; break;
                                }
                            }
                        }
                    }
                    Rectangle {
                        width: 120; height: 40; radius: 9
                        color: shuffleArea.containsMouse ? root.accent : "transparent"
                        border.color: root.accent; border.width: 1
                        Text {
                            anchors.centerIn: parent; text: "󰒟  Shuffle"; font.pixelSize: 14
                            color: shuffleArea.containsMouse ? root.themeBg : root.accent
                        }
                        MouseArea {
                            id: shuffleArea; anchors.fill: parent; hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor; onClicked: root.choose("--shuffle")
                        }
                    }
                }

                // --- grid (each tile previews live video when highlighted) ---
                GridView {
                    id: grid
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    // Stretch cells so the columns fill the full width — no right gap.
                    property int minCell: 240
                    readonly property int columns: Math.max(1, Math.floor(width / minCell))
                    cellWidth: Math.floor(width / columns)
                    cellHeight: Math.round(cellWidth * 0.62)
                    model: viewModel
                    currentIndex: 0
                    highlightMoveDuration: 110
                    keyNavigationWraps: true

                    delegate: Item {
                        id: tile
                        width: grid.cellWidth
                        height: grid.cellHeight
                        required property var model
                        required property int index
                        readonly property bool selected: index === grid.currentIndex
                        readonly property bool isCurrent: model.video === root.current
                        property alias sink: voutTile

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 7
                            radius: 11
                            clip: true
                            color: "#000000"
                            scale: tile.selected ? 1.05 : 1.0
                            Behavior on scale { NumberAnimation { duration: 90 } }
                            border.width: (tile.selected || tile.isCurrent) ? 3 : 0
                            border.color: tile.selected ? root.accent : (tile.isCurrent ? root.accent2 : root.accent)

                            // still thumbnail underneath; video draws on top when this tile is active
                            Image {
                                anchors.fill: parent
                                source: "file://" + model.thumb
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true; cache: true
                            }
                            VideoOutput {
                                id: voutTile
                                anchors.fill: parent
                                fillMode: VideoOutput.PreserveAspectCrop
                                visible: tile.selected
                            }
                            // active-wallpaper marker
                            Rectangle {
                                visible: tile.isCurrent
                                anchors { top: parent.top; right: parent.right; margins: 6 }
                                width: 12; height: 12; radius: 6
                                color: root.accent2; border.color: "#000000"; border.width: 1
                            }
                            // name label (on the active tile)
                            Rectangle {
                                anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                                height: 28
                                color: "#cc000000"
                                visible: tile.selected
                                Text {
                                    anchors.centerIn: parent
                                    text: model.name
                                    color: "#ffffff"; font.pixelSize: 12
                                }
                            }
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: grid.currentIndex = index
                                onClicked: root.choose(model.video)
                            }
                        }
                    }
                }

                // --- shader strip (applied to whatever wallpaper you pick) ---
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    Text {
                        text: "Shader"
                        color: root.accent2
                        font.pixelSize: 13
                        font.bold: true
                    }
                    ListView {
                        Layout.fillWidth: true
                        height: 34
                        orientation: ListView.Horizontal
                        clip: true
                        spacing: 8
                        model: shaderModel
                        delegate: Rectangle {
                            required property var model
                            readonly property bool active: model.spath === root.selectedShader
                            height: 34
                            width: chipText.implicitWidth + 24
                            radius: 8
                            color: active ? root.accent2 : "transparent"
                            border.color: root.accent2
                            border.width: 1
                            Text {
                                id: chipText
                                anchors.centerIn: parent
                                text: model.sname
                                font.pixelSize: 12
                                color: parent.active ? root.themeBg : root.accent2
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.selectedShader = model.spath
                            }
                        }
                    }
                }
            }
        }
    }
}
