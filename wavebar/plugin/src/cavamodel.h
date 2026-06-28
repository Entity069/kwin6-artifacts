#pragma once

#include <QObject>
#include <QProcess>
#include <QTimer>
#include <QVariantList>
#include <QtQmlIntegration/qqmlintegration.h>

class CavaModel : public QObject {
  Q_OBJECT
  QML_ELEMENT

  Q_PROPERTY(QVariantList levels READ levels NOTIFY levelsChanged)
  Q_PROPERTY(int bars READ bars WRITE setBars NOTIFY barsChanged)
  Q_PROPERTY(qreal sensitivity READ sensitivity WRITE setSensitivity NOTIFY
                 sensitivityChanged)
  Q_PROPERTY(bool running READ running WRITE setRunning NOTIFY runningChanged)
  Q_PROPERTY(
      int framerate READ framerate WRITE setFramerate NOTIFY framerateChanged)
  Q_PROPERTY(
      int riseSpeed READ riseSpeed WRITE setriseSpeed NOTIFY riseSpeedChanged)
  Q_PROPERTY(int releaseSpeed READ releaseSpeed WRITE setReleaseSpeed NOTIFY
                 releaseSpeedChanged)
  Q_PROPERTY(qreal noiseReduction READ noiseReduction WRITE setNoiseReduction
                 NOTIFY noiseReductionChanged)
  Q_PROPERTY(
      int lowCutoff READ lowCutoff WRITE setLowCutoff NOTIFY lowCutoffChanged)
  Q_PROPERTY(int highCutoff READ highCutoff WRITE setHighCutoff NOTIFY
                 highCutoffChanged)

public:
  explicit CavaModel(QObject *parent = nullptr);
  ~CavaModel() override;

  QVariantList levels() const { return m_levels; }
  int bars() const { return m_bars; }
  qreal sensitivity() const { return m_sensitivity; }
  bool running() const { return m_running; }
  int framerate() const { return m_framerate; }
  int riseSpeed() const { return m_riseSpeed; }
  int releaseSpeed() const { return m_releaseSpeed; }
  qreal noiseReduction() const { return m_noiseReduction; }
  int lowCutoff() const { return m_lowCutoff; }
  int highCutoff() const { return m_highCutoff; }

  void setBars(int bars);
  void setSensitivity(qreal sensitivity);
  void setRunning(bool running);
  void setFramerate(int fps);
  void setriseSpeed(int speed);
  void setReleaseSpeed(int speed);
  void setNoiseReduction(qreal value);
  void setLowCutoff(int hz);
  void setHighCutoff(int hz);

  Q_INVOKABLE void start();
  Q_INVOKABLE void stop();

signals:
  void levelsChanged();
  void barsChanged();
  void sensitivityChanged();
  void runningChanged();
  void framerateChanged();
  void riseSpeedChanged();
  void releaseSpeedChanged();
  void noiseReductionChanged();
  void lowCutoffChanged();
  void highCutoffChanged();

private:
  void pollFrame();
  void writeConfig();
  void launchCava();
  void killCava();
  void resetLevels();

  int m_bars = 16;
  qreal m_sensitivity = 1.0;
  bool m_running = false;
  int m_framerate = 60;
  int m_riseSpeed = 80;
  int m_releaseSpeed = 12;
  qreal m_noiseReduction = 0.77;
  int m_lowCutoff = 50;
  int m_highCutoff = 10000;

  QVariantList m_levels;
  QList<float> m_smoothed;

  QProcess *m_process = nullptr;
  QTimer *m_timer = nullptr;

  QString m_confPath;
  QString m_rawPath;
};
