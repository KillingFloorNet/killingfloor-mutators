#pragma once

#include <fstream>  // file reading and writing
//#include <iostream> // screen-output
#include <cstdlib>  // atoi()
#include <cstring>  // strncpy() and strlen()
#include <list>     // for the bytes (mainly used for RLE-Compression)

using namespace std;

enum ECompressionType
{
  NoCompression = 0x00,
  ChromaSubsampling,
  ToGreyscale8,
  ToGreyscale4,
  ToGreyscale2
};

//typedef unsigned long int ULONG;

const short int NumEndBytes = 13; // The UScript part appended 13 bytes to the end
const short int NumBeginBytes = 9;

class CConverter
{
  public:
    CConverter(void);
    ~CConverter(void);
    
    bool Convert(CString File, CString& ConsoleOutput);

  
  private:
    unsigned long int GetFinalSize(ifstream& HTMLFile); // Returns the size of all bytes (already converted)
    void GetBitmapInfos(ifstream& HTMLFile,        // Reads the appended informations from the HTML-File
                        ULONG* Width, ULONG* Height, ECompressionType* CompressionType, 
                        bool* RLECompression);
    inline ULONG GetNum0Bytes(ULONG Width);  // Calculates how many 0-bytes are appended per row
    ULONG CopyBitmapHeader(ofstream& BMPFile, ULONG width, ULONG height); // Writes the bitmap header
    void WriteNormal_Grey(const list<unsigned char>& Bytes, ofstream& BMPFile, bool bGreyscale,
                          ULONG Width);  // Writes the pixels (in Normal and Greyscale mode)
    void WriteGrey4(const list<unsigned char>& Bytes, ofstream& BMPFile, ULONG Width);
    void WriteGrey2(const list<unsigned char>& Bytes, ofstream& BMPFile, ULONG Width);
    void WriteChroma(const list<unsigned char>& Bytes, ofstream& BMPFile, ULONG Width); // Writes the pixels (in ChromaSubsampling mode)
    inline void ConvertToRGB(unsigned char* Pixel); // Converts a pixel in YCbCr back to RGB
    inline int Clamp(int Val);  // If Val > 255, return 255. If Val < 0, return 0. Else: return Val
    void ConvertCharArrayToList(const unsigned char* In, ULONG Len, list<unsigned char>& Out);  // Copies all bytes from the char-array into the list
    void RLEDecompression(const unsigned char* In, ULONG Len, list<unsigned char>& Out); // Decompresses the bytes if RLE-Compression was used
    inline unsigned char ConvertToChar(double In); // Converts a double to a char
};
