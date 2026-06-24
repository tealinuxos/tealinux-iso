/*
 *   Copyright 2014 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License version 2,
 *   or (at your option) any later version, as published by the Free
 *   Software Foundation
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick

Image {
    id: root
    source: "images/background.png"
    fillMode: Image.PreserveAspectCrop

    property int stage

    onStageChanged: {
        if (stage == 1) {
            introAnimation.running = true
        }
    }

    Item {
        id: topRect
        anchors.horizontalCenter: parent.horizontalCenter
        y: root.height
        width: 460
        height: 290

        Image {
            source: "images/tea.svg"
            anchors.centerIn: parent
        }
        Rectangle {
            radius: 2
            color: "#9f81d0"
            anchors {
                bottom: parent.bottom
                bottomMargin: 35
                horizontalCenter: parent.horizontalCenter
            }
            height: 4
            width: 200
            Rectangle {
                radius: 2
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                }
                width: (parent.width / 6) * (stage - 1)
                color: "#ffffff"
                Behavior on width { 
                    PropertyAnimation {
                        duration: 250
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }
    }

    SequentialAnimation {
        id: introAnimation
        running: false

        ParallelAnimation {
            PropertyAnimation {
                property: "y"
                target: topRect
                to: (root.height - topRect.height) / 2
                duration: 1000
                easing.type: Easing.InOutBack
                easing.overshoot: 1.0
            }
        }
    }
}
