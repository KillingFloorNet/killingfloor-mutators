#include "StdAfx.h"
#include "Converter.h"

CConverter::CConverter(void)
{
}

CConverter::~CConverter(void)
{
}

bool CConverter::Convert(CString File, CString& ConsoleOutput)
{
	ConsoleOutput = "";
	
	long int len = File.GetLength();
	char* OutputName = new char[len];     // used to get the output-file-name. it is 1 character smaller than FileName (len contains the length of FileName minus \0)
	char Temp[4] = {'\0', '\0', '\0', '\0'};   // used to temporary save the read characters

	strncpy(OutputName, File.GetString(), len-4);   // remove the html-extension
	OutputName[len-4]='b';       // and add the bmp-extension and the \0 character
	OutputName[len-3]='m';
	OutputName[len-2]='p';
	OutputName[len-1]='\0';

	ifstream HTMLFile(File.GetString(), ios::in);  // open the input file
  ofstream BMPFile(OutputName, ios::out|ios::binary|ios::trunc);  // and the output file

	if (HTMLFile && BMPFile)
	{
    //---------------------------------------------------------------
    // Get the total count of bytes saved in the HTML-File.
    // The value is used to stop writing in the target file
    ULONG FileEnd = GetFinalSize(HTMLFile);

    ULONG OffBits = 54;
    ULONG Width = 0;
    ULONG Height = 0;
    ECompressionType CompressionType = NoCompression;
    bool bRLECompression = false;

    GetBitmapInfos(HTMLFile, &Width, &Height, &CompressionType, &bRLECompression);
    
    //---------------------------------------------------------------
    // Now go through the file, convert the "text-bytes" into real bytes
    // and save them into an temporary array.
    ULONG BitmapBytesLen = FileEnd-NumBeginBytes;
    
    unsigned char* BitmapBytes = new unsigned char[BitmapBytesLen];
    if (BitmapBytes == NULL)
    {
      ConsoleOutput = "Error: Not enough memory to read the file!";
      HTMLFile.close();
      BMPFile.close();
      return false;
    }
    
    CopyBitmapHeader(BMPFile, Width, Height);
    ULONG ByteCounter = 0;

    while(!HTMLFile.eof() && ByteCounter<FileEnd)
		{
      HTMLFile.getline(Temp, 4, '\n');  // get the next 1 till 3 bytes
			if (!Temp[0])
				continue;
			if (HTMLFile.eof())
				break;      
		  if (ByteCounter>=NumBeginBytes)
        BitmapBytes[ByteCounter-NumBeginBytes] = (unsigned char)(atoi(Temp));                 
      ++ByteCounter;
    }
    
    //---------------------------------------------------------------
    // We've got the bytes, now decompress them if they are RLE-Compressed. If not, just
    // copy them into the new array, so that we only need to implement the other stuff
    // once (i.e. for the list).
    list<unsigned char> UncompressedBytes;
       
    if (bRLECompression) // Decompress it      
      RLEDecompression(BitmapBytes, BitmapBytesLen, UncompressedBytes);
    else  // Just copy it so that we can go on with it.
      ConvertCharArrayToList(BitmapBytes, BitmapBytesLen, UncompressedBytes);
    
    delete[] BitmapBytes; // We don't need it anymore. Free the memory.
    BitmapBytes = 0; 
       
    //---------------------------------------------------------------
    // We are ready to write the pixels into the BMP-File. However, the list might
    // still not contain the final bytes. The bytes are either in greyscale,
    // normal or ChromaSubsampling was applied.
    
    if (CompressionType == ChromaSubsampling)
      WriteChroma(UncompressedBytes, BMPFile, Width);
    else if (CompressionType == ToGreyscale8 || CompressionType == NoCompression)
      WriteNormal_Grey(UncompressedBytes, BMPFile, CompressionType == ToGreyscale8, Width);
    else if (CompressionType == ToGreyscale4)
      WriteGrey4(UncompressedBytes, BMPFile, Width);
    else
      WriteGrey2(UncompressedBytes, BMPFile, Width);
    
    ConsoleOutput = "Converted HTML-file successfully to " + CString(OutputName) + ".";
  }
	else
	{
		if (!HTMLFile)
		{
			ConsoleOutput = "Error: Couldn't open HTML-file: " + File;
		  if (!BMPFile)
		    ConsoleOutput += "\n";
		}
		if (!BMPFile)
			ConsoleOutput += "Error: Couldn't create BMP-file: " + CString(OutputName);	
    return false;
  }
  
	delete[] OutputName;  // delete the created array
	HTMLFile.close();     // and close the two streams
	BMPFile.close();
	return true;
}
  

