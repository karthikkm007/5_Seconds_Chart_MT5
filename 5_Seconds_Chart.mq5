//+------------------------------------------------------------------+
//| 5 Seconds Chart Indicator                                       |
//| MetaTrader 5                                                   |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots 2
#property strict

input int timeframe = 5; // Custom timeframe in seconds

double bufferOpenUp[];
double bufferHighUp[];
double bufferLowUp[];
double bufferCloseUp[];
double bufferOpenDown[];
double bufferHighDown[];
double bufferLowDown[];
double bufferCloseDown[];

datetime lastBarTime = 0;
double currentOpen = 0, currentHigh = 0, currentLow = 0, currentClose = 0;

int OnInit() {
  // Configure buffers
  SetIndexBuffer(0, bufferOpenUp, INDICATOR_DATA);
  SetIndexBuffer(1, bufferHighUp, INDICATOR_DATA);
  SetIndexBuffer(2, bufferLowUp, INDICATOR_DATA);
  SetIndexBuffer(3, bufferCloseUp, INDICATOR_DATA);
  SetIndexBuffer(4, bufferOpenDown, INDICATOR_DATA);
  SetIndexBuffer(5, bufferHighDown, INDICATOR_DATA);
  SetIndexBuffer(6, bufferLowDown, INDICATOR_DATA);
  SetIndexBuffer(7, bufferCloseDown, INDICATOR_DATA);

  // Configure the plot
  PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_CANDLES);
  PlotIndexSetInteger(0, PLOT_LINE_COLOR, clrGreen);
  PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);

  PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_CANDLES);
  PlotIndexSetInteger(1, PLOT_LINE_COLOR, clrRed);
  PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);

  // Set arrays as series
  ArraySetAsSeries(bufferOpenUp, true);
  ArraySetAsSeries(bufferHighUp, true);
  ArraySetAsSeries(bufferLowUp, true);
  ArraySetAsSeries(bufferCloseUp, true);
  ArraySetAsSeries(bufferOpenDown, true);
  ArraySetAsSeries(bufferHighDown, true);
  ArraySetAsSeries(bufferLowDown, true);
  ArraySetAsSeries(bufferCloseDown, true);

  return(INIT_SUCCEEDED);
}

int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[], const long &tick_volume[], const long &volume[], const int &spread[]) {
  datetime now = TimeCurrent();
  double bidPrice = SymbolInfoDouble(Symbol(), SYMBOL_BID);

  // Calculate the start time of the current custom bar
  datetime customBarStart = now - (now % timeframe);

  // If it's a new custom bar
  if (customBarStart != lastBarTime) {
    // Shift data to the right
    int size = ArraySize(bufferOpenUp);
    if (size > 0) { // Ensure the arrays are large enough
      for (int i = size - 2; i >= 0; i--) {
        bufferOpenUp[i + 1] = bufferOpenUp[i];
        bufferHighUp[i + 1] = bufferHighUp[i];
        bufferLowUp[i + 1] = bufferLowUp[i];
        bufferCloseUp[i + 1] = bufferCloseUp[i];
        bufferOpenDown[i + 1] = bufferOpenDown[i];
        bufferHighDown[i + 1] = bufferHighDown[i];
        bufferLowDown[i + 1] = bufferLowDown[i];
        bufferCloseDown[i + 1] = bufferCloseDown[i];
      }
    }

    // Save the last bar's data
    if (lastBarTime != 0) {
      if (currentClose > currentOpen) {
        bufferOpenUp[0] = currentOpen;
        bufferHighUp[0] = currentHigh;
        bufferLowUp[0] = currentLow;
        bufferCloseUp[0] = currentClose;
        bufferOpenDown[0] = EMPTY_VALUE;
        bufferHighDown[0] = EMPTY_VALUE;
        bufferLowDown[0] = EMPTY_VALUE;
        bufferCloseDown[0] = EMPTY_VALUE;
      } else {
        bufferOpenDown[0] = currentOpen;
        bufferHighDown[0] = currentHigh;
        bufferLowDown[0] = currentLow;
        bufferCloseDown[0] = currentClose;
        bufferOpenUp[0] = EMPTY_VALUE;
        bufferHighUp[0] = EMPTY_VALUE;
        bufferLowUp[0] = EMPTY_VALUE;
        bufferCloseUp[0] = EMPTY_VALUE;
      }
    }

    // Initialize the new bar's data
    currentOpen = bidPrice;
    currentHigh = bidPrice;
    currentLow = bidPrice;
    currentClose = bidPrice;
    lastBarTime = customBarStart;
  }

  // Update the current bar's data
  if (bidPrice > currentHigh) currentHigh = bidPrice;
  if (bidPrice < currentLow) currentLow = bidPrice;
  currentClose = bidPrice;

  // Update the current buffers
  if (currentClose > currentOpen) {
    bufferOpenUp[0] = currentOpen;
    bufferHighUp[0] = currentHigh;
    bufferLowUp[0] = currentLow;
    bufferCloseUp[0] = currentClose;
    bufferOpenDown[0] = EMPTY_VALUE;
    bufferHighDown[0] = EMPTY_VALUE;
    bufferLowDown[0] = EMPTY_VALUE;
    bufferCloseDown[0] = EMPTY_VALUE;
  } else {
    bufferOpenDown[0] = currentOpen;
    bufferHighDown[0] = currentHigh;
    bufferLowDown[0] = currentLow;
    bufferCloseDown[0] = currentClose;
    bufferOpenUp[0] = EMPTY_VALUE;
    bufferHighUp[0] = EMPTY_VALUE;
    bufferLowUp[0] = EMPTY_VALUE;
    bufferCloseUp[0] = EMPTY_VALUE;
  }

  return(rates_total);
}
