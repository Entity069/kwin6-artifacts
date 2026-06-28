#include "cavamodel.h"

#include <QDebug>
#include <QFile>
#include <QtEndian>

#include <algorithm>

static constexpr const char *kConfPath = "/tmp/wavebar_cava.conf";
static constexpr const char *kRawPath = "/tmp/wavebar_cava.raw";

CavaModel::CavaModel(QObject *parent) : QObject(parent) {
  m_confPath = QString::fromLatin1(kConfPath);
  m_rawPath = QString::fromLatin1(kRawPath);

  m_timer = new QTimer(this);
  m_timer->setInterval(1000 / m_framerate);
  connect(m_timer, &QTimer::timeout, this, &CavaModel::pollFrame);

  m_process = new QProcess(this);
  m_process->setProgram(QStringLiteral("cava"));
  connect(m_process, &QProcess::finished, this,
          [this](int, QProcess::ExitStatus) {
            if (m_running) {
              m_timer->stop();
            }
          });

  resetLevels();
}

CavaModel::~CavaModel() { stop(); }

void CavaModel::resetLevels() {
  m_levels.clear();
  m_smoothed.clear();
  m_levels.reserve(m_bars);
  m_smoothed.reserve(m_bars);
  for (int i = 0; i < m_bars; i++) {
    m_levels.append(0.0f);
    m_smoothed.append(0.0f);
  }
  emit levelsChanged();
}

void CavaModel::setBars(int bars) {
  bars = std::max(1, bars);
  if (bars == m_bars) {
    return;
  }
  m_bars = bars;
  resetLevels();
  emit barsChanged();
  if (m_running) {
    killCava();
    launchCava();
  }
}

void CavaModel::setSensitivity(qreal sensitivity) {
  if (qFuzzyCompare(m_sensitivity, sensitivity)) {
    return;
  }
  m_sensitivity = sensitivity;
  emit sensitivityChanged();
}

void CavaModel::setRunning(bool running) {
  if (running == m_running) {
    return;
  }
  if (running) {
    start();
  } else {
    stop();
  }
}

void CavaModel::setFramerate(int fps) {
  fps = std::clamp(fps, 1, 240);
  if (fps == m_framerate) {
    return;
  }
  m_framerate = fps;
  m_timer->setInterval(1000 / m_framerate);
  emit framerateChanged();
}

void CavaModel::setriseSpeed(int speed) {
  speed = std::clamp(speed, 1, 100);
  if (speed == m_riseSpeed) {
    return;
  }
  m_riseSpeed = speed;
  emit riseSpeedChanged();
}

void CavaModel::setReleaseSpeed(int speed) {
  speed = std::clamp(speed, 1, 100);
  if (speed == m_releaseSpeed) {
    return;
  }
  m_releaseSpeed = speed;
  emit releaseSpeedChanged();
}

void CavaModel::setNoiseReduction(qreal value) {
  value = std::clamp(value, 0.0, 1.0);
  if (qFuzzyCompare(m_noiseReduction, value)) {
    return;
  }
  m_noiseReduction = value;
  emit noiseReductionChanged();
  if (m_running) {
    killCava();
    launchCava();
  }
}

void CavaModel::setLowCutoff(int hz) {
  hz = std::clamp(hz, 20, 20000);
  if (hz == m_lowCutoff) {
    return;
  }
  m_lowCutoff = hz;
  emit lowCutoffChanged();
  if (m_running) {
    killCava();
    launchCava();
  }
}

void CavaModel::setHighCutoff(int hz) {
  hz = std::clamp(hz, 20, 20000);
  if (hz == m_highCutoff) {
    return;
  }
  m_highCutoff = hz;
  emit highCutoffChanged();
  if (m_running) {
    killCava();
    launchCava();
  }
}

void CavaModel::start() {
  if (m_running) {
    return;
  }
  m_running = true;
  emit runningChanged();
  launchCava();
}

void CavaModel::stop() {
  if (!m_running) {
    return;
  }
  killCava();
  m_running = false;
  emit runningChanged();
}

void CavaModel::launchCava() {
  writeConfig();

  QFile::remove(m_rawPath);
  QFile seed(m_rawPath);
  if (seed.open(QIODevice::WriteOnly)) {
    seed.close();
  }

  m_process->setArguments({QStringLiteral("-p"), m_confPath});
  m_process->start();
  m_timer->start();
}

void CavaModel::killCava() {
  m_timer->stop();
  if (m_process->state() != QProcess::NotRunning) {
    m_process->terminate();
    if (!m_process->waitForFinished(1000)) {
      m_process->kill();
    }
  }
  for (int i = 0; i < m_smoothed.size(); i++) {
    m_smoothed[i] = 0.0f;
    m_levels[i] = 0.0f;
  }
  emit levelsChanged();
}

void CavaModel::writeConfig() {
  const QString conf = QStringLiteral("[general]\n"
                                      "bars = %1\n"
                                      "framerate = %2\n"
                                      "lower_cutoff_freq = %4\n"
                                      "higher_cutoff_freq = %5\n"
                                      "[smoothing]\n"
                                      "noise_reduction = %3\n"
                                      "[output]\n"
                                      "method = raw\n"
                                      "channels = mono\n"
                                      "data_format = binary\n"
                                      "bit_format = 16bit\n"
                                      "raw_target = %6\n")
                           .arg(m_bars)
                           .arg(m_framerate)
                           .arg(m_noiseReduction, 0, 'f', 2)
                           .arg(m_lowCutoff)
                           .arg(m_highCutoff)
                           .arg(m_rawPath);

  QFile f(m_confPath);
  if (f.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
    f.write(conf.toUtf8());
  }
}

void CavaModel::pollFrame() {
  if (m_bars <= 0) {
    return;
  }

  QFile f(m_rawPath);
  if (!f.open(QIODevice::ReadOnly)) {
    return;
  }

  const qint64 frameSize = static_cast<qint64>(m_bars) * 2;
  const qint64 size = f.size();
  if (size < frameSize) {
    return;
  }

  const qint64 fullFrames = size / frameSize;
  const qint64 pos = (fullFrames - 1) * frameSize;
  if (!f.seek(pos)) {
    return;
  }

  const QByteArray data = f.read(frameSize);
  if (data.size() < frameSize) {
    return;
  }

  const float rise = static_cast<float>(m_riseSpeed) / 100.0f;
  const float release = static_cast<float>(m_releaseSpeed) / 100.0f;

  const auto *bytes = reinterpret_cast<const uchar *>(data.constData());
  for (int i = 0; i < m_bars; i++) {
    const quint16 raw = qFromLittleEndian<quint16>(bytes + i * 2);
    float v = static_cast<float>(raw) / 65535.0f;
    v *= static_cast<float>(m_sensitivity);
    v = std::clamp(v, 0.0f, 1.0f);

    float &s = m_smoothed[i];
    if (v > s) {
      s += (v - s) * rise;
    } else {
      s += (v - s) * release;
    }
    s = std::clamp(s, 0.0f, 1.0f);

    m_levels[i] = s;
  }
  emit levelsChanged();
}
