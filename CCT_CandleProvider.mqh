#ifndef CCT_CANDLEPROVIDER_MQH
#define CCT_CANDLEPROVIDER_MQH

#include "CCT_ProvidersBase.mqh"

class CCctCandleProvider : public CCctProvider
{
private:
  string m_symbol;
  ENUM_TIMEFRAMES m_tf;

public:
  CCctCandleProvider(const string symbol, const ENUM_TIMEFRAMES tf)
  {
    m_symbol=symbol; m_tf=tf;
  }

  string Name() const override { return "CANDLE HISTORY"; }

  string GetData(ENUM_TIMEFRAMES tf, int bars) override
  {
    if(bars<=0) return "";

    MqlRates rates[];
    ArrayResize(rates, bars);
    int n = CopyRates(m_symbol, m_tf, 0, bars, rates);
    if(n<=0) return "";

    string out = StringFormat("# %s %s\nTime,Open,High,Low,Close,TickVolume\n", Name(), TfToStr(m_tf));

    // rates[0] is current bar, print old->new
    int last = MathMin(n, bars) - 1;
    for(int i=0;i<=last;i++)
    {
      out += StringFormat("%s,%.5f,%.5f,%.5f,%.5f,%d\n",
                          TimeToString(rates[i].time, TIME_DATE|TIME_MINUTES|TIME_SECONDS),
                          rates[i].open, rates[i].high, rates[i].low, rates[i].close,
                          (int)rates[i].tick_volume);
    }
    out += "\n";
    return out;
  }
};

#endif
