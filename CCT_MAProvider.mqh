// CCT_MAProvider.mqh
#ifndef CCT_MAPROVIDER_MQH
#define CCT_MAPROVIDER_MQH

#include "CCT_Config.mqh"
#include "CCT_ProvidersBase.mqh"

class CCctMAProvider : public CCctProvider
{
private:
  string m_symbol;
  ENUM_TIMEFRAMES m_tf;
  int m_period;
  int m_handle;

public:
  CCctMAProvider(const string symbol, const ENUM_TIMEFRAMES tf, const int period, const CCctConfig &cfg)
  {
    m_symbol=symbol; m_tf=tf; m_period=period;

    m_handle = iMA(m_symbol, m_tf, m_period, 0, cfg.ma_method, cfg.ma_price);
    if(m_handle==INVALID_HANDLE)
      Print("MAProvider: failed to create handle for ", m_symbol);
  }

  ~CCctMAProvider() override
  {
    if(m_handle!=INVALID_HANDLE) IndicatorRelease(m_handle);
  }

  string Name() const override { return "MA"; }

  string GetData(ENUM_TIMEFRAMES tf, int bars) override
  {
    if(m_handle==INVALID_HANDLE || bars<=0) return "";

    datetime tt[];
    ArrayResize(tt, bars);
    int n = CopyTime(m_symbol, m_tf, 0, bars, tt);
    if(n<=0) return "";

    double val[];
    ArrayResize(val, bars);
    n = CopyBuffer(m_handle, 0, 0, bars, val);
    if(n<=0) return "";

    string out = StringFormat("# %s %s %d\nTime,Value\n", Name(), TfToStr(m_tf), m_period);

    // CopyBuffer: считаем что [0] = current, печатаем old->new
    int last = MathMin(n, bars) - 1;
    for(int i=0;i<=last;i++)
    {
      out += StringFormat("%s,%.5f\n",
                          TimeToString(tt[i], TIME_DATE|TIME_MINUTES|TIME_SECONDS),
                          val[i]);
    }
    out += "\n";
    return out;
  }
};

#endif
