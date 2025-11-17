// ScreenReaderConverter.h : Hauptheaderdatei für die PROJECT_NAME-Anwendung
//

#pragma once

#ifndef __AFXWIN_H__
	#error "\"stdafx.h\" vor dieser Datei für PCH einschließen"
#endif

#include "resource.h"		// Hauptsymbole


// CScreenReaderConverterApp:
// Siehe ScreenReaderConverter.cpp für die Implementierung dieser Klasse
//

class CScreenReaderConverterApp : public CWinApp
{
public:
	CScreenReaderConverterApp();

// Überschreibungen
	public:
	virtual BOOL InitInstance();

// Implementierung

	DECLARE_MESSAGE_MAP()
};

extern CScreenReaderConverterApp theApp;