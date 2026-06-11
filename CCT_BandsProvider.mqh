#ifndef CCT_BANDSPROVIDER_MQH
#define CCT_BANDSPROVIDER_MQH

#include "CCT_Config.mqh"
#include "CCT_ProvidersBase.mqh"

class CCctBandsProvider : public CCctProvider
{
private:
  string m_symbol;
  ENUM_TIMEFRAMES m_tf;
  int m_period;
  int m_handle;

public:
  CCctBandsProvider(const string symbol, const ENUM_TIMEFRAMES tf, const int period, const CCctConfig &cfg)
  {
    m_symbol=symbol; m_tf=tf; m_period=period;
    m_handle = iBands(m_symbol, m_tf, m_period, cfg.bb_shift, cfg.bb_deviation, cfg.bb_price);
    if(m_handle==INVALID_HANDLE)
      Print("BandsProvider: failed to create handle for ", m_symbol);
  }

  ~CCctBandsProvider() override
  {
    if(m_handle!=INVALID_HANDLE) IndicatorRelease(m_handle);
  }

  string Name() const override { return "BOLLINGER BANDS"; }

  string GetData(ENUM_TIMEFRAMES tf, int bars) override
  {
    if(m_handle==INVALID_HANDLE || bars<=0) return "";

    datetime tt[];
    ArrayResize(tt, bars);
    int n = CopyTime(m_symbol, m_tf, 0, bars, tt);
    if(n<=0) return "";

    double upper[], mid[], lower[];
    ArrayResize(upper,bars);
    ArrayResize(mid,  bars);
    ArrayResize(lower,bars);

    int nM = CopyBuffer(m_handle, 0, 0, bars, mid);
    int nU = CopyBuffer(m_handle, 1, 0, bars, upper);
    int nL = CopyBuffer(m_handle, 2, 0, bars, lower);
    if(nU<=0 || nM<=0 || nL<=0) return "";

    string out = StringFormat("# %s %s %d\nTime,Upper,Middle,Lower\n", Name(), TfToStr(m_tf), m_period);

    int last = MathMin(n, bars) - 1;
    for(int i=0;i<=last;i++)
    {
      out += StringFormat("%s,%.5f,%.5f,%.5f\n",
                          TimeToString(tt[i], TIME_DATE|TIME_MINUTES|TIME_SECONDS),
                          upper[i], mid[i], lower[i]);
    }
    out += "\n";
    return out;
  }
};

#endif
