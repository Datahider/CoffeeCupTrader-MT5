#ifndef CCT_MACDPROVIDER_MQH
#define CCT_MACDPROVIDER_MQH

#include "CCT_Config.mqh"
#include "CCT_ProvidersBase.mqh"

class CCctMACDProvider : public CCctProvider
{
private:
  string m_symbol;
  ENUM_TIMEFRAMES m_tf;
  int m_fast, m_slow, m_signal;
  int m_handle;

public:
  CCctMACDProvider(const string symbol, const ENUM_TIMEFRAMES tf,
                   const int fast, const int slow, const int signal,
                   const CCctConfig &cfg)
  {
    m_symbol=symbol; m_tf=tf;
    m_fast=fast; m_slow=slow; m_signal=signal;
    m_handle = iMACD(m_symbol, m_tf, m_fast, m_slow, m_signal, cfg.macd_price);
    if(m_handle==INVALID_HANDLE)
      Print("MACDProvider: failed to create handle for ", m_symbol);
  }

  ~CCctMACDProvider() override
  {
    if(m_handle!=INVALID_HANDLE) IndicatorRelease(m_handle);
  }

  string Name() const override { return "MACD"; }

  string GetData(ENUM_TIMEFRAMES tf, int bars) override
  {
    if(m_handle==INVALID_HANDLE || bars<=0) return "";

    datetime tt[];
    ArrayResize(tt, bars);
    int n = CopyTime(m_symbol, m_tf, 0, bars, tt);
    if(n<=0) return "";

    double macd[];
    double sig[];
    ArrayResize(macd, bars);
    ArrayResize(sig,  bars);

    int n1 = CopyBuffer(m_handle, 0, 0, bars, macd);
    int n2 = CopyBuffer(m_handle, 1, 0, bars, sig);
    if(n1<=0 || n2<=0) return "";

    string out;
    out = StringFormat("# %s %s %d,%d,%d\nTime,MACD,Signal\n",
                       Name(), TfToStr(m_tf), m_fast, m_slow, m_signal);

    int last = MathMin(n, bars) - 1;
    for(int i=0;i<=last;i++)
    {
      out += StringFormat("%s,%.6f,%.6f\n",
                          TimeToString(tt[i], TIME_DATE|TIME_MINUTES|TIME_SECONDS),
                          macd[i], sig[i]);
    }
    out += "\n";
    return out;
  }
};

#endif
