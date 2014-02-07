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
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import qt.conclave.theme 1.0
import qt.conclave.models 1.0

Item {
    id: root
    property string conferenceId
    property string dayId

    Rectangle {
        id: headerBackground
        anchors { fill: parent }
        color: "black"
        opacity: 0.7
    }

    Model {
        id: conference
        backendId: "52de5155e5bde50fab014f67"
        onDataReady: {
            header.text = conference.data(0, "name")
            root.conferenceId = conference.data(0, "id")
        }
        Component.onCompleted: query({"objectType": "objects.Conference"})
    }

    Column {
        id: texts
        anchors { fill: parent; margins: 3; rightMargin: info.width }
        Label {
            id: header
            color: "white"
            fontSizeMode: Text.Fit
            font.pixelSize: headerBackground.height * 2/4
            horizontalAlignment: Text.AlignHCenter
            width: parent.width
        }
        Label {
            id: dayLabel
            color: "white"
            fontSizeMode: Text.Fit
            font.pixelSize: headerBackground.height * 1/4
            horizontalAlignment: Text.AlignHCenter
            width: parent.width
        }
    }

    MouseArea {
        anchors.fill: texts
        onClicked: dropMenu.show()
    }

    Image {
        id: info
        anchors { right: parent.right }
        height: parent.height
        width: height
        source: "qrc:/image/info"
        smooth: true
    }

    DropDownMenu {
        id: dropMenu
        anchors {
            top: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }

        delegate: ListItem {
            height: dropMenu.delegateHeight
            width: dropMenu.width
            Label {
                id: label
                anchors { fill: parent; margins: 3 }
                color: "white"
                fontSizeMode: Text.Fit
                font.pixelSize: parent.height
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: Qt.formatDate(date, "ddd d.M.yyyy")
            }
            onClicked: {
                dayLabel.text = Qt.formatDate(date, "dddd d.M.yyyy")
                root.dayId = id
                dropMenu.close()
            }
        }
        model: SortFilterModel {
            id: dayModel;
            sortRole: "date"
        }

        Model {
            id: day
            backendId: "52de5155e5bde50fab014f67"
            onDataReady: {
                dayModel.model = day
                dayLabel.text = Qt.formatDate(dayModel.get(0,"date"), "dddd d.M.yyyy")
                root.dayId = dayModel.get(0,"id")
            }
        }
        width: Math.min(window.width * 0.6, 400)


    }
    onConferenceIdChanged: day.query({ "objectType": "objects.Day",
                                         "query": {
                                             "conference": {
                                                 "id": root.conferenceId, "objectType": "objects.Conference"
                                             }
                                         }
                                     })
}
