#ifndef APICLIENT_H
#define APICLIENT_H

#include <QObject>

#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QHttpMultiPart>

#include <QJsonDocument>


class ApiClient : public QObject
{
    Q_OBJECT
public:
    enum class RequestType {
        Login,
        Projects,
        ProjectInfo,
        UpdateProject
    };

    Q_ENUMS(RequestType)

    explicit ApiClient(QObject *parent = nullptr);

    Q_INVOKABLE void login(const QString &login, const QString &password);
    Q_INVOKABLE void getProjects();
    Q_INVOKABLE void getProjectInfo(int projectId);
    Q_INVOKABLE void updateProjectName(int projectId, const QString &name);

    void setBaseUrl(const QString &baseUrl);

signals:
    void authSuccess();
    void authFailed(const QString &error);

    void projectsReceived(const QJsonObject &projects);
    void projectInfoReceived(int projectId, const QJsonObject &projectInfo);
    void projectUpdated();
    void projectUpdateFailed();

private slots:
    void onNetworkReplyFinished();
    void onNetworkReplyError(QNetworkReply::NetworkError error);

private:
    QNetworkRequest createRequest(const QString &path, const QString &params = QString());
    QNetworkReply *sendRequest(QNetworkAccessManager::Operation operation, const QNetworkRequest &request, const QByteArray &data = QByteArray());
    QNetworkReply *sendRequest(const QNetworkRequest &request, QHttpMultiPart *multipart);

private:
    QString m_baseUrl;
    QString m_accessToken;
    QNetworkAccessManager m_accessManager;
    QHash<QNetworkReply *, RequestType> m_replyHash;
};

#endif // APICLIENT_H
