// CCT_ADXProvider.mqh
#ifndef CCT_ADXPROVIDER_MQH
#define CCT_ADXPROVIDER_MQH

#include "CCT_Config.mqh"
#include "CCT_ProvidersBase.mqh"

class CCctADXProvider : public CCctProvider
{
private:
  string m_symbol;
  ENUM_TIMEFRAMES m_tf;
  int m_period;
  int m_handle;

public:
  CCctADXProvider(const string symbol, const ENUM_TIMEFRAMES tf, const int period)
  {
    m_symbol=symbol; m_tf=tf; m_period=period;
    m_handle = iADX(m_symbol, m_tf, m_period);
    if(m_handle==INVALID_HANDLE)
      Print("ADXProvider: failed to create handle for ", m_symbol);
  }

  ~CCctADXProvider() override
  {
    if(m_handle!=INVALID_HANDLE) IndicatorRelease(m_handle);
  }

  string Name() const override { return "ADX"; }

  string GetData(ENUM_TIMEFRAMES tf, int bars) override
  {
    if(m_handle==INVALID_HANDLE || bars<=0) return "";

    datetime tt[];
    ArrayResize(tt, bars);
    int n = CopyTime(m_symbol, m_tf, 0, bars, tt);
    if(n<=0) return "";

    double adx[], plusdi[], minusdi[];
    ArrayResize(adx, bars);
    ArrayResize(plusdi, bars);
    ArrayResize(minusdi, bars);

    int n0 = CopyBuffer(m_handle, 0, 0, bars, adx);
    int n1 = CopyBuffer(m_handle, 1, 0, bars, plusdi);
    int n2 = CopyBuffer(m_handle, 2, 0, bars, minusdi);
    if(n0<=0 || n1<=0 || n2<=0) return "";

    string out = StringFormat("# %s %s %d\nTime,ADX,PlusDI,MinusDI\n", Name(), TfToStr(m_tf), m_period);

    int last = MathMin(MathMin(n0,n1), MathMin(n2,bars)) - 1;
    for(int i=0;i<=last;i++)
    {
      out += StringFormat("%s,%.6f,%.6f,%.6f\n",
                          TimeToString(tt[i], TIME_DATE|TIME_MINUTES|TIME_SECONDS),
                          adx[i], plusdi[i], minusdi[i]);
    }
    out += "\n";
    return out;
  }
};

#endif
