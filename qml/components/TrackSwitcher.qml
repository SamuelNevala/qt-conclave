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
import QtQuick.Window 2.1
import qt.conclave.theme 1.0
import qt.conclave.models 1.0

Item {
    id: root
    anchors.fill: parent

    Image {
        id: background

        property real factor: window.width / listView.contentWidth
        property real maxX: (-listView.contentWidth + listView.trackWidth * listView.visibleTracks) * factor

        fillMode: Image.TileHorizontally
        height: root.height
        horizontalAlignment:  Image.AlignTop
        source: "qrc:/image/bg"
        width: Math.max(listView.contentWidth, window.width)
        x: Math.max(Math.min(0, -listView.contentX * factor), maxX)
    }

    ConferenceHeader {
        id: header

        property var trackQuery: {
            "objectType": "objects.Track",
            "query": { "conference": { "objectType": "objects.Conference" } }
        }

        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: 93
        z: 1

        onConferenceIdChanged: {
            trackQuery.query.conference.id = header.conferenceId
            trackModel.query(trackQuery)
        }
    }


    ListView {
        id: listView

        property int visibleTracks: Math.max(Math.min(Math.floor(window.width / Theme.trackWidthDivider), count), 1)
        property real trackWidth: count > 1 ? Math.round(window.width / visibleTracks) : window.width

        anchors { topMargin: header.height + 10; fill: parent }
        clip: true

        delegate: Track {
            height: window.height - header.height - 30
            width: listView.trackWidth
        }

        model: SortFilterModel {
            id: tracks
            filterRole: "day"
            filterRegExp: new RegExp(header.dayId)
        }

        snapMode: ListView.SnapOneItem
        orientation: ListView.Horizontal
        Model {
            id: trackModel;
            backendId: "52de5155e5bde50fab014f67"
            onDataReady: tracks.model = trackModel
        }
    }
}