unsigned long int CConverter::GetFinalSize(ifstream& HTMLFile)
{
	char Temp[4] = {'\0', '\0', '\0', '\0'};   // used to temporary save the read characters
  ULONG FileEnd = 0;
  while(!HTMLFile.eof())
	{
	 HTMLFile.getline(Temp, 4, '\n');
	 if (!Temp[0])
	   continue;
	 if (HTMLFile.eof())
	   break;
   ++FileEnd;
  }
  HTMLFile.clear(); // Remove the EOF-flag
  HTMLFile.seekg(0, ios::beg);
  return FileEnd;
}

void CConverter::GetBitmapInfos(ifstream& HTMLFile,
                    ULONG* Width, ULONG* Height, ECompressionType* CompressionType, 
                    bool* RLECompression)
{
	char Temp[4] = {'\0', '\0', '\0', '\0'};   // used to temporary save the read characters

  ULONG ByteCounter = 0;

  unsigned char UnsignedLong[4] = {0, 0, 0, 0}; // 4 bytes -> 1 unsigned long int
  short int i=0;

  // Width
  while(i<4)
  {
    HTMLFile.getline(Temp, 4, '\n');
		if (!Temp[0])
		  continue;
    UnsignedLong[i] = (unsigned char)(atoi(Temp)); // save the single bytes in the array
    ++i;   
  }
  // "UnsignedLong" now holds all information we need in the correct order.
  // -> convert it into an usable unsinged long int
  (*Width) = *((unsigned long int*)(UnsignedLong));
  
  // Height
  i=0;
  while(i<4)
  {
    HTMLFile.getline(Temp, 4, '\n');
		if (!Temp[0])
		  continue;
    UnsignedLong[i] = (unsigned char)(atoi(Temp)); // save the single bytes in the array
    ++i;   
  }
  (*Height) = *((unsigned long int*)(UnsignedLong));

  // The other settings
  i=0;
  unsigned char OneByte = 0;
  while(i<1)
  {
    HTMLFile.getline(Temp, 4, '\n');
		if (!Temp[0])
		  continue;
    OneByte = (unsigned char)(atoi(Temp)); 
    ++i;   
  }

  unsigned char CompressByte = OneByte&0xe0; // Filter RLECompression out. In bits:
                                             // 1110 0000 (The 4. bit is RLECompression),
  if (CompressByte == 0x20)                  // the rest is not used
    (*CompressionType) = ChromaSubsampling;
  else if (CompressByte == 0x40)
    (*CompressionType) = ToGreyscale8;
  else if (CompressByte == 0x60)
    (*CompressionType) = ToGreyscale4;
  else if (CompressByte == 0x80)
    (*CompressionType) = ToGreyscale2;
  else
    (*CompressionType) = NoCompression;

  if ((OneByte&0x10) == 0x10)
    (*RLECompression) = true;
  else
    (*RLECompression) = false;

  HTMLFile.clear(); // Remove the EOF-flag
  HTMLFile.seekg(0, ios::beg);
}

