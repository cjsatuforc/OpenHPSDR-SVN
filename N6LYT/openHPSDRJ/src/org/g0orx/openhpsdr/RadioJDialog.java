/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package org.g0orx.openhpsdr;

import javax.swing.event.ChangeEvent;
import javax.swing.event.ChangeListener;
import javax.swing.JRadioButton;

import org.g0orx.openhpsdr.wdsp.WDSP;
import org.g0orx.openhpsdr.discovery.Discovered;

/**
 *
 * @author john
 */
public class RadioJDialog extends javax.swing.JDialog {

    /**
     * Creates new form RadioJDialog
     */
    public RadioJDialog(java.awt.Frame parent, boolean modal) {
        super(parent, modal);
        initComponents();
        configuration = Configuration.getInstance();
        wdsp = WDSP.getInstance();
        this.jCheckBoxNB2Enable.setSelected(configuration.NB2);
        this.jCheckBoxAEFilter.setSelected(configuration.NB2_AE);
        this.jRadioButtonLinear.setSelected(configuration.NB2_GAIN == 0);
        this.jRadioButtonLog.setSelected(configuration.NB2_GAIN == 1);
        this.jRadioButtonOSMS.setSelected(configuration.NB2_NPE == 0);
        this.jRadioButtonMMSE.setSelected(configuration.NB2_NPE == 1);
        this.jRadioButtonPreAGC.setSelected(configuration.NB2_POSITION == 0);
        this.jRadioButtonPostAGC.setSelected(configuration.NB2_POSITION == 1);
        this.jCheckBoxNR.setSelected(configuration.NR);
        this.jCheckBoxANF.setSelected(configuration.ANF);
            
        Band band = configuration.bands.get();
        JRadioButton rb;
        if (configuration.radio != Configuration.METIS_PENELOPE
                && configuration.radio != Configuration.METIS_PENNYLANE) {
            switch (band.get().getTxAntenna()) {
                case 0:
                    rb = (JRadioButton) this.jRadioButtonAnt1;
                    rb.setSelected(true);
                    break;
                case 1:
                    rb = (JRadioButton) this.jRadioButtonAnt2;
                    rb.setSelected(true);
                    break;
                case 2:
                    if (configuration.radio != Configuration.METIS_PENELOPE
                            && configuration.radio != Configuration.METIS_PENNYLANE) {
                        switch (band.get().getTxAntenna()) {
                            case 0:
                                rb = (JRadioButton) this.jRadioButtonAnt1;
                                rb.setSelected(true);
                                break;
                            case 1:
                                rb = (JRadioButton) this.jRadioButtonAnt2;
                                rb.setSelected(true);
                                break;
                            case 2:
                                rb = (JRadioButton) this.jRadioButtonAnt3;
                                rb.setSelected(true);
                                break;
                        }
                    } else {
                        jRadioButtonAnt1.setEnabled(false);
                        jRadioButtonAnt2.setEnabled(false);
                        jRadioButtonAnt3.setEnabled(false);
                    }
                    rb = (JRadioButton) this.jRadioButtonAnt3;
                    rb.setSelected(true);
                    break;
            }
        } else {
            jRadioButtonAnt1.setEnabled(false);
            jRadioButtonAnt2.setEnabled(false);
            jRadioButtonAnt3.setEnabled(false);
        }

        if (configuration.radio != Configuration.METIS_PENELOPE
                && configuration.radio != Configuration.METIS_PENNYLANE) {
            if (configuration.radio == Configuration.ANGELIA_ANAN100D || configuration.radio == Configuration.ORION_ANAN200D) {
                rb = (JRadioButton) this.jRadioButtonRX1;
                rb.setText("EXT 2");
                rb = (JRadioButton) this.jRadioButtonRX2;
                rb.setText("EXT 1");
            }

            switch (band.get().getRxAntenna()) {
                case 0:
                    rb = (JRadioButton) this.jRadioButtonNone;
                    rb.setSelected(true);
                    break;
                case 1:
                    rb = (JRadioButton) this.jRadioButtonRX1;
                    rb.setSelected(true);
                    break;
                case 2:
                    rb = (JRadioButton) this.jRadioButtonRX2;
                    rb.setSelected(true);
                    break;
                case 3:
                    rb = (JRadioButton) this.jRadioButtonRXXV;
                    rb.setSelected(true);
                    break;
            }

        } else {
            jRadioButtonNone.setEnabled(false);
            jRadioButtonRX1.setEnabled(false);
            jRadioButtonRX2.setEnabled(false);
            jRadioButtonRXXV.setEnabled(false);
        }

    }

