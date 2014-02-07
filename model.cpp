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

#include "model.h"

#include <Enginio/enginioclient.h>
#include <Enginio/enginioreply.h>
#include <QtCore/QDebug>
#include <QtCore/QJsonValue>
#include <QtCore/QJsonArray>
#include <QtCore/QJsonDocument>
#include <QtCore/QFile>
#include <QtCore/QStandardPaths>
#include <QtCore/QDir>

Model::Model(QObject *parent)
    : QAbstractListModel(parent)
{
    m_client = new EnginioClient(this);
    connect(m_client, SIGNAL(finished(EnginioReply*)), this, SLOT(onFinished(EnginioReply*)));
}


int Model::rowCount(const QModelIndex & parent) const
{
    Q_UNUSED(parent);
    return m_data.count();
}

QVariant Model::data(const QModelIndex & index, int role) const
{
    QVariant variant = m_data.at(index.row()).value(m_roleNames.value(role));
    // Hack to make it possible to filter by refence
    if (variant.type() == QVariant::Map) {
        return variant.toMap().value("id");
    }

    return variant;
}

QHash<int, QByteArray> Model::roleNames() const
{
    return m_roleNames;
}

QString Model::backendId() const
{
    return m_client ? m_client->backendId() : "";
}

void Model::setBackendId(const QString &id)
{
    if (m_client && m_client->backendId() == id.toLatin1())
        return;

    m_client->setBackendId(id.toLatin1());
    Q_EMIT backendIdChanged();
}

void Model::query(const QJSValue &query)
{
    if (!query.hasProperty("objectType"))
        return;

    if (load(query.property("objectType").toString())) {
        // TODO: check updates;
        return;
    }

    QJsonObject queryObject;
    queryObject["objectType"] = query.property("objectType").toString();

    if (query.hasProperty("query")) {
        queryObject["query"] = QJsonObject::fromVariantMap(query.property("query").toVariant().toMap());
    }

    if (query.hasProperty("sort")) {
        queryObject["sort"] = QJsonObject::fromVariantMap(query.property("sort").toVariant().toMap());
    }

    m_client->query(queryObject);
}

QVariant Model::data(int index, const QString &role) const
{
    return data(this->index(index, 0), m_roleNames.key(role.toLatin1()));
}

void Model::onFinished(EnginioReply *reply)
{
    //save(reply->data());
    parse(reply->data());
    reply->deleteLater();
}

bool Model::save(const QJsonObject &object)
{
    if (!object.keys().contains("results")) {
        qWarning()<< "Wrong json format";
        return false;
    }

    QString fileName = object.value("results").toArray().at(0).toVariant().toMap().value("objectType").toString();
    QString path = QStandardPaths::writableLocation(QStandardPaths::DataLocation);
    QDir dir(path);
    if (!dir.exists() && !dir.mkpath(path)) {
        qWarning("Could not create dir");
        return false;
    }

    QFile file(QString("%1/%2").arg(path).arg(fileName));
    if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        qWarning("On save couldn't open file.");
        return false;
    }

    QJsonDocument saveDoc(object);
    file.write(saveDoc.toJson());
    file.close();
    return true;
}

bool Model::load(const QString &objectType)
{
    QString path = QStandardPaths::writableLocation(QStandardPaths::DataLocation);
    QFile file(QString("%1/%2").arg(path).arg(objectType));
    if (!file.open(QIODevice::ReadOnly)) {
        qWarning("On load couldn't open file.");
        return false;
    }

    QByteArray data = file.readAll();
    QJsonDocument loadDoc(QJsonDocument::fromJson(data));
    parse(loadDoc.object());
    return true;
}

void Model::parse(const QJsonObject &object)
{
    beginResetModel();
    m_data.clear();
    m_roleNames.clear();
    endResetModel();

    QJsonArray array = object.value("results").toArray();
    QStringList keys = array.at(0).toVariant().toMap().keys();

    for (int index = 0; index < keys.count(); ++index) {
        m_roleNames.insert(Qt::UserRole + index, keys.at(index).toLatin1());
    }

    beginInsertRows(QModelIndex(), m_data.count(), m_data.count() + array.count() - 1);
    foreach (QJsonValue value, array) {
        m_data.append(value.toVariant().toMap());
    }
    endInsertRows();
    Q_EMIT dataReady();
}
