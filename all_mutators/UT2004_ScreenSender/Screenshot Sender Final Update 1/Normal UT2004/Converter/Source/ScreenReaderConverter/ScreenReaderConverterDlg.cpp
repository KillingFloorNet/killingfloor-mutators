// ScreenReaderConverterDlg.cpp : Implementierungsdatei
//

#include "stdafx.h"
#include "ScreenReaderConverter.h"
#include "ScreenReaderConverterDlg.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif


// CAboutDlg-Dialogfeld für Anwendungsbefehl "Info"

class CAboutDlg : public CDialog
{
public:
	CAboutDlg();

// Dialogfelddaten
	enum { IDD = IDD_ABOUTBOX };

	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV-Unterstützung

// Implementierung
protected:
	DECLARE_MESSAGE_MAP()
};

CAboutDlg::CAboutDlg() : CDialog(CAboutDlg::IDD)
{
}

void CAboutDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
}

BEGIN_MESSAGE_MAP(CAboutDlg, CDialog)
END_MESSAGE_MAP()


// CScreenReaderConverterDlg-Dialogfeld




CScreenReaderConverterDlg::CScreenReaderConverterDlg(CWnd* pParent /*=NULL*/)
	: CDialog(CScreenReaderConverterDlg::IDD, pParent)
  , m_strTextOut(_T(""))
{
	//m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
	AfxInitRichEdit2();
}

void CScreenReaderConverterDlg::DoDataExchange(CDataExchange* pDX)
{
  CDialog::DoDataExchange(pDX);
  DDX_Text(pDX, IDC_TEXTOUT, m_strTextOut);
  DDX_Control(pDX, IDC_PROGRESS, m_ProgressCtrl);
}

BEGIN_MESSAGE_MAP(CScreenReaderConverterDlg, CDialog)
	ON_WM_SYSCOMMAND()
	ON_WM_PAINT()
	ON_WM_QUERYDRAGICON()
	//}}AFX_MSG_MAP
  ON_WM_DROPFILES()
END_MESSAGE_MAP()


// CScreenReaderConverterDlg-Meldungshandler

BOOL CScreenReaderConverterDlg::OnInitDialog()
{
	CDialog::OnInitDialog();

	// Hinzufügen des Menübefehls "Info..." zum Systemmenü.

	// IDM_ABOUTBOX muss sich im Bereich der Systembefehle befinden.
	ASSERT((IDM_ABOUTBOX & 0xFFF0) == IDM_ABOUTBOX);
	ASSERT(IDM_ABOUTBOX < 0xF000);

	CMenu* pSysMenu = GetSystemMenu(FALSE);
	if (pSysMenu != NULL)
	{
		CString strAboutMenu;
		strAboutMenu.LoadString(IDS_ABOUTBOX);
		if (!strAboutMenu.IsEmpty())
		{
			pSysMenu->AppendMenu(MF_SEPARATOR);
			pSysMenu->AppendMenu(MF_STRING, IDM_ABOUTBOX, strAboutMenu);
		}
	}

	// Symbol für dieses Dialogfeld festlegen. Wird automatisch erledigt
	//  wenn das Hauptfenster der Anwendung kein Dialogfeld ist
	SetIcon(m_hIcon, TRUE);			// Großes Symbol verwenden
	SetIcon(m_hIcon, FALSE);		// Kleines Symbol verwenden

	// TODO: Hier zusätzliche Initialisierung einfügen
	DragAcceptFiles();
  m_strTextOut = "Drag & Drop some files onto the window to convert them! \
                  \nThe converted files are saved in the same folder as the \
input files and\nthey have the same name.\n\nCoded by Gugi";
  
  UpdateData(FALSE);
  	
	return TRUE;  // Geben Sie TRUE zurück, außer ein Steuerelement soll den Fokus erhalten
}

void CScreenReaderConverterDlg::OnSysCommand(UINT nID, LPARAM lParam)
{
	if ((nID & 0xFFF0) == IDM_ABOUTBOX)
	{
		CAboutDlg dlgAbout;
		dlgAbout.DoModal();
	}
	else
	{
		CDialog::OnSysCommand(nID, lParam);
	}
}

// Wenn Sie dem Dialogfeld eine Schaltfläche "Minimieren" hinzufügen, benötigen Sie 
//  den nachstehenden Code, um das Symbol zu zeichnen. Für MFC-Anwendungen, die das 
//  Dokument/Ansicht-Modell verwenden, wird dies automatisch ausgeführt.

void CScreenReaderConverterDlg::OnPaint()
{
	if (IsIconic())
	{
		CPaintDC dc(this); // Gerätekontext zum Zeichnen

		SendMessage(WM_ICONERASEBKGND, reinterpret_cast<WPARAM>(dc.GetSafeHdc()), 0);

		// Symbol in Clientrechteck zentrieren
		int cxIcon = GetSystemMetrics(SM_CXICON);
		int cyIcon = GetSystemMetrics(SM_CYICON);
		CRect rect;
		GetClientRect(&rect);
		int x = (rect.Width() - cxIcon + 1) / 2;
		int y = (rect.Height() - cyIcon + 1) / 2;

		// Symbol zeichnen
		dc.DrawIcon(x, y, m_hIcon);
	}
	else
	{
		CDialog::OnPaint();
	}
}

// Die System ruft diese Funktion auf, um den Cursor abzufragen, der angezeigt wird, während der Benutzer
//  das minimierte Fenster mit der Maus zieht.
HCURSOR CScreenReaderConverterDlg::OnQueryDragIcon()
{
	return static_cast<HCURSOR>(m_hIcon);
}


void CScreenReaderConverterDlg::OnDropFiles(HDROP hDropInfo)
{
  m_strTextOut = "";
  
  int NumFiles = ::DragQueryFile(hDropInfo, 0xFFFFFFFF, NULL, 0);
  
  m_ProgressCtrl.SetRange32(0, NumFiles);
  m_ProgressCtrl.SetPos(0);
  m_strTextOut.Format("%d files to convert...\n\n", NumFiles);
  UpdateData(FALSE);

  CConverter Converter;
  int SuccessfulConversions = 0;
  int i = 0;
  for(i=0; i<NumFiles; ++i)
  {
    CString TempStr;
    LPTSTR pFilename = TempStr.GetBufferSetLength(MAX_PATH);
    ::DragQueryFile(hDropInfo, i, pFilename, MAX_PATH);
    TempStr.ReleaseBuffer();
    
    if (TempStr.Right(5) == ".html")
    {
      m_strTextOut += "Converting: " + TempStr + "\n";
      UpdateData(FALSE);
      
      CString ConsoleOutput;
      
      if (Converter.Convert(TempStr, ConsoleOutput))
        ++SuccessfulConversions;
      
      m_strTextOut += ConsoleOutput + "\n\n";
      UpdateData(FALSE);
    }
    else
    {
      m_strTextOut += "No html-file: " + TempStr + "\n\n";
      UpdateData(FALSE);
    }
    m_ProgressCtrl.SetPos(i+1);
  }
  ::DragFinish(hDropInfo);
  
  CString Temp;
  Temp.Format("\n--- Converted %d of %d files! ---", SuccessfulConversions, i);
  m_strTextOut += Temp;
  UpdateData(FALSE);
  ((CRichEditCtrl*)GetDlgItem(IDC_TEXTOUT))->LineScroll(
                      ((CRichEditCtrl*)GetDlgItem(IDC_TEXTOUT))->GetLineCount()-5);
  
  CDialog::OnDropFiles(hDropInfo);
}
