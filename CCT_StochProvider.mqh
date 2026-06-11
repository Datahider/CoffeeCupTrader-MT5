// CCT_StochProvider.mqh
#ifndef CCT_STOCHPROVIDER_MQH
#define CCT_STOCHPROVIDER_MQH

#include "CCT_Config.mqh"
#include "CCT_ProvidersBase.mqh"

class CCctStochProvider : public CCctProvider
{
private:
  string m_symbol;
  ENUM_TIMEFRAMES m_tf;
  int m_k, m_d, m_slow;
  int m_handle;

public:
  CCctStochProvider(const string symbol, const ENUM_TIMEFRAMES tf,
                    const int k, const int d, const int slow,
                    const CCctConfig &cfg)
  {
    m_symbol=symbol; m_tf=tf;
    m_k=k; m_d=d; m_slow=slow;

    m_handle = iStochastic(m_symbol, m_tf, m_k, m_d, m_slow, cfg.stoch_method, cfg.stoch_price);
    if(m_handle==INVALID_HANDLE)
      Print("StochProvider: failed to create handle for ", m_symbol);
  }

  ~CCctStochProvider() override
  {
    if(m_handle!=INVALID_HANDLE) IndicatorRelease(m_handle);
  }

  string Name() const override { return "Stoch"; }

  string GetData(ENUM_TIMEFRAMES tf, int bars) override
  {
    if(m_handle==INVALID_HANDLE || bars<=0) return "";

    datetime tt[];
    ArrayResize(tt, bars);
    int n = CopyTime(m_symbol, m_tf, 0, bars, tt);
    if(n<=0) return "";

    double mainv[], signalv[];
    ArrayResize(mainv, bars);
    ArrayResize(signalv, bars);

    int n1 = CopyBuffer(m_handle, 0, 0, bars, mainv);
    int n2 = CopyBuffer(m_handle, 1, 0, bars, signalv);
    if(n1<=0 || n2<=0) return "";

    string out = StringFormat("# %s %s %d,%d,%d\nTime,Main,Signal\n",
                              Name(), TfToStr(m_tf), m_k, m_d, m_slow);

    int last = MathMin(MathMin(n1,n2), bars) - 1;
    for(int i=0;i<=last;i++)
    {
      out += StringFormat("%s,%.6f,%.6f\n",
                          TimeToString(tt[i], TIME_DATE|TIME_MINUTES|TIME_SECONDS),
                          mainv[i], signalv[i]);
    }
    out += "\n";
    return out;
  }
};

#endif
