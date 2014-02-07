/****************************************************************************
**
** Copyright (C) 2014 Digia Plc and/or its subsidiary(-ies).
** Contact: http://www.qt-project.org/legal
**
** This file is part of the examples of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:BSD$
** You may use this file under the terms of the BSD license as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of Digia Plc and its Subsidiary(-ies) nor the names
**     of its contributors may be used to endorse or promote products derived
**     from this software without specific prior written permission.
**
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
**
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import qt.conclave.models 1.0

ColumnLayout {
    id: root

    spacing: 10

    //TODO: move to TrackHeader file
    Item {
        Layout.fillWidth: true
        height: 70

        Rectangle {
            id: header
            anchors {fill: parent; rightMargin: 10; leftMargin: 10; topMargin: 10}
            color: "black"
            opacity: 0.7
        }

        Label {
            anchors { fill: header; rightMargin: 20; leftMargin: 20; margins: 10 }
            text: name
            color: "white"
            fontSizeMode: Text.Fit
            font.pixelSize: parent.height
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
        }
    }

    ListView {
        id: trackList
        property string trackId: id

        clip: true
        delegate: Item {
            anchors { left: parent.left; right: parent.right }
            height: 180

            Rectangle {
                anchors { fill: parent; rightMargin: 10; leftMargin: 10 }
                color: "black"
                opacity: 0.7
            }

            RowLayout {
                anchors { top: parent.top; left: parent.left; right: parent.right; rightMargin: 20; leftMargin: 20; margins: 10 }
                height: 30
                Label {
                    text: Qt.formatTime(start, "h:mm") + " - " + Qt.formatTime(end, "h:mm")
                    color: "white"
                    fontSizeMode: Text.Fit
                    font.pixelSize: parent.height
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    Layout.fillWidth: true
                }
            }

            Label {
                anchors { fill: parent; rightMargin: 20; leftMargin: 20; margins:10 }
                text: topic
                color: "white"
                fontSizeMode: Text.Fit
                font.pixelSize: parent.height
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            MouseArea {
                anchors.fill: parent
                onClicked: stack.push({"item" : Qt.resolvedUrl("Event.qml"), "properties" : {"text" : topic}})
            }
        }

        spacing: 10
        model: SortFilterModel { id:tmp;  sortRole: "start" }
        Layout.fillHeight: true
        Layout.fillWidth: true

        Model { id: eventModel;
            backendId: "52de5155e5bde50fab014f67"
            onDataReady: tmp.model = eventModel
        }

        onTrackIdChanged: eventModel.query({ "objectType": "objects.Event",
                                               "query": {
                                                   "track": {
                                                       "id": trackList.trackId, "objectType": "objects.Track"
                                                   }
                                               }
                                           })
    }
}