inline ULONG CConverter::GetNum0Bytes(ULONG Width)
{
  // This is the long-form of the calculation:
  //    ULONG Temp = (Width*3)%4;
  //    if (Temp!=0)               // How many 0-bytes at the end of the row?
  //      Temp = 4-Temp;
  //    return Temp;
  return ((Width*3)%4 == 0) ? 0 : (4-(Width*3)%4);
}

// Needed, because of alignment issues.
// http://msdn2.microsoft.com/en-us/library/2e70t5y1(VS.80).aspx
#pragma pack(push,2)

struct BitmapHeader
{
  unsigned short int bfType;
  ULONG              bfSize;
  unsigned short int bfReserved1;
  unsigned short int bfReserved2;
  ULONG              bfOffBits;

  ULONG              biSize;
  ULONG              biWidth;
  ULONG              biHeight;
  unsigned short int biPlanes;
  unsigned short int biBitCount;
  ULONG              biCompression;
  ULONG              biSizeImage;
  ULONG              biXPelsPerMeter;
  ULONG              biYPelsPerMeter;
  ULONG              biClrUsed;
  ULONG              biClrImportant;

  BitmapHeader(ULONG width, ULONG height) : 
    bfType(19778), bfReserved1(0), bfReserved2(0), bfOffBits(54), biSize(40),
    biWidth(width), biHeight(height), biPlanes(1), biBitCount(24), biCompression(0),
    biXPelsPerMeter(0), biYPelsPerMeter(0), biClrUsed(0), biClrImportant(0)
  {
    bfSize = width*height*3 + bfOffBits;
    biSizeImage = width*height*3;
  }
};

#pragma pack(pop)

ULONG CConverter::CopyBitmapHeader(ofstream& BMPFile, ULONG width, ULONG height)
{  
  BitmapHeader Header(width, height);
  BMPFile.write((char*)(&Header), sizeof(BitmapHeader));

  /*unsigned short int ShortInt = 19778;
  BMPFile.write((char*)(&ShortInt), 2);
  ULONG LongInt = width*height*3 + 54;
  BMPFile.write((char*)(&LongInt), 4);
  ShortInt = 0;
  BMPFile.write((char*)(&ShortInt), 2);
  BMPFile.write((char*)(&ShortInt), 2);
  LongInt = 54;
  BMPFile.write((char*)(&LongInt), 4);
  LongInt = 40;
  BMPFile.write((char*)(&LongInt), 4);
  LongInt = width;
  BMPFile.write((char*)(&LongInt), 4);
  LongInt = height;
  BMPFile.write((char*)(&LongInt), 4);
  ShortInt = 1;
  BMPFile.write((char*)(&ShortInt), 2);
  ShortInt = 24;
  BMPFile.write((char*)(&ShortInt), 2);
  LongInt = 0;
  BMPFile.write((char*)(&LongInt), 4);
  LongInt = width*height*3;
  BMPFile.write((char*)(&LongInt), 4);
  LongInt = 0;
  BMPFile.write((char*)(&LongInt), 4);
  BMPFile.write((char*)(&LongInt), 4);
  BMPFile.write((char*)(&LongInt), 4);
  BMPFile.write((char*)(&LongInt), 4);*/

	return NumBeginBytes;
}

// Handels Normal color and greyscale
void CConverter::WriteNormal_Grey(const list<unsigned char>& Bytes, ofstream& BMPFile, bool bGreyscale8, 
                      ULONG Width)
{
  list<unsigned char>::const_iterator ByteCounter = Bytes.begin();
  ULONG WidthCounter = 1;

  while(ByteCounter!=Bytes.end())
  {
   BMPFile << (*ByteCounter); // Write the color red
        
   if (bGreyscale8) // uhm, we also need to handle green and blue -> just write the same value again
   {
	  if (WidthCounter <= Width) // Still the pixels in the row
    {
     BMPFile << (*ByteCounter); // Green
		 BMPFile << (*ByteCounter); // Blue
    }
    // else: the current byte is a appended 0-byte!
    ++WidthCounter; 
    if (WidthCounter>Width) // Uhm, a new row!
      WidthCounter=1;
   }

   ++ByteCounter; // Go to the next byte
  }
}

