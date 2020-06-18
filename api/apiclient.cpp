#include "apiclient.h"

#include <QJsonObject>

ApiClient::ApiClient(QObject *parent) : QObject(parent)
{
    connect(&m_accessManager, &QNetworkAccessManager::sslErrors, [=](QNetworkReply *reply, const QList<QSslError> &errors){
        Q_UNUSED(errors)
        reply->ignoreSslErrors();
    });
}

void ApiClient::login(const QString &login, const QString &password)
{
    auto request = createRequest("auth/login");

    QJsonObject data
        {
            {"email", login},
            {"password", password}
        };

    m_replyHash.insert(sendRequest(QNetworkAccessManager::PostOperation, request, QJsonDocument(data).toJson(QJsonDocument::Compact)),
                       RequestType::Login);

}

void ApiClient::getProjects()
{
    auto request = createRequest("projects-manage/index");

    m_replyHash.insert(sendRequest(QNetworkAccessManager::GetOperation, request),
                       RequestType::Projects);
}

void ApiClient::getProjectInfo(int projectId)
{
    auto request = createRequest(QString("projects-manage/%1").arg(projectId));

    m_replyHash.insert(sendRequest(QNetworkAccessManager::GetOperation, request),
                       RequestType::ProjectInfo);
}

void ApiClient::updateProjectName(int projectId, const QString &name)
{
    auto request = createRequest("projects-manage/update", QString("id=%1").arg(projectId));

    QHttpMultiPart *multipart = new QHttpMultiPart(QHttpMultiPart::FormDataType);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "multipart/form-data; boundary=" + multipart->boundary());

    QHttpPart namePart;
    namePart.setHeader(QNetworkRequest::ContentDispositionHeader, "form-data; name=\"name\"");
    namePart.setBody(name.toLatin1());
    multipart->append(namePart);

    m_replyHash.insert(sendRequest(request, multipart),
                       RequestType::UpdateProject);
}

void ApiClient::setBaseUrl(const QString &baseUrl)
{
    m_baseUrl = baseUrl;
}

void ApiClient::onNetworkReplyFinished()
{
    auto reply = qobject_cast<QNetworkReply *>(sender());
    Q_ASSERT(reply);

    RequestType type = m_replyHash.take(reply);

    const QJsonObject &response = QJsonDocument::fromJson(reply->readAll()).object();

    qDebug() << response;

    switch (type) {
    case RequestType::Login: {
        if (reply->error() == QNetworkReply::NoError) {
            m_accessToken = response.value("token").toString();
            emit authSuccess();
        } else {
            auto firstKey = response.value("first_errors").toObject().keys().at(0);
            QString errorStr = firstKey + ": " + response.value("first_errors").toObject().value(firstKey).toString();
            emit authFailed(errorStr);
        }
        break;
    }
    case RequestType::Projects: {
        emit projectsReceived(response);
        break;
    }
    case RequestType::ProjectInfo: {
        int projectId = response.value("project").toObject().value("id").toInt();
        emit projectInfoReceived(projectId, response);
        break;
    }
    case RequestType::UpdateProject: {
        if (reply->error() == QNetworkReply::NoError) {
            emit projectUpdated();
        } else {
            emit projectUpdateFailed();
        }

        break;
    }
    }

    reply->deleteLater();
}

// Должна быть нормальная обработка ошибок, но в рамках тестового задания ее нет.
void ApiClient::onNetworkReplyError(QNetworkReply::NetworkError error)
{
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    qDebug() << "Request " << reply->request().url() << " failed with error: " << error;
    qDebug() << "Http code: " << reply->attribute(QNetworkRequest::HttpStatusCodeAttribute);
}

QNetworkRequest ApiClient::createRequest(const QString &path, const QString &params)
{
    QNetworkRequest request(QUrl(QString("%1/%2?%3").arg(m_baseUrl).arg(path).arg(params)));

    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    if (!m_accessToken.isEmpty()) {
        request.setRawHeader("Authorization", QString("Bearer %1").arg(m_accessToken).toLatin1());
    }

    return request;
}

QNetworkReply *ApiClient::sendRequest(QNetworkAccessManager::Operation operation, const QNetworkRequest &request, const QByteArray &data)
{
    QNetworkReply *reply = nullptr;
    switch (operation) {
    case QNetworkAccessManager::PostOperation: {
        reply = m_accessManager.post(request, data);
        break;
    }
    case QNetworkAccessManager::GetOperation: {
        reply = m_accessManager.get(request);
        break;
    }
    default: {
        Q_ASSERT_X(reply, "ApiClient", "Not supported operation");
        return nullptr;
    }
    }

    connect(reply, SIGNAL(error(QNetworkReply::NetworkError)), this, SLOT(onNetworkReplyError(QNetworkReply::NetworkError)));
    connect(reply, &QNetworkReply::finished, this, &ApiClient::onNetworkReplyFinished);

    return reply;
}

QNetworkReply *ApiClient::sendRequest(const QNetworkRequest &request, QHttpMultiPart *multipart)
{
    auto reply = m_accessManager.post(request, multipart);

    connect(reply, SIGNAL(error(QNetworkReply::NetworkError)), this, SLOT(onNetworkReplyError(QNetworkReply::NetworkError)));
    connect(reply, &QNetworkReply::finished, this, &ApiClient::onNetworkReplyFinished);

    multipart->setParent(reply);
    return reply;
}
