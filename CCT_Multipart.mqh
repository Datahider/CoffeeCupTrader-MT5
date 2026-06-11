// CCT_Multipart.mqh
#ifndef CCT_MULTIPART_MQH
#define CCT_MULTIPART_MQH

void AppendBytes(uchar &dst[], const uchar &src[])
{
  int a=ArraySize(dst), b=ArraySize(src);
  ArrayResize(dst, a+b);
  for(int i=0;i<b;i++) dst[a+i]=src[i];
}

void AppendStr(uchar &dst[], const string s)
{
  uchar tmp[];
  StringToCharArray(s, tmp, 0, StringLen(s));
  AppendBytes(dst, tmp);
}

bool LoadFileBytes(const string filename, uchar &out[])
{
  int h = FileOpen(filename, FILE_READ|FILE_BIN);
  if(h==INVALID_HANDLE) return false;
  int sz = (int)FileSize(h);
  ArrayResize(out, sz);
  FileReadArray(h, out, 0, sz);
  FileClose(h);
  return true;
}

void BuildMultipart(const string boundary, const string payload,
                    const bool hasFile, const string pngName, const uchar &pngBytes[],
                    uchar &outBody[])
{
  ArrayResize(outBody,0);

  string b = "--"+boundary+"\r\n";
  string e = "--"+boundary+"--\r\n";

  AppendStr(outBody, b);
  AppendStr(outBody, "Content-Disposition: form-data; name=\"data\"\r\n\r\n");
  AppendStr(outBody, payload);
  AppendStr(outBody, "\r\n");

  if(hasFile)
  {
    AppendStr(outBody, b);
    AppendStr(outBody, "Content-Disposition: form-data; name=\"file\"; filename=\""+pngName+"\"\r\n");
    AppendStr(outBody, "Content-Type: image/png\r\n\r\n");
    AppendBytes(outBody, pngBytes);
    AppendStr(outBody, "\r\n");
  }

  AppendStr(outBody, e);
}

#endif
