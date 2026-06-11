#ifndef CCT_COLLECTOR_MQH
#define CCT_COLLECTOR_MQH

#include "CCT_ProvidersBase.mqh"

int CctGetVisibleBars(const long chart_id)
{
  int vb = (int)ChartGetInteger(chart_id, CHART_VISIBLE_BARS, 0);
  if(vb<=0) vb = (int)ChartGetInteger(chart_id, CHART_WIDTH_IN_BARS, 0);
  if(vb<=0) vb = 100;
  return vb;
}

string CctCollectPayload(const long chart_id, CCctProvider* &providers[], const ENUM_TIMEFRAMES tf)
{
  int bars = CctGetVisibleBars(chart_id);

  string payload;
  for(int i=0;i<ArraySize(providers);i++)
  {
    if(providers[i]==NULL) continue;
    payload += providers[i].GetData(tf, bars);
  }
  return payload;
}

#endif
