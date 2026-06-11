#ifndef CCT_DETECTOR_MQH
#define CCT_DETECTOR_MQH

#include "CCT_Config.mqh"
#include "CCT_ProvidersBase.mqh"

#include "CCT_MACDProvider.mqh"
#include "CCT_BandsProvider.mqh"
#include "CCT_MAProvider.mqh"
#include "CCT_RSIProvider.mqh"
#include "CCT_StochProvider.mqh"
#include "CCT_ATRProvider.mqh"
#include "CCT_ADXProvider.mqh"


string CctTrim(string s)
{
  StringTrimLeft(s);
  StringTrimRight(s);
  return s;
}

bool CctParseIntList(const string inside, int &out[], int &n)
{
  n=0;
  string t = CctTrim(inside);
  if(t=="") { ArrayResize(out,0); return true; }

  string parts[];
  int pc = StringSplit(t, ',', parts);
  if(pc<=0) return false;

  ArrayResize(out, pc);
  for(int i=0;i<pc;i++)
    out[i] = (int)StringToInteger(CctTrim(parts[i]));
  n=pc;
  return true;
}

bool CctParseShortName(const string shortname, string &base, int &params[], int &nparams)
{
  base=""; nparams=0;
  string s = CctTrim(shortname);

  int lp = StringFind(s, "(");
  if(lp<0)
  {
    base=s;
    ArrayResize(params,0);
    return true;
  }

  int rp = StringFind(s, ")", lp+1);
  if(rp<0) return false;

  base = CctTrim(StringSubstr(s,0,lp));
  string inside = StringSubstr(s, lp+1, rp-lp-1);

  int tmp[]; int n=0;
  if(!CctParseIntList(inside, tmp, n)) return false;

  ArrayResize(params,n);
  for(int i=0;i<n;i++) params[i]=tmp[i];
  nparams=n;
  return true;
}

ECctIndType CctMapBaseToType(const string base)
{
  if(base=="MA")    return CCT_IND_MA;
  if(base=="Bands") return CCT_IND_BANDS;
  if(base=="MACD")  return CCT_IND_MACD;
  if(base=="RSI")   return CCT_IND_RSI;
  if(base=="Stoch") return CCT_IND_STOCH;
  if(base=="ATR")   return CCT_IND_ATR;
  if(base=="ADX")   return CCT_IND_ADX;
  return CCT_IND_UNSUPPORTED;
}

void CctProvidersAdd(CCctProvider* &providers[], CCctProvider* p)
{
  if(p==NULL) return;
  int n = ArraySize(providers);
  ArrayResize(providers, n+1);
  providers[n]=p;
}

CCctProvider* CctCreateProvider(const ECctIndType type, const string shortname, const int subwindow,
                                const int &params[], const int nparams, const CCctConfig &cfg)
{
  if(type==CCT_IND_MA && nparams==1)
    return new CCctMAProvider(_Symbol, (ENUM_TIMEFRAMES)_Period, params[0], cfg);

  if(type==CCT_IND_BANDS && nparams==1)
    return new CCctBandsProvider(_Symbol, (ENUM_TIMEFRAMES)_Period, params[0], cfg);

  if(type==CCT_IND_MACD && nparams==3)
    return new CCctMACDProvider(_Symbol, (ENUM_TIMEFRAMES)_Period, params[0], params[1], params[2], cfg);

  if(type==CCT_IND_RSI && nparams==1)
    return new CCctRSIProvider(_Symbol, (ENUM_TIMEFRAMES)_Period, params[0], cfg);

  if(type==CCT_IND_STOCH && nparams==3)
    return new CCctStochProvider(_Symbol, (ENUM_TIMEFRAMES)_Period, params[0], params[1], params[2], cfg);

  if(type==CCT_IND_ATR && nparams==1)
    return new CCctATRProvider(_Symbol, (ENUM_TIMEFRAMES)_Period, params[0]);

  if(type==CCT_IND_ADX && nparams==1)
    return new CCctADXProvider(_Symbol, (ENUM_TIMEFRAMES)_Period, params[0]);

  if(type==CCT_IND_UNSUPPORTED)
    return new CCctUnsupportedProvider(shortname, subwindow);

  return NULL;
}

void CctScanChartProviders(const long chart_id, CCctProvider* &providers[], const CCctConfig &cfg)
{
  int wins = (int)ChartGetInteger(chart_id, CHART_WINDOWS_TOTAL, 0);

  for(int w=0; w<wins; w++)
  {
    int total = ChartIndicatorsTotal(chart_id, w);
    for(int i=0; i<total; i++)
    {
      string sn = ChartIndicatorName(chart_id, w, i);

      string base; int params[]; int np=0;
      if(!CctParseShortName(sn, base, params, np))
      {
        CctProvidersAdd(providers, new CCctUnsupportedProvider(sn, w));
        continue;
      }

      ECctIndType type = CctMapBaseToType(base);
      CCctProvider* p = CctCreateProvider(type, sn, w, params, np, cfg);
      if(p!=NULL) CctProvidersAdd(providers, p);
      else if(type==CCT_IND_UNSUPPORTED) CctProvidersAdd(providers, new CCctUnsupportedProvider(sn, w));
    }
  }
}

#endif