// Handles 4-bit greyscale
void CConverter::WriteGrey4(const list<unsigned char>& Bytes, ofstream& BMPFile, ULONG Width)
{
  list<unsigned char>::const_iterator ByteCounter = Bytes.begin();
  ULONG WidthCounter = 1;
  unsigned char APixel = 0;

  while(ByteCounter!=Bytes.end())
  {    
    if (WidthCounter <= Width) // Still the pixels in the row
    {
      APixel = (((*ByteCounter)>>4) & 0x0f) * 16;
      BMPFile << APixel;  // Red
      BMPFile << APixel;  // Green
      BMPFile << APixel;  // Blue
      

      ++WidthCounter;
      APixel = ((*ByteCounter) & 0x0f) * 16;
      BMPFile << APixel;  // Red
      BMPFile << APixel;  // Green
      BMPFile << APixel;  // Blue
    }
    else
      BMPFile << (*ByteCounter);

    ++WidthCounter; 
    if (WidthCounter>Width) 
      WidthCounter=1;

   ++ByteCounter; // Go to the next byte
  }
}

// Handles 2-bit greyscale
void CConverter::WriteGrey2(const list<unsigned char>& Bytes, ofstream& BMPFile, ULONG Width)
{
  list<unsigned char>::const_iterator ByteCounter = Bytes.begin();
  ULONG WidthCounter = 1;
  unsigned char APixel = 0;

  while(ByteCounter!=Bytes.end())
  {    
    if (WidthCounter <= Width) // Still the pixels in the row
    {
      APixel = (((*ByteCounter)>>6)&0x03)*64;
      BMPFile << APixel;  // Red
      BMPFile << APixel;  // Green
      BMPFile << APixel;  // Blue
      

      if (WidthCounter+1 <= Width)
      {
        ++WidthCounter;
        APixel = (((*ByteCounter)>>4)&0x03)*64;
        BMPFile << APixel;  // Red
        BMPFile << APixel;  // Green
        BMPFile << APixel;  // Blue
      
        if (WidthCounter+1 <= Width)
        {
          ++WidthCounter;
          APixel = (((*ByteCounter)>>2)&0x03)*64;
          BMPFile << APixel;  // Red
          BMPFile << APixel;  // Green
          BMPFile << APixel;  // Blue
          
          if (WidthCounter+1 <= Width)
          {
            ++WidthCounter;
            APixel = ((*ByteCounter)&0x03)*64;
            BMPFile << APixel;  // Red
            BMPFile << APixel;  // Green
            BMPFile << APixel;  // Blue
          }
        }
      }
    }
    else
      BMPFile << (*ByteCounter);

    ++WidthCounter; 
    if (WidthCounter>Width) 
      WidthCounter=1;

   ++ByteCounter; // Go to the next byte
  }
}