    /**
     * This method is called from within the constructor to initialize the form.
     * WARNING: Do NOT modify this code. The content of this method is always
     * regenerated by the Form Editor.
     */
    @SuppressWarnings("unchecked")
    // <editor-fold defaultstate="collapsed" desc="Generated Code">//GEN-BEGIN:initComponents
    private void initComponents() {

        buttonGroupGain = new javax.swing.ButtonGroup();
        buttonGroupNPEMethod = new javax.swing.ButtonGroup();
        buttonGroupPosition = new javax.swing.ButtonGroup();
        buttonGroupTXAnt = new javax.swing.ButtonGroup();
        buttonGroupRXAnt = new javax.swing.ButtonGroup();
        jTabbedPane1 = new javax.swing.JTabbedPane();
        jPanel1 = new javax.swing.JPanel();
        jCheckBoxNB2Enable = new javax.swing.JCheckBox();
        jLabel1 = new javax.swing.JLabel();
        jRadioButtonLinear = new javax.swing.JRadioButton();
        jRadioButtonLog = new javax.swing.JRadioButton();
        jLabel2 = new javax.swing.JLabel();
        jRadioButtonOSMS = new javax.swing.JRadioButton();
        jRadioButtonMMSE = new javax.swing.JRadioButton();
        jLabel3 = new javax.swing.JLabel();
        jRadioButtonPreAGC = new javax.swing.JRadioButton();
        jRadioButtonPostAGC = new javax.swing.JRadioButton();
        jCheckBoxAEFilter = new javax.swing.JCheckBox();
        jCheckBoxNR = new javax.swing.JCheckBox();
        jCheckBoxANF = new javax.swing.JCheckBox();
        jPanel3 = new javax.swing.JPanel();
        jRadioButtonAnt1 = new javax.swing.JRadioButton();
        jRadioButtonAnt2 = new javax.swing.JRadioButton();
        jRadioButtonAnt3 = new javax.swing.JRadioButton();
        jRadioButtonNone = new javax.swing.JRadioButton();
        jRadioButtonRX1 = new javax.swing.JRadioButton();
        jRadioButtonRX2 = new javax.swing.JRadioButton();
        jRadioButtonRXXV = new javax.swing.JRadioButton();
        jLabel4 = new javax.swing.JLabel();
        jLabel5 = new javax.swing.JLabel();
        jButtonClose = new javax.swing.JButton();

        setDefaultCloseOperation(javax.swing.WindowConstants.DISPOSE_ON_CLOSE);

        jCheckBoxNB2Enable.setText("NB2");
        jCheckBoxNB2Enable.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                jCheckBoxNB2EnableActionPerformed(evt);
            }
        });

        jLabel1.setText("Gain Method:");

        buttonGroupGain.add(jRadioButtonLinear);
        jRadioButtonLinear.setText("Linear");
        jRadioButtonLinear.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                jRadioButtonLinearActionPerformed(evt);
            }
        });

        buttonGroupGain.add(jRadioButtonLog);
        jRadioButtonLog.setText("Log");
        jRadioButtonLog.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                jRadioButtonLogActionPerformed(evt);
            }
        });

        jLabel2.setText("NPE Method:");

        buttonGroupNPEMethod.add(jRadioButtonOSMS);
        jRadioButtonOSMS.setText("OSMS");
        jRadioButtonOSMS.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                jRadioButtonOSMSActionPerformed(evt);
            }
        });

        buttonGroupNPEMethod.add(jRadioButtonMMSE);
        jRadioButtonMMSE.setText("MMSE");
        jRadioButtonMMSE.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                jRadioButtonMMSEActionPerformed(evt);
            }
        });

        jLabel3.setText("Position:");

        buttonGroupPosition.add(jRadioButtonPreAGC);
        jRadioButtonPreAGC.setText("Pre AGC");
        jRadioButtonPreAGC.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                jRadioButtonPreAGCActionPerformed(evt);
            }
        });

        buttonGroupPosition.add(jRadioButtonPostAGC);
        jRadioButtonPostAGC.setText("Post AGC");
        jRadioButtonPostAGC.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                jRadioButtonPostAGCActionPerformed(evt);
            }
        });

        jCheckBoxAEFilter.setText("AE Filter");
        jCheckBoxAEFilter.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                jCheckBoxAEFilterActionPerformed(evt);
            }
        });

        jCheckBoxNR.setText("NR");
        jCheckBoxNR.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                jCheckBoxNRActionPerformed(evt);
            }
        });

        jCheckBoxANF.setText("ANF");
        jCheckBoxANF.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                jCheckBoxANFActionPerformed(evt);
            }
        });

        javax.swing.GroupLayout jPanel1Layout = new javax.swing.GroupLayout(jPanel1);
        jPanel1.setLayout(jPanel1Layout);
        jPanel1Layout.setHorizontalGroup(
            jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel1Layout.createSequentialGroup()
                .addContainerGap()
                .addGroup(jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(jPanel1Layout.createSequentialGroup()
                        .addComponent(jCheckBoxNB2Enable)
                        .addGap(19, 19, 19)
                        .addGroup(jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addGroup(jPanel1Layout.createSequentialGroup()
                                .addComponent(jLabel1)
                                .addGap(18, 18, 18)
                                .addGroup(jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                                    .addGroup(jPanel1Layout.createSequentialGroup()
                                        .addGap(12, 12, 12)
                                        .addComponent(jLabel2)
                                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, 52, Short.MAX_VALUE)
                                        .addGroup(jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                                            .addComponent(jRadioButtonPreAGC)
                                            .addComponent(jLabel3))
                                        .addGap(19, 19, 19))
                                    .addGroup(jPanel1Layout.createSequentialGroup()
                                        .addComponent(jCheckBoxAEFilter)
                                        .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))))
                            .addGroup(jPanel1Layout.createSequentialGroup()
                                .addGroup(jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                                    .addComponent(jRadioButtonLinear)
                                    .addComponent(jRadioButtonLog))
                                .addGap(53, 53, 53)
                                .addGroup(jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                                    .addGroup(jPanel1Layout.createSequentialGroup()
                                        .addComponent(jRadioButtonMMSE)
                                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                                        .addComponent(jRadioButtonPostAGC)
                                        .addContainerGap())
                                    .addGroup(jPanel1Layout.createSequentialGroup()
                                        .addComponent(jRadioButtonOSMS)
                                        .addGap(0, 0, Short.MAX_VALUE))))))
                    .addGroup(jPanel1Layout.createSequentialGroup()
                        .addGroup(jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addComponent(jCheckBoxNR)
                            .addComponent(jCheckBoxANF))
                        .addGap(0, 0, Short.MAX_VALUE))))
        );
        jPanel1Layout.setVerticalGroup(
            jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel1Layout.createSequentialGroup()
                .addGap(34, 34, 34)
                .addGroup(jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(jCheckBoxNB2Enable)
                    .addComponent(jCheckBoxAEFilter))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addGroup(jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addComponent(jLabel1, javax.swing.GroupLayout.PREFERRED_SIZE, 17, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addGroup(jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                        .addComponent(jLabel3)
                        .addComponent(jLabel2)))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addGroup(jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(jRadioButtonOSMS)
                    .addComponent(jRadioButtonPreAGC)
                    .addComponent(jRadioButtonLinear))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addGroup(jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(jRadioButtonMMSE)
                    .addComponent(jRadioButtonPostAGC)
                    .addComponent(jRadioButtonLog))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(jCheckBoxNR)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(jCheckBoxANF)
                .addContainerGap(54, Short.MAX_VALUE))
        );

        jTabbedPane1.addTab("DSP", jPanel1);

        buttonGroupTXAnt.add(jRadioButtonAnt1);
        jRadioButtonAnt1.setText("Ant 1");
        jRadioButtonAnt1.addChangeListener(new javax.swing.event.ChangeListener() {
            public void stateChanged(javax.swing.event.ChangeEvent evt) {
                jRadioButtonAnt1StateChanged(evt);
            }
        });
        jRadioButtonAnt1.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                jRadioButtonAnt1ActionPerformed(evt);
            }
        });

        buttonGroupTXAnt.add(jRadioButtonAnt2);
        jRadioButtonAnt2.setText("Ant 2");
        jRadioButtonAnt2.addChangeListener(new javax.swing.event.ChangeListener() {
            public void stateChanged(javax.swing.event.ChangeEvent evt) {
                jRadioButtonAnt2StateChanged(evt);
            }
        });
        jRadioButtonAnt2.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                jRadioButtonAnt2ActionPerformed(evt);
            }
        });

        buttonGroupTXAnt.add(jRadioButtonAnt3);
        jRadioButtonAnt3.setText("Ant 3");
        jRadioButtonAnt3.addChangeListener(new javax.swing.event.ChangeListener() {
            public void stateChanged(javax.swing.event.ChangeEvent evt) {
                jRadioButtonAnt3StateChanged(evt);
            }
        });
        jRadioButtonAnt3.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                jRadioButtonAnt3ActionPerformed(evt);
            }
        });

        buttonGroupRXAnt.add(jRadioButtonNone);
        jRadioButtonNone.setText("None (Use Tx)");
        jRadioButtonNone.addChangeListener(new javax.swing.event.ChangeListener() {
            public void stateChanged(javax.swing.event.ChangeEvent evt) {
                jRadioButtonNoneStateChanged(evt);
            }
        });
        jRadioButtonNone.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                jRadioButtonNoneActionPerformed(evt);
            }
        });

        buttonGroupRXAnt.add(jRadioButtonRX1);
        jRadioButtonRX1.setText("RX 1");
        jRadioButtonRX1.addChangeListener(new javax.swing.event.ChangeListener() {
            public void stateChanged(javax.swing.event.ChangeEvent evt) {
                jRadioButtonRX1StateChanged(evt);
            }
        });
        jRadioButtonRX1.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                jRadioButtonRX1ActionPerformed(evt);
            }
        });

        buttonGroupRXAnt.add(jRadioButtonRX2);
        jRadioButtonRX2.setText("RX 2");
        jRadioButtonRX2.addChangeListener(new javax.swing.event.ChangeListener() {
            public void stateChanged(javax.swing.event.ChangeEvent evt) {
                jRadioButtonRX2StateChanged(evt);
            }
        });
        jRadioButtonRX2.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                jRadioButtonRX2ActionPerformed(evt);
            }
        });

        buttonGroupRXAnt.add(jRadioButtonRXXV);
        jRadioButtonRXXV.setText("RX  XV");
        jRadioButtonRXXV.addChangeListener(new javax.swing.event.ChangeListener() {
            public void stateChanged(javax.swing.event.ChangeEvent evt) {
                jRadioButtonRXXVStateChanged(evt);
            }
        });
        jRadioButtonRXXV.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                jRadioButtonRXXVActionPerformed(evt);
            }
        });

        jLabel4.setText("RX Ant:");

        jLabel5.setText("TX Ant:");

        javax.swing.GroupLayout jPanel3Layout = new javax.swing.GroupLayout(jPanel3);
        jPanel3.setLayout(jPanel3Layout);
        jPanel3Layout.setHorizontalGroup(
            jPanel3Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel3Layout.createSequentialGroup()
                .addGap(29, 29, 29)
                .addGroup(jPanel3Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.TRAILING, false)
                    .addGroup(jPanel3Layout.createSequentialGroup()
                        .addGroup(jPanel3Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addComponent(jRadioButtonAnt2)
                            .addComponent(jRadioButtonAnt3))
                        .addGap(101, 101, 101)
                        .addGroup(jPanel3Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addComponent(jRadioButtonRX2)
                            .addComponent(jRadioButtonRX1)
                            .addComponent(jRadioButtonRXXV))
                        .addGap(0, 0, Short.MAX_VALUE))
                    .addGroup(jPanel3Layout.createSequentialGroup()
                        .addGroup(jPanel3Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.TRAILING, false)
                            .addGroup(jPanel3Layout.createSequentialGroup()
                                .addComponent(jLabel5)
                                .addGap(114, 114, 114))
                            .addGroup(javax.swing.GroupLayout.Alignment.LEADING, jPanel3Layout.createSequentialGroup()
                                .addComponent(jRadioButtonAnt1)
                                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)))
                        .addGroup(jPanel3Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addComponent(jLabel4)
                            .addComponent(jRadioButtonNone))))
                .addContainerGap(138, Short.MAX_VALUE))
        );
        jPanel3Layout.setVerticalGroup(
            jPanel3Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel3Layout.createSequentialGroup()
                .addGap(26, 26, 26)
                .addGroup(jPanel3Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(jLabel4)
                    .addComponent(jLabel5))
                .addGap(18, 18, 18)
                .addGroup(jPanel3Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(jRadioButtonAnt1)
                    .addComponent(jRadioButtonNone))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addGroup(jPanel3Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(jRadioButtonAnt2)
                    .addComponent(jRadioButtonRX1))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addGroup(jPanel3Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(jRadioButtonAnt3)
                    .addComponent(jRadioButtonRX2))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(jRadioButtonRXXV)
                .addContainerGap(62, Short.MAX_VALUE))
        );

        jTabbedPane1.addTab("Antenna", jPanel3);

        jButtonClose.setText("Close");
        jButtonClose.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                jButtonCloseActionPerformed(evt);
            }
        });

        javax.swing.GroupLayout layout = new javax.swing.GroupLayout(getContentPane());
        getContentPane().setLayout(layout);
        layout.setHorizontalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addComponent(jTabbedPane1)
            .addGroup(layout.createSequentialGroup()
                .addGap(174, 174, 174)
                .addComponent(jButtonClose)
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );
        layout.setVerticalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(layout.createSequentialGroup()
                .addComponent(jTabbedPane1, javax.swing.GroupLayout.PREFERRED_SIZE, 292, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(18, 18, 18)
                .addComponent(jButtonClose)
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );

        pack();
    }// </editor-fold>//GEN-END:initComponents

    private void jButtonCloseActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jButtonCloseActionPerformed
        this.dispose();
    }//GEN-LAST:event_jButtonCloseActionPerformed

    private void jRadioButtonOSMSActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jRadioButtonOSMSActionPerformed
        configuration.NB2_NPE = 0;
        wdsp.SetRXAEMNRnpeMethod(Channel.RX, 0);
    }//GEN-LAST:event_jRadioButtonOSMSActionPerformed

    private void jCheckBoxNB2EnableActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jCheckBoxNB2EnableActionPerformed
        configuration.NB2 = this.jCheckBoxNB2Enable.isSelected();
        wdsp.SetRXAEMNRRun(Channel.RX, configuration.NB2 ? 1 : 0);
    }//GEN-LAST:event_jCheckBoxNB2EnableActionPerformed

    private void jCheckBoxAEFilterActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jCheckBoxAEFilterActionPerformed
        configuration.NB2_AE = this.jCheckBoxAEFilter.isSelected();
        wdsp.SetRXAEMNRaeRun(Channel.RX, configuration.NB2_AE ? 1 : 0);
    }//GEN-LAST:event_jCheckBoxAEFilterActionPerformed

    private void jRadioButtonLinearActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jRadioButtonLinearActionPerformed
        configuration.NB2_GAIN = 0;
        wdsp.SetRXAEMNRgainMethod(Channel.RX, 0);
    }//GEN-LAST:event_jRadioButtonLinearActionPerformed

    private void jRadioButtonLogActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jRadioButtonLogActionPerformed
        configuration.NB2_GAIN = 1;
        wdsp.SetRXAEMNRgainMethod(Channel.RX, 1);
    }//GEN-LAST:event_jRadioButtonLogActionPerformed

    private void jRadioButtonMMSEActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jRadioButtonMMSEActionPerformed
        configuration.NB2_NPE = 1;
        wdsp.SetRXAEMNRnpeMethod(Channel.RX, 1);
    }//GEN-LAST:event_jRadioButtonMMSEActionPerformed

    private void jRadioButtonPreAGCActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jRadioButtonPreAGCActionPerformed
        configuration.NB2_POSITION = 0;
        wdsp.SetRXAEMNRPosition(Channel.RX, 0);
    }//GEN-LAST:event_jRadioButtonPreAGCActionPerformed

    private void jRadioButtonPostAGCActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jRadioButtonPostAGCActionPerformed
        configuration.NB2_POSITION = 1;
        wdsp.SetRXAEMNRPosition(Channel.RX, 1);
    }//GEN-LAST:event_jRadioButtonPostAGCActionPerformed

    private void jCheckBoxNRActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jCheckBoxNRActionPerformed
        configuration.NR = this.jCheckBoxNR.isSelected();
        wdsp.SetRXAANRRun(Channel.RX, configuration.NR ? 1 : 0);
    }//GEN-LAST:event_jCheckBoxNRActionPerformed

    private void jCheckBoxANFActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jCheckBoxANFActionPerformed
        configuration.ANF = this.jCheckBoxANF.isSelected();
        wdsp.SetRXAANFRun(Channel.RX, configuration.ANF ? 1 : 0);
    }//GEN-LAST:event_jCheckBoxANFActionPerformed

    private void jRadioButtonAnt2ActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jRadioButtonAnt2ActionPerformed
        configuration.bands.get().get().setTxAntenna(1);
    }//GEN-LAST:event_jRadioButtonAnt2ActionPerformed

    private void jRadioButtonAnt1StateChanged(javax.swing.event.ChangeEvent evt) {//GEN-FIRST:event_jRadioButtonAnt1StateChanged
        // TODO add your handling code here:
    }//GEN-LAST:event_jRadioButtonAnt1StateChanged

    private void jRadioButtonAnt2StateChanged(javax.swing.event.ChangeEvent evt) {//GEN-FIRST:event_jRadioButtonAnt2StateChanged
        // TODO add your handling code here:
    }//GEN-LAST:event_jRadioButtonAnt2StateChanged

    private void jRadioButtonAnt3StateChanged(javax.swing.event.ChangeEvent evt) {//GEN-FIRST:event_jRadioButtonAnt3StateChanged
        // TODO add your handling code here:
    }//GEN-LAST:event_jRadioButtonAnt3StateChanged

    private void jRadioButtonNoneStateChanged(javax.swing.event.ChangeEvent evt) {//GEN-FIRST:event_jRadioButtonNoneStateChanged
        // TODO add your handling code here:
    }//GEN-LAST:event_jRadioButtonNoneStateChanged

    private void jRadioButtonRX1StateChanged(javax.swing.event.ChangeEvent evt) {//GEN-FIRST:event_jRadioButtonRX1StateChanged
        // TODO add your handling code here:
    }//GEN-LAST:event_jRadioButtonRX1StateChanged

    private void jRadioButtonRX2StateChanged(javax.swing.event.ChangeEvent evt) {//GEN-FIRST:event_jRadioButtonRX2StateChanged
        // TODO add your handling code here:
    }//GEN-LAST:event_jRadioButtonRX2StateChanged

    private void jRadioButtonRXXVStateChanged(javax.swing.event.ChangeEvent evt) {//GEN-FIRST:event_jRadioButtonRXXVStateChanged
        // TODO add your handling code here:
    }//GEN-LAST:event_jRadioButtonRXXVStateChanged

    private void jRadioButtonAnt1ActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jRadioButtonAnt1ActionPerformed
        configuration.bands.get().get().setTxAntenna(0);
    }//GEN-LAST:event_jRadioButtonAnt1ActionPerformed

    private void jRadioButtonAnt3ActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jRadioButtonAnt3ActionPerformed
        configuration.bands.get().get().setTxAntenna(1);
    }//GEN-LAST:event_jRadioButtonAnt3ActionPerformed

    private void jRadioButtonNoneActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jRadioButtonNoneActionPerformed
        // TODO add your handling code here:
    }//GEN-LAST:event_jRadioButtonNoneActionPerformed

    private void jRadioButtonRX1ActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jRadioButtonRX1ActionPerformed
        // TODO add your handling code here:
    }//GEN-LAST:event_jRadioButtonRX1ActionPerformed

    private void jRadioButtonRX2ActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jRadioButtonRX2ActionPerformed
        // TODO add your handling code here:
    }//GEN-LAST:event_jRadioButtonRX2ActionPerformed

    private void jRadioButtonRXXVActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jRadioButtonRXXVActionPerformed
        // TODO add your handling code here:
    }//GEN-LAST:event_jRadioButtonRXXVActionPerformed

    private Configuration configuration;
    private WDSP wdsp;

    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.ButtonGroup buttonGroupGain;
    private javax.swing.ButtonGroup buttonGroupNPEMethod;
    private javax.swing.ButtonGroup buttonGroupPosition;
    private javax.swing.ButtonGroup buttonGroupRXAnt;
    private javax.swing.ButtonGroup buttonGroupTXAnt;
    private javax.swing.JButton jButtonClose;
    private javax.swing.JCheckBox jCheckBoxAEFilter;
    private javax.swing.JCheckBox jCheckBoxANF;
    private javax.swing.JCheckBox jCheckBoxNB2Enable;
    private javax.swing.JCheckBox jCheckBoxNR;
    private javax.swing.JLabel jLabel1;
    private javax.swing.JLabel jLabel2;
    private javax.swing.JLabel jLabel3;
    private javax.swing.JLabel jLabel4;
    private javax.swing.JLabel jLabel5;
    private javax.swing.JPanel jPanel1;
    private javax.swing.JPanel jPanel3;
    private javax.swing.JRadioButton jRadioButtonAnt1;
    private javax.swing.JRadioButton jRadioButtonAnt2;
    private javax.swing.JRadioButton jRadioButtonAnt3;
    private javax.swing.JRadioButton jRadioButtonLinear;
    private javax.swing.JRadioButton jRadioButtonLog;
    private javax.swing.JRadioButton jRadioButtonMMSE;
    private javax.swing.JRadioButton jRadioButtonNone;
    private javax.swing.JRadioButton jRadioButtonOSMS;
    private javax.swing.JRadioButton jRadioButtonPostAGC;
    private javax.swing.JRadioButton jRadioButtonPreAGC;
    private javax.swing.JRadioButton jRadioButtonRX1;
    private javax.swing.JRadioButton jRadioButtonRX2;
    private javax.swing.JRadioButton jRadioButtonRXXV;
    private javax.swing.JTabbedPane jTabbedPane1;
    // End of variables declaration//GEN-END:variables
}
