#-------------------------------------------------
#
# Project created by QtCreator 2014-01-17T12:39:08
#
#-------------------------------------------------

QT += qml quick enginio
TARGET = conclave
TEMPLATE = app
SOURCES += main.cpp \
    theme.cpp \
    model.cpp \
    sortfiltermodel.cpp

OTHER_FILES += \
    qml/main.qml \
    qml/components/Event.qml \
    qml/components/TrackSwitcher.qml \
    qml/components/Track.qml \
    qml/components/ConferenceHeader.qml \
    qml/components/DropDownMenu.qml \
    qml/components/ListItem.qml

RESOURCES += \
    resource.qrc

HEADERS += \
    theme.h \
    model.h \
    sortfiltermodel.h
