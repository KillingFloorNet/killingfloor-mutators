// ScreenReaderConverterDlg.h : Headerdatei
//

#pragma once

#include "Converter.h"
#include "afxcmn.h"

// CScreenReaderConverterDlg-Dialogfeld
class CScreenReaderConverterDlg : public CDialog
{
// Konstruktion
public:
	CScreenReaderConverterDlg(CWnd* pParent = NULL);	// Standardkonstruktor

// Dialogfelddaten
	enum { IDD = IDD_SCREENREADERCONVERTER_DIALOG };

	protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV-Unterstützung


// Implementierung
protected:
	HICON m_hIcon;

	// Generierte Funktionen für die Meldungstabellen
	virtual BOOL OnInitDialog();
	afx_msg void OnSysCommand(UINT nID, LPARAM lParam);
	afx_msg void OnPaint();
	afx_msg HCURSOR OnQueryDragIcon();
	DECLARE_MESSAGE_MAP()
public:
  afx_msg void OnDropFiles(HDROP hDropInfo);
  CString m_strTextOut;
  CProgressCtrl m_ProgressCtrl;
};
