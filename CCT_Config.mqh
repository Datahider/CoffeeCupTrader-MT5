#ifndef CCT_CONFIG_MQH
#define CCT_CONFIG_MQH

class CCctConfig
{
public:
  // defaults for indicators when chart shortname doesn't contain them
  ENUM_MA_METHOD   ma_method;
  ENUM_APPLIED_PRICE ma_price;

  double           bb_deviation;
  int              bb_shift;
  ENUM_APPLIED_PRICE bb_price;

  ENUM_APPLIED_PRICE macd_price;

  ENUM_APPLIED_PRICE rsi_price;

  ENUM_MA_METHOD   stoch_method;
  ENUM_STO_PRICE   stoch_price;

  CCctConfig()
  {
    ma_method   = MODE_EMA;
    ma_price    = PRICE_CLOSE;

    bb_deviation = 2.0;
    bb_shift     = 0;
    bb_price     = PRICE_CLOSE;

    macd_price   = PRICE_CLOSE;
    rsi_price    = PRICE_CLOSE;

    stoch_method = MODE_SMA;
    stoch_price  = STO_LOWHIGH;
  }
};
#endif 