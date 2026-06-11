#ifndef CCT_PROVIDERSBASE_MQH
#define CCT_PROVIDERSBASE_MQH

enum ECctIndType
{
  CCT_IND_UNSUPPORTED = 0,
  CCT_IND_MA,
  CCT_IND_BANDS,
  CCT_IND_MACD,
  CCT_IND_RSI,
  CCT_IND_STOCH,
  CCT_IND_ATR,
  CCT_IND_ADX
};

class CCctProvider
{
public:
  virtual ~CCctProvider() {}
  virtual string GetData(ENUM_TIMEFRAMES tf, int bars) { return ""; }
  virtual string Name() const { return "Provider"; }

protected:
  string TfToStr(const ENUM_TIMEFRAMES tf) const
  {
    if(tf==PERIOD_M1)  return "M1";
    if(tf==PERIOD_M5)  return "M5";
    if(tf==PERIOD_M15) return "M15";
    if(tf==PERIOD_M30) return "M30";
    if(tf==PERIOD_H1)  return "H1";
    if(tf==PERIOD_H4)  return "H4";
    if(tf==PERIOD_D1)  return "D1";
    if(tf==PERIOD_W1)  return "W1";
    if(tf==PERIOD_MN1) return "MN1";
    return IntegerToString((int)tf);
  }
  
};

class CCctUnsupportedProvider : public CCctProvider
{
private:
  string m_name;
  int    m_subwindow;
public:
  CCctUnsupportedProvider(const string name, const int subwindow)
  {
    m_name=name; m_subwindow=subwindow;
    Print("Unsupported indicator on chart: ", m_name, " (subwindow=", m_subwindow, ")");
  }
  string GetData(ENUM_TIMEFRAMES tf, int bars) override { return ""; }
  string Name() const override { return m_name; }
};

#endif