// Handels ChromaSubsampling
void CConverter::WriteChroma(const list<unsigned char>& Bytes, ofstream& BMPFile, ULONG Width)
{
  list<unsigned char>::const_iterator ByteCounter = Bytes.begin();
  ULONG WidthCounter = 0;
  ULONG HeightCounter = 0;
    
  unsigned char* CbTable = 0;
  unsigned char* CrTable = 0;
  if (Width%2 == 0)
  {
    CbTable = new unsigned char[Width/2];
    CrTable = new unsigned char[Width/2];
  }
  else
  {
    CbTable = new unsigned char[(Width+1)/2];
    CrTable = new unsigned char[(Width+1)/2];      
  }
  double Y = 0;
  ULONG TableIndex = 0;

  unsigned char Pixel[3] = {0, 0, 0};
  while(ByteCounter != Bytes.end())
  {
    if (WidthCounter >= Width)
      BMPFile << (*ByteCounter);
    else if (WidthCounter%2 == 0 && HeightCounter%2 == 0) // The next 3 bytes are all colors of the same pixel
    {
      Pixel[0] = (*ByteCounter);
      ++ByteCounter;
      Pixel[1] = (*ByteCounter);
      ++ByteCounter;
      Pixel[2] = (*ByteCounter);

      CbTable[WidthCounter/2] = Pixel[1]; 
      CrTable[WidthCounter/2] = Pixel[2]; 

      ConvertToRGB(Pixel);  // Convert the Y, Cb and Cr value to R, G and B

      BMPFile.write((char*)(Pixel), 3);

    }
    else  // This byte is a Y-Value -> Calculate the red-value and look up the green and the blue one in the table
    {
      if (HeightCounter%2 == 0) // WidthCounter is oddly -> we need to decrement it first
      {
        TableIndex = (WidthCounter-1)/2;
      }
      else // Hum, either it is oddly or not...
      {
        if (WidthCounter%2==0)
          TableIndex = WidthCounter/2;
        else
          TableIndex = (WidthCounter-1)/2;
          //TableIndex = ((WidthCounter)-((WidthCounter-1)%2))/2;
      }

      Pixel[0] = (*ByteCounter);
      Pixel[1] = CbTable[TableIndex];
      Pixel[2] = CrTable[TableIndex];

      ConvertToRGB(Pixel);  // Convert the Y, Cb and Cr value to R, G and B

      BMPFile.write((char*)(Pixel), 3);
    }

    ++WidthCounter;
    if (WidthCounter >= Width) 
    {
      WidthCounter = 0;
      ++HeightCounter;
    } 
    
    ++ByteCounter;          
  }

  delete[] CbTable;
  delete[] CrTable;
} 

inline int CConverter::Clamp(int Val)
{
  if (Val>0xff)
    return 0xff;
  else if (Val<0)
    return 0;
  else
    return Val;
}

void CConverter::ConvertToRGB(unsigned char* Pixel)
{
  int Y = Pixel[0];
  int Pb = Pixel[1]-128;
  int Pr = Pixel[2]-128;
  
  Pixel[0] = (unsigned char)(Clamp((int)(Y + 1.402*Pr)));
  Pixel[1] = (unsigned char)(Clamp((int)(Y - 0.344136*Pb - 0.714136*Pr)));
  Pixel[2] = (unsigned char)(Clamp((int)(Y + 1.772*Pb)));
}

void CConverter::ConvertCharArrayToList(const unsigned char* const In, ULONG Len, list<unsigned char>& Out)
{
  for(ULONG i = 0; i<Len; ++i)
  {
    Out.push_back(In[i]);
  }  
}

void CConverter::RLEDecompression(const unsigned char* const In, ULONG Len, list<unsigned char>& Out)
{
  unsigned char LastByte = In[0];
  Out.push_back(In[0]);

  bool bFound2Bytes = false;

  short int InsertCounter = 0;
  
  ULONG i;
  for(i = 1; i<Len; ++i)
  {
    if (bFound2Bytes) // the last 2 bytes were the same -> the current byte is the repetition-counter
    {       
      // Insert x elements instead of the repetition counter byte
      for(InsertCounter = 0; InsertCounter<(unsigned short int)(In[i]); ++InsertCounter)
        Out.push_back(LastByte);

      bFound2Bytes = false;
      ++i;
      if (i<Len)
      {
        LastByte = In[i];
        Out.push_back(In[i]);
      }
    }
    else if (LastByte == In[i])
    {
      bFound2Bytes = true;  // The next byte is the repetition-counter!
      Out.push_back(In[i]);
    }
    else
    {
      LastByte = In[i];
      Out.push_back(In[i]);
    }
  }
}

inline unsigned char CConverter::ConvertToChar(double In)
{
  return (unsigned char)(In);  // Just convert it. No need to round it correctly I think
  //return (unsigned char)(In+0.5);
}
