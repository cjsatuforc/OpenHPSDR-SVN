/*
 * File:   Spectrum.h
 * Author: john
 *
 * Created on 16 August 2010, 10:03
 */

#ifndef SPECTRUM_H
#define	SPECTRUM_H

#include <QtCore>

#include <QFrame>
#include <QPainter>
#include <QMouseEvent>

class Spectrum: public QFrame {
    Q_OBJECT
public:
    Spectrum();
    Spectrum(QWidget*& widget);
    virtual ~Spectrum();
    void setObjectName(QString name);
    void setGeometry(QRect rect);
    void initialize();
    void setFrequency(long long f);
    void setSubRxFrequency(long long f);
    void setFilter(int low,int high);
    void updateSpectrum(char* header,char* buffer);
    int samplerate();

    int getHigh();
    int getLow();
    void setHigh(int high);
    void setLow(int low);

    void setSubRxState(bool state);

signals:
    void frequencyMoved(int step);

protected:
    void paintEvent(QPaintEvent*);

    void mousePressEvent(QMouseEvent* event);
    void mouseMoveEvent(QMouseEvent* event);
    void mouseReleaseEvent(QMouseEvent* event);

    void wheelEvent(QWheelEvent *event);

private:
    float* samples;
    int spectrumHigh;
    int spectrumLow;

    int startX;
    int lastX;
    int moved;

    int sampleRate;

    int filterLow;
    int filterHigh;
    long long frequency;
    long long subRxFrequency;
    bool subRx;

    QVector <QPoint> plot;
};


#endif	/* SPECTRUM_H */

