#ifndef CCT_SCREENSHOT_MQH
#define CCT_SCREENSHOT_MQH

const string AnchorBase = "CCT_SCREENSHOT_";
#define CCT_SCREENSHOT_SEP_PX       5
#define CCT_SCREENSHOT_MARGIN_W_PX  70
#define CCT_SCREENSHOT_MARGIN_H_PX  25


const bool   Toggle    = true;        // если метка уже есть на этом графике — удалить
const bool   Unique    = true;        // удалить такую же метку с других графиков

//--- CRC32 (стандартный полином 0xEDB88320)
uint CRC32(const uchar &data[])
{
   uint crc = 0xFFFFFFFF;
   for(int i=0; i<ArraySize(data); i++)
   {
      crc ^= (uint)data[i];
      for(int b=0; b<8; b++)
      {
         if((crc & 1) != 0)
            crc = (crc >> 1) ^ 0xEDB88320;
         else
            crc >>= 1;
      }
   }
   return ~crc;
}

string ToHex8(uint v)
{
   // 8 hex символов, upper-case
   return StringFormat("%08X", v);
}

string MakeAnchorName(const string token)
{
   uchar bytes[];
   StringToCharArray(token, bytes, 0, WHOLE_ARRAY, CP_UTF8);
   // StringToCharArray добавляет '\0' в конец — уберём, чтобы CRC был стабильный
   int n = ArraySize(bytes);
   if(n > 0 && bytes[n-1] == 0) ArrayResize(bytes, n-1);

   uint c = CRC32(bytes);
   return AnchorBase + ToHex8(c);
}

long FindScreenshotChartId(const string token)
{
  string anchor = MakeAnchorName(token);

  long cid = ChartFirst();
  while(cid != -1)
  {
    if(ObjectFind(cid, anchor) >= 0)
      return cid;
    cid = ChartNext(cid);
  }
  return ChartID(); // fallback
}

bool MakeScreenshot(const string token, string &out_filename)
{
  string anchor = MakeAnchorName(token);
  long cid = FindScreenshotChartId(token);

  int wins = (int)ChartGetInteger(cid, CHART_WINDOWS_TOTAL, 0);

  int w = (int)ChartGetInteger(cid, CHART_WIDTH_IN_PIXELS, 0);

  int h = 0;
  for(int sw=0; sw<wins; sw++)
  {
    int wh = (int)ChartGetInteger(cid, CHART_HEIGHT_IN_PIXELS, sw);
    if(wh>0) h += wh;
  }
  if(wins>1) h += (wins-1)*CCT_SCREENSHOT_SEP_PX;

  w += CCT_SCREENSHOT_MARGIN_W_PX;
  h += CCT_SCREENSHOT_MARGIN_H_PX;

  out_filename = anchor + ".png";
  bool ok = ChartScreenShot(cid, out_filename, w, h, ALIGN_RIGHT);
  if(!ok)
    Print("ChartScreenShot failed. chart_id=", cid, " file=", out_filename, " err=", GetLastError());
  return ok;
}

#endif 